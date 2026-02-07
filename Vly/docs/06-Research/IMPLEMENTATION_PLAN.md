# Vly 完整开发方案

> **版本**: 2.0  
> **更新日期**: 2026-02-07  
> **状态**: KSPlayer 源码分析完成，可以开始

---

## 一、项目概述

### 1.1 目标

开发 Vly - 一个简洁优雅的 macOS/iOS 开源视频播放器。

### 1.2 核心技术

| 技术 | 选型 | 说明 |
|------|------|------|
| **播放器** | **KSPlayer** | SwiftUI 封装完整，源码质量好 |
| **解码** | FFmpeg 6.1 (GPL) | 支持多格式 |
| **最高分辨率** | **4K** | 完全够用 |
| **UI 框架** | SwiftUI | 参考 IINA 设计 |
| **许可证** | GPL 3.0 | 开源项目 |

### 1.3 KSPlayer 源码质量评估

| 指标 | 评分 | 说明 |
|------|------|------|
| 代码结构 | ⭐⭐⭐⭐ | 清晰分层，模块化 |
| 文档完整 | ⭐⭐⭐⭐ | README + Demo 完整 |
| 维护状态 | ⭐⭐⭐⭐ | 最近更新 9 天前 |
| Stars | 1.5k | 活跃项目 |
| Swift 友好 | ⭐⭐⭐⭐ | 原生 Swift API |
| Demo 可运行 | ⭐⭐⭐⭐⭐ | 开箱即用 |

**结论**：KSPlayer 源码质量好，设计清晰，完全符合"代码要好"的要求。

---

## 二、功能清单

### 2.1 MVP 功能（P0）

| 功能 | 说明 | 状态 |
|------|------|------|
| 基础播放 | KSVideoPlayerView 一行代码 | ✅ |
| 快进/快退 | coordinator.skip(interval:) | ✅ |
| 音量控制 | coordinator.playbackVolume | ✅ |
| 静音 | coordinator.isMuted | ✅ |
| 全屏 | .fullScreenCover | ✅ |
| 画中画 | coordinator.playerLayer?.isPipActive | ✅ |

### 2.2 扩展功能（P1）

| 功能 | 说明 | 状态 |
|------|------|------|
| 字幕支持 | KSPlayer 内置 | ✅ |
| 画质切换 | KSPlayer 内置 | ✅ |
| 播放列表 | 自己实现 | ⏳ |
| 拖放打开 | .onDrop modifier | ⏳ |
| 进度记忆 | UserDefaults | ⏳ |

### 2.3 多格式支持

| 格式 | 状态 | 备注 |
|------|------|------|
| MP4 | ✅ | H.264/H.265 |
| MKV | ✅ | 多编码 |
| AVI | ✅ | 多编码 |
| FLV | ✅ | H.264/AAC |
| WebM | ✅ | VP8/VP9 |
| **最高分辨率** | **✅ 4K** | 完全够用 |

---

## 三、UI 设计规范（基于 IINA）

### 3.1 设计原则

| 原则 | 说明 |
|------|------|
| **简洁** | 不做臃肿功能 |
| **优雅** | 现代化 UI，参考 IINA |
| **原生** | 遵循 Apple HIG |
| **流畅** | 平滑动画和交互 |

### 3.2 颜色方案

```swift
// Vly 颜色方案
background: Color.black.opacity(0.95)
controlBar: VisualEffectMaterial.ultraDark
accent: Color.blue
text: Color.white
textSecondary: Color.gray.opacity(0.8)
sliderTrack: Color.gray.opacity(0.5)
sliderThumb: Color.white
hoverBackground: Color.white.opacity(0.1)
```

### 3.3 图标规范

```swift
// 使用 SF Symbols
play: "play.fill"
pause: "pause.fill"
skipBackward: "gobackward.15"
skipForward: "goforward.15"
fullscreen: "arrow.up.left.and.arrow.down.right"
volumeUp: "speaker.wave.2.fill"
volumeDown: "speaker.wave.1.fill"
volumeOff: "speaker.slash.fill"
subtitle: "captions.bubble.fill"
settings: "gear"
playlist: "list.bullet"
pip: "rectangle.on.rectangle"
```

### 3.4 控制栏设计

```swift
// SwiftUI 实现参考
ControlBarView {
    // 播放按钮
    Button(action: togglePlayPause) {
        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
    }
    
    // 进度条
    Slider(value: $progress)
    
    // 时间标签
    Text("\(currentTime) / \(duration)")
        .font(.monospacedDigitSystemFont(size: 12))
    
    // 功能按钮
    Button(action: toggleFullscreen) {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
    }
}
.background(.ultraThinMaterial)
.cornerRadius(10)
```

---

## 四、实施步骤

### 阶段 1：环境清理（15 分钟）

| 步骤 | 命令 | 说明 |
|------|------|------|
| 1.1 | `rm Cartfile` | 删除 Carthage 配置 |
| 1.2 | `rm Cartfile.resolved` | 删除锁定文件 |
| 1.3 | `rm -rf Carthage/` | 删除依赖目录 |
| 1.4 | `rm project.yml` | 删除旧配置 |
| 1.5 | `rm -rf Vly.xcodeproj/` | 删除旧项目 |

**结果**：只保留 `Package.swift`

---

### 阶段 2：修复配置（15 分钟）

