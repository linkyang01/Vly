# Vly 项目 AI 行为规范

## 项目概述

- **名称**: Vly
- **描述**: 简洁优雅的 macOS/iOS 开源视频播放器
- **技术栈**: SwiftUI 4.0, KSPlayer (AVPlayer + FFmpeg)
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
3. ✅ 遵循代码规范
4. ✅ 保持文档更新
5. ✅ 提交前运行代码格式化

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

- ❌ 不要修改 KSPlayer 源码（使用适配器模式）
- ❌ 不要跳过代码规范
- ❌ 不要忘记更新文档
- ❌ 不要使用过时的 API

## 相关链接

- [KSPlayer](https://github.com/kingslay/KSPlayer)
- [SwiftUI 文档](https://developer.apple.com/swiftui/)
- [Apple Swift Style Guide](https://www.swift.org/documentation/api-design-guidelines/)
