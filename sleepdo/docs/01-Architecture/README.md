# SleepDo 架构设计

> 重构日期: 2026-02-05
> 核心定位: 帮助失眠人群入睡

## 产品定位

### 核心问题
帮助失眠/难入睡人群改善睡眠质量

### 目标用户
- 入睡困难者
- 浅睡眠易醒者
- 希望通过数据改善睡眠的用户

### 核心差异化
- AI 智能唤醒（Apple Watch 浅睡检测）
- 科学验证的睡前仪式
- 成就激励养成习惯

## 核心功能

| 功能 | 优先级 | 科学依据 |
|------|--------|---------|
| 声音助眠 | P0 | 白噪声掩盖环境噪音，自然声音触发放松反应 |
| 4-7-8呼吸 | P0 | Harvard研究证实可缩短50%入睡时间 |
| AI智能唤醒 | P1 | Apple Watch HRV检测浅睡眠窗口 |
| 成就系统 | P2 | 行为心理学，小目标降低入睡焦虑 |

## 技术栈

| 类别 | 技术 |
|------|------|
| UI框架 | SwiftUI 4.0 (iOS 16.0+) |
| 平台 | iOS + watchOS |
| 数据同步 | WatchConnectivity |
| 健康数据 | HealthKit |
| 音频 | AVFoundation |
| 通知 | UserNotifications |

## 项目结构

```
sleepdo/
├── Sources/
│   ├── App/              # 应用入口
│   │   ├── L_SleepApp.swift
│   │   └── ContentView.swift
│   ├── Views/            # UI视图
│   │   ├── SleepHomeView.swift
│   │   ├── SoundsView.swift
│   │   ├── AlarmView.swift
│   │   ├── StatsView.swift
│   │   ├── SettingsView.swift
│   │   ├── BreathingView.swift      # 4-7-8呼吸
│   │   └── SoundMixerView.swift     # 混音器
│   ├── Models/           # 数据模型
│   │   ├── UserProfile.swift
│   │   ├── SleepSession.swift
│   │   ├── Achievement.swift
│   │   └── Sound.swift
│   ├── Services/         # 业务逻辑
│   │   ├── SleepTracker.swift
│   │   ├── AchievementService.swift
│   │   ├── SoundPlayer.swift
│   │   └── SubscriptionManager.swift
│   └── WatchApp/         # Watch应用
│       ├── SleepDoWatchApp.swift
│       └── Views/
├── Resources/            # 资源
│   ├── Assets.xcassets
│   └── Sounds/           # 音频文件
├── docs/                 # 设计文档
└── scripts/              # 工具脚本
```

## 数据流架构

```
┌─────────────────────────────────────────────────────────┐
│                    Apple Watch                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐     │
│  │ 心率监测  │→ │ HRV分析  │→ │ 浅睡窗口检测     │     │
│  └──────────┘  └──────────┘  └──────────────────┘     │
│                      │                                 │
└──────────────────────┼─────────────────────────────────┘
                       │ WatchConnectivity
                       ▼
┌─────────────────────────────────────────────────────────┐
│                      iPhone App                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐     │
│  │ 声音播放  │← │ 成就系统 │← │ 睡眠数据分析     │     │
│  └──────────┘  └──────────┘  └──────────────────┘     │
│       │              │                │                │
│       ▼              ▼                ▼                │
│  ┌──────────────────────────────────────────────┐     │
│  │              UserDefaults + HealthKit        │     │
│  └──────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

## 关键技术决策

### 1. 睡眠数据来源
- **Apple Watch** - 心率、HRV、运动
- **HealthKit** - 官方睡眠分析
- **本地记录** - 用户手动记录

### 2. 浅睡唤醒算法
```python
def detect_light_sleep_window(hrv_samples, motion_samples):
    # 输入: 最近30分钟的HRV和运动数据
    # 处理: 计算HRV趋势、运动强度
    # 输出: 是否处于浅睡眠窗口
    
    hrv_trend = calculate_trend(hrv_samples)  # HRV上升趋势
    motion_level = average(motion_samples)    # 运动量
    
    if hrv_trend > HRV_THRESHOLD and motion_level < MOTION_THRESHOLD:
        return True  # 浅睡眠窗口
    return False
```

### 3. 声音播放架构
```swift
class SoundPlayer {
    var channels: [AudioChannel]  // 支持多声音混音
    var masterVolume: Double
    
    func play(soundId: String)
    func stop(soundId: String)
    func setVolume(soundId: String, volume: Double)
    func fadeOut(soundId: String, duration: TimeInterval)
}
```

## 订阅模式

### 定价策略
| 方案 | 价格 | 说明 |
|------|------|------|
| 月付 | $4.99/月 | 自动续订 |
| 年付 | $39.99/年 | 节省20% |
| 终身 | $99.99 | 一次购买 |

### 免费功能（转化漏斗）
- 基础声音（5个）
- 基础4-7-8呼吸
- 手动闹钟
- 3天数据存储

### 付费功能
- 全部声音（15个）
- AI智能唤醒
- 完整成就系统
- 30天数据存储
- Apple Watch同步

## 成就系统设计（简化版）

### 15个核心成就

| 类别 | 数量 | 示例 |
|------|------|------|
| 入睡习惯 | 5 | 连续3天使用、7天使用、14天使用、30天使用、100天使用 |
| 呼吸练习 | 3 | 第一次完成、累计10次、累计50次 |
| 睡眠改善 | 4 | 入睡时间缩短、深睡增加、连续7天7小时+、睡眠评分90+ |
| 智能唤醒 | 3 | 第一次使用、浅睡唤醒10次、30天浅睡唤醒 |

## 成功指标

### 北极星指标
- 用户 7 天内入睡时间缩短 ≥ 30%

### 过程指标
- 日活跃用户 (DAU)
- 声音播放完成率
- 呼吸练习完成率
- 智能唤醒使用率

### 商业指标
- 试用 → 付费转化率
- 续费率
- LTV/CAC
