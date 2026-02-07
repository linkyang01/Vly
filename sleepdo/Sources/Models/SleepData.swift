//
//  SleepData.swift
//  SleepDo
//
//  睡眠数据模型
//

import Foundation

struct SleepData: Identifiable, Codable {
    let id: UUID
    let date: Date
    let sleepStartTime: Date
    let sleepEndTime: Date
    let totalDuration: TimeInterval  // 总睡眠时长（秒）
    let deepSleepDuration: TimeInterval  // 深睡眠时长
    let lightSleepDuration: TimeInterval  // 浅睡眠时长
    let remSleepDuration: TimeInterval  // REM睡眠时长
    let awakeDuration: TimeInterval  // 清醒时长
    let sleepQualityScore: Int  // 睡眠质量评分 (0-100)
    let heartRateData: [HeartRateSample]?  // 心率数据
    
    init(
        id: UUID = UUID(),
        date: Date,
        sleepStartTime: Date,
        sleepEndTime: Date,
        totalDuration: TimeInterval,
        deepSleepDuration: TimeInterval,
        lightSleepDuration: TimeInterval,
        remSleepDuration: TimeInterval,
        awakeDuration: TimeInterval,
        sleepQualityScore: Int,
        heartRateData: [HeartRateSample]? = nil
    ) {
        self.id = id
        self.date = date
        self.sleepStartTime = sleepStartTime
        self.sleepEndTime = sleepEndTime
        self.totalDuration = totalDuration
        self.deepSleepDuration = deepSleepDuration
        self.lightSleepDuration = lightSleepDuration
        self.remSleepDuration = remSleepDuration
        self.awakeDuration = awakeDuration
        self.sleepQualityScore = sleepQualityScore
        self.heartRateData = heartRateData
    }
    
    // 便捷属性
    var formattedDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    var deepSleepPercentage: Double {
        guard totalDuration > 0 else { return 0 }
        return deepSleepDuration / totalDuration
    }
    
    var lightSleepPercentage: Double {
        guard totalDuration > 0 else { return 0 }
        return lightSleepDuration / totalDuration
    }
    
    var remSleepPercentage: Double {
        guard totalDuration > 0 else { return 0 }
        return remSleepDuration / totalDuration
    }
}

struct HeartRateSample: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let bpm: Int
    
    init(id: UUID = UUID(), timestamp: Date, bpm: Int) {
        self.id = id
        self.timestamp = timestamp
        self.bpm = bpm
    }
}

// 每日睡眠汇总
struct DailySleepSummary: Identifiable {
    let id = UUID()
    let date: Date
    let averageDuration: TimeInterval
    let averageQuality: Int
    let sleepCount: Int
}

extension SleepData {
    static var sampleData: SleepData {
        SleepData(
            date: Date(),
            sleepStartTime: Date().addingTimeInterval(-8 * 3600),
            sleepEndTime: Date(),
            totalDuration: 7 * 3600 + 23 * 60,
            deepSleepDuration: 1.8 * 3600,
            lightSleepDuration: 3.2 * 3600,
            remSleepDuration: 1.5 * 3600,
            awakeDuration: 0.4 * 3600,
            sleepQualityScore: 85,
            heartRateData: nil
        )
    }
}
