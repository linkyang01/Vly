# BeatSleep 数据模型

> 版本: 1.0.0  
> 更新日期: 2026-02-06  
> 状态: 正式发布

---

## 模型总览

```
SleepManager
├── SleepSession (1:N)
└── UserSettings (1:1)
```

---

## 助眠技术模型

### BreathingTechnique

```swift
enum BreathingTechnique: String, CaseIterable, Identifiable {
    case478 = "4-7-8呼吸"
    case progressiveMuscleRelaxation = "渐进式肌肉放松"
    case bodyScan = "身体扫描"
    case breathing216 = "2-1-6呼吸"
    case whiteNoise = "白噪音"
    
    var id: String { rawValue }
    var icon: String
    var description: String
    var duration: TimeInterval
    var recommendedFor: String
    var hasVoiceGuide: Bool
    var steps: [BreathingStep]
}
```

### BreathingStep

```swift
struct BreathingStep: Identifiable {
    let id = UUID()
    let name: String           // "吸气" / "屏息" / "呼气"
    let duration: TimeInterval // 时长（秒）
    let instruction: String     // 英文指令
}
```

---

## 睡眠会话模型

### SleepSession

```swift
struct SleepSession: Identifiable, Codable {
    let id: UUID
    let date: Date                          // 记录日期
    let bedTime: Date                       // 上床时间
    let wakeTime: Date?                     // 起床时间（可选）
    let techniqueUsed: String               // 使用的助眠方法
    let timeToFallAsleep: TimeInterval?     // 入睡耗时（秒）
    let quality: SleepQuality                // 睡眠质量
    let heartRateData: [HeartRateSample]?   // 心率数据（可选）
    let notes: String?                      // 备注（可选）
}
```

### SleepQuality

```swift
enum SleepQuality: String, Codable, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    
    var emoji: String
    var description: String
}
```

### HeartRateSample

```swift
struct HeartRateSample: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let bpm: Int                // 每分钟心跳
    let hrv: Double?            // 心率变异性（可选）
}
```

---

## 用户设置模型

### UserSettings（待扩展）

```swift
struct UserSettings: Codable {
    var targetSleepDuration: Double = 8.0       // 目标睡眠时长（小时）
    var reminderEnabled: Bool = true           // 提醒开关
    var reminderTime: Date = Date()            // 提醒时间
    var watchHapticEnabled: Bool = true        // Watch 震动
    var watchSoundEnabled: Bool = true         // Watch 声音
}
```

---

## 订阅状态模型

### SubscriptionStatus

```swift
enum SubscriptionStatus: String, Codable {
    case trial          // 试用中
    case active         // 活跃订阅
    case expired        // 已过期
    case canceled       // 已取消
}

struct Subscription: Codable {
    var status: SubscriptionStatus
    var startDate: Date?
    var expiryDate: Date?
    var autoRenew: Bool
    var trialDaysRemaining: Int?
}
```

---

## 统计模型

### SleepStats

```swift
struct SleepStats {
    var averageTimeToFallAsleep: TimeInterval?  // 平均入睡时间
    var improvementFromLastWeek: String?        // 相比上周
    var weeklyTrend: [SleepSession]             // 周趋势
    var monthlyTrend: [SleepSession]            // 月趋势
    var totalSessions: Int                      // 总记录数
    var streak: Int                             // 连续使用天数
}
```

---

## 数据持久化

| 模型 | 存储方式 | 键 | 说明 |
|------|---------|---|------|
| SleepSession | Codable + UserDefaults | `sleepSessions` | JSON 数组 |
| UserSettings | UserDefaults | `userSettings` | 单个对象 |
| Subscription | Keychain | `subscription` | 加密存储 |

### 存储示例

```swift
// 保存
if let encoded = try? JSONEncoder().encode(sessions) {
    UserDefaults.standard.set(encoded, forKey: "sleepSessions")
}

// 读取
if let data = UserDefaults.standard.data(forKey: "sleepSessions"),
   let decoded = try? JSONDecoder().decode([SleepSession].self, from: data) {
    sessions = decoded
}
```

---

## 相关文档

- [架构设计](../01-Architecture/README.md)
- [服务设计](../05- Services/README.md)
- [代码规范](../CODING_STANDARDS.md)
