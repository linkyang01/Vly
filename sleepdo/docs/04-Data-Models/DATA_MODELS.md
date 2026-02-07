# SleepDo 数据模型设计

> 重构日期: 2026-02-05

## 模型总览

```
UserProfile
├── SleepSession (1:N)
├── AchievementProgress (1:N)
├── Subscription (1:1)
└── Settings (1:1)

SleepSession
├── SleepStage (1:N)
└── HeartRateSample (0:N)
```

## 用户模型

### UserProfile
```swift
struct UserProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatarURL: URL?
    var joinDate: Date
    var lastActiveDate: Date
    var totalSleepDuration: TimeInterval  // 累计睡眠时长
    var averageSleepScore: Int             // 平均睡眠评分
}
```

### UserSettings
```swift
struct UserSettings: Codable {
    var targetSleepDuration: TimeInterval  // 目标睡眠时长 (8小时)
    var targetBedtime: DateComponents       // 目标入睡时间 (23:00)
    var smartWakeupEnabled: Bool           // 智能唤醒开关
    var wakeWindowMinutes: Int             // 唤醒窗口 (30分钟)
    var soundsEnabled: Bool                // 声音提醒开关
    var achievementsEnabled: Bool          // 成就通知开关
    
    // 偏好设置
    var preferredSounds: [String]          // 偏好声音ID列表
    var breathingTechnique: BreathingTechnique  // 呼吸方法
}
```

## 睡眠模型

### SleepSession
```swift
struct SleepSession: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let date: Date                          // 睡眠日期
    let bedTime: Date                       // 上床时间
    let wakeTime: Date                      // 起床时间
    let totalDuration: TimeInterval         // 总时长
    let sleepDuration: TimeInterval         // 实际睡眠时长
    let timeToFallAsleep: TimeInterval      // 入睡耗时
    let sleepScore: Int                     // 睡眠评分 (0-100)
    let wakeCount: Int                      // 夜间清醒次数
    let source: SleepSource                 // 数据来源
    
    // 统计数据
    var deepSleepDuration: TimeInterval?    // 深睡眠时长
    var lightSleepDuration: TimeInterval?   // 浅睡眠时长
    var remSleepDuration: TimeInterval?     // REM时长
    var avgHeartRate: Int?                  // 平均心率
    var minHeartRate: Int?                  // 最低心率
    var hrvScore: Double?                   // HRV评分
    
    var stages: [SleepStage]                // 睡眠阶段详情
    var heartRateSamples: [HeartRateSample] // 心率样本
}
```

### SleepStage
```swift
struct SleepStage: Identifiable, Codable {
    let id: UUID
    let sessionId: UUID
    let stage: SleepStageType
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let quality: Double                     // 质量评分 0-1
}

enum SleepStageType: String, Codable {
    case awake = "清醒"
    case rem = "REM"
    case light = "浅睡眠"
    case deep = "深睡眠"
}
```

### HeartRateSample
```swift
struct HeartRateSample: Identifiable, Codable {
    let id: UUID
    let sessionId: UUID
    let timestamp: Date
    let bpm: Int                            // 每分钟心跳
    let hrv: Double?                        // 心率变异性 (可选)
}
```

## 成就模型

### Achievement
```swift
struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let targetValue: Int
    let condition: AchievementCondition     // 解锁条件类型
}

enum AchievementCategory: String, Codable {
    case habit = "习惯养成"
    case breathing = "呼吸练习"
    case sleep = "睡眠改善"
    case smartWakeup = "智能唤醒"
}

enum AchievementCondition: String, Codable {
    case consecutiveDays      // 连续天数
    case totalCount           // 累计次数
    case sleepDuration        // 睡眠时长
    case sleepScore           // 睡眠评分
    case timeToFallAsleep     // 入睡耗时
    case usage                // 使用次数
}
```

### AchievementProgress
```swift
struct AchievementProgress: Identifiable, Codable {
    let id: String
    var currentValue: Int
    var isUnlocked: Bool
    var unlockedAt: Date?
    var isNew: Bool                               // 用于动画提示
}
```

## 声音模型

### Sound
```swift
struct Sound: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let category: SoundCategory
    let description: String
    let isPremium: Bool
    
    // 音频
    let audioFileName: String
    let duration: TimeInterval?      // 循环时长
}
```

### SoundCategory
```swift
enum SoundCategory: String, Codable, CaseIterable {
    case nature = "自然"
    case whiteNoise = "白噪声"
    case ambient = "环境"
    case meditation = "冥想"
}
```

### SoundMixer
```swift
struct SoundMixer: Identifiable, Codable {
    let id: UUID
    var name: String
    var sounds: [MixerSound]
    var isPreset: Bool
    var createdAt: Date
}
```

### MixerSound
```swift
struct MixerSound: Identifiable, Codable {
    let id: UUID
    let soundId: String
    var volume: Double            // 0.0 - 1.0
    var isPlaying: Bool
}
```

## 订阅模型

### Subscription
```swift
struct Subscription: Codable {
    var status: SubscriptionStatus
    var startDate: Date?
    var expiryDate: Date?
    var autoRenew: Bool
}

enum SubscriptionStatus: String, Codable {
    case trial          // 试用中
    case active         // 活跃订阅
    case expired        // 已过期
    case canceled       // 已取消
}
```

## 呼吸练习模型

### BreathingSession
```swift
struct BreathingSession: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let date: Date
    let technique: BreathingTechnique
    let cyclesCompleted: Int
    let totalDuration: TimeInterval
    let completed: Bool
}
```

### BreathingTechnique
```swift
enum BreathingTechnique: String, Codable, CaseIterable {
    case478 = "4-7-8呼吸"      // 吸气4秒-屏息7秒-呼气8秒
    case box = "方块呼吸"       // 吸气4秒-屏息4秒-呼气4秒-屏息4秒
    case relax = "放松呼吸"     // 吸气6秒-呼气6秒
    
    var inhaleDuration: Double { ... }
    var holdAfterInhale: Double { ... }
    var exhaleDuration: Double { ... }
    var holdAfterExhale: Double { ... }
    var cyclesPerSession: Int { 3 }  // 每轮循环次数
    var totalDuration: TimeInterval { ... }  // 预计总时长
}
```

## 数据持久化策略

| 模型 | 存储方式 | 说明 |
|------|---------|------|
| UserProfile | UserDefaults | 小数据量 |
| UserSettings | UserDefaults | 配置项 |
| SleepSession | UserDefaults + HealthKit | 本地存储30天，HealthKit永久 |
| AchievementProgress | UserDefaults | 自动同步 |
| Subscription | Keychain | 安全存储 |
| SoundMixer | UserDefaults | 最多20个 |
| BreathingSession | UserDefaults | 最近100条 |

## 数据迁移

```swift
struct DataMigration {
    static func migrateFromV1ToV2() {
        // V1 → V2 数据迁移逻辑
    }
}
```
