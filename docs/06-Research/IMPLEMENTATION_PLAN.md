# Vly 完整开发方案

> **版本**: 3.0（完整版）  
> **更新日期**: 2026-02-07  
> **状态**: 一次性完成所有功能  
> **预计时间**: 5-6 小时  
> **目标完成度**: 90%+

---

## 一、项目概述

### 1.1 目标

开发 Vly - 一个简洁优雅的 macOS/iOS 开源视频播放器，目标是成为 IINA 的开源替代品。

### 1.2 核心技术

| 技术 | 选型 | 说明 |
|------|------|------|
| **播放器** | **KSPlayer** | SwiftUI 封装完整，源码质量好 |
| **解码** | FFmpeg 6.1 (GPL) | 支持多格式 |
| **最高分辨率** | **4K HDR** | 完全够用 |
| **UI 框架** | SwiftUI | 参考 IINA 设计 |
| **许可证** | GPL 3.0 | 开源项目 |

### 1.3 KSPlayer 特性

| 特性 | 支持情况 |
|------|---------|
| 本地视频播放 | ✅ |
| 网络流媒体 | ✅ |
| 4K/HDR/杜比视界 | ✅ |
| 画中画 (PiP) | ✅ |
| 字幕（内嵌/外挂） | ✅ |
| 多画质切换 | ✅ |
| 硬件加速 | ✅ |

---

## 二、功能清单（完整版）

### 2.1 核心播放功能（P0）- 必须完成

| 功能 | 说明 | 实现方式 |
|------|------|---------|
| 基础播放 | MP4/MKV/AVI/FLV/WebM | KSPlayer + FFmpeg |
| 4K 视频播放 | 支持 4K 分辨率 | KSPlayer |
| HDR/杜比视界 | 宽色域 + 高动态范围 | KSPlayer 配置 |
| 快进/快退 | 15秒步进 | KSPlayer |
| 进度条拖动 | 任意位置跳转 | KSPlayer |
| 播放/暂停 | 切换播放状态 | KSPlayer |
| 音量控制 | 0-100% 调节 | KSPlayer |
| 倍速播放 | 0.5x/0.75x/1x/1.25x/1.5x/2x | KSPlayer |
| 静音 | Toggle | KSPlayer |
| 全屏 | 窗口全屏切换 | SwiftUI |
| 画中画 (PiP) | 系统 PiP | KSPlayer |

### 2.2 字幕功能（P1）- 必须完成

| 功能 | 说明 | 实现方式 |
|------|------|---------|
| 内嵌字幕 | 视频自带字幕轨道 | KSPlayer |
| 外挂字幕 | SRT/ASS/SSA/VTT 加载 | KSPlayer |
| 字幕切换 | 多字幕轨道切换 | KSPlayer |
| 字幕样式 | 字体/大小/颜色/位置 | SubtitleService |

### 2.3 画质功能（P1）- 必须完成

| 功能 | 说明 | 实现方式 |
|------|------|---------|
| 多分辨率 | 1080p/720p/480p 切换 | KSPlayer |
| 自动画质 | 根据网速自动切换 | KSPlayer |
| 码率显示 | 当前码率监控 | KSPlayer |

### 2.4 播放列表功能（P1）- 必须完成

| 功能 | 说明 | 实现方式 |
|------|------|---------|
| 创建播放列表 | 新建空列表 | PlaylistService |
| 删除播放列表 | 删除已有列表 | PlaylistService |
| 添加视频 | 拖放或选择添加 | PlaylistService |
| 移除视频 | 从列表删除 | PlaylistService |
| 拖拽排序 | 调整视频顺序 | SwiftUI DragGesture |
| 播放列表持久化 | JSON 保存/加载 | PlaylistService |
| 播放历史 | 记录播放记录 | HistoryService |

### 2.5 网络功能（P2）- 必须完成

| 功能 | 说明 | 实现方式 |
|------|------|---------|
| HTTP/HTTPS | 网络视频 URL | KSPlayer |
| RTMP | 直播流支持 | KSPlayer |
| 本地文件 | 拖放/选择打开 | FileService |
| URL 解析 | 智能识别协议 | URLParser |

### 2.6 快捷键功能（P2）- 必须完成

| 按键 | 功能 |
|------|------|
| 空格 | 播放/暂停 |
| ← / → | 快退/快退 15 秒 |
| ↑ / ↓ | 音量 +/- 5% |
| F | 全屏切换 |
| M | 静音切换 |
| , / . | 上一帧/下一帧 |
| 0-9 | 跳转 0%-90% 进度 |
| [ / ] | 减速/加速播放 (0.75x ↔ 1.5x) |
| \ | 重置播放速度 (1x) |
| Q | 退出播放 |
| Cmd+N | 新建窗口 |
| Cmd+W | 关闭窗口 |

