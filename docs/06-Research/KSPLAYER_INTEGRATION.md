# KSPlayer 集成研究

> 版本: 1.0
> 更新日期: 2026-02-06

## 1. 概述

本文档记录 KSPlayer 框架的集成研究和实践经验。

## 2. KSPlayer 简介

### 2.1 项目信息

| 项目 | 值 |
|------|------|
| GitHub | https://github.com/kingslay/KSPlayer |
| Stars | 1,458 |
| License | GPL / LGPL |
| Platform | iOS / macOS / tvOS / visionOS |
| 技术栈 | AVPlayer + FFmpeg |

### 2.2 功能特性

| 功能 | GPL | LGPL |
|------|-----|------|
| 4K/HDR/Dolby Vision | ✅ | ✅ |
| 画中画 (PiP) | ✅ | ✅ |
| 硬件加速 | ✅ | ✅ |
| 字幕支持 | ✅ | ✅ |
| Dolby AC-4 | ❌ | ✅ |
| Swift Concurrency | ❌ | ✅ |
| AV1 硬件解码 | ❌ | ✅ |
| 8K / 120FPS | ❌ | ✅ |

## 3. 集成方式

### 3.1 Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/kingslay/KSPlayer.git", branch: "main")
]
```

### 3.2 CocoaPods

```ruby
# Podfile
target 'Vly' do
  use_frameworks!
  pod 'KSPlayer', :git => 'https://github.com/kingslay/KSPlayer.git', :branch => 'main'
end
```

## 4. API 使用指南

### 4.1 基础播放

```swift
import KSPlayer

// 初始化
let playerView = IOSVideoPlayerView()
view.addSubview(playerView)

// 设置视频
playerView.set(url: URL(string: "http://example.com/video.mp4")!)

// 播放控制
playerView.play()
playerView.pause()
playerView.seek(time: 30)
```

### 4.2 状态监听

```swift
// Delegate
playerView.delegate = self

extension PlayerDelegate {
    func playerController(state: KSPlayerState) {
        switch state {
        case .playing:
            print("正在播放")
        case .paused:
            print("已暂停")
        case .finished:
            print("播放完成")
        default:
            break
        }
    }
    
    func playerController(currentTime: TimeInterval, totalTime: TimeInterval) {
        print("当前: \(currentTime) / 总: \(totalTime)")
    }
}
```

### 4.3 画质切换

```swift
let hd = KSPlayerResourceDefinition(
    url: URL(string: "http://example.com/hd.mp4")!,
    definition: "1080P"
)

let sd = KSPlayerResourceDefinition(
    url: URL(string: "http://example.com/sd.mp4")!,
    definition: "720P"
)

let resource = KSPlayerResource(
    name: "视频标题",
    definitions: [hd, sd]
)

playerView.set(resource: resource)
```

### 4.4 字幕

```swift
playerView.set(resource: KSPlayerResource(
    url: url,
    subtitleURL: URL(string: "http://example.com/subtitle.srt")
))
```

## 5. 封装设计

### 5.1 适配器模式

```swift
import Foundation

/// 播放器协议 - 便于替换实现
protocol VideoPlayerProtocol {
    var state: PlaybackState { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    
    func load(url: URL)
    func play()
    func pause()
    func seek(to time: TimeInterval)
}

/// KSPlayer 适配器
final class KSPlayerAdapter: VideoPlayerProtocol {
    private let playerView: IOSVideoPlayerView
    private var stateRelay = BehaviorRelay<PlaybackState>(value: .idle)
    
    var state: PlaybackState { stateRelay.value }
    var currentTime: TimeInterval { playerView.currentTime }
    var duration: TimeInterval { playerView.totalTime }
    
    init() {
        self.playerView = IOSVideoPlayerView()
    }
    
    func load(url: URL) {
        playerView.set(url: url)
        stateRelay.accept(.loading)
    }
    
    func play() {
        playerView.play()
    }
    
    func pause() {
        playerView.pause()
    }
    
    func seek(to time: TimeInterval) {
        playerView.seek(time: time)
    }
}
```

### 5.2 工厂模式

```swift
/// 播放器工厂
enum VideoPlayerFactory {
    static func create() -> VideoPlayerProtocol {
        #if USE_NATIVE_PLAYER
        return NativeAVPlayerAdapter()
        #else
        return KSPlayerAdapter()
        #endif
    }
}
```

## 6. 常见问题

### 6.1 Q: 如何处理视频加载失败？

```swift
playerView.backBlock = { [weak self] in
    if case .failed(let error) = self?.state {
        print("加载失败: \(error)")
        // 显示错误提示
        self?.showError(error)
    }
}
```

### 6.2 Q: 如何获取缓冲进度？

```swift
func playerController(bufferedCount: Int, consumeTime: TimeInterval) {
    // bufferedCount: 0 表示首次加载
    // consumeTime: 缓冲耗时
}
```

### 6.3 Q: 如何切换字幕轨道？

```swift
// 轨道选择
override func player(layer: KSPlayerLayer, state: KSPlayerState) {
    if state == .readyToPlay {
        let tracks = layer.player?.tracks(mediaType: .subtitle)
        // 选择轨道
        layer.player?.select(track: tracks?.first)
    }
}
```

## 7. 性能优化

### 7.1 缓存配置

```swift
let options = KSOptions()
options.cache = true
options.preferredForwardBufferDuration = 5.0
options.maxBufferDuration = 30.0
```

### 7.2 硬件解码

```swift
options.hardwareDecode = true
```

## 8. License 注意事项

### 8.1 GPL 版本

- ✅ 免费使用
- ❌ 必须开源整个项目
- ✅ 可以修改代码

### 8.2 LGPL 版本

- 💰 需要付费购买
- ✅ 可以闭源商用
- ✅ 更多高级功能

## 9. 相关链接

- KSPlayer GitHub: https://github.com/kingslay/KSPlayer
- KSPlayer 文档: https://github.com/kingslay/KSPlayer/blob/main/README.md
- App Store 示例: https://apps.apple.com/app/tracyplayer/id6450770064
