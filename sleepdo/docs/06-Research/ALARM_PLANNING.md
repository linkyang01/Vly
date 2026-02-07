# 闹钟功能规划

> 最后更新: 2026-02-05

## 功能规划

### Phase 1: 基础功能
- [ ] 设置单个闹钟
- [ ] 设置重复周期
- [ ] 闹钟开关
- [ ] 基础通知

### Phase 2: 进阶功能
- [ ] 渐强音量
- [ ] 渐强震动
- [ ] 延后功能
- [ ] 智能跳过

### Phase 3: 智能唤醒
- [ ] 浅睡检测
- [ ] 最佳唤醒时间计算
- [ ] 心率辅助唤醒
- [ ] 个性化唤醒

## 技术实现

### 通知管理
```swift
UNUserNotificationCenter.current()
    .requestAuthorization(options: [.alert, .sound, .badge])
```

### 声音渐强
```swift
// 从 30% 开始，每 5 秒增加 10%
```

### 震动模式
```swift
WKInterfaceDevice.current().play(.notification)
```

## 用户体验

### 设置界面
- 简洁的时间选择器
- 清晰的重复设置
- 易于理解的开关

### 唤醒体验
- 温和的渐强过程
- 清晰的停止/延后选项
- 智能唤醒状态提示
