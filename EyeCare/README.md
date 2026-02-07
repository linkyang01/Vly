# EyeCare

> 20-20-20 护眼助手 - 帮助用户养成健康的用眼习惯

## 项目简介

EyeCare 是一款基于 SwiftUI 开发的 iOS 护眼应用，采用科学认可的 20-20-20 法则：
> 每 20 分钟看远处 20 秒，可以有效缓解眼疲劳

## 功能特性

### 核心功能
- 🔔 **定时提醒**：每 20 分钟提醒用户休息眼睛
- ⏱️ **倒计时**：20 秒远眺倒计时
- 📊 **用眼统计**：每日、每周用眼数据分析
- 🏆 **成就系统**：解锁成就徽章，激励养成习惯
- 📱 **Apple Watch 联动**：手表震动提醒

### 辅助功能
- 🔄 **BeatSleep 联动**：与睡眠应用数据互通
- 🔔 **智能提醒**：视频/会议中不打扰
- 🌙 **夜间模式**：自动适配系统主题
- 🌐 **多语言支持**：中文、英文

## 技术栈

- **框架**：SwiftUI 4.0
- **系统**：iOS 16.0+
- **语言**：Swift 5.9+
- **包管理**：Swift Package Manager

## 项目结构

```
EyeCare/
├── Sources/
│   ├── App/
│   │   ├── EyeCareApp.swift       # 应用入口
│   │   ├── ContentView.swift      # TabBar 导航
│   │   └── AppState.swift         # 全局状态管理
│   ├── Views/
│   │   ├── EyeHomeView.swift       # 首页
│   │   ├── EyeStatsView.swift      # 统计页
│   │   ├── EyeAchievementsView.swift # 成就页
│   │   └── EyeSettingsView.swift   # 设置页
│   ├── Services/
│   │   ├── NotificationManager.swift   # 通知管理
│   │   ├── LocalStorageManager.swift   # 数据存储
│   │   └── RestTimerView.swift        # 倒计时视图
│   └── Extensions/
│       └── EyeCareExtensions.swift     # 扩展方法
├── Resources/
│   ├── Assets.xcassets/            # 资源文件
│   ├── Sounds/                     # 音频文件
│   ├── en.lproj/                  # 英文本地化
│   └── zh-Hans.lproj/             # 中文本地化
└── info.plist                     # 配置文件
```

## 设计规范

### 颜色主题

| 元素 | 颜色 | 说明 |
|------|------|------|
| **主色调** | `#22C55E` | 绿色 - 护眼、健康 |
| **渐变背景** | `#ECFDF5` → `#D1FAE5` | 浅绿渐变 |
| **强调色** | `#10B981` | 成功、达成 |

### 字体
- SF Pro Display / SF Pro Text
- 遵循 Apple Human Interface Guidelines

### 布局
- 边距：16pt
- 卡片圆角：16pt
- TabBar：胶囊式设计

## 运行环境

- Xcode 15.0+
- iOS 16.0+
- macOS Sonoma 14.0+

## 安装运行

1. 克隆项目：
```bash
git clone https://github.com/yourusername/EyeCare.git
```

2. 用 Xcode 打开 `EyeCare.xcodeproj`

3. 选择模拟器或真机，运行（⌘ + R）

## 项目配置

### Bundle Identifier
```
com.eyecare.app
```

### App Groups
```
group.com.eyecare.shared
```

### Capabilities
- Push Notifications
- Sign in with Apple
- App Groups
- HealthKit (可选)

## 设计文档

- [原型设计](docs/03-UI-UX/PROTOTYPE.md)
- [20-20-20 功能设计](docs/03-UI-UX/2020_RULE_DESIGN.md)
- [BeatSleep 联动设计](docs/05-Services/BEATSLEEP_INTEGRATION.md)
- [市场分析](docs/06-Research/EYECARE_RESEARCH.md)

## 版本历史

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| 1.0.0 | 2026-02-07 | 初始版本发布 |

## 许可证

MIT License

## 贡献者

- 项目负责人：杨林
- 设计：参考 BeatSleep 设计规范
- 开发：OpenClaw AI
