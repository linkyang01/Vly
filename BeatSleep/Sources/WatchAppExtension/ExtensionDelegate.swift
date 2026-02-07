import WatchKit
import Foundation
import HealthKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, ObservableObject {
    static let shared = ExtensionDelegate()
    
    @Published var currentHeartRate: Int?
    @Published var currentHRV: Double?
    @Published var isConnected = false
    
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var hrvQuery: HKAnchoredObjectQuery?
    private var session: WCSession?
    
    override init() {
        super.init()
        setupWCSession()
    }
    
    func applicationDidFinishLaunching() {
        requestHealthKitAuthorization()
    }
    
    func applicationWillEnterForeground() {
        startHeartRateMonitoring()
        startHRVMonitoring()
    }
    
    func applicationDidEnterBackground() {
        stopHeartRateMonitoring()
        stopHRVMonitoring()
    }
    
    // MARK: - WCSession
    
    private func setupWCSession() {
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    // MARK: - HealthKit Authorization
    
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.startHeartRateMonitoring()
                    self.startHRVMonitoring()
                }
            }
        }
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
        ) { [weak self] _, samples, _, _, _ in
            self?.processHeartRateSamples(samples)
        }
        
        heartRateQuery?.updateHandler = { [weak self] _, samples, _, _, _ in
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
            self?.sendToPhone()
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
        ) { [weak self] _, samples, _, _, _ in
            self?.processHRVSamples(samples)
        }
        
        hrvQuery?.updateHandler = { [weak self] _, samples, _, _, _ in
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
            self?.sendToPhone()
        }
    }
    
    // MARK: - Send to Phone
    
    private func sendToPhone() {
        guard let session = session, session.isReachable else { return }
        
        var message: [String: Any] = ["command": "watchData"]
        
        if let hr = currentHeartRate {
            message["heartRate"] = hr
        }
        if let hrv = currentHRV {
            message["hrv"] = hrv
        }
        
        session.sendMessage(message) { reply in
            print("Phone replied: \(reply)")
        } errorHandler: { error in
            print("Send to phone error: \(error)")
        }
    }
}

// MARK: - WCSessionDelegate

extension ExtensionDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            switch activationState {
            case .activated:
                self?.isConnected = true
            default:
                self?.isConnected = false
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let command = message["command"] as? String {
            switch command {
            case "getStatus":
                var reply: [String: Any] = ["status": "ok"]
                if let hr = currentHeartRate {
                    reply["heartRate"] = hr
                }
                session.sendMessage(reply) { _ in }
            case "startBreathing":
                break
            case "stopBreathing":
                break
            default:
                break
            }
        }
    }
}
