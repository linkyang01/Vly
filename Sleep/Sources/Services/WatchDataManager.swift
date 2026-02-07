import Foundation
import WatchConnectivity
import Combine

class WatchDataManager: NSObject, ObservableObject {
    static let shared = WatchDataManager()
    
    @Published var isConnected = false
    @Published var isMonitoring = false
    @Published var currentHeartRate: Int?
    @Published var currentHRV: Double?
    @Published var sleepReadiness: SleepReadiness = .ready
    @Published var history: [HeartRateSample] = []
    
    private var session: WCSession?
    
    private override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else {
            print("WatchConnectivity not supported")
            return
        }
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    // MARK: - 控制
    
    func startMonitoring() {
        isMonitoring = true
        sendMessage(["command": "startMonitoring"])
    }
    
    func stopMonitoring() {
        isMonitoring = false
        sendMessage(["command": "stopMonitoring"])
    }
    
    func requestSync() {
        sendMessage(["command": "sync"])
    }
    
    // MARK: - 消息发送
    
    private func sendMessage(_ message: [String: Any]) {
        guard let session = session, session.isReachable else {
            print("Watch session not reachable")
            return
        }
        
        session.sendMessage(message) { reply in
            print("Watch reply: \(reply)")
        } errorHandler: { error in
            print("Watch error: \(error)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchDataManager: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        isConnected = false
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        isConnected = false
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch activation error: \(error)")
            return
        }
        
        isConnected = activationState == .activated
        print("Watch connected: \(isConnected)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let heartRate = message["heartRate"] as? Int {
                self.currentHeartRate = heartRate
            }
            
            if let hrv = message["hrv"] as? Double {
                self.currentHRV = hrv
            }
            
            if let readiness = message["readiness"] as? String,
               let readinessEnum = SleepReadiness(rawValue: readiness) {
                self.sleepReadiness = readinessEnum
            }
            
            // 添加到历史
            if let heartRate = message["heartRate"] as? Int {
                let sample = HeartRateSample(
                    id: UUID(),
                    timestamp: Date(),
                    bpm: heartRate,
                    hrv: message["hrv"] as? Double
                )
                self.history.append(sample)
                
                // 只保留最近30条
                if self.history.count > 30 {
                    self.history.removeFirst()
                }
            }
        }
    }
}