**创建 `project.yml`**：
```yaml
name: Vly
options:
  bundleIdPrefix: com.vly
  xcodeVersion: "15.0"

packages:
  KSPlayer:
    url: https://github.com/kingslay/KSPlayer.git
    from: "0.1.0"

targets:
  Vly:
    type: application
    platform: macOS
    deploymentTarget: "12.0"
    sources:
      - path: Sources
      - path: Resources
    dependencies:
      - package: KSPlayer
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.vly.app
        SWIFT_VERSION: "5.9"
```

**生成项目**：
```bash
xcodegen generate
```

**验证**：检查 `Vly.xcodeproj/` 包含 KSPlayer 依赖

---

### 阶段 3：重构代码（2 小时）

#### 3.1 删除旧代码

| 文件 | 操作 |
|------|------|
| `Sources/Views/Player/VideoPlayerView.swift` | 删除 |
| `Sources/App/ContentView.swift` | 重写 |
| 所有 `import AVKit` | 删除 |

#### 3.2 创建 KSPlayer 播放器

**创建 `Sources/Services/KSPlayerManager.swift`**：
```swift
import KSPlayer
import Combine

final class KSPlayerManager: ObservableObject {
    @Published private(set) var player: KSPlayerNode
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var status: PlayerStatus = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        player = KSPlayerNode()
        setupBindings()
    }
    
    private func setupBindings() {
        player.statusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.status = status
            }
            .store(in: &cancellables)
        
        player.playbackPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.isPlaying = isPlaying
            }
            .store(in: &cancellables)
        
        player.timePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                self?.currentTime = time.seconds
            }
            .store(in: &cancellables)
    }
    
    func load(url: URL) {
        let options = KSOptions()
        player.replaceWithItem(url: url, options: options)
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func togglePlayPause() {
        isPlaying ? pause() : play()
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: cmTime)
    }
    
    func skip(interval: TimeInterval) {
        let newTime = max(0, min(duration, currentTime + interval))
        seek(to: newTime)
    }
}
```

**创建 `Sources/Views/Player/KSVideoPlayerView.swift`**：
```swift
import SwiftUI
import KSPlayer

struct KSVideoPlayerView: View {
    let url: URL
    @StateObject private var manager = KSPlayerManager()
    @State private var showingControls = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                // 使用 KSPlayer 的 SwiftUI 封装
                KSVideoPlayer(coordinator: manager.coordinator, url: url, options: KSOptions())
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                if showingControls {
                    FloatingControlBar(playerManager: manager)
                        .transition(.opacity)
                }
            }
            .onTapGesture {
                withAnimation {
                    showingControls.toggle()
                }
            }
            .onAppear {
                manager.load(url: url)
            }
        }
    }
}
```

#### 3.3 重写 ContentView.swift

- 使用 `KSVideoPlayerView` 替代旧 `VideoPlayerView`
- 保留文件选择器逻辑
- 保留控制栏 UI（参考 IINA 设计）

---

### 阶段 4：测试验证（30 分钟）

| 测试项 | 预期结果 |
|--------|---------|
| MP4 播放 | ✅ 正常播放 |
| MKV 播放 | ✅ FFmpeg 解码 |
| AVI 播放 | ✅ FFmpeg 解码 |
| 4K 播放 | ✅ 流畅 |
| 进度条拖动 | ✅ 正常 |
| 播放/暂停 | ✅ 正常 |
| 全屏切换 | ✅ 正常 |
| 画中画 | ✅ 正常 |

---

## 五、文件变更清单

| 文件 | 操作 |
|------|------|
| `Cartfile` | 删除 |
| `Cartfile.resolved` | 删除 |
| `Carthage/` | 删除 |
| `project.yml` | 重写 |
| `Vly.xcodeproj/` | 重新生成 |
| `Sources/Views/Player/VideoPlayerView.swift` | 删除 |
| `Sources/Services/KSPlayerManager.swift` | **新建** |
| `Sources/Views/Player/KSVideoPlayerView.swift` | **新建** |
| `Sources/App/ContentView.swift` | 重写 |

---

## 六、时间安排

| 阶段 | 时间 |
|------|------|
| 第一阶段：清理环境 | 15 分钟 |
| 第二阶段：修复配置 | 15 分钟 |
| 第三阶段：重构代码 | 2 小时 |
| 第四阶段：测试验证 | 30 分钟 |
| **总计** | **3 小时** |

---

## 七、验收标准

| 标准 | 说明 |
|------|------|
| KSPlayer 集成 | Xcode 项目包含 KSPlayer 依赖 |
| FFmpeg 激活 | 能播放 MKV/AVI 等格式 |
| 4K 支持 | 能流畅播放 4K 视频 |
| 代码规范 | 遵循 Google Swift Style Guide |
| UI 设计 | 参考 IINA，深色主题 + 毛玻璃控制栏 |
| 文档更新 | README.md 已更新 |

---

## 八、相关文档

| 文档 | 说明 |
|------|------|
| `docs/02-Requirements/FEATURES.md` | 功能需求 |
| `docs/06-Research/KSPLAYER_AND_IINA_REFERENCE.md` | KSPlayer + IINA 参考 |
| `KSPlayer GitHub` | https://github.com/kingslay/KSPlayer |
| `IINA GitHub` | https://github.com/iina/iina |

---

**文档版本**: 2.0  
**最后更新**: 2026-02-07  
**作者**: Nex ✨
