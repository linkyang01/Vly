# Vly 架构设计

> 版本: 1.0
> 更新日期: 2026-02-06

## 1. 概述

Vly 是一个基于 SwiftUI + KSPlayer 构建的跨平台视频播放器，支持 macOS 和 iOS。

## 2. 技术架构

### 2.1 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| UI | SwiftUI | 4.0 |
| 播放器 | KSPlayer | 最新 (main) |
| 包管理 | Swift Package Manager | - |
| 部署目标 | macOS | 12.0+ |
| | iOS | 15.0+ |
| Xcode | - | 15.0+ |

### 2.2 架构模式

采用 **MVVM** (Model-View-ViewModel) 架构：

```
┌─────────────────────────────────────────────────────┐
│                    Views (SwiftUI)                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │ VideoPlayer │  │  Controls   │  │  Playlist   │ │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘ │
└─────────┼────────────────┼────────────────┼──────────┘
          │                │                │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────┐
│                 ViewModels                           │
│  ┌─────────────────┐  ┌─────────────────────────┐ │
│  │ PlayerViewModel  │  │ PlaylistViewModel        │ │
│  └─────────────────┘  └─────────────────────────┘ │
└─────────────────────┬───────────────────────────────┘
                      │
          ┌───────────┴───────────┐
          ▼                       ▼
┌─────────────────────┐  ┌─────────────────────┐
│       Models         │  │      Services        │
│  ┌────────────────┐ │  │  ┌───────────────┐ │
│  │ Video          │ │  │  │ PlayerManager │ │
│  │ Playlist       │ │ │  │  │ PlaylistMgr   │ │
│  │ PlaybackState  │ │ │  │  └───────────────┘ │
│  └────────────────┘ │  └─────────────────────┘
└─────────────────────┘
```

## 3. 模块设计

### 3.1 播放器模块

```swift
// 核心播放器接口
protocol VideoPlayerProtocol {
    var state: PlaybackState { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    
    func load(url: URL)
    func play()
    func pause()
    func seek(to time: TimeInterval)
}

// KSPlayer 实现
final class VlyPlayer: VideoPlayerProtocol {
    // 基于 KSPlayer 的实现
}
```

### 3.2 状态管理

```swift
// 统一状态管理
final class PlayerViewModel: ObservableObject {
    @Published var state: PlaybackState = .idle
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isPlaying: Bool = false
    @Published var volume: Float = 1.0
    @Published var playbackRate: Float = 1.0
    @Published var currentQuality: VideoQuality = .auto
}
```

## 4. 数据流

### 4.1 用户操作流

```
用户操作 → View → ViewModel → Player → 更新 State → View
```

### 4.2 事件传递

| 事件 | 方向 | 方式 |
|------|------|------|
| 播放/暂停 | User → Player | ViewModel |
| 进度更新 | Player → UI | Combine |
| 状态变更 | Player → ViewModel | Delegate |

## 5. 跨平台策略

### 5.1 平台适配

```swift
#if os(macOS)
typealias PlatformView = NSView
#elseif os(iOS)
typealias PlatformView = UIView
#endif

struct VlyPlayerView: View {
    var body: some View {
        PlatformVideoView()
            .frame(minWidth: 300, minHeight: 200)
    }
}
```

### 5.2 功能差异

| 功能 | macOS | iOS | 说明 |
|------|-------|-----|------|
| 基础播放 | ✅ | ✅ | 通用 |
| 画中画 | ✅ | ✅ | 通用 |
| Touch Bar | ✅ | ❌ | macOS 专属 |
| 键盘快捷键 | ✅ | ⚠️ | 外接键盘 |
| AirPlay | ❌ | ✅ | iOS 专属 |

## 6. 依赖管理

### 6.1 Swift Package

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/kingslay/KSPlayer.git", branch: "main")
]
```

## 7. 目录结构

```
Sources/
├── App/
│   ├── VlyApp.swift              # 应用入口
│   └── ContentView.swift         # 根视图
├── Views/
│   ├── Player/
│   │   ├── VideoPlayerView.swift  # 播放器主视图
│   │   └── PlayerControlBar.swift # 控制栏
│   ├── Controls/
│   │   ├── ProgressBar.swift     # 进度条
│   │   ├── PlaybackControls.swift # 播放控制
│   │   └── VolumeControl.swift    # 音量控制
│   ├── Playlist/
│   │   ├── PlaylistView.swift    # 播放列表
│   │   └── PlaylistItem.swift     # 列表项
│   └── Settings/
│       └── SettingsView.swift     # 设置页
├── Models/
│   ├── Video.swift               # 视频模型
│   ├── Playlist.swift            # 播放列表模型
│   └── PlaybackState.swift       # 播放状态
├── Services/
│   ├── PlayerManager.swift        # 播放器管理
│   └── PlaylistManager.swift      # 列表管理
└── Utilities/
    ├── TimeFormatter.swift        # 时间格式化
    └── Extensions.swift            # 扩展方法
```

## 8. 性能优化

### 8.1 策略

| 优化项 | 方法 |
|--------|------|
| 视频加载 | 预加载 + 缓存 |
| UI 响应 | 主线程更新 |
| 内存 | 按需加载 |
| 列表滚动 | 懒加载 |

## 9. 相关文档

- [功能需求](../02-Requirements/FEATURES.md)
- [UI/UX 设计](../03-UI-UX/DESIGN.md)
- [数据模型](../04-Data-Models/MODELS.md)
- [服务设计](../05-Services/SERVICES.md)
- [KSPlayer 集成研究](../06-Research/KSPLAYER_INTEGRATION.md)
