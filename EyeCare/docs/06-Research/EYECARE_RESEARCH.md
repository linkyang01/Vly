# EyeCare 眼疲劳缓解研究

> 版本: 1.0.0  
> 更新日期: 2026-02-07  
> 状态: 调研中

---

## 眼疲劳科学基础

### 20-20-20 规则

**来源**: American Optometric Association (美国验光协会)

**规则**: 每使用电子设备 **20 分钟**，看 **20 英尺（约 6 米）** 远的地方，至少 **20 秒**

### 数字眼疲劳 (Digital Eye Strain / Computer Vision Syndrome)

| 症状 | 发生率 |
|------|--------|
| 眼干 | ~50% |
| 眼疲劳 | ~65% |
| 头痛 | ~30% |
| 视力模糊 | ~25% |

### 蓝光影响

| 类型 | 波长 | 影响 |
|------|------|------|
| 蓝光 | 400-500nm | 影响褪黑素分泌，抑制睡眠 |

---

## 核心功能设计

### 基础功能

| 功能 | 描述 | 技术实现 |
|------|------|---------|
| **定时提醒** | 每 20 分钟提醒休息 | UserNotifications |
| **用眼统计** | 今日/本周用眼时长 | Screen Time API |
| **20-20-20 引导** | 引导看远处 20 秒 | 动画 + 倒计时 |
| **护眼模式** | 屏幕色调调节 | Night Shift 联动 |

### 进阶功能

| 功能 | 描述 | 技术实现 |
|------|------|---------|
| **Apple Watch 联动** | 手表震动提醒 | WatchConnectivity |
| **用眼热力图** | 一天中疲劳时段分析 | Charts + 数据聚合 |
| **姿势提醒** | 检测用眼距离（需摄像头）| ARKit / 红外传感器 |
| **眨眼提醒** | 提醒多眨眼防止眼干 | - |

---

## Apple 健康数据

### 可读取数据

| 数据类型 | API | 说明 |
|---------|------|------|
| Screen Time | HealthKit | 设备使用时长 |
| 心率 | HealthKit | HRV 分析压力 |
| 步数 | HealthKit | 活动量关联 |

### 可写入数据

| 数据类型 | API | 说明 |
|---------|------|------|
| 护眼时长 | HealthKit | 冥想/放松时间 |

---

## 竞品分析

### iOS 已有的功能

| 应用 | 功能 | 特点 |
|------|------|------|
| **屏幕使用时间** | 用眼统计 | 系统自带 |
| **Night Shift** | 护眼模式 | 系统自带 |
| **Apple Watch 站立提醒** | 定时活动 | 系统自带 |

### 差异化机会

| 方向 | 说明 |
|------|------|
| **20-20-20 引导** | 系统没有主动引导 |
| **用眼热力图** | 可视化疲劳时段 |
| **助眠联动** | 和 BeatSleep 形成闭环 |
| **社交挑战** | 和朋友比谁能坚持 |

---

## 技术实现要点

### 1. 定时提醒

```swift
// 使用 UserNotifications
UNUserNotificationCenter.current().requestAuthorization()
```

### 2. Screen Time API

```swift
// 获取今日屏幕使用时间
let query = CKExtensionApplication.shared
```

### 3. Apple Watch 联动

```swift
// 发送消息到 Watch
WCSession.default.sendMessage(["action": "rest"], replyHandler: nil)
```

---

## 设计原则

1. **轻量级** - 不打扰用户工作
2. **温柔提醒** - 不是强制中断
3. **数据可视化** - 让用户看到进步
4. **隐私保护** - 本地存储用眼数据

---

## 后续研究

- [ ] 深入 ARKit 姿势检测可行性
- [ ] Apple Watch 睡眠数据联动
- [ ] 和 BeatSleep 助眠功能联动

---

## 参考文献

1. **American Optometric Association.** (2020). 20-20-20 Rule.
2. **The Vision Council.** (2021). Digital Eye Strain Report.
3. **Harvard Health.** (2022). Blue Light and Sleep.

---

## 相关文档

- [架构设计](../01-Architecture/README.md)
- [数据模型](../04-Data-Models/DATA_MODELS.md)
