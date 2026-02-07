# BeatSleep 服务层设计

> 版本: 1.0.0  
> 更新日期: 2026-02-06  
> 状态: 正式发布

---

## 服务概览

| 服务 | 职责 | 依赖 |
|------|------|------|
| SleepTracker | 睡眠追踪、数据分析 | HealthKit, WatchConnectivity |
| WatchDataManager | Watch 数据同步 | WatchConnectivity |
| SubscriptionManager | 订阅管理 | StoreKit |
| NotificationManager | 本地通知 | UserNotifications |
| SoundManager | 声音播放 | AVFoundation |

---

## SleepTracker 服务

### 功能

- 记录睡眠会话
- 分析睡眠数据
- 计算统计信息
- 保存到本地存储

### 接口

```swift
class SleepTracker {
    // 单例
    static let shared = SleepTracker()
    
    // 属性
    @Published var sessions: [SleepSession] = []
    @Published var currentSession: SleepSession?
    
    // 方法
    func startSession(technique: BreathingTechnique)
    func endSession(quality: SleepQuality)
    func addNote(_ note: String)
    func fetchRecentSessions(limit: Int = 7) -> [SleepSession]
    func calculateStats() -> SleepStats
}
```

---

## WatchDataManager 服务

### 功能

- 监听 Watch 连接状态
- 同步心率数据
- 同步 HRV 数据
- 管理历史数据

### 接口

```swift
class WatchDataManager: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var currentHeartRate: Int?
    @Published var currentHRV: Double?
    @Published var history: [HeartRateSample] = []
    
    func startMonitoring()
    func stopMonitoring()
    func sendToWatch(_ message: [String: Any])
}
```

---

## SubscriptionManager 服务

### 功能

- 检查订阅状态
- 恢复购买
- 处理订阅
- 管理试用

### 接口

```swift
class SubscriptionManager {
    static let shared = SubscriptionManager()
    
    @Published var isSubscribed = false
    @Published var trialDaysRemaining = 7
    
    func checkSubscriptionStatus()
    func purchaseSubscription(product: Product)
    func restorePurchases()
    func startTrial()
}
```

---

## NotificationManager 服务

### 功能

- 睡眠提醒通知
- 练习完成通知
- 成就解锁通知

### 通知类型

| 类型 | 触发 | 优先级 |
|------|------|--------|
| bedtimeReminder | 每天固定时间 | 低 |
| practiceComplete | 练习结束 | 中 |
| streakMilestone | 连续天数达成 | 高 |

---

## SoundManager 服务

### 功能

- 播放背景音
- 管理音量
- 渐强/渐弱
- 混音支持

### 接口

```swift
class SoundManager {
    static let shared = SoundManager()
    
    @Published var isPlaying = false
    @Published var currentVolume: Float = 0.5
    
    func play(sound: SoundType)
    func stop()
    func setVolume(_ volume: Float)
    func fadeOut(duration: TimeInterval)
}
```

---

## 数据流

```
User Action
    │
    ▼
┌───────────────────────┐
│       View            │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│    SleepTracker       │ ← 数据处理
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│   UserDefaults        │ ← 本地存储
└───────────────────────┘
```

---

## 相关文档

- [架构设计](../01-Architecture/README.md)
- [数据模型](../04-Data-Models/DATA_MODELS.md)
- [UI 规范](UI_SPECIFICATION.md)
