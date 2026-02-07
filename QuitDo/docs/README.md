# QuitDo 项目文档

## 📁 文档结构

```
QuitDo/
├── README.md                    # 项目主文档
├── AGENTS.md                    # AI 行为规范
├── TODO.md                      # 待办列表
│
├── docs/
│   ├── README.md                # 文档索引
│   │
│   ├── 01-Overview/
│   │   └── PROJECT.md           # 项目概述
│   │
│   ├── 02-Architecture/
│   │   └── SYSTEM.md            # 系统架构
│   │
│   ├── 03-UI-UX/
│   │   └── DESIGN.md            # UI/UX 设计规范
│   │
│   ├── 04-Models/
│   │   └── DATA.md              # 数据模型设计
│   │
│   ├── 05-Services/
│   │   └── SERVICES.md          # 服务层设计
│   │
│   └── 06-Research/
│       └── MARKET.md            # 竞品与市场研究
│
├── Sources/
│   ├── App/
│   ├── Views/
│   ├── Models/
│   ├── Services/
│   └── Cells/
│
├── Resources/
│   ├── sounds/
│   ├── assets/
│   └── Localizable.strings
│
├── scripts/
│   ├── setup.sh                 # 项目初始化
│   └── build.sh                 # 构建脚本
│
└── tests/
```

---

## 📖 文档说明

### 必读文档
| 文档 | 说明 | 必读 |
|------|------|------|
| README.md | 项目概览 | ✅ |
| PROJECT.md | 详细项目介绍 | ✅ |
| SYSTEM.md | 架构设计 | ✅ 开发时 |
| DESIGN.md | UI/UX 规范 | ✅ UI时 |
| DATA.md | 数据模型 | ✅ 开发时 |
| SERVICES.md | 服务设计 | ✅ 开发时 |
| MARKET.md | 市场研究 | 📋 了解背景 |

### 选读文档
| 文档 | 说明 |
|------|------|
| TODO.md | 开发待办列表 |
| scripts/ | 工具脚本 |

---

## 🔗 相关链接

### 技术参考
- [Firebase iOS 文档](https://firebase.google.com/docs/ios/setup)
- [MiniMax API 文档](https://api.minimax.chat/docs)
- [HealthKit 文档](https://developer.apple.com/documentation/healthkit)
- [SwiftUI 官方教程](https://developer.apple.com/tutorials/swiftui)

### 设计参考
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [SleepDo UI 设计](../sleepdo/docs/03-UI-UX/)

### 开源参考
- [QuitCoach](https://github.com/KyriakosPapoutsis/QuitCoach-AI-Gamification)
- [SmokeFree](https://github.com/Polymath-Saksh/SmokeFree)

---

*最后更新: 2026-02-06*
