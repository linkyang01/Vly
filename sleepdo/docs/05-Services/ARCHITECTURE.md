# SleepDo 服务层架构

> 重构日期: 2026-02-05

## 服务列表

| 服务 | 职责 | 依赖 |
|------|------|------|
| SleepTracker | 睡眠追踪、浅睡检测 | HealthKit, WatchConnectivity |
| SoundPlayer | 声音播放、混音 | AVFoundation |
| AchievementService | 成就管理 | UserDefaults |
| SubscriptionManager | 订阅管理 | StoreKit |
| NotificationManager | 本地通知 | UserNotifications |
| DataStore | 数据持久化 | UserDefaults, Keychain |

## 架构图

```
┌─────────────────────────────────────────────────────────┐
│                      View Layer                         │
│   (SleepHomeView, SoundsView, AlarmView, etc.)         │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                   Service Layer                          │
│  ┌────────────┐ ┌────────────┐ ┌────────────────────┐  │
│  │SleepTracker│ │SoundPlayer │ │AchievementService │  │
│  └─────┬──────┘ └─────┬──────┘ └─────────┬──────────┘  │
│        │              │                    │              │
│  ┌─────▼──────┐ ┌─────▼──────┐ ┌──────────▼──────────┐  │
│  │HealthKit   │ │AVFoundation│ │   DataStore         │  │
│  │WatchConnect│ │            │ │   (UserDefaults     │  │
│  └────────────┘ └────────────┘ │    Keychain)        │  │
│                                 └────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## SleepTracker 服务

### 职责
1. 从 Apple Watch 同步睡眠数据
2. 从 HealthKit 读取官方睡眠分析
3. 分析睡眠阶段，计算浅睡窗口
4. 检测最佳唤醒时机

### 核心算法

```swift
class SleepTracker {
    // MARK: - 浅睡窗口检测
    
    func detectLightSleepWindow(
        hrvSamples: [HRVData],
        motionSamples: [MotionData]
    ) -> LightSleepWindow? {
        // 1. 分析HRV趋势
        let hrvTrend = calculateHRVTrend(hrvSamples)
        
        // 2. 分析运动量
        let motionLevel = calculateMotionLevel(motionSamples)
        
        // 3. 综合判断
        if hrvTrend.isRising && motionLevel.isLow {
            return LightSleepWindow(
                startTime: Date(),
                confidence: calculateConfidence(hrvTrend, motionLevel)
            )
        }
        
        return nil
    }
    
    // MARK: - 睡眠评分
    
    func calculateSleepScore(for session: SleepSession) -> Int {
        let durationScore = scoreDuration(session.totalDuration)
        let qualityScore = scoreQuality(session.sleepQuality)
        let efficiencyScore = scoreEfficiency(session)
        
        return Int(Double(durationScore) * 0.3 + 
                   Double(qualityScore) * 0.4 + 
                   Double(efficiencyScore) * 0.3)
    }
}
```

### 数据同步策略

| 数据源 | 同步频率 | 存储位置 |
|--------|---------|---------|
| Apple Watch | 实时 | App内存 + UserDefaults |
| HealthKit | 每日1次 | HealthKit + UserDefaults |
| 本地记录 | 实时 | UserDefaults |

## SoundPlayer 服务

### 职责
1. 管理声音播放（单播/混音）
2. 音量控制（独立/整体）
3. 渐变效果
4. 定时关闭

### 架构

```swift
class SoundPlayer: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentSounds: [String: AudioChannel] = [:]
    @Published var masterVolume: Double = 1.0
    
    // 单个声音
    func play(soundId: String)
    func pause(soundId: String)
    func stop(soundId: String)
    func setVolume(soundId: String, volume: Double)
    
    // 混音
    func playMultiple(soundIds: [String])
    func stopAll()
    func fadeOutAll(duration: TimeInterval)
    
    // 定时
    func scheduleStop(after duration: TimeInterval)
}
```

## NotificationManager 服务

### 职责
1. 睡眠提醒通知
2. 闹钟通知
3. 成就解锁通知
4. 订阅到期提醒

### 通知类型

| 类型 | 触发条件 | 优先级 |
|------|---------|--------|
| bedtimeReminder | 每天睡前1小时 | 低 |
| alarm | 闹钟时间 | 高 |
| achievement | 成就解锁 | 中 |
| subscriptionExpiring | 订阅即将到期 | 中 |

## DataStore 服务

### 职责
1. 统一数据存储接口
2. 数据加密（敏感信息）
3. 数据迁移

### 存储策略

```swift
struct DataStore {
    // UserDefaults - 非敏感配置
    func save<T: Codable>(_ object: T, key: String)
    func load<T: Codable>(key: String) -> T?
    
    // Keychain - 敏感信息
    func saveSensitive(_ data: Data, key: String)
    func loadSensitive(key: String) -> Data?
    
    // 清理
    func clearExpiredData()
}
```
