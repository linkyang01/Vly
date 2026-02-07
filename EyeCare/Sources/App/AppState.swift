import SwiftUI
import Combine

/// 应用全局状态管理
final class AppState: ObservableObject {
    // MARK: - Published Properties
    
    @Published var todayRestCount: Int = 0
    @Published var todayRestDuration: Int = 0
    @Published var streakDays: Int = 0
    @Published var lastRestTime: Date?
    @Published var isTimerActive: Bool = false
    @Published var weeklyStats: [DailyStats] = []
    
    // MARK: - Private Properties
    
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Keys
    
    private enum Keys {
        static let todayRestCount = "todayRestCount"
        static let todayRestDuration = "todayRestDuration"
       RestTime = " static let lastlastRestTime"
        static let streakDays = "streakDays"
        static let lastActiveDate = "lastActiveDate"
    }
    
    // MARK: - Initialization
    
    init() {
        loadTodayData()
        checkAndUpdateStreak()
        generateWeeklyStats()
    }
    
    // MARK: - Public Methods
    
    /// 完成一次护眼休息
    func completeRest(duration: Int = 20) {
        todayRestCount += 1
        todayRestDuration += duration
        lastRestTime = Date()
        isTimerActive = false
        
        saveTodayData()
        checkAndUpdateStreak()
        generateWeeklyStats()
        
        // 发送通知
        NotificationCenter.default.post(name: .restCompleted, object: nil)
    }
    
    /// 开始计时
    func startTimer() {
        isTimerActive = true
    }
    
    /// 跳过计时
    func skipTimer() {
        isTimerActive = false
    }
    
    /// 重置今日数据（每天凌晨调用）
    func resetTodayData() {
        todayRestCount = 0
        todayRestDuration = 0
        lastRestTime = nil
        isTimerActive = false
        saveTodayData()
    }
    
    // MARK: - Private Methods
    
    private func loadTodayData() {
        let lastActive = defaults.object(forKey: Keys.lastActiveDate) as? Date ?? Date.distantPast
        let calendar = Calendar.current
        
        // 如果是同一天，加载数据
        if calendar.isDateInToday(lastActive) {
            todayRestCount = defaults.integer(forKey: Keys.todayRestCount)
            todayRestDuration = defaults.integer(forKey: Keys.todayRestDuration)
            lastRestTime = defaults.object(forKey: Keys.lastRestTime) as? Date
            streakDays = defaults.integer(forKey: Keys.streakDays)
        } else {
            // 新的一天，重置数据
            resetTodayData()
        }
    }
    
    private func saveTodayData() {
        defaults.set(todayRestCount, forKey: Keys.todayRestCount)
        defaults.set(todayRestDuration, forKey: Keys.todayRestDuration)
        defaults.set(lastRestTime, forKey: Keys.lastRestTime)
        defaults.set(streakDays, forKey: Keys.streakDays)
        defaults.set(Date(), forKey: Keys.lastActiveDate)
    }
    
    private func checkAndUpdateStreak() {
        let calendar = Calendar.current
        
        if let lastRest = lastRestTime {
            let lastDate = calendar.startOfDay(for: lastRest)
            let today = calendar.startOfDay(for: Date())
            
            let components = calendar.dateComponents([.day], from: lastDate, to: today)
            
            if let days = components.day {
                if days == 0 {
                    // 同一天，不更新连续天数
                } else if days == 1 {
                    // 昨天，连续天数 +1
                    streakDays += 1
                } else {
                    // 中间断开，重新开始
                    streakDays = 1
                }
            }
        } else {
            // 还没有休息记录
            if todayRestCount > 0 {
                streakDays = 1
            }
        }
        
        defaults.set(streakDays, forKey: Keys.streakDays)
    }
    
    private func generateWeeklyStats() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        weeklyStats = (0..<7).reversed().map { dayOffset -> DailyStats in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) ?? today
            let dayOfWeek = calendar.component(.weekday, from: date)
            
            // 模拟数据（实际应用中应该从历史数据读取）
            let isToday = dayOffset == 0
            let count = isToday ? todayRestCount : Int.random(in: 2...10)
            
            return DailyStats(
                date: date,
                dayOfWeek: dayOfWeek,
                restCount: count,
                completionRate: min(100, count * 10)
            )
        }
    }
}

// MARK: - Supporting Types

/// 每日统计数据
struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let dayOfWeek: Int
    let restCount: Int
    let completionRate: Int
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.shortWeekdaySymbols[dayOfWeek - 1]
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let restCompleted = Notification.Name("restCompleted")
    static let restSkipped = Notification.Name("restSkipped")
}
