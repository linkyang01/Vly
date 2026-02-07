//
//  Achievement.swift
//  SleepDo
//
//  成就定义
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let targetValue: Int
    let isLifetime: Bool  // 终身会员专属
    
    init(
        id: String,
        name: String,
        description: String,
        icon: String,
        category: AchievementCategory,
        targetValue: Int,
        isLifetime: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.category = category
        self.targetValue = targetValue
        self.isLifetime = isLifetime
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case sleep = "睡眠"
    case streak = "连续"
    case alarm = "闹钟"
    case milestone = "里程碑"
    
    var icon: String {
        switch self {
        case .sleep: return "moon.fill"
        case .streak: return "flame.fill"
        case .alarm: return "bell.fill"
        case .milestone: return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .sleep: return "blue"
        case .streak: return "orange"
        case .alarm: return "purple"
        case .milestone: return "yellow"
        }
    }
}

// 成就进度
struct AchievementProgress: Identifiable, Codable {
    let id: String
    var currentValue: Int
    var isUnlocked: Bool
    var unlockedAt: Date?
    
    var progress: Double {
        guard let achievement = Achievement.all.first(where: { $0.id == id }) else {
            return 0
        }
        return min(Double(currentValue) / Double(achievement.targetValue), 1.0)
    }
}

extension Achievement {
    static let all: [Achievement] = [
        // 睡眠成就
        Achievement(id: "sleep_1", name: "早睡早起", description: "第一次记录睡眠", icon: "moon.stars.fill", category: .sleep, targetValue: 1),
        Achievement(id: "sleep_2", name: "充足睡眠", description: "单日睡眠超过8小时", icon: "bed.double.fill", category: .sleep, targetValue: 1),
        Achievement(id: "sleep_3", name: "深度睡眠", description: "深睡眠占比超过25%", icon: "moon.zzz.fill", category: .sleep, targetValue: 1),
        Achievement(id: "sleep_4", name: "睡眠记录员", description: "记录7天睡眠数据", icon: "calendar", category: .sleep, targetValue: 7),
        Achievement(id: "sleep_5", name: "优质睡眠", description: "获得睡眠质量评分90+", icon: "star.fill", category: .sleep, targetValue: 1),
        Achievement(id: "sleep_6", name: "数据分析", description: "查看30天睡眠报告", icon: "chart.bar.fill", category: .sleep, targetValue: 30),
        Achievement(id: "sleep_7", name: "睡眠专家", description: "记录30天睡眠数据", icon: "brain.head.profile", category: .sleep, targetValue: 30),
        Achievement(id: "sleep_8", name: "完美睡眠", description: "连续5天睡眠评分85+", icon: "crown.fill", category: .sleep, targetValue: 5),
        
        // 连续成就
        Achievement(id: "streak_1", name: "开始坚持", description: "连续3天使用", icon: "flame", category: .streak, targetValue: 3),
        Achievement(id: "streak_2", name: "渐入佳境", description: "连续7天使用", icon: "flame.fill", category: .streak, targetValue: 7),
        Achievement(id: "streak_3", name: "一周达人", description: "连续14天使用", icon: "flame.circle.fill", category: .streak, targetValue: 14),
        Achievement(id: "streak_4", name: "两周坚持", description: "连续14天记录睡眠", icon: "calendar.badge.checkmark", category: .streak, targetValue: 14),
        Achievement(id: "streak_5", name: "习惯养成", description: "连续21天使用", icon: "checkmark.circle.fill", category: .streak, targetValue: 21),
        Achievement(id: "streak_6", name: "月度挑战", description: "连续30天使用", icon: "calendar.circle.fill", category: .streak, targetValue: 30),
        Achievement(id: "streak_7", name: "百日坚持", description: "连续100天使用", icon: "trophy.fill", category: .streak, targetValue: 100),
        Achievement(id: "streak_8", name: "全年无休", description: "连续365天使用", icon: "star.circle.fill", category: .streak, targetValue: 365),
        Achievement(id: "streak_9", name: "早起鸟", description: "连续7天23:00前入睡", icon: "sunrise.fill", category: .streak, targetValue: 7),
        Achievement(id: "streak_10", name: "早睡达人", description: "连续30天23:00前入睡", icon: "moon.stars.fill", category: .streak, targetValue: 30),
        
        // 闹钟成就
        Achievement(id: "alarm_1", name: "第一次闹钟", description: "设置第一个闹钟", icon: "bell.fill", category: .alarm, targetValue: 1),
        Achievement(id: "alarm_2", name: "准时起床", description: "第一次准时起床", icon: "alarm.fill", category: .alarm, targetValue: 1),
        Achievement(id: "alarm_3", name: "一周准时", description: "连续7天准时起床", icon: "clock.fill", category: .alarm, targetValue: 7),
        Achievement(id: "alarm_4", name: "自然醒", description: "使用智能唤醒自然醒", icon: "sparkles", category: .alarm, targetValue: 1),
        Achievement(id: "alarm_5", name: "智能睡眠", description: "使用智能唤醒10次", icon: "brain.head.profile", category: .alarm, targetValue: 10),
        Achievement(id: "alarm_6", name: "延后挑战", description: "只延后闹钟5次", icon: "clock.badge.exclamationmark", category: .alarm, targetValue: 5),
        Achievement(id: "alarm_7", name: "彻底告别", description: "30天没有延后闹钟", icon: "hand.thumbsup.fill", category: .alarm, targetValue: 30),
        
        // 里程碑成就
        Achievement(id: "milestone_1", name: "新手入门", description: "解锁10个成就", icon: "star", category: .milestone, targetValue: 10),
        Achievement(id: "milestone_2", name: "渐入佳境", description: "解锁20个成就", icon: "star.leadinghalf.filled", category: .milestone, targetValue: 20),
        Achievement(id: "milestone_3", name: "成就达人", description: "解锁30个成就", icon: "star.fill", category: .milestone, targetValue: 30),
        Achievement(id: "milestone_4", name: "成就大师", description: "解锁全部35个成就", icon: "crown.fill", category: .milestone, targetValue: 35),
        Achievement(id: "milestone_5", name: "睡眠探索", description: "尝试10种不同的声音", icon: "music.note", category: .milestone, targetValue: 10),
        Achievement(id: "milestone_6", name: "混音大师", description: "使用混音器创建5个预设", icon: "slider.horizontal.3", category: .milestone, targetValue: 5),
        Achievement(id: "milestone_7", name: "分享达人", description: "分享睡眠数据", icon: "square.and.arrow.up", category: .milestone, targetValue: 1),
        Achievement(id: "milestone_8", name: "反馈专家", description: "提交5次反馈", icon: "bubble.left.and.bubble.right.fill", category: .milestone, targetValue: 5),
        Achievement(id: "milestone_9", name: "终身会员", description: "购买终身会员", icon: "creditcard.fill", category: .milestone, targetValue: 1, isLifetime: true),
        Achievement(id: "milestone_10", name: "两周年", description: "使用2周年", icon: "calendar.badge.clock", category: .milestone, targetValue: 730)
    ]
}
