import Foundation

// MARK: - 睡眠状态

enum SleepReadiness: String {
    case ready = "Ready"
    case building = "Building"
    case windingDown = "Winding Down"
    case readyToSleep = "Ready to Sleep"
    
    var emoji: String {
        switch self {
        case .ready: return "⚡"
        case .building: return "🌱"
        case .windingDown: return "🌙"
        case .readyToSleep: return "😴"
        }
    }
    
    var description: String {
        switch self {
        case .ready: return "Alert and awake"
        case .building: return "Starting to relax"
        case .windingDown: return "Getting sleepy"
        case .readyToSleep: return "Ready for bed"
        }
    }
}
