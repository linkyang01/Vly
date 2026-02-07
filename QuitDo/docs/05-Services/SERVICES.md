# QuitDo 服务层设计

## 📡 MiniMax AI Service

### 核心功能
```swift
class MiniMaxService {
    private let apiKey: String
    private let baseURL = "https://api.minimax.chat/v1"
    
    // 对话接口
    func chat(messages: [ChatMessage]) async throws -> String
    
    // 烟瘾应对
    func handleCraving(trigger: TriggerType, intensity: Int) async throws -> String
    
    // 进度鼓励
    func generateEncouragement(days: Int, moneySaved: Double) async throws -> String
    
    // 个性化建议
    func generateSuggestion(basedOn record: SmokingRecord) async throws -> String
}
```

### Prompt 设计

#### System Prompt
```swift
let systemPrompt = """
你是 QuitDo，一个专业、温暖、有耐心的戒烟教练。

## 你的角色
- 帮助用户度过戒烟难关
- 在用户想抽烟时提供应对策略
- 鼓励用户坚持戒烟
- 用数据和事实说明戒烟的好处

## 沟通风格
- 温暖、有同理心
- 简洁、不说教
- 积极、正面
- 具体、可操作

## 你不能做的
- 批评或责怪用户
- 说教或讲大道理
- 提供医学建议（请用户咨询医生）

## 当前用户信息
- 戒烟天数：{days}
- 节省金额：¥{money}
- 最近一次吸烟：{lastSmoke}
- 触发因素：{triggers}

请根据以上信息，给出温暖、鼓励、具体的回复。
"""
```

#### 烟瘾应对 Prompt
```swift
let cravingPrompt = """
用户正在经历烟瘾，强度 {intensity}/10。

触发因素：{trigger}

请：
1. 表达理解和同情
2. 提供 3 个具体的应对技巧
3. 询问用户想尝试哪个
4. 给予鼓励

回复要简洁、温暖、有帮助。
"""
```

#### 打卡鼓励 Prompt
```swift
let encouragementPrompt = """
用户已经戒烟 {days} 天，节省了 ¥{money}。

请：
1. 热情祝贺
2. 告诉用户身体正在发生的变化
3. 提醒用户已经取得的成就
4. 鼓励继续坚持

回复要热情、正面！
"""
```

---

## 🔥 Firebase Service

### 用户认证
```swift
class FirebaseAuthService {
    // 注册
    func signUp(email: String, password: String) async throws -> User
    
    // 登录
    func signIn(email: String, password: String) async throws -> User
    
    // 登出
    func signOut() throws
    
    // 重置密码
    func resetPassword(email: String) async throws
}
```

### Firestore 数据操作
```swift
class FirestoreService {
    // 保存用户
    func saveUser(_ user: User) async throws
    
    // 获取用户
    func fetchUser(id: String) async throws -> User?
    
    // 更新用户
    func updateUser(id: String, data: [String: Any]) async throws
    
    // 保存记录
    func saveSmokingRecord(_ record: SmokingRecord) async throws
    
    // 获取记录
    func fetchSmokingRecords(userId: String, from: Date, to: Date) async throws -> [SmokingRecord]
    
    // 获取统计
    func fetchStats(userId: String) async throws -> QuitStats
}
```

---

## 💪 HealthKit Service

### 权限请求
```swift
class HealthKitService {
    private let healthStore = HKHealthStore()
    
    // 请求权限
    func requestAuthorization() async throws -> Bool
    
    // 读取心率
    func fetchHeartRate() async throws -> Double
    
    // 读取步数
    func fetchSteps(from: Date, to: Date) async throws -> Int
    
    // 写入戒烟数据
    func saveQuitProgress(_ progress: QuitProgress) async throws
}
```

---

## 🔔 Notification Service

### 推送设置
```swift
class NotificationService {
    // 请求权限
    func requestAuthorization() async throws -> Bool
    
    // 每日打卡提醒
    func scheduleDailyReminder(at time: Date)
    
    // 自定义提醒
    func scheduleReminder(id: String, title: String, body: String, at date: Date)
    
    // 取消提醒
    func cancelReminder(id: String)
    
    // 取消所有
    func cancelAllReminders()
}
```

### 推送类型
| 类型 | 标题 | 内容 | 时间 |
|------|------|------|------|
| 每日提醒 | 新的一天！ | 别忘了今天的打卡 | 每天早上9点 |
| 成就提醒 | 🎉 太棒了！ | 你解锁了新成就！ | 即时 |
| 鼓励提醒 | 💪 你可以的！ | 已经坚持X天了！ | 晚间8点 |
| 烟瘾提醒 | 🫂 我在这里 | 想抽烟了？来找我聊聊 | 即时触发 |

---

## 🎯 Achievement Service

### 成就检查
```swift
class AchievementService {
    // 检查并解锁成就
    func checkAndUnlock(userId: String, event: AchievementEvent) async throws -> [Achievement]
    
    // 获取所有成就
    func fetchAllAchievements() async throws -> [Achievement]
    
    // 获取用户成就
    func fetchUserAchievements(userId: String) async throws -> [Achievement]
}
```

### 成就事件
```swift
enum AchievementEvent {
    case streakChanged(days: Int)
    case moneySavedChanged(amount: Double)
    case cravingRecorded(intensity: Int)
    case chatWithAI
    case appOpened
    case weekCompleted
    case monthCompleted
}
```

### 成就列表
| ID | 名称 | 描述 | 阈值 | 类别 |
|----|------|------|------|------|
| day1 | 第一天 | 完成第一天戒烟 | 1 | streak |
| day7 | 一周战士 | 连续7天 | 7 | streak |
| day30 | 月度冠军 | 连续30天 | 30 | streak |
| day100 | 百日英雄 | 连续100天 | 100 | streak |
| save100 | 百元户 | 节省100元 | 100 | money |
| save1000 | 千元户 | 节省1000元 | 1000 | money |
| first_craving | 直面烟瘾 | 第一次记录烟瘾 | 1 | special |
| streak_7 | 七天连续 | 七天不抽烟 | 7 | streak |

---

*最后更新: 2026-02-06*
