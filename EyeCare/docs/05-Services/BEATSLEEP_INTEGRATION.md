# EyeCare × BeatSleep 联动设计

> 版本: 1.0.0  
> 更新日期: 2026-02-07

---

## 联动愿景

**白天 EyeCare 护眼 → 晚上 BeatSleep 助眠 → 形成完整健康闭环**

---

## 联动方式

### 1. 数据联动

| 数据 | EyeCare 记录 | BeatSleep 使用 |
|------|-------------|---------------|
| **睡前用眼时长** | 最后 1 小时用眼时间 | 影响睡眠准备建议 |
| **用眼高峰时段** | 全天用眼热力图 | 分析对睡眠的影响 |
| **护眼完成率** | 每日达标率 | 关联睡眠质量评分 |

**实现方式**：App Groups 共享数据

```swift
// App Groups 共享数据
let sharedDefaults = UserDefaults(suiteName: "group.com.eyecare.shared")
```

---

### 2. 功能联动

#### BeatSleep 睡前仪式新增「护眼环节」

```
睡前仪式流程：
1. 护眼提醒 ⭐ NEW
   - "你已经用眼 X 小时，建议先休息眼睛"
   - 引导 20-20-20 远眺

2. 4-7-8 呼吸（原有）

3. 白噪音（原有）
```

#### EyeCare 睡眠联动

```
睡前场景：
- 检测到临近睡眠时间（iOS Sleep Focus）
- EyeCare 自动提醒："睡前 30 分钟建议开始放松眼睛"
- 可一键跳转到 BeatSleep
```

---

### 3. 跨 App 跳转

#### EyeCare 内跳转

```
设置页面 → "关联 App" → "连接 BeatSleep"
```

#### BeatSleep 内跳转

```
首页 → "添加助眠习惯" → "护眼提醒" ⭐ NEW
```

#### 快捷指令（Shortcuts）联动

```swift
// 创建 Shortcut
"Open EyeCare" → "记录用眼"
"Open BeatSleep" → "开始睡前仪式"
```

---

## 技术实现

### 1. App Groups 配置

```swift
// Bundle ID
BeatSleep: com.beatsleep.app
EyeCare: com.eyecare.app
App Group: group.com.beatsleep.eyecare

// 共享数据
@AppStorage("todayScreenMinutes", store: sharedDefaults) 
@AppStorage("eyeCareStreak", store: sharedDefaults)
@AppStorage("sleepQualityScore", store: sharedDefaults)
```

---

### 2. HealthKit 数据共享

| 数据 | 写入方 | 读取方 |
|------|--------|--------|
| 护眼时长 | EyeCare | BeatSleep |
| 睡眠质量 | BeatSleep | EyeCare |

```swift
// EyeCare 写入护眼时长
let eyeRestType = HKQuantityType.quantityType(forIdentifier: .mindfulMinutes)!
let quantity = HKQuantity(unit: .minute(), doubleValue: 15)
let eyeRest = HKQuantitySample(type: eyeRestType, quantity: quantity)

// BeatSleep 读取
let predicate = HKQuery.predicateForSamples(withStart: .startOfDay(), end: .now())
```

---

### 3. 数据模型

```swift
// SharedModels.swift (App Groups 共享)

struct SharedHealthData: Codable {
    var todayScreenMinutes: Int       // 今日用眼分钟数
    var lastUseTime: Date            // 最后一次用眼时间
    var eyeRestCompleted: Bool        // 今日护眼完成
    var streakDays: Int              // 连续护眼天数
    var sleepQualityScore: Double     // 睡眠质量评分 (BeatSleep 提供)
    var focusMinutes: Int            // 专注分钟数
}
```

---

### 4. 联动触发逻辑

```swift
// EyeCare: 睡前检测
class BedtimeDetector {
    func checkBedtime() {
        let hour = Calendar.current.component(.hour, from: Date())
        // 假设睡眠时间是 22:00-23:00
        if hour >= 21 && hour <= 23 {
            showBedtimeReminder()
        }
    }
}

// BeatSleep: 读取用眼数据
class SleepAdvisor {
    func getPreSleepAdvice() -> String {
        let screenMinutes = sharedDefaults?.integer(forKey: "todayScreenMinutes") ?? 0
        if screenMinutes > 300 { // > 5 小时
            return "你今天用眼时间较长，建议先做 20-20-20 远眺放松眼睛"
        }
        return "眼睛状态良好，可以直接开始睡前仪式"
    }
}
```

---

## 用户体验流程

### 场景：用户晚上打开 BeatSleep

```
1. 打开 BeatSleep
2. 首页显示：
   ┌─────────────────────────────┐
   │ 今日用眼: 5小时 32分钟 ⚠️    │
   │ 睡眠质量: 85分 ⭐           │
   │                              │
   │ 💡 建议：先做 20-20-20 远眺   │
   │                              │
   │   [开始睡前仪式]              │
   └─────────────────────────────┘
3. 点击「开始睡前仪式」
4. 第一步自动显示「护眼提醒」
5. 完成护眼后进入正常的 4-7-8 呼吸
```

### 场景：用户白天用 EyeCare

```
1. 20-20-20 提醒响起
2. 用户完成远眺
3. EyeCare 显示：
   ┌─────────────────────────────┐
   │ ✅ 护眼完成                 │
   │ 连续: 7 天 ⭐              │
   │                              │
   │ 今晚 BeatSleep 助眠效果    │
   │ 预估提升: +15%             │
   └─────────────────────────────┘
```

---

## 联动优势

| 维度 | 单 App | 联动后 |
|------|--------|--------|
| **用户价值** | 只解决一个问题 | 解决全天健康问题 |
| **留存率** | 低 ⭐ | 高 ⭐⭐⭐ |
| **付费转化** | 单点付费 | 套装溢价 |
| **竞争壁垒** | 易被复制 | 生态护城河 |

---

## 高级版联动功能（仅 Pro）

| 功能 | 免费版 | Pro 版 |
|------|--------|--------|
| 基础联动（数据共享） | ✅ | ✅ |
| 护眼 → 睡眠质量关联分析 | ❌ | ✅ |
| BeatSleep 一键跳转 | ❌ | ✅ |
| 套装购买优惠 | ❌ | ✅ |

---

## 实现优先级

| 优先级 | 功能 | 说明 |
|--------|------|------|
| P0 | App Groups 数据共享 | 技术基础 |
| P0 | BeatSleep 读取用眼数据 | 核心联动 |
| P1 | EyeCare → BeatSleep 跳转 | 用户导流 |
| P1 | 睡前护眼提醒入口 | 功能闭环 |
| P2 | 睡眠质量关联分析 | 高级功能 |

---

## 注意事项

1. **用户授权**：首次联动需要用户确认
2. **隐私透明**：明确告知数据如何共享
3. **独立可用**：一个 App 坏了，另一个仍可独立使用

---

## 相关文档

- [EyeCare 研究文档](../06-Research/EYECARE_RESEARCH.md)
- [BeatSleep 架构设计](../BeatSleep/docs/01-Architecture/README.md)
