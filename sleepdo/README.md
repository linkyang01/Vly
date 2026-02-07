# SleepDo - 木木眠

> 智能睡眠助手 iOS App

## 项目信息

| 项目 | 值 |
|------|------|
| 中文名 | 木木眠 |
| 英文名 | SleepDo |
| Bundle ID | com.sleepdo.app |
| 技术栈 | SwiftUI 4.0, iOS 16.0+ |

## 核心功能

- 🎵 **声音播放** - 42个助眠声音，支持混音
- ⏰ **智能闹钟** - 渐强唤醒 + 浅睡唤醒算法
- 📊 **睡眠追踪** - HealthKit + Apple Watch 集成
- 🏆 **成就系统** - 35个成就
- 💰 **订阅模式** - 7天试用 + 终身$49.99

## 项目结构

```
sleepdo/
├── Sources/
│   ├── App/              # 应用入口
│   ├── Views/            # UI 视图
│   ├── Models/           # 数据模型
│   ├── Services/         # 业务逻辑
│   ├── Cells/            # 复用组件
│   └── WatchApp/         # Watch App
├── Resources/            # 资源文件
├── scripts/              # 工具脚本
├── docs/                 # 设计文档
└── archive/              # 历史版本
```

## 设计文档

详见 [docs/README.md](docs/README.md)

## AI 行为规范

详见 [AGENTS.md](AGENTS.md)

## 构建要求

- macOS
- Xcode 15+
- iOS 16.0+ SDK

## 运行

```bash
open SleepDo.xcodeproj
```
