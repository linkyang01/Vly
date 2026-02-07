import Foundation

/// 本地数据存储管理
final class LocalStorageManager {
    static let shared = LocalStorageManager()
    
    private let defaults = UserDefaults.standard
    private let suiteName = "group.com.eyecare.shared"
    
    // MARK: - Keys
    
    private enum Keys {
        // 用户数据
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let userName = "userName"
        
        // 护眼数据
        static let todayRestCount = "todayRestCount"
        static let todayRestDuration = "todayRestDuration"
        static let lastRestTime = "lastRestTime"
        static let totalRestCount = "totalRestCount"
        static let streakDays = "streakDays"
        static let bestStreakDays = "bestStreakDays"
        
        // 设置
        static let notificationsEnabled = "notificationsEnabled"
        static let reminderInterval = "reminderInterval"
        static let watchHapticEnabled = "watchHapticEnabled"
        static let soundEnabled = "soundEnabled"
        
        // 成就
        static let unlockedAchievements = "unlockedAchievements"
        static let achievementProgress = "achievementProgress"
        
        // 统计
        static let dailyStats = "dailyStats"
        static let weeklyStats = "weeklyStats"
        static let monthlyStats = "monthlyStats"
    }
    
    // MARK: - Shared Defaults (用于 App Groups)
    
    var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }
    
    private init() {}
    
    // MARK: - Onboarding
    
    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }
    
    // MARK: - Rest Data
    
    var todayRestCount: Int {
        get { defaults.integer(forKey: Keys.todayRestCount) }
        set { defaults.set(newValue, forKey: Keys.todayRestCount) }
    }
    
    var todayRestDuration: Int {
        get { defaults.integer(forKey: Keys.todayRestDuration) }
        set { defaults.set(newValue, forKey: Keys.todayRestDuration) }
    }
    
    var lastRestTime: Date? {
        get { defaults.object(forKey: Keys.lastRestTime) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastRestTime) }
    }
    
    var totalRestCount: Int {
        get { defaults.integer(forKey: Keys.totalRestCount) }
        set { defaults.set(newValue, forKey: Keys.totalRestCount) }
    }
    
    var streakDays: Int {
        get { defaults.integer(forKey: Keys.streakDays) }
        set { defaults.set(newValue, forKey: Keys.streakDays) }
    }
    
    var bestStreakDays: Int {
        get { defaults.integer(forKey: Keys.bestStreakDays) }
        set { defaults.set(newValue, forKey: Keys.bestStreakDays) }
    }
    
    // MARK: - Settings
    
    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: Keys.notificationsEnabled) }
        set { defaults.set(newValue, forKey: Keys.notificationsEnabled) }
    }
    
    var reminderInterval: TimeInterval {
        get { defaults.double(forKey: Keys.reminderInterval) }
        set { defaults.set(newValue, forKey: Keys.reminderInterval) }
    }
    
    var watchHapticEnabled: Bool {
        get { defaults.bool(forKey: Keys.watchHapticEnabled) }
        set { defaults.set(newValue, forKey: Keys.watchHapticEnabled) }
    }
    
    var soundEnabled: Bool {
        get { defaults.bool(forKey: Keys.soundEnabled) }
        set { defaults.set(newValue, forKey: Keys.soundEnabled) }
    }
    
    // MARK: - Achievements
    
    var unlockedAchievements: [String] {
        get { defaults.stringArray(forKey: Keys.unlockedAchievements) ?? [] }
        set { defaults.set(newValue, forKey: Keys.unlockedAchievements) }
    }
    
    // MARK: - Methods
    
    /// 记录一次护眼完成
    func recordRest(duration: Int = 20) {
        todayRestCount += 1
        todayRestDuration += duration
        totalRestCount += 1
        lastRestTime = Date()
    }
    
    /// 重置今日数据（每天调用）
    func resetTodayData() {
        todayRestCount = 0
        todayRestDuration = 0
        lastRestTime = nil
    }
    
    /// 更新连续天数
    func updateStreak() {
        let calendar = Calendar.current
        
        if let lastRest = lastRestTime {
            let lastDate = calendar.startOfDay(for: lastRest)
            let today = calendar.startOfDay(for: Date())
            
            let components = calendar.dateComponents([.day], from: lastDate, to: today)
            
            if let days = components.day {
                if days == 0 {
                    // 同一天，不更新
                } else if days == 1 {
                    // 昨天，连续
                    streakDays += 1
                } else {
                    // 中间断开
                    streakDays = 1
                }
            }
        } else {
            if todayRestCount > 0 {
                streakDays = 1
            }
        }
        
        // 更新最佳记录
        if streakDays > bestStreakDays {
            bestStreakDays = streakDays
        }
    }
    
    /// 解锁成就
    func unlockAchievement(_ id: String) {
        guard !unlockedAchievements.contains(id) else { return }
        unlockedAchievements.append(id)
    }
    
    /// 检查成就进度
    func checkAchievementProgress(for achievementId: String) -> Bool {
        // 根据成就ID检查进度
        switch achievementId {
        case "beginner":
            return totalRestCount >= 1
        case "streak3":
            return streakDays >= 3
        case "streak5":
            return streakDays >= 5
        case "streak7":
            return streakDays >= 7
        case "eyesGuardian":
            return totalRestCount >= 100
        case "master":
            return totalRestCount >= 365
        default:
            return false
        }
    }
    
    /// 清除所有数据
    func clearAllData() {
        let domain = Bundle.main.bundleIdentifier
        defaults.removePersistentDomain(forName: domain ?? "")
        defaults.synchronize()
    }
}
