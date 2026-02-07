# Apple Watch 设计文档

> 最后更新: 2026-02-05

## 功能概览

| 功能 | 描述 | 优先级 |
|------|------|--------|
| 睡眠卡片 | 显示当前睡眠状态和进度 | P0 |
| 闹钟控制 | 在手表上设置和响应闹钟 | P0 |
| 晨间挑战 | 起床后的简单挑战活动 | P1 |
| 心率监测 | 辅助浅睡唤醒算法 | P1 |
| 震动反馈 | 渐强震动唤醒模式 | P1 |

## 睡眠卡片设计

### UI 结构
```
┌─────────────────────┐
│      🌙 睡眠中       │
│      2h 23m         │
├─────────────────────┤
│ 💓 72 bpm    🌡️ 36°C│
├─────────────────────┤
│ [取消]     [延后10m] │
└─────────────────────┘
```

### 数据展示
- 当前状态图标
- 已睡眠时长
- 实时心率
- 环境温度（如果有）

## 闹钟控制

### 功能
- 在手表上查看和设置闹钟
- 响应闹钟（停止/延后）
- 渐强唤醒（音量/震动渐强）

### 渐强震动模式
```swift
// 震动强度渐强
WKInterfaceDevice.current().play(.notification)
delay(0.5) { play(.notification) }
delay(1.0) { play(.notification) }
// ... 渐强
```

## 晨间挑战 (Morning Challenge)

### 挑战类型
1. **清醒测试** - 连续点击直到清醒
2. **呼吸练习** - 30秒深呼吸
3. **伸展运动** - 简单拉伸动作

### 奖励机制
- 完成挑战获得积分
- 积分可兑换成就

## 心率辅助浅睡唤醒

### 算法思路
1. 持续监测睡眠期间心率变异性 (HRV)
2. 当 HRV 显示进入浅睡眠阶段时触发唤醒
3. 比固定时间唤醒更自然醒

### 数据源
- Apple Watch 心率传感器
- HealthKit 心率数据

## WatchConnectivity 数据同步

### 同步内容
| iPhone → Watch | Watch → iPhone |
|----------------|----------------|
| 闹钟设置 | 闹钟响应 |
| 睡眠状态 | 睡眠数据 |
| 成就进度 | 心率数据 |

### 数据格式
```swift
struct WatchMessage: Codable {
    let type: MessageType
    let payload: [String: Any]
    
    enum MessageType: String {
        case alarmAction
        case sleepStatus
        case achievementUpdate
        case heartRateData
    }
}
```

## 实现优先级

### Phase 1 (立即)
- [ ] 基础手表 App 框架
- [ ] 睡眠状态卡片 UI
- [ ] WatchConnectivity 基础通信

### Phase 2 (短期)
- [ ] 闹钟显示和控制
- [ ] 震动唤醒反馈
- [ ] 简单的数据同步

### Phase 3 (中期)
- [ ] 心率监测集成
- [ ] 浅睡唤醒算法
- [ ] 晨间挑战功能

## 技术栈

- watchOS 10.0+
- SwiftUI
- WatchConnectivity
- HealthKit
