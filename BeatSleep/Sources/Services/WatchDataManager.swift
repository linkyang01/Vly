import Foundation
import WatchConnectivity
import HealthKit

// MARK: - Watch 数据管理器

class WatchDataManager: NSObject, ObservableObject {
    static let shared = WatchDataManager()
    
    // MARK: - Published Properties (主线程更新)
    
    @Published var isConnected = false
    @Published var isWatchAppInstalled = false
    @Published var currentHeartRate: Int?
    @Published var currentHRV: Double?
    @Published var history: [HeartRateSample] = []
    @Published var syncError: String?
    
    // MARK: - Private Properties
    
    private let session: WCSession
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var hrvQuery: HKAnchoredObjectQuery?
    
    // MARK: - Initialization
    
    private override init() {
        session = WCSession.default
        super.init()
        session.delegate = self
        session.activate()
    }
    
    // MARK: - Public Methods
    
    /// 启动监测
    func startMonitoring() {
        guard isConnected else {
            syncError = "Watch not connected"
            return
        }
        
        startHeartRateMonitoring()
        startHRVMonitoring()
        sendMessage(["command": "startMonitoring"])
    }
    
    /// 停止监测
    func stopMonitoring() {
        stopHeartRateMonitoring()
        stopHRVMonitoring()
        sendMessage(["command": "stopMonitoring"])
    }
    
    /// 发送消息到Watch
    func sendMessage(_ message: [String: Any]) {
        guard isConnected else { return }
        
        session.sendMessage(message) { reply in
            print("Watch replied: \(reply)")
        } errorHandler: { error in
            print("Watch send error: \(error)")
        }
    }
    
    /// 请求同步数据
    func requestSync() {
        sendMessage(["command": "syncData"])
    }
    
    // MARK: - Heart Rate Monitoring
    
    private func startHeartRateMonitoring() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        heartRateQuery = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        heartRateQuery?.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        if let query = heartRateQuery {
            healthStore.execute(query)
        }
    }
    
    private func stopHeartRateMonitoring() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample],
              let lastSample = heartRateSamples.last else { return }
        
        let bpm = Int(lastSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
        
        DispatchQueue.main.async { [weak self] in
            self?.currentHeartRate = bpm
            
            let sample = HeartRateSample(
                id: UUID(),
                timestamp: lastSample.startDate,
                bpm: bpm,
                hrv: self?.currentHRV
            )
            self?.history.append(sample)
            
            if self?.history.count ?? 0 > 100 {
                self?.history.removeFirst()
            }
        }
    }
    
    // MARK: - HRV Monitoring
    
    private func startHRVMonitoring() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        
        hrvQuery = HKAnchoredObjectQuery(
            type: hrvType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHRVSamples(samples)
        }
        
        hrvQuery?.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHRVSamples(samples)
        }
        
        if let query = hrvQuery {
            healthStore.execute(query)
        }
    }
    
    private func stopHRVMonitoring() {
        if let query = hrvQuery {
            healthStore.stop(query)
            hrvQuery = nil
        }
    }
    
    private func processHRVSamples(_ samples: [HKSample]?) {
        guard let hrvSamples = samples as? [HKQuantitySample],
              let lastSample = hrvSamples.last else { return }
        
        let hrvUnit = HKUnit.secondUnit(with: .milli)
        let hrv = lastSample.quantity.doubleValue(for: hrvUnit)
        
        DispatchQueue.main.async { [weak self] in
            self?.currentHRV = hrv
        }
    }
    
    // MARK: - Authorization
    
    func requestHealthKitAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]
        
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
                continuation.resume(returning: success)
            }
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchDataManager: WCSessionDelegate {
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        Task { @MainActor in
            self.isConnected = false
        }
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        Task { @MainActor in
            self.isConnected = false
        }
    }
    
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            switch activationState {
            case .activated:
                self.isConnected = true
                self.isWatchAppInstalled = true
            case .inactive:
                self.isConnected = false
            case .notActivated:
                self.isConnected = false
            @unknown default:
                self.isConnected = false
            }
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            if let heartRate = message["heartRate"] as? Int {
                self.currentHeartRate = heartRate
            }
            if let hrv = message["hrv"] as? Double {
                self.currentHRV = hrv
            }
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        replyHandler(["status": "received"])
    }
}

// MARK: - 便捷扩展

extension WatchDataManager {
    var averageHeartRate: Int? {
        guard !history.isEmpty else { return nil }
        let total = history.reduce(0) { $0 + $1.bpm }
        return total / history.count
    }
    
    var hrvTrend: HRVTrend {
        guard history.count >= 5 else { return .unknown }
        
        let recent = history.suffix(5)
        let recentAvg = recent.reduce(0) { $0 + $1.bpm } / 5
        let older = history.prefix(5)
        let olderAvg = older.reduce(0) { $0 + $1.bpm } / 5
        
        let change = Double(recentAvg - olderAvg) / Double(olderAvg)
        
        if change > 0.05 {
            return .rising
        } else if change < -0.05 {
            return .falling
        } else {
            return .stable
        }
    }
    
    var sleepReadiness: SleepReadiness {
        guard let hrv = currentHRV else { return .unknown }
        
        if hrv > 50 {
            return .ready
        } else if hrv > 30 {
            return .moderate
        } else {
            return .notReady
        }
    }
}

// MARK: - HRV Trend

enum HRVTrend {
    case rising
    case falling
    case stable
    case unknown
}

// MARK: - Sleep Readiness

enum SleepReadiness {
    case ready
    case moderate
    case notReady
    case unknown
    
    var description: String {
        switch self {
        case .ready: return "Relaxed and ready for sleep"
        case .moderate: return "Getting there..."
        case .notReady: return "Still quite alert"
        case .unknown: return "Collecting data..."
        }
    }
    
    var emoji: String {
        switch self {
        case .ready: return "🌙"
        case .moderate: return "💤"
        case .notReady: return "☀️"
        case .unknown: return "📊"
        }
    }
}
