# EyeCare 20-20-20 功能设计

> 版本: 1.0.0  
> 更新日期: 2026-02-07  
> 状态: 设计完成，待实现

---

## 功能概述

### 核心逻辑

```
每 20 分钟 → 提醒用户 → 看 6 米远 → 持续 20 秒
```

### 用户价值

- 科学认可的护眼方法（American Optometric Association）
- 简单易执行，不影响工作
- 养成习惯后自动保护眼睛

---

## 用户体验设计

### 场景 1：日常用眼状态

```
┌─────────────────────────────────────┐
│ 💼 工作中...                         │
│ ⏱️ 距下次休息: 15:32               │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 👁️ 上次休息: 20分钟前           │ │
│ │ ✅ 已完成 3 次护眼              │ │
│ │ 🔥 连续 5 天达成目标！          │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 场景 2：提醒响起

```
┌─────────────────────────────────────┐
│ 💡                                │
│                                     │
│     👁️ 休息眼睛 20 秒            │
│     看向 6 米远的地方               │
│                                     │
│        ⏱️ 20                      │
│                                     │
│    ┌─────────────┐                │
│    │   开始计时   │                │
│    └─────────────┘                │
│                                     │
│    [暂不提醒]  [跳过]              │
└─────────────────────────────────────┘
```

### 场景 3：倒计时进行中

```
┌─────────────────────────────────────┐
│ 👁️ 20-20-20 护眼时间              │
│                                     │
│         ┌─────────┐                │
│         │         │                │
│         │   👁️   │                │
│         │    🌿   │ ← 远眺动画     │
│         │         │                │
│         └─────────┘                │
│                                     │
│           ⏱️ 18...17...           │
│                                     │
│      👏 完成！眼睛焕然一新         │
└─────────────────────────────────────┘
```

---

## 技术实现

### 1. 定时通知管理器

```swift
// NotificationManager.swift
class NotificationManager {
    private var restTimer: Timer?
    private let restInterval: TimeInterval = 20 * 60  // 20 分钟
    private let restDuration: TimeInterval = 20       // 20 秒
    
    func startMonitoring() {
        // 每分钟检查一次用眼状态
        restTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkRestNeeded()
        }
    }
    
    private func checkRestNeeded() {
        // 检查 Screen Time API 获取用眼时长
        let usageMinutes = ScreenTimeManager.shared.getTodayUsageMinutes()
        
        if usageMinutes > 0 && usageMinutes % 20 == 0 {
            // 刚好满 20 分钟，发出提醒
            showRestNotification()
        }
    }
    
    private func showRestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "👁️ 让眼睛休息一下"
        content.body = "每 20 分钟看远处 20 秒，有助于缓解眼疲劳"
        content.sound = .default
        
        // 点击直接打开 App
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "rest-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func stopMonitoring() {
        restTimer?.invalidate()
        restTimer = nil
    }
}
```

---

### 2. Screen Time 集成

```swift
// ScreenTimeManager.swift
class ScreenTimeManager {
    static let shared = ScreenTimeManager()
    
    // 获取今日屏幕使用时间（分钟）
    func getTodayUsageMinutes() -> Int {
        // 实际实现需要使用 Screen Time API 或 HealthKit
        return UserDefaults.standard.integer(forKey: "todayScreenMinutes")
    }
    
    // 更新今日用眼时长
    func updateTodayUsage(_ minutes: Int) {
        UserDefaults.standard.set(minutes, forKey: "todayScreenMinutes")
        UserDefaults.standard.set(Date(), forKey: "lastUsageUpdate")
    }
    
    // 检查是否正在使用设备
    func isCurrentlyUsingDevice() -> Bool {
        // 检查最后活跃时间
        guard let lastActive = UserDefaults.standard.object(forKey: "lastActiveTime") as? Date else {
            return false
        }
        return Date().timeIntervalSince(lastActive) < 60  // 1 分钟内有活动
    }
}
```

---

### 3. 倒计时视图

```swift
// RestTimerView.swift
import SwiftUI

struct RestTimerView: View {
    @State private var countdown = 20
    @State private var timer: Timer?
    @State private var isCompleted = false
    
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // 标题
            Text(isCompleted ? "👁️ 完成！" : "看看远处")
                .font(.title)
                .bold()
            
