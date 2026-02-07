import Foundation

// MARK: - 转化阶段

enum ConversionStage: String, Codable {
    case day1Onboarding = "day1"
    case day2ValueProof = "day2"
    case day3ValueProof = "day3"
    case day4Exploration = "day4"
    case day5Exploration = "day5"
    case day6ValueDisplay = "day6"
    case day7ValueDisplay = "day7"
    case day8Paywall = "day8"
    case subscribed = "subscribed"
    
    var day: Int {
        switch self {
        case .day1Onboarding: return 1
        case .day2ValueProof: return 2
        case .day3ValueProof: return 3
        case .day4Exploration: return 4
        case .day5Exploration: return 5
        case .day6ValueDisplay: return 6
        case .day7ValueDisplay: return 7
        case .day8Paywall: return 8
        case .subscribed: return 99
        }
    }
    
    var title: String {
        switch self {
        case .day1Onboarding: return "开始你的睡眠之旅"
        case .day2ValueProof, .day3ValueProof: return "发现你的睡眠模式"
        case .day4Exploration, .day5Exploration: return "探索更多助眠方式"
        case .day6ValueDisplay, .day7ValueDisplay: return "你的睡眠进步"
        case .day8Paywall: return "解锁完整功能"
        case .subscribed: return "感谢订阅"
        }
    }
    
    var subtitle: String {
        switch self {
        case .day1Onboarding: return "只需3分钟，获得更好的睡眠"
        case .day2ValueProof, .day3ValueProof: return "追踪你的睡眠进步"
        case .day4Exploration, .day5Exploration: return "尝试不同的声音和疗法"
        case .day6ValueDisplay, .day7ValueDisplay: return "查看你的睡眠数据"
        case .day8Paywall: return "获取最佳睡眠体验"
        case .subscribed: return "享受完整功能"
        }
    }
}

// MARK: - 转化事件

enum ConversionEvent: String {
    case appOpened
    case breathingCompleted
    case soundPlayed
    case timerUsed
    case hrvChecked
    case storyListened
    case meditationCompleted
    case streakContinued
}

// MARK: - 转化跟踪服务

@MainActor
final class ConversionTracker: ObservableObject {
    static let shared = ConversionTracker()
    
    @Published private(set) var currentStage: ConversionStage
    @Published private(set) var daysActive: Int
    @Published private(set) var eventsToday: [ConversionEvent]
    @Published private(set) var totalEvents: [ConversionEvent]
    @Published private(set) var streak: Int
    @Published private(set) var onboardingCompleted: Bool
    
    private let userDefaults = UserDefaults.standard
    private let keyStage = "conversion_stage"
    private let keyFirstLaunch = "first_launch_date"
    private let keyEvents = "conversion_events"
    private let keyStreak = "conversion_streak"
    
    private init() {
        // 初始化
        if let stageString = userDefaults.string(forKey: keyStage),
           let stage = ConversionStage(rawValue: stageString) {
            self.currentStage = stage
        } else {
            self.currentStage = .day1Onboarding
        }
        
        // 计算活跃天数
        if let firstLaunch = userDefaults.object(forKey: keyFirstLaunch) as? Date {
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
            self.daysActive = max(1, days + 1)
        } else {
            self.daysActive = 1
            userDefaults.set(Date(), forKey: keyFirstLaunch)
        }
        
        // 初始化事件
        if let eventsData = userDefaults.array(forKey: keyEvents) as? [String] {
            self.totalEvents = eventsData.compactMap { ConversionEvent(rawValue: $0) }
        } else {
            self.totalEvents = []
        }
        
        self.eventsToday = []
        self.streak = userDefaults.integer(forKey: keyStreak)
        self.onboardingCompleted = userDefaults.bool(forKey: "onboarding_completed")
        
        // 更新阶段
        updateStage()
    }
    
    // MARK: - Public Methods
    
