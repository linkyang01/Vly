import Foundation

// MARK: - 睡眠会话模型

struct SleepSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let bedTime: Date           // 上床时间
    let wakeTime: Date?         // 起床时间
    let techniqueUsed: String   // 使用的助眠方法
    let timeToFallAsleep: TimeInterval?  // 入睡耗时（秒）
    let quality: SleepQuality
    let heartRateData: [HeartRateSample]?
    let notes: String?
    
    var duration: TimeInterval? {
        guard let wakeTime = wakeTime else { return nil }
        return wakeTime.timeIntervalSince(bedTime)
    }
    
    // 格式化入睡时间
    var formattedTimeToFallAsleep: String {
        guard let seconds = timeToFallAsleep else { return "--" }
        let minutes = Int(seconds / 60)
        return "\(minutes) min"
    }
    
    // 总睡眠时长（秒）
    var totalSleepTime: Int {
        guard let wakeTime = wakeTime else { return 0 }
        return Int(wakeTime.timeIntervalSince(bedTime))
    }
    
    // 平均心率
    var averageHeartRate: Int {
        guard let data = heartRateData, !data.isEmpty else { return 0 }
        return Int(data.map(\.bpm).reduce(0, +) / data.count)
    }
}

// MARK: - 睡眠质量

enum SleepQuality: String, Codable, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    
    var emoji: String {
        switch self {
        case .excellent: return "😴"
        case .good: return "🙂"
        case .fair: return "😐"
        case .poor: return "😫"
        }
    }
    
    var description: String {
        switch self {
        case .excellent: return "Slept very well"
        case .good: return "Slept well"
        case .fair: return "Okay sleep"
        case .poor: return "Tough night"
        }
    }
}

// MARK: - 心率样本

struct HeartRateSample: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let bpm: Int
    let hrv: Double?
}

// MARK: - 睡眠管理器

@MainActor
class SleepManager: ObservableObject {
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
        // 计算平均入睡时间
        let completedSessions = sessions.filter { $0.timeToFallAsleep != nil }
        guard !completedSessions.isEmpty else {
            averageTimeToFallAsleep = nil
            return
        }
        
        let total = completedSessions.reduce(0) { $0 + $1.timeToFallAsleep! }
        averageTimeToFallAsleep = total / Double(completedSessions.count)
        
        // 更新周趋势（最近7天）
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