            // 进度圆环
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(countdown) / 20)
                    .stroke(
                        isCompleted ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: countdown)
                
                // 中心图标
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                }
            }
            
            // 倒计时数字
            if !isCompleted {
                Text("\(countdown)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            // 提示文字
            Text(isCompleted ? "眼睛焕然一新！" : "看向 6 米远的地方")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // 跳过按钮
            if !isCompleted {
                Button("跳过") {
                    stopTimer()
                    onSkip()
                }
                .foregroundColor(.secondary)
            } else {
                Button("完成") {
                    onComplete()
                }
                .font(.headline)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .onAppear {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                isCompleted = true
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
```

---

### 4. Apple Watch 联动

```swift
// WatchManager.swift
import WatchConnectivity

class WatchManager: ObservableObject {
    static let shared = WatchManager()
    private let session = WCSession.default
    
    func setup() {
        session.delegate = self
        session.activate()
    }
    
    func sendRestReminder() {
        // 发送消息到 Watch
        let message: [String: Any] = [
            "type": "rest-reminder",
            "title": "👁️ 休息眼睛",
            "duration": 20
        ]
        
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }
    
    func triggerHaptic() {
        // Apple Watch 震动提醒
        if let device = WKInterfaceDevice.current() {
            device.play(.notification)
        }
    }
}

extension WatchManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // 处理来自 Watch 的消息
        DispatchQueue.main.async {
            if let action = message["action"] as? String {
                switch action {
                case "complete-rest":
                    // 用户在 Watch 上完成了休息
                    NotificationCenter.default.post(name: .restCompleted, object: nil)
                case "snooze":
                    // 稍后再提醒
                    NotificationCenter.default.post(name: .restSnoozed, object: nil)
                default:
                    break
                }
            }
        }
    }
}
```

---

### 5. 智能不打扰

```swift
// SmartRestManager.swift
class SmartRestManager {
    static let shared = SmartRestManager()
    
    // 判断是否应该显示提醒
    func shouldShowRest() -> Bool {
        // 如果用户正在看视频，不打扰
        if isWatchingVideo() { return false }
        
        // 如果用户在开会，不打扰
        if isInMeeting() { return false }
        
        // 如果用户刚跳过，5 分钟内不再提醒
        if let lastSkip = UserDefaults.standard.object(forKey: "lastSkipTime") as? Date {
            if Date().timeIntervalSince(lastSkip) < 5 * 60 {
                return false
            }
        }
        
        // 其他情况，正常提醒
        return true
    }
    
    private func isWatchingVideo() -> Bool {
        // 检测前台应用是否是视频类
        let videoApps = ["YouTube", "Netflix", "VLC", "iina", "QuickTime Player"]
        return videoApps.contains(getFrontmostApp())
    }
    
    private func isInMeeting() -> Bool {
        // 检测是否在会议应用中
        let meetingApps = ["Zoom", "Teams", "Meet", "FaceTime"]
        return meetingApps.contains(getFrontmostApp())
    }
    
    private func getFrontmostApp() -> String {
        // 获取前台应用名称
        // 实际实现需要使用 Accessibility API
        return ""
    }
}
```

---

### 6. 数据模型

```swift
// RestRecord.swift
import Foundation

struct RestRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: Int  // 实际休息时长（秒）
    let completed: Bool  // 是否完成 20 秒
    let method: RestMethod  // 提醒方式
    
    enum RestMethod: String, Codable {
        case notification  // 通知
        case watch        // Watch 提醒
        case manual       // 手动
    }
}

// 用眼统计数据
struct EyeUsageStats {
    var todayRestCount: Int       // 今日护眼次数
    var todayRestDuration: Int     // 今日护眼总时长（秒）
    var weeklyRestCount: [Int]     // 本周每日次数
    var streakDays: Int           // 连续天数
    var totalRestCount: Int       // 累计次数
}
```

---

## 成就系统

### 成就列表

| 成就 | 名称 | 条件 | 奖励 |
|------|------|------|------|
| 🌱 | 新手护眼者 | 完成第 1 次 | 解锁初级徽章 |
| 📅 | 每日护眼 | 完成 7 天 | 解锁进度卡片 |
| 🔥 | 连续护眼 | 连续 30 天 | 解锁高级徽章 |
| 👁️ | 眼睛卫士 | 累计 100 次 | 解锁统计报表 |
| 🏆 | 护眼大师 | 累计 365 次 | 解锁全部功能 |
| ⏰ | 准时休息 | 连续 7 天准时完成 | 解锁自定义提示音 |

---

## 用户流程图

```
开始使用 App
      │
      ↓
首次引导 → 介绍 20-20-20 规则
      │
      ↓
日常使用 → Screen Time 监控
      │
      ↓
每 20 分钟 ─── 是 ───→ 检查是否打扰
      │                  │
      否                 │
      ↓                  ↓
继续工作 ←───────── 不打扰 → 显示提醒
                              │
                              ↓
                         用户操作
                          /  │  \
                         /   │   \
                   开始计时  跳过  暂不提醒
                        │        │
                        ↓        ↓
                    完成 20 秒  5 分钟后重试
                        │
                        ↓
                   记录数据 + 更新统计
                        │
                        ↓
              显示成就 / 更新连续天数
```

---

## 设计原则

### 1. 不打扰

- 智能检测用户状态
- 视频/会议中不强制提醒
- 用户可设置"勿扰时段"

### 2. 温柔提醒

- 不是警告，是关心
- 简洁的文案
- 好听的提示音

### 3. 有成就感

- 统计数据展示
- 成就徽章激励
- 连续天数显示

### 4. 简单直接

- 20 秒完成
- 无复杂操作
- 一键开始/跳过

---

## 相关文档

- [核心功能设计](../02-Requirements/CORE_FEATURES.md)
- [BeatSleep 联动设计](../05-Services/BEATSLEEP_INTEGRATION.md)
- [商业模式分析](../06-Research/EYECARE_RESEARCH.md)
