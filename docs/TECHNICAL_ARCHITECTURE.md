# Vly 技术架构设计

## 1. 架构目标

Vly 的架构目标是建立一个可扩展的 Apple 生态全能媒体播放器基础，先从 macOS 本地播放器开始，再逐步扩展到媒体库、网络媒体源和多端同步。

架构必须满足：

- 播放内核可替换、可封装；
- UI 不直接耦合第三方播放器；
- 播放状态统一管理；
- 后续可扩展字幕、音轨、媒体库、网络源；
- 保持 Apple 原生体验。

## 2. 总体架构

```text
Vly
├── UI Layer
│   ├── HomeView
│   ├── PlayerView
│   ├── ControlBar
│   ├── PlaylistPanel
│   └── SettingsView
│
├── Player Core
│   ├── KSPlayerAdapter
│   ├── PlaybackController
│   ├── PlaybackStateStore
│   ├── MediaOpenHandler
│   └── PlayerErrorHandler
│
├── Subtitle & Audio
│   ├── SubtitleManager
│   ├── SubtitleTrack
│   ├── AudioTrackManager
│   └── TrackSelectionState
│
├── Media Library
│   ├── FileScanner
│   ├── MediaMatcher
│   ├── MetadataService
│   ├── PosterCache
│   └── LibraryDatabase
│
├── Source Manager
│   ├── LocalFileSource
│   ├── LocalFolderSource
│   ├── SMBSource
│   ├── WebDAVSource
│   ├── DLNASource
│   └── URLStreamSource
│
└── Sync Layer
    ├── iCloudSyncManager
    ├── WatchProgressSync
    └── PreferencesSync
```

## 3. 第一阶段架构

第一阶段只实现以下模块：

```text
Vly
├── App
├── PlayerCore
│   ├── KSPlayerAdapter
│   ├── PlaybackController
│   └── PlaybackState
├── Services
│   └── FileOpenService
├── Views
│   ├── RootView
│   ├── PlayerView
│   ├── PlayerControlBar
│   └── DropZoneView
└── Models
    └── MediaItem
```

## 4. Player Core 设计

### 4.1 KSPlayerAdapter

负责封装 KSPlayer，向上层提供统一接口。

职责：

- 初始化播放器；
- 加载本地媒体 URL；
- 播放、暂停、停止；
- 读取播放进度；
- 设置音量；
- 暴露播放错误；
- 向 SwiftUI 提供可嵌入视图。

### 4.2 PlaybackController

负责业务层播放控制。

职责：

- 管理当前播放媒体；
- 接收 UI 操作；
- 调用 PlayerAdapter；
- 管理播放状态；
- 处理播放错误。

### 4.3 PlaybackState

统一描述播放器状态。

字段建议：

- currentURL；
- title；
- duration；
- currentTime；
- isPlaying；
- volume；
- isFullscreen；
- errorMessage。

## 5. UI 设计原则

第一阶段 UI 只追求清晰可用：

- 默认空状态：提示拖拽或打开视频；
- 播放状态：主区域为视频画面；
- 底部悬浮控制栏：播放、进度、时间、音量、全屏；
- 错误状态：展示可读错误信息；
- 不先做复杂媒体库首页。

## 6. 后续扩展点

| 扩展方向 | 依赖模块 |
|---|---|
| 字幕 | SubtitleManager |
| 音轨 | AudioTrackManager |
| 播放列表 | PlaylistService |
| 媒体库 | FileScanner + LibraryDatabase |
| 元数据 | MetadataService + TMDB |
| NAS | SourceManager |
| 同步 | iCloudSyncManager |

## 7. 技术风险

| 风险 | 说明 | 处理方式 |
|---|---|---|
| KSPlayer 集成失败 | macOS SwiftUI 嵌入可能存在适配问题 | 先做最小 Demo 验证 |
| FFmpeg 能力不足 | 部分格式或编码不一定可播 | 建立格式测试清单 |
| 许可证风险 | FFmpeg 与播放器依赖可能影响开源协议 | 技术验证阶段明确协议 |
| 性能风险 | 4K、HDR、大码率视频可能卡顿 | 后续建立性能测试集 |

## 8. 第一阶段验收

- 工程能打开；
- 能选择本地视频文件；
- 能拖拽视频文件；
- 能播放 MP4；
- 能播放 MKV；
- 能暂停、继续、调整进度和音量；
- 播放异常时有错误提示。
