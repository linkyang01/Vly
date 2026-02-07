# QuitDo UI/UX 设计规范

## 🎨 设计理念

> **极简 + 专注 + 温暖**

- 不做社交噪音，只做戒烟陪伴
- 视觉简洁，功能直观
- 情感化设计，在脆弱时刻给予支持

## 🎨 配色方案

### 主色调
```swift
let primaryGradient = LinearGradient(
    colors: [
        Color(hex: "#0D0D1A"), // 深黑蓝
        Color(hex: "#1A1A3E"), // 深紫
        Color(hex: "#2D1B4E")  // 紫色
    ],
    startPoint: .top,
    endPoint: .bottom
)
```

### 辅助色
```swift
struct QuitDoColors {
    static let success = Color.green       // 成就、解锁
    static let warning = Color.orange      // 提醒
    static let danger = Color.red          // 烟瘾警报
    static let accent = Color.purple      // 强调色
    static let text = Color.white         // 主文字
    static let textSecondary = Color.gray // 次要文字
}
```

### 成就徽章色
```swift
struct BadgeColors {
    static let bronze = Color(hex: "#CD7F32")
    static let silver = Color(hex: "#C0C0C0")
    static let gold = Color(hex: "#FFD700")
    static let platinum = Color(hex: "#E5E4E2")
}
```

## 📐 组件规范

### TabBar (复用 SleepDo 设计)
```swift
TabView {
    HomeView().tabItem {
        Label("首页", systemImage: "house.fill")
    }
    ChatView().tabItem {
        Label("AI教练", systemImage: "bubble.left.fill")
    }
    AchievementsView().tabItem {
        Label("成就", systemImage: "medal.fill")
    }
    ProfileView().tabItem {
        Label("我的", systemImage: "person.fill")
    }
}
.frame(width: screenWidth * 0.5)
.ultraThinMaterial()
```

### 打卡卡片
```swift
struct CheckInCard: View {
    let streakDays: Int
    let moneySaved: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(streakDays) 天")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text("节省 ¥\(moneySaved, specifier: "%.2f")")
                .font(.title3)
                .foregroundColor(.green)
        }
        .padding(24)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }
}
```

### 成就徽章
```swift
struct AchievementBadge: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack {
            Image(systemName: isUnlocked ? achievement.icon : "lock.fill")
                .font(.system(size: 32))
                .foregroundColor(isUnlocked ? .yellow : .gray)
            
            Text(achievement.name)
                .font(.caption)
                .foregroundColor(.white)
        }
        .opacity(isUnlocked ? 1.0 : 0.5)
    }
}
```

## 📱 页面结构

### 1. HomeView (首页)
```
┌─────────────────────────────────┐
│  戒烟倒计时（大字体）           │
├─────────────────────────────────┤
│  ┌───────────┐ ┌───────────┐   │
│  │ 连续天数  │ │ 节省金额  │   │
│  └───────────┘ └───────────┘   │
├─────────────────────────────────┤
│  今日打卡按钮                   │
├─────────────────────────────────┤
│  健康恢复进度条                 │
│  • 20分钟: 心率下降            │
│  • 48小时: 味觉恢复            │
│  • 2周: 肺功能改善             │
└─────────────────────────────────┘
```

### 2. ChatView (AI教练)
```
┌─────────────────────────────────┐
│  AI教练头像 + 状态              │
├─────────────────────────────────┤
│  ┌─────────────────────────┐   │
│  │ 用户: 我今天特别想抽...   │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ AI: 理解你的处境...      │   │
│  └─────────────────────────┘   │
├─────────────────────────────────┤
│  ┌─────────────────────────┐   │
│  │ 输入框...               │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
```

### 3. AchievementsView (成就墙)
```
┌─────────────────────────────────┐
│  已解锁: 5/35                   │
├─────────────────────────────────┤
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐      │
│  │🥇│ │🥈│ │🥉│ │🔒│      │
│  └───┘ └───┘ └───┘ └───┘      │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐      │
│  │🔒│ │🔒│ │🔒│ │🔒│      │
│  └───┘ └───┘ └───┘ └───┘      │
├─────────────────────────────────┤
│  进度条                         │
└─────────────────────────────────┘
```

### 4. ProfileView (我的)
```
┌─────────────────────────────────┐
│  头像 + 用户名                  │
├─────────────────────────────────┤
│  设置                          │
│  ├── 吸烟习惯设置               │
│  ├── 提醒时间                   │
│  ├── 烟价设置                   │
│  └── 关于                        │
├─────────────────────────────────┤
│  会员状态                       │
│  [升级到会员]                   │
└─────────────────────────────────┘
```

## 📝 文案规范

### 正面激励
- ✅ "太棒了！又坚持了一天！"
- ✅ "你已经节省了 ¥500！"
- ✅ "肺功能正在恢复中..."

### 烟瘾应对
- 🟡 "我理解这个时刻很难..."
- 🟡 "试试这个技巧：深呼吸5次"
- 🟡 "你不是一个人，我一直陪着你"

### 成就解锁
- 🎉 "恭喜解锁：第一周成就！"
- 🏆 "连续30天！太厉害了！"

## 🔄 动效规范

| 动效 | 场景 | 方式 |
|------|------|------|
| 打卡成功 | 按钮点击 | 缩放 + 绿色闪光 |
| 成就解锁 | 徽章亮起 | 旋转 + 金光 |
| AI回复 | 打字机效果 | 逐字显示 |
| 进度更新 | 数字变化 | 渐变过渡 |

---

*最后更新: 2026-02-06*
