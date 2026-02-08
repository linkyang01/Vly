# Vly 项目 AI 行为规范

## ⚠️ 核心约束（必须做到）

> **做不到就放弃这个项目**

### 播放器约束

| 约束 | 要求 | 做不到？ |
|------|------|---------|
| **KSPlayer** | 必须使用 KSPlayer 作为播放器内核 | ❌ 放弃项目 |
| **FFmpeg** | 必须激活 FFmpeg 解码，支持多格式 | ❌ 放弃项目 |
| **多格式** | MKV、AVI、FLV 等必须能播放 | ❌ 放弃项目 |
| **AVPlayer** | 基础 AVPlayer 无法满足多格式需求 | ❌ 不能只用 AVPlayer |

### 代码约束

```swift
// ✅ 正确：使用 KSPlayer
import KSPlayer
let player = KSPlayerNode()

// ❌ 错误：只使用 AVPlayer
import AVKit
let player = AVPlayer()  // ← 不允许！
```

## 项目概述

- **名称**: Vly
- **描述**: 简洁优雅的 macOS/iOS 视频播放器
- **技术栈**: SwiftUI 4.0, **KSPlayer + FFmpeg**
- **平台**: macOS 12.0+ / iOS 15.0+
- **License**: GPL v3

## 代码规范

### 命名规范

- **Swift**: 遵循 Apple Swift Style Guide
- **文件名**: UpperCamelCase (例如: `VideoPlayerView.swift`)
- **变量/函数**: lowerCamelCase (例如: `currentTime`)
- **常量**: k 开头 (例如: `kMaxVolume`)

### 架构规范

- **MVVM**: 遵循 Model-View-ViewModel 模式
- **Protocol**: 面向接口编程
- **Separation of Concerns**: 视图、服务、模型分离

### 文件组织

```
Sources/
├── App/           # 应用入口和根视图
├── Views/          # UI 组件
│   ├── Player/     # 播放器相关
│   ├── Controls/   # 控制组件
│   ├── Playlist/   # 播放列表
│   └── Settings/  # 设置页面
├── Models/         # 数据模型
├── Services/       # 业务逻辑
└── Utilities/      # 工具类
```

## 文档规范

### 文档位置

所有设计文档存放在 `docs/` 目录：

| 目录 | 内容 |
|------|------|
| `docs/01-Architecture/` | 架构设计 |
| `docs/02-Requirements/` | 功能需求 |
| `docs/03-UI-UX/` | UI/UX 设计 |
| `docs/04-Data-Models/` | 数据模型 |
| `docs/05-Services/` | 服务设计 |
| `docs/06-Research/` | 研究文档 |

### 文档格式

- 使用 Markdown (.md)
- 标题使用中文
- 代码示例使用 Swift
- 保持文档与代码同步更新

## 会话启动

处理 Vly 项目时必须：

1. ✅ 首先阅读项目 README.md
2. ✅ 阅读相关设计文档
3. ✅ 确认使用 KSPlayer（不是基础 AVPlayer）
4. ✅ 遵循代码规范
5. ✅ 保持文档更新
6. ✅ 提交前运行代码格式化

## 常用命令

### XcodeGen

```bash
# 生成项目
xcodegen generate

# 查看配置
xcodegen dump
```

### 格式化

```bash
# SwiftFormat (如果安装)
swiftformat .
```

## 禁止行为

- ❌ **不要只使用 AVPlayer**（必须用 KSPlayer + FFmpeg）
- ❌ 不要修改 KSPlayer 源码（使用适配器模式）
- ❌ 不要跳过代码规范
- ❌ 不要忘记更新文档
- ❌ 不要使用过时的 API

## 相关链接

- [KSPlayer](https://github.com/kingslay/KSPlayer)
- [FFmpeg](https://ffmpeg.org/)
- [SwiftUI 文档](https://developer.apple.com/swiftui/)
- [Apple Swift Style Guide](https://www.swift.org/documentation/api-design-guidelines/)
