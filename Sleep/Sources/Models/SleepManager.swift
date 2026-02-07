import Foundation
import Combine

// MARK: - 睡眠管理器

@MainActor
class SleepManager: ObservableObject {
    static let shared = SleepManager()
    
    @Published var sessions: [SleepSession] = []
    @Published var averageTimeToFallAsleep: TimeInterval?
    @Published var weeklyTrend: [SleepSession] = []
    
    init() {
        loadSessions()
    }
    
    // MARK: - 数据操作
    
    func addSession(_ session: SleepSession) {
        sessions.insert(session, at: 0)
        saveSessions()
        updateStats()
    }
    
    func deleteSession(_ session: SleepSession) {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
        updateStats()
    }
    
    // MARK: - 统计
    
    private func updateStats() {
        let completedSessions = sessions.filter { $0.timeToFallAsleep != nil }
        guard !completedSessions.isEmpty else {
            averageTimeToFallAsleep = nil
            return
        }
        
        let total = completedSessions.reduce(0) { $0 + $1.timeToFallAsleep! }
        averageTimeToFallAsleep = total / Double(completedSessions.count)
        
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        weeklyTrend = sessions.filter { $0.date >= oneWeekAgo }
    }
    
    // MARK: - 持久化
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "sleepSessions")
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "sleepSessions"),
           let decoded = try? JSONDecoder().decode([SleepSession].self, from: data) {
            sessions = decoded
            updateStats()
        }
    }
    
    // MARK: - 便捷方法
    
    var lastSession: SleepSession? {
        sessions.first
    }
    
    var improvementFromLastWeek: String? {
        guard weeklyTrend.count >= 7 else { return nil }
        
        let recent = weeklyTrend.prefix(3)
        let older = weeklyTrend.suffix(3)
        
        guard let recentAvg = recent.compactMap({ $0.timeToFallAsleep }).average(),
              let olderAvg = older.compactMap({ $0.timeToFallAsleep }).average() else {
            return nil
        }
        
        let diff = olderAvg - recentAvg
        guard diff > 0 else { return nil }
        
        let minutes = Int(diff / 60)
        return "\(minutes) min faster"
    }
}

// MARK: - Array Extension

extension Array where Element == Double {
    func average() -> Double? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / Double(count)
    }
}
