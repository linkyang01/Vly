# QuitDo 数据模型设计

## 📊 核心数据模型

### 1. User (用户)
```swift
struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let email: String
    var displayName: String
    var avatarURL: String?
    
    // 戒烟相关
    var quitDate: Date                    // 戒烟开始日期
    var cigarettesPerDay: Int              // 每天吸烟量
    var cigarettesPerPack: Int             // 每包烟支数
    var pricePerPack: Double              // 每包烟价格
    
    // 统计
    var streakDays: Int                   // 连续天数
    var totalSavedMoney: Double           // 总节省金额
    var totalNotSmoked: Int               // 总未吸烟支数
    
    // 成就
    var unlockedAchievements: [String]    // 已解锁成就ID列表
    
    // 设置
    var notificationsEnabled: Bool         // 推送开关
    var reminderTimes: [Date]              // 提醒时间
    var aiCoachingEnabled: Bool           // AI辅导开关
    
    var createdAt: Date
    var updatedAt: Date
}
```

### 2. SmokingRecord (吸烟记录)
```swift
struct SmokingRecord: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let date: Date
    
    // 今日数据
    var cigarettesSmoked: Int              // 今日吸烟数量（复吸时记录）
    var cravings: [Craving]               // 烟瘾记录
    
    // 状态
    var didSmokeToday: Bool               // 今日是否复吸
    var mood: Mood                        // 今日心情
    
    // AI对话摘要
    var aiConversationSummary: String?     // AI对话摘要
    
    var createdAt: Date
    var updatedAt: Date
}
```

### 3. Craving (烟瘾记录)
```swift
struct Craving: Identifiable, Codable, Equatable {
    let id: String
    let timestamp: Date
    
    // 触发因素
    var triggers: [TriggerType]           // 触发类型
    var customTrigger: String?             // 自定义触发
    
    // 强度
    var intensity: Int                     // 1-10 强度
    var duration: Int                     // 持续分钟数
    
    // 应对方式
    var copingStrategy: CopingStrategy?    // 使用的应对策略
    
    // 结果
    var didSmoke: Bool                   // 是否复吸
    var notes: String?                    // 备注
}
```

### 4. Achievement (成就)
```swift
struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String                      // SF Symbols 名称
    let category: AchievementCategory
    let requirement: AchievementRequirement
    
    // 解锁条件
    var threshold: Int                    // 解锁阈值
    var points: Int                       // 成就积分
    
    var isSecret: Bool                   // 是否隐藏成就
    var isUnlocked: Bool                 // 是否已解锁（运行时计算）
}

enum AchievementCategory: String, Codable {
    case streak        // 连续类
    case money         // 省钱类
    case health       // 健康类
    case special      // 特殊类
    case social       // 社交类（如果有）
}
```

### 5. QuitProgress (戒烟进度)
```swift
struct QuitProgress: Codable {
    let userId: String
    let quitDate: Date
    
    // 时间维度
    var minutesQuit: Int { quitDate.distanceInMinutes(to: Date()) }
    var hoursQuit: Int { quitDate.distanceInHours(to: Date()) }
    var daysQuit: Int { quitDate.distanceInDays(to: Date()) }
    var weeksQuit: Int { quitDate.distanceInWeeks(to: Date()) }
    
    // 健康恢复（简化版）
    var heartRateImprovement: String {
        switch daysQuit {
        case 0..<1: return "心率开始下降..."
        case 1..<2: return "心率下降约10%"
        case 2..<7: return "心率接近正常水平"
        default: return "心率完全正常"
        }
    }
    
    var tasteRecovery: String {
        switch daysQuit {
        case 0..<2: return "味觉正在恢复..."
        case 2..<7: return "味觉开始改善"
        default: return "味觉完全恢复"
        }
    }
    
    // 省钱
    var dailySavings: Double
    var weeklySavings: Double
    var monthlySavings: Double
    
    // 等效健康活动
    var equivalentSteps: Int { daysQuit * 10000 }
    var equivalentRunningHours: Double { Double(daysQuit) * 0.5 }
}
```

### 6. AIConversation (AI对话)
```swift
struct AIConversation: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let date: Date
    
    var messages: [AIMessage]
    var context: AIContext              // 对话上下文
    
    var summary: String?                // 对话摘要
    var sentiment: Sentiment             // 用户情绪
    
    var createdAt: Date
}

struct AIMessage: Identifiable, Codable {
    let id: String
    let role: MessageRole               // user / assistant
    let content: String
    let timestamp: Date
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}
```

## 📋 枚举定义

### TriggerType (触发类型)
```swift
enum TriggerType: String, Codable, CaseIterable {
    case stress          = "压力"
    case coffee          = "喝咖啡"
    case alcohol         = "饮酒"
    case afterMeal       = "饭后"
    case social          = "社交场合"
    case boredom         = "无聊"
    case workBreak       = "工作休息"
    case driving         = "开车"
    case waiting         = "等待"
    case seeingSmoker    = "看到别人吸烟"
    case custom          = "其他"
}
```

### CopingStrategy (应对策略)
```swift
enum CopingStrategy: String, Codable, CaseIterable {
    case deepBreathing   = "深呼吸"
    case drinkingWater   = "喝水"
    case chewingGum      = "嚼口香糖"
    case eatingSnack     = "吃零食"
    case walking        = "散步"
    case callingFriend   = "打电话给朋友"
    case breathingExercise = "呼吸练习"
    case distraction    = "转移注意力"
    case waiting5min     = "等5分钟"
    case positiveSelfTalk = "自我鼓励"
    case custom          = "其他"
}
```

### Mood (心情)
```swift
enum Mood: String, Codable, CaseIterable {
    case great          = "非常好"
    case good           = "不错"
    case neutral        = "一般"
    case difficult      = "有点难"
    case veryHard       = "非常难"
    
    var emoji: String {
        switch self {
        case .great: return "😄"
        case .good: return "🙂"
        case .neutral: return "😐"
        case .difficult: return "😟"
        case .veryHard: return "😫"
        }
    }
}
```

## 🔗 关联关系

```
User (1)
  ├── SmokingRecord (*)
  ├── AIConversation (*)
  └── Achievement (通过 unlockedAchievements 关联)
```

## 📈 Firestore 集合设计

| 集合名 | 类型 | 说明 |
|--------|------|------|
| `users` | Document | 用户主表 |
| `smoking_records` | Collection | 吸烟记录 |
| `conversations` | Collection | AI对话 |
| `achievements` | Document (全局) | 成就定义 |
| `app_config` | Document | App配置 |

---

*最后更新: 2026-02-06*
