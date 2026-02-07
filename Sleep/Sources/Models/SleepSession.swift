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
}

// MARK: - 心率样本

struct HeartRateSample: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let bpm: Int
    let hrv: Double?
}
