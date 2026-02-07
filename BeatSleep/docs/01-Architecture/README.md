# BeatSleep 架构设计

> 版本: 1.0.0  
> 更新日期: 2026-02-06  
> 状态: 正式发布

---

## 概述

BeatSleep 是一款帮助用户快速入睡的 iOS 应用，核心差异化是 4-7-8 呼吸法 + Apple Watch 数据展示。

---

## 技术栈

| 类别 | 技术 | 最低版本 |
|------|------|----------|
| UI 框架 | SwiftUI | iOS 16.0 |
| Watch | SwiftUI + WatchKit | watchOS 9.0 |
| 数据存储 | UserDefaults + HealthKit | - |
| 数据同步 | WatchConnectivity | - |
| 音频 | AVFoundation | - |
| 通知 | UserNotifications | - |
| 构建工具 | XcodeGen | 15.0 |

---

## 项目结构

```
BeatSleep/
├── Sources/
│   ├── App/                     # 应用入口
│   │   ├── BeatSleepApp.swift  # @main 入口
│   │   └── ContentView.swift   # TabView 导航
│   │
│   ├── Views/                   # UI 视图
│   │   ├── SleepHomeView.swift        # 首页
│   │   ├── TechniquesView.swift       # 方法选择
│   │   ├── BreathingSessionView.swift # ⭐ 呼吸练习
│   │   ├── WatchDataView.swift         # Watch 数据
│   │   └── SettingsView.swift         # 设置
│   │
│   ├── Models/                  # 数据模型
│   │   ├── BreathingTechnique.swift   # 助眠技术
│   │   └── SleepSession.swift         # 睡眠会话
│   │
│   └── Services/               # 业务逻辑
│       ├── SleepTracker.swift
│       ├── WatchDataManager.swift
│       └── SubscriptionManager.swift
│
│   └── WatchApp/                # Watch 应用
│       ├── BeatSleepWatchApp.swift
│       ├── WatchHomeView.swift
│       ├── WatchTechniquesView.swift
│       └── WatchSettingsView.swift
│
├── Resources/                   # 资源
│   ├── Assets.xcassets/
│   └── Sounds/
│
└── docs/                        # 文档
```

---

## 架构模式

采用 **MVVM** (Model-View-ViewModel) 模式：

```
┌─────────────────────────────────────────────────────┐
│                      View Layer                       │
│   (SleepHomeView, TechniquesView, etc.)             │
└─────────────────────────┬───────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────┐
│                   ViewModel Layer                       │
│   (@Published properties, business logic)            │
└─────────────────────────┬───────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────┐
│                    Model Layer                         │
│   (SleepSession, BreathingTechnique, etc.)           │
└─────────────────────────────────────────────────────┘
```

---

## 数据流

```
User Action
    │
    ▼
┌───────────────────────┐
│       View            │  ← UI 事件
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│    ViewModel          │  ← 状态管理
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│      Service         │  ← 业务逻辑
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│      Storage          │  ← 数据持久化
└───────────────────────┘
```

---

## 核心组件

### 1. SleepManager

负责睡眠数据管理：

```swift
@MainActor
class SleepManager: ObservableObject {
    @Published var sessions: [SleepSession]
    @Published var averageTimeToFallAsleep: TimeInterval?
    
    func addSession(_ session: SleepSession)
    func deleteSession(_ session: SleepSession)
    private func updateStats()
}
```

### 2. BreathingSessionView

4-7-8 呼吸练习核心页面：

```swift
struct BreathingSessionView: View {
    let technique: BreathingTechnique
    @State private var currentStepIndex = 0
    @State private var timeRemaining: TimeInterval
    @State private var isRunning = false
    @State private var cycleCount = 0
}
```

### 3. WatchDataManager

Watch 数据同步：

```swift
@MainActor
class WatchDataManager: ObservableObject {
    @Published var isConnected = false
    @Published var currentHeartRate: Int?
    @Published var currentHRV: Double?
    @Published var history: [HeartRateSample]
}
```

---

## 服务层

| 服务 | 职责 | 依赖 |
|------|------|------|
| SleepTracker | 睡眠追踪、数据分析 | HealthKit, WatchConnectivity |
| WatchDataManager | Watch 数据同步 | WatchConnectivity |
| SubscriptionManager | 订阅管理 | StoreKit |
| NotificationManager | 本地通知 | UserNotifications |

---

## 数据持久化

| 数据 | 存储方式 | 位置 |
|------|---------|------|
| 睡眠会话 | Codable + UserDefaults | App Sandbox |
| 设置 | UserDefaults | App Sandbox |
| 订阅状态 | Keychain | 加密存储 |
| HealthKit | 原生 API | 系统数据库 |

---

## 跨平台数据流

```
┌─────────────────────┐      WatchConnectivity       ┌─────────────────────┐
│    Apple Watch      │ ───────────────────────────→ │      iPhone App     │
│  • 心率监测          │   • 实时数据同步              │  • 数据展示          │
│  • HRV 采集         │   • 状态更新                  │  • 数据分析          │
│  • 震动反馈          │                              │  • 通知发送          │
└─────────────────────┘                              └─────────────────────┘
```

---

## 安全性

- 敏感数据（订阅状态）存储在 Keychain
- 健康数据仅本地存储，不上传服务器
- 遵循 Apple 隐私政策

---

## 相关文档

- [数据模型](../04-Data-Models/DATA_MODELS.md)
- [服务设计](../05-Services/README.md)
- [代码规范](../CODING_STANDARDS.md)