### 2.7 多窗口功能（P2）- 必须完成

| 功能 | 说明 | 实现方式 |
|------|------|---------|
| 新建窗口 | Cmd+N 或菜单 | SwiftUI WindowGroup |
| 关闭窗口 | Cmd+W 或按钮 | SwiftUI |
| 窗口切换 | Mission Control | macOS 原生 |
| 独立播放 | 每个窗口独立播放器 | SwiftUI |

### 2.8 用户体验功能（P2）- 必须完成

| 功能 | 说明 | 实现方式 |
|------|------|---------|
| 首次启动引导 | 功能介绍 + 快捷键提示 | OnboardingView |
| 进度记忆 | 自动保存播放位置 | UserDefaults |
| 记住音量 | 上次音量设置 | UserDefaults |
| 播放模式 | 单曲/循环/随机 | PlaybackMode |

---

### 3.3 控制栏布局（完整版）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ ⏮ 15 │ ⏯ │ 15⏭ │ 🔊 │ ⏱ 00:00 / 01:23:45 │ [1. CC0x] │ │ ⚙️ │ ⛶          │
│       │    │      │                                              │     │    │
│       │    │      │                                              │     │    └─ 全屏
│       │    │      │                                              │     └─ 设置
│       │    │      │                                              └─ 字幕开关
│       │    │      └─ 音量
│       │    └─ 快进 15秒
│       └─ 快退 15秒
└─────────────────────────────────────────────────────────────────────────────┘
```

**控制栏按钮说明**：

| 位置 | 按钮 | 功能 | 状态 |
|------|------|------|------|
| 左 | ⏮ 15 | 快退 15 秒 | 已有 |
| 左 | ⏯ | 播放/暂停 | 已有 |
| 左 | 15⏭ | 快进 15 秒 | 已有 |
| 左 | 🔊 | 音量滑块 | 已有 |
| 中 | ⏱ | 进度条 + 时间显示 | 已有 |
| 右 | [1.0x] | 倍速选择菜单 | **新增** |
| 右 | CC | 字幕开关/选择 | **新增** |
| 右 | ⚙️ | 设置菜单（画质/比例/旋转） | 已有 |
| 右 | ⛶ | 全屏切换 | 已有 |

**新增按钮功能**：

1. **倍速 [1.0x]**：
   - 下拉菜单：0.5x / 0.75x / 1.0x / 1.25x / 1.5x / 2.0x
   - 快捷键：`[` 减速，`]` 加速，`\` 重置

2. **字幕 CC**：
   - 开关：显示/隐藏字幕
   - 下拉菜单：选择字幕轨道
   - 快捷键：`C` 切换

3. **画质切换**（在设置菜单 ⚙️）：
   - 下拉菜单：Auto / 1080p / 720p / 480p
   - 显示当前码率

---

## 四、项目结构

```
Vly/
├── Sources/
│   ├── App/
│   │   ├── VlyApp.swift           # 应用入口
│   │   └── ContentView.swift      # 主内容视图
│   ├── Models/
│   │   ├── Video.swift            # 视频模型
│   │   ├── Playlist.swift         # 播放列表模型
│   │   └── PlaybackState.swift    # 播放状态模型
│   ├── Services/
│   │   ├── PlayerService.swift    # 播放器服务
│   │   ├── PlaylistService.swift  # 播放列表服务
│   │   ├── HistoryService.swift   # 播放历史服务
│   │   ├── FileService.swift      # 文件服务
│   │   ├── SettingsService.swift  # 设置服务
│   │   └── SubtitleService.swift  # 字幕服务
│   ├── Views/
│   │   ├── Player/
│   │   │   ├── KSVideoPlayerView.swift    # KSPlayer 播放器视图
│   │   │   ├── PlayerControlsView.swift   # 控制栏视图
│   │   │   └── PlaylistView.swift         # 播放列表视图
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift         # 设置页面
│   │   │   └── KeyboardShortcutsView.swift # 快捷键设置
│   │   └── Onboarding/
│   │       └── OnboardingView.swift       # 引导页面
│   └── Extensions/
│       └── Color+Extensions.swift          # 颜色扩展
├── Resources/
│   ├── Assets.xcassets/
│   └── Sounds/
├── docs/
│   ├── 01-Architecture/
│   ├── 02-Requirements/
│   ├── 03-UI-UX/
│   ├── 04-Data-Models/
│   ├── 05-Services/
│   └── 06-Research/
├── project.yml
└── Package.swift (可选)
```

---

## 五、完整实施步骤

### 阶段 1：环境清理（15 分钟）

| 步骤 | 命令 | 说明 |
|------|------|------|
| 1.1 | `rm Cartfile` | 删除 Carthage 配置 |
| 1.2 | `rm Cartfile.resolved` | 删除锁定文件 |
| 1.3 | `rm -rf Carthage/` | 删除依赖目录 |
| 1.4 | `rm project.yml` | 删除旧配置 |
| 1.5 | `rm -rf Vly.xcodeproj/` | 删除旧项目 |

**结果**：只保留 `Package.swift`（如果有）

---

### 阶段 2：修复配置（15 分钟）

**创建 `project.yml`**：包含 KSPlayer 完整配置

**生成项目**：
```bash
cd /Users/yanglin/.openclaw/workspace/Vly
rm -rf Vly.xcodeproj/
xcodegen generate
```

---

### 阶段 3：创建数据模型（30 分钟）

#### 3.1 创建目录
```bash
mkdir -p /Users/yanglin/.openclaw/workspace/Vly/Sources/Models/
mkdir -p /Users/yanglin/.openclaw/workspace/Vly/Sources/Services/
mkdir -p /Users/yanglin/.openclaw/workspace/Vly/Sources/Views/Player/
mkdir -p /Users/yanglin/.openclaw/workspace/Vly/Sources/Views/Settings/
mkdir -p /Users/yanglin/.openclaw/workspace/Vly/Sources/Views/Onboarding/
mkdir -p /Users/yanglin/.openclaw/workspace/Vly/Sources/Extensions/
```

#### 3.2 创建的模型文件

| 文件 | 内容 |
|------|------|
| `Video.swift` | 视频模型（包含 VideoFormat, VideoResolution, VideoSource） |
| `Playlist.swift` | 播放列表模型（包含 CRUD + 持久化） |
| `PlaybackState.swift` | 播放状态模型（PlaybackState, PlaybackMode, VideoQuality, SubtitleTrack, SubtitleStyle） |
| `HistoryEntry.swift` | 历史记录 + 快捷键配置 |

---

### 阶段 4：创建服务层（1.5 小时）

#### 4.1 创建的服务文件

| 文件 | 功能 |
|------|------|
| `PlayerService.swift` | 播放器核心控制（KSPlayer 封装） |
| `PlaylistService.swift` | 播放列表管理（CRUD + 持久化） |
| `HistoryService.swift` | 播放历史记录 |
| `FileService.swift` | 文件扫描和导入 |
| `SettingsService.swift` | 用户设置管理 |
| `ShortcutService.swift` | 快捷键管理 |

---

### 阶段 5：创建视图层（1.5 小时）

#### 5.1 创建的视图文件

| 文件 | 功能 |
|------|------|
| `KSVideoPlayerView.swift` | KSPlayer 播放器主视图 |
| `PlayerControlsView.swift` | 控制栏（播放/暂停/进度/音量） |
| `PlaylistView.swift` | 播放列表侧边栏 |
| `SettingsView.swift` | 设置页面 |
| `KeyboardShortcutsView.swift` | 快捷键设置页面 |
| `OnboardingView.swift` | 首次启动引导页 |
| `ContentView.swift` | 主内容视图（集成所有组件） |
| `VlyApp.swift` | 应用入口（多窗口支持） |

---

### 阶段 6：实现快捷键（30 分钟）

- 在 `VlyApp.swift` 中注册全局快捷键
- 使用 `NSApplication.keyEvents` 监听
- 实现所有快捷键动作

---

### 阶段 7：实现多窗口（30 分钟）

- 使用 `WindowGroup` 实现多窗口
- 每个窗口独立播放
- 支持 Mission Control

---

### 阶段 8：实现引导教程（30 分钟）

- 首次启动检测
- 功能介绍页面
- 快捷键提示

---

### 阶段 9：编译测试（30 分钟）

| 测试项 | 预期结果 |
|--------|---------|
| Xcode 项目编译 | ✅ 通过，无警告 |
| MP4 播放 | ✅ 正常播放 |
| MKV/AVI 播放 | ✅ FFmpeg 解码 |
| 4K 播放 | ✅ 流畅 |
| HDR 播放 | ✅ 色彩正常 |
| 字幕加载 | ✅ 内嵌/外挂正常 |
| 画质切换 | ✅ 分辨率切换正常 |
| 播放列表 | ✅ CRUD 正常 |
| 快捷键 | ✅ 所有快捷键生效 |
| 多窗口 | ✅ 独立播放 |

---

## 六、时间安排（总计 5-6 小时）

| 阶段 | 时间 |
|------|------|
| 阶段 1：环境清理 | 15 分钟 |
| 阶段 2：修复配置 | 15 分钟 |
| 阶段 3：创建模型 | 30 分钟 |
| 阶段 4：创建服务 | 1.5 小时 |
| 阶段 5：创建视图 | 1.5 小时 |
| 阶段 6：快捷键 | 30 分钟 |
| 阶段 7：多窗口 | 30 分钟 |
| 阶段 8：引导教程 | 30 分钟 |
| 阶段 9：编译测试 | 30 分钟 |
| **总计** | **5-6 小时** |

---

## 七、文件变更清单

### 7.1 新建文件

| 文件 | 路径 |
|------|------|
| `Video.swift` | `Sources/Models/Video.swift` |
| `Playlist.swift` | `Sources/Models/Playlist.swift` |
| `PlaybackState.swift` | `Sources/Models/PlaybackState.swift` |
| `HistoryEntry.swift` | `Sources/Models/HistoryEntry.swift` |
| `PlayerService.swift` | `Sources/Services/PlayerService.swift` |
| `PlaylistService.swift` | `Sources/Services/PlaylistService.swift` |
| `HistoryService.swift` | `Sources/Services/HistoryService.swift` |
| `FileService.swift` | `Sources/Services/FileService.swift` |
| `SettingsService.swift` | `Sources/Services/SettingsService.swift` |
| `ShortcutService.swift` | `Sources/Services/ShortcutService.swift` |
| `KSVideoPlayerView.swift` | `Sources/Views/Player/KSVideoPlayerView.swift` |
| `PlayerControlsView.swift` | `Sources/Views/Player/PlayerControlsView.swift` |
| `PlaylistView.swift` | `Sources/Views/Player/PlaylistView.swift` |
| `SettingsView.swift` | `Sources/Views/Settings/SettingsView.swift` |
| `KeyboardShortcutsView.swift` | `Sources/Views/Settings/KeyboardShortcutsView.swift` |
| `OnboardingView.swift` | `Sources/Views/Onboarding/OnboardingView.swift` |

### 7.2 修改文件

| 文件 | 改动 |
|------|------|
| `project.yml` | 添加 KSPlayer 依赖 |
| `VlyApp.swift` | 多窗口 + 快捷键支持 |
| `ContentView.swift` | 集成 KSPlayer + 服务 |

### 7.3 删除文件

| 文件 | 说明 |
|------|------|
| `Cartfile` | Carthage 配置 |
| `Cartfile.resolved` | 锁定文件 |
| `Carthage/` | 依赖目录 |
| `Sources/Views/Player/VlyVideoPlayerView.swift` | AVPlayer 旧实现 |

---

## 八、验收标准

| 标准 | 说明 |
|------|------|
| KSPlayer 集成 | Xcode 项目包含 KSPlayer 依赖 |
| FFmpeg 激活 | 能播放 MKV/AVI 等格式 |
| 4K/HDR 支持 | 能流畅播放 4K HDR 视频 |
| 字幕功能 | 支持内嵌/外挂字幕 |
| 画质切换 | 支持多分辨率切换 |
| 播放列表 | 完整 CRUD + 持久化 |
| 播放历史 | 记录 + 查看 |
| 快捷键 | 全部快捷键生效 |
| 多窗口 | 独立播放 |
| 引导教程 | 首次启动体验 |
| 代码规范 | 遵循 Google Swift Style Guide |
| UI 设计 | 参考 IINA，深色主题 |
| 文档更新 | README.md 已更新 |

---

## 九、相关文档

| 文档 | 说明 |
|------|------|
| `docs/02-Requirements/FEATURES.md` | 功能需求 |
| `docs/04-Data-Models/MODELS.md` | 数据模型设计 |
| `docs/05- Services/SERVICES.md` | 服务层设计 |
| `docs/06-Research/KSPLAYER_AND_IINA_REFERENCE.md` | KSPlayer + IINA 参考 |
| `KSPlayer GitHub` | https://github.com/kingslay/KSPlayer |
| `IINA GitHub` | https://github.com/iina/iina |

---

**文档版本**: 3.0  
**最后更新**: 2026-02-07  
**作者**: Nex ✨
