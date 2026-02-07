//
//  Models.swift
//  EyeCare
//
//  应用程序数据模型定义
//

import Foundation

/// 护眼记录
struct RestRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: Int  // 实际休息时长（秒）
    let completed: Bool  // 是否完成 20 秒
    let method: RestMethod  // 提醒方式
    
    enum RestMethod: String, Codable {
        case notification  // 通知
        case watch        // Watch 提醒
        case manual       // 手动
    }
    
    init(id: UUID = UUID(), date: Date = Date(), duration: Int, completed: Bool, method: RestMethod) {
        self.id = id
        self.date = date
        self.duration = duration
        self.completed = completed
        self.method = method
    }
}

/// 用眼统计数据
struct EyeUsageStats {
    var todayRestCount: Int       // 今日护眼次数
    var todayRestDuration: Int     // 今日护眼总时长（秒）
    var weeklyRestCount: [Int]      // 本周每日次数
    var streakDays: Int            // 连续天数
    var totalRestCount: Int       // 累计次数
    
    init(todayRestCount: Int = 0, todayRestDuration: Int = 0, weeklyRestCount: [Int] = Array(repeating: 0, count: 7), streakDays: Int = 0, totalRestCount: Int = 0) {
        self.todayRestCount = todayRestCount
        self.todayRestDuration = todayRestDuration
        self.weeklyRestCount = weeklyRestCount
        self.streakDays = streakDays
        self.totalRestCount = totalRestCount
    }
}

/// 成就数据
struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let condition: Int
    var currentProgress: Int
    let isUnlocked: Bool
    let unlockedDate: Date?
    
    var progress: Double {
        return Double(currentProgress) / Double(condition)
    }
}

/// 每日统计
struct DailyStats: Codable, Identifiable {
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

/// 设置数据
struct AppSettings: Codable {
    var notificationsEnabled: Bool
    var reminderInterval: TimeInterval
    var watchHapticEnabled: Bool
    var soundEnabled: Bool
    var theme: AppTheme
    
    enum AppTheme: String, Codable {
        case system
        case light
        case dark
    }
    
    static var `default`: AppSettings {
        AppSettings(
            notificationsEnabled: true,
            reminderInterval: 20 * 60,  // 20 分钟
            watchHapticEnabled: true,
            soundEnabled: true,
            theme: .system
        )
    }
}

/// BeatSleep 共享数据 (App Groups)
struct SharedHealthData: Codable {
    var todayScreenMinutes: Int       // 今日用眼分钟数
    var lastUseTime: Date            // 最后一次用眼时间
    var eyeRestCompleted: Bool        // 今日护眼完成
    var streakDays: Int              // 连续护眼天数
    var sleepQualityScore: Double?    // 睡眠质量评分 (BeatSleep 提供)
    var focusMinutes: Int            // 专注分钟数
    
    static var `default`: SharedHealthData {
        SharedHealthData(
            todayScreenMinutes: 0,
            lastUseTime: Date(),
            eyeRestCompleted: false,
            streakDays: 0,
            sleepQualityScore: nil,
            focusMinutes: 0
        )
    }
}
