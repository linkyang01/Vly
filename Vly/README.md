# Vly - 视频播放器

> 简洁优雅的 macOS/iOS 开源视频播放器

## 项目信息

| 项目 | 值 |
|------|------|
| 名称 | Vly |
| 描述 | 简洁优雅的 macOS/iOS 视频播放器 |
| 目标平台 | macOS 12.0+ / iOS 15.0+ |
| 技术栈 | SwiftUI 4.0, KSPlayer (AVPlayer + FFmpeg) |
| GitHub | https://github.com/linkyang01/Vly |

## 核心功能

- ✅ 视频播放（本地/网络）
- ✅ 多格式支持（MP4/MKV/AVI 等）
- ✅ 画质切换
- ✅ 字幕支持
- ✅ 画中画 (PiP)
- ✅ 播放列表管理
- ⏳ 播放队列
- ⏳ 键盘快捷键

## 技术选型

| 组件 | 选择 | 理由 |
|------|------|------|
| UI 框架 | SwiftUI | 跨平台、声明式 |
| 播放器 | KSPlayer | 功能全、跨平台 |
| 包管理 | Swift Package Manager | 官方推荐 |
| License | GPL | 免费使用 |

## 开始使用

### 环境要求

- macOS 12.0+ / Xcode 15.0+
- iOS 15.0+ / Xcode 15.0+

### 克隆项目

```bash
# 克隆仓库
git clone https://github.com/linkyang01/Vly.git
cd Vly

# 生成 Xcode 项目
xcodegen generate

# 打开项目
open Vly.xcodeproj
```

### 添加依赖

Xcode → File → Add Package Dependencies

```
https://github.com/kingslay/KSPlayer.git
选择 main 分支
添加到目标 Vly
```

## GitHub 同步指南

本项目采用 **阶段性同步** 策略，每个开发阶段完成后同步到 GitHub。

### 同步流程

```
┌─────────────────────────────────────────────────────────────┐
│                    本地开发阶段                              │
│  1. 在 workspace/Vly/ 中开发                             │
│  2. 测试功能完整性                                         │
│  3. 更新相关文档                                          │
│  4. 提交代码                                             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    同步到 GitHub                            │
│                                                          │
│  # 方式 1: 使用 Git 命令 (推荐)                          │
│  git add .                                               │
│  git commit -m "描述: 完成的功能"                        │
│  git push origin main                                    │
│                                                          │
│  # 方式 2: 使用 GitHub CLI                               │
│  gh repo create Vly --public --description "描述"         │
│  gh repo push Vly --source=.                            │
└─────────────────────────────────────────────────────────────┘
```

### 同步检查清单

每个阶段完成后检查：

- [ ] 代码编译通过
- [ ] 功能测试通过
- [ ] 相关文档已更新
- [ ] 无临时文件
- [ ] 提交信息清晰

### 提交信息规范

```bash
# 格式
git commit -m "类型: 描述

类型:
- feat: 新功能
- fix: 修复 bug
- docs: 文档更新
- refactor: 重构
- style: 格式调整
- test: 测试相关

示例:
git commit -m "feat: 添加播放列表管理功能

- 实现播放列表 CRUD 操作
- 添加拖动排序支持
- 更新 PlaylistService
"
```

### 分支策略

```bash
# 主分支 (保护)
main        # 稳定版本

# 开发分支 (可选)
develop     # 开发中功能

# 特性分支
feature/playlist   # 播放列表功能
feature/subtitle    # 字幕支持
feature/pip         # 画中画
```

### 常用命令速查

```bash
# 查看状态
git status

# 查看差异
git diff

# 查看提交历史
git log --oneline

# 查看远程
git remote -v

# 拉取最新
git pull origin main

# 强制推送 (谨慎使用)
git push -f origin main
```

## 项目结构

```
Vly/
├── Sources/
│   ├── App/
│   │   ├── VlyApp.swift              # 应用入口
│   │   └── ContentView.swift         # 根视图
│   ├── Views/
│   │   ├── Player/
│   │   │   └── VideoPlayerView.swift  # 播放器主视图
│   │   ├── Controls/
│   │   │   ├── ProgressBar.swift      # 进度条
│   │   │   └── PlaybackControls.swift   # 播放控制
│   │   ├── Playlist/
│   │   │   ├── PlaylistView.swift     # 播放列表
│   │   │   └── PlaylistItem.swift       # 列表项
│   │   └── Settings/
│   │       └── SettingsView.swift      # 设置页
│   ├── Models/
│   │   ├── Video.swift                # 视频模型
│   │   ├── Playlist.swift             # 播放列表模型
│   │   └── PlaybackState.swift         # 播放状态
│   ├── Services/
│   │   ├── PlayerService.swift         # 播放器管理
│   │   └── PlaylistService.swift       # 列表管理
│   └── Utilities/
│       ├── TimeFormatter.swift         # 时间格式化
│       └── Extensions.swift             # 扩展方法
├── Resources/
│   ├── Sounds/                        # 音效文件
│   └── Localization/                    # 本地化资源
├── docs/
│   ├── README.md                       # 文档索引
│   ├── 01-Architecture/               # 架构设计
│   │   └── README.md
│   ├── 02-Requirements/               # 功能需求
│   │   └── FEATURES.md
│   ├── 03-UI-UX/                     # UI/UX 设计
│   │   └── DESIGN.md
│   ├── 04-Data-Models/               # 数据模型
│   │   └── MODELS.md
│   ├── 05-Services/                  # 服务设计
│   │   └── SERVICES.md
│   └── 06-Research/                   # 研究文档
│       └── KSPLAYER_INTEGRATION.md
├── scripts/
│   └── build.sh                       # 构建脚本
├── project.yml                         # XcodeGen 配置
├── Package.swift                       # Swift Package 配置
├── README.md                           # 项目说明
├── AGENTS.md                           # AI 行为规范
└── LICENSE                            # GPL v3
```

## 文档

- [架构设计](docs/01-Architecture/README.md)
- [功能需求](docs/02-Requirements/FEATURES.md)
- [UI/UX 设计](docs/03-UI-UX/DESIGN.md)
- [数据模型](docs/04-Data-Models/MODELS.md)
- [服务设计](docs/05-Services/SERVICES.md)
- [KSPlayer 集成研究](docs/06-Research/KSPLAYER_INTEGRATION.md)
- [原型图设计](docs/PROTOTYPES.md)

## 许可证

**GPL v3** - 基于 [KSPlayer](https://github.com/kingslay/KSPlayer)

## 相关链接

- KSPlayer: https://github.com/kingslay/KSPlayer
- SwiftUI: https://developer.apple.com/swiftui/
- Apple Swift Style Guide: https://www.swift.org/documentation/api-design-guidelines/