    func recordEvent(_ event: ConversionEvent) {
        // 记录事件
        totalEvents.append(event)
        eventsToday.append(event)
        
        // 保存
        let eventStrings = totalEvents.map { $0.rawValue }
        userDefaults.set(eventStrings, forKey: keyEvents)
        
        // 更新连续天数
        if event == .appOpened {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            if let lastOpen = userDefaults.object(forKey: "last_open_date") as? Date {
                let lastDay = calendar.startOfDay(for: lastOpen)
                let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
                
                if daysDiff == 1 {
                    streak += 1  // 连续两天
                } else if daysDiff > 1 {
                    streak = 1  // 断了，重新开始
                }
            } else {
                streak = 1
            }
            
            userDefaults.set(Date(), forKey: "last_open_date")
            userDefaults.set(streak, forKey: keyStreak)
        }
        
        // 更新阶段
        updateStage()
        
        // 检查是否完成引导
        if event == .breathingCompleted && !onboardingCompleted {
            completeOnboarding()
        }
    }
    
    func completeOnboarding() {
        onboardingCompleted = true
        userDefaults.set(true, forKey: "onboarding_completed")
        
        // 移动到 Day 2-3
        if currentStage == .day1Onboarding {
            currentStage = .day2ValueProof
            userDefaults.set(currentStage.rawValue, forKey: keyStage)
        }
    }
    
    func shouldShowOnboarding() -> Bool {
        return !onboardingCompleted && currentStage == .day1Onboarding
    }
    
    func shouldShowPaywall() -> Bool {
        return currentStage == .day8Paywall && !isSubscribed()
    }
    
    func isSubscribed() -> Bool {
        // TODO: 集成真实订阅状态
        return userDefaults.bool(forKey: "is_subscribed")
    }
    
    func subscribe() {
        currentStage = .subscribed
        userDefaults.set(currentStage.rawValue, forKey: keyStage)
        userDefaults.set(true, forKey: "is_subscribed")
    }
    
    func getProgress() -> Double {
        return min(Double(daysActive) / 7.0, 1.0)
    }
    
    func getDaysRemaining() -> Int {
        return max(0, 8 - daysActive)
    }
    
    // MARK: - Private Methods
    
    private func updateStage() {
        if isSubscribed() {
            currentStage = .subscribed
            return
        }
        
        let newStage: ConversionStage
        switch daysActive {
        case 1:
            newStage = .day1Onboarding
        case 2, 3:
            newStage = .day2ValueProof
        case 4, 5:
            newStage = .day4Exploration
        case 6, 7:
            newStage = .day6ValueDisplay
        default:
            if daysActive >= 8 {
                newStage = .day8Paywall
            } else {
                newStage = .day1Onboarding
            }
        }
        
        if newStage != currentStage {
            currentStage = newStage
            userDefaults.set(newStage.rawValue, forKey: keyStage)
        }
    }
}

// MARK: - 每日挑战

struct DailyChallenge: Identifiable {
    let id = UUID()
    let day: Int
    let title: String
    let description: String
    let icon: String
    let reward: Int  // XP 奖励
    
    static func forDay(_ day: Int) -> DailyChallenge {
        switch day {
        case 1:
            return DailyChallenge(
                day: 1,
                title: "第一次呼吸练习",
                description: "完成一次3分钟的4-7-8呼吸练习",
                icon: "wind",
                reward: 50
            )
        case 2:
            return DailyChallenge(
                day: 2,
                title: "记录你的睡眠",
                description: "设置睡前提醒，记录你的睡眠时间",
                icon: "clock.fill",
                reward: 30
            )
        case 3:
            return DailyChallenge(
                day: 3,
                title: "尝试新声音",
                description: "播放一种新的助眠声音至少10分钟",
                icon: "speaker.wave.2.fill",
                reward: 30
            )
        case 4:
            return DailyChallenge(
                day: 4,
                title: "阅读睡眠故事",
                description: "听完一个完整的睡眠故事",
                icon: "book.fill",
                reward: 40
            )
        case 5:
            return DailyChallenge(
                day: 5,
                title: "引导冥想",
                description: "完成一次引导冥想练习",
                icon: "leaf.fill",
                reward: 40
            )
        case 6:
            return DailyChallenge(
                day: 6,
                title: "查看你的进步",
                description: "查看本周睡眠数据报告",
                icon: "chart.line.uptrend.xyaxis",
                reward: 30
            )
        case 7:
            return DailyChallenge(
                day: 7,
                title: "连续使用7天",
                description: "完成连续7天的睡眠练习",
                icon: "flame.fill",
                reward: 100
            )
        default:
            return DailyChallenge(
                day: day,
                title: "保持习惯",
                description: "继续你的睡眠之旅",
                icon: "star.fill",
                reward: 20
            )
        }
    }
}
