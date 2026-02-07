import Foundation
import HealthKit

// MARK: - HealthKit 睡眠管理器

class HealthKitManager {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    private let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    
    /// 演示模式：在模拟器上返回模拟数据
    private let isDemoMode: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
    
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
    
    /// 获取指定日期的睡眠数据
    func fetchSleepData(for date: Date) async -> SleepData {
        // 演示模式：返回模拟数据
        if isDemoMode {
            return generateDemoSleepData(for: date)
        }
        
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
    
    // MARK: - 演示数据生成
    
    /// 生成演示睡眠数据
    private func generateDemoSleepData(for date: Date) -> SleepData {
        let calendar = Calendar.current
        
        // 模拟昨晚 11:30 入睡，今天 7:30 起床
        let yesterday = calendar.date(byAdding: .day, value: -1, to: date)!
        let bedtime = calendar.date(bySettingHour: 23, minute: 30, second: 0, of: yesterday)!
        let wakeTime = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: date)!
        
        // 模拟心率数据（睡眠期间心率较低）
        var heartRateData: [HeartRateSample] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        // 生成睡眠期间的心率样本（每 30 分钟一个）
        var currentTime = bedtime
        while currentTime < wakeTime {
            let hour = calendar.component(.hour, from: currentTime)
            // 后半夜心率更低
            let baseBpm = hour >= 2 && hour <= 5 ? 55 : 60
            let bpm = baseBpm + Int.random(in: -5...5)
            
            heartRateData.append(HeartRateSample(
                id: UUID(),
                timestamp: currentTime,
                bpm: bpm,
                hrv: Double.random(in: 40...80)
            ))
            
            currentTime = calendar.date(byAdding: .minute, value: 30, to: currentTime)!
        }
        
        return SleepData(
            bedtime: bedtime,
            wakeTime: wakeTime,
            deepSleepMinutes: 90,      // 约 1.5 小时深睡
            lightSleepMinutes: 240,    // 约 4 小时浅睡
            remSleepMinutes: 90,       // 约 1.5 小时 REM
            awakeMinutes: 15,          // 醒来 15 分钟
            heartRateData: heartRateData,
            hrvData: heartRateData.compactMap { $0.hrv }
        )
    }
    
    // MARK: - 获取心率数据
    
    /// 获取指定时间段的心率数据
    func fetchHeartRateData(from startDate: Date, to endDate: Date) async -> [HeartRateSample] {
        // 演示模式：返回模拟心率数据
        if isDemoMode {
            return generateDemoHeartRateData(from: startDate, to: endDate)
        }
        
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
    
    /// 生成演示心率数据
    private func generateDemoHeartRateData(from startDate: Date, to endDate: Date) -> [HeartRateSample] {
        var result: [HeartRateSample] = []
        let calendar = Calendar.current
        var currentTime = startDate
        
        while currentTime < endDate {
            let hour = calendar.component(.hour, from: currentTime)
            let baseBpm = hour >= 2 && hour <= 5 ? 55 : 62
            let bpm = baseBpm + Int.random(in: -8...8)
            
            result.append(HeartRateSample(
                id: UUID(),
                timestamp: currentTime,
                bpm: bpm,
                hrv: Double.random(in: 45...75)
            ))
            
            currentTime = calendar.date(byAdding: .minute, value: 30, to: currentTime)!
        }
        
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
