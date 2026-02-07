import Foundation
import HealthKit

// MARK: - HealthKit 睡眠管理器

class HealthKitManager {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    private let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    
    private init() {}
    
    // MARK: - 权限请求
    
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]
        
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
    
    // MARK: - 获取睡眠数据
    
    func fetchSleepData(for date: Date) async -> SleepData {
        let calendar = Calendar.current
        
        // 获取昨晚的睡眠数据（从昨晚 6 点到今天中午 12 点）
        let yesterday = calendar.date(byAdding: .day, value: -1, to: date)!
        let startOfSleep = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: yesterday)!
        let endOfSleep = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfSleep,
            end: endOfSleep,
            options: .strictStartDate
        )
        
        // 使用 semaphore 等待结果
        let semaphore = DispatchSemaphore(value: 0)
        var result: SleepData?
        
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, _ in
            defer { semaphore.signal() }
            
            guard let samples = samples as? [HKCategorySample], !samples.isEmpty else {
                // 没有数据，返回默认值
                result = SleepData(
                    bedtime: startOfSleep,
                    wakeTime: endOfSleep,
                    deepSleepMinutes: 0,
                    lightSleepMinutes: 0,
                    remSleepMinutes: 0,
                    awakeMinutes: 0,
                    heartRateData: [],
                    hrvData: []
                )
                return
            }
            
            // 分析睡眠数据
            var bedtime: Date?
            var wakeTime: Date?
            var deepSleepMinutes: Int = 0
            var lightSleepMinutes: Int = 0
            var remSleepMinutes: Int = 0
            var awakeMinutes: Int = 0
            
            for sample in samples.sorted(by: { $0.startDate < $1.startDate }) {
                switch sample.value {
                case HKCategoryValueSleepAnalysis.inBed.rawValue:
                    if bedtime == nil {
                        bedtime = sample.startDate
                    }
                    wakeTime = sample.endDate
                case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                    deepSleepMinutes += Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)
                case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                    lightSleepMinutes += Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)
                case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                    remSleepMinutes += Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)
                case HKCategoryValueSleepAnalysis.awake.rawValue:
                    awakeMinutes += Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)
                default:
                    break
                }
            }
            
            result = SleepData(
                bedtime: bedtime ?? startOfSleep,
                wakeTime: wakeTime ?? endOfSleep,
                deepSleepMinutes: deepSleepMinutes,
                lightSleepMinutes: lightSleepMinutes,
                remSleepMinutes: remSleepMinutes,
                awakeMinutes: awakeMinutes,
                heartRateData: [],
                hrvData: []
            )
        }
        
        healthStore.execute(query)
        semaphore.wait()
        
        return result ?? SleepData(
            bedtime: startOfSleep,
            wakeTime: endOfSleep,
            deepSleepMinutes: 0,
            lightSleepMinutes: 0,
            remSleepMinutes: 0,
            awakeMinutes: 0,
            heartRateData: [],
            hrvData: []
        )
    }
    
    // MARK: - 获取心率数据
    
    func fetchHeartRateData(from startDate: Date, to endDate: Date) async -> [HeartRateSample] {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return []
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: [HeartRateSample] = []
        
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: "startDate", ascending: true)]
        ) { _, samples, _ in
            defer { semaphore.signal() }
            
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            
            result = samples.map { sample in
                let bpm = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
                return HeartRateSample(id: UUID(), timestamp: sample.startDate, bpm: bpm, hrv: nil)
            }
        }
        
        healthStore.execute(query)
        semaphore.wait()
        
        return result
    }
}

// MARK: - 睡眠数据结构

struct SleepData {
    let bedtime: Date
    let wakeTime: Date
    let deepSleepMinutes: Int
    let lightSleepMinutes: Int
    let remSleepMinutes: Int
    let awakeMinutes: Int
    let heartRateData: [HeartRateSample]
    let hrvData: [Double]
    
    var totalSleepMinutes: Int {
        deepSleepMinutes + lightSleepMinutes + remSleepMinutes
    }
    
    var totalTimeInBed: Int {
        let total = Int(wakeTime.timeIntervalSince(bedtime) / 60)
        return total - awakeMinutes
    }
    
    var sleepEfficiency: Double {
        guard totalTimeInBed > 0 else { return 0 }
        return Double(totalSleepMinutes) / Double(totalTimeInBed) * 100
    }
    
    var formattedBedtime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: bedtime)
    }
    
    var formattedWakeTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: wakeTime)
    }
    
    var formattedTotalSleep: String {
        let hours = totalSleepMinutes / 60
        let minutes = totalSleepMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
