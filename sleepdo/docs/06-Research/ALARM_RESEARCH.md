# 闹钟功能研究

> 最后更新: 2026-02-05

## iOS 闹钟最佳实践

### 技术方案
- UserNotifications API
- 本地通知（不需要服务器）
- UNUserNotificationCenter 管理

### 功能设计

#### 基础功能
- 设置时间
- 设置标签
- 设置重复周期
- 开关控制

#### 进阶功能
- 渐强音量
- 渐强震动
- 智能唤醒（浅睡眠唤醒）

### 渐强唤醒算法

#### 音量渐强
```swift
// 从 30% 开始，每 5 秒增加 10%
for i in 0..<8 {
    delay(Double(i) * 5) {
        setVolume(0.3 + Double(i) * 0.1)
    }
}
```

#### 震动渐强
```swift
WKInterfaceDevice.current().play(.notification)
// 间隔 5 秒再次震动
delay(5) { play(.notification) }
// 渐强...
```

#### 浅睡唤醒
1. 持续监测睡眠阶段（Apple Watch）
2. 检测 HRV（心率变异性）
3. 在浅睡眠窗口触发唤醒
4. 比固定时间唤醒更自然

### 通知声音
- 系统默认声音
- 可自定义音频文件
- 支持渐强播放

### 用户体验

#### 交互设计
- 大按钮易于操作
- 清晰的开关状态
- 简洁的设置界面

#### 反馈
- 震动反馈
- 声音反馈
- 视觉反馈
