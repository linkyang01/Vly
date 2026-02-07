# 音频引擎设计

> 最后更新: 2026-02-05

## 概述

音频引擎负责声音的播放、混音和音量控制。

## 架构

```
┌─────────────────────────────────────┐
│          AudioEngineController       │
├─────────────────────────────────────┤
│                                      │
│  ┌─────────────┐  ┌─────────────┐   │
│  │  Channel 1  │  │  Channel 2  │   │
│  │  (声音A)    │  │  (声音B)    │   │
│  └─────────────┘  └─────────────┘   │
│         │                │           │
│         └───────┬────────┘           │
│                 ▼                    │
│         ┌─────────────┐              │
│         │   Mixer     │              │
│         └─────────────┘              │
│                 │                    │
│                 ▼                    │
│         ┌─────────────┐              │
│         │  Output     │              │
│         │  (播放器)   │              │
│         └─────────────┘              │
└─────────────────────────────────────┘
```

## 功能

### 单个声音播放
```swift
class AudioChannel {
    let soundId: String
    var volume: Double
    var isPlaying: Bool
    
    func play()
    func pause()
    func stop()
    func setVolume(_ volume: Double)
}
```

### 混音功能
```swift
class AudioMixer {
    var channels: [AudioChannel]
    
    func addChannel(soundId: String)
    func removeChannel(soundId: String)
    func setChannelVolume(soundId: String, volume: Double)
    func playAll()
    func pauseAll()
    func stopAll()
}
```

### 渐变效果
```swift
// 音量渐变
func fadeVolume(to target: Double, duration: TimeInterval) {
    let steps = 10
    let stepDuration = duration / Double(steps)
    let stepChange = (target - currentVolume) / Double(steps)
    
    for i in 1...steps {
        delay(Double(i) * stepDuration) {
            setVolume(currentVolume + stepChange * Double(i))
        }
    }
}
```

## 支持格式

| 格式 | 支持 | 说明 |
|------|------|------|
| MP3 | ✅ | 主要格式 |
| AAC | ✅ | 支持 |
| WAV | ✅ | 支持 |
| CAF | ✅ | iOS 原生 |

## 播放模式

### 循环播放
```swift
enum PlaybackMode {
    case single      // 播放一次
    case loop        // 循环播放
    case shuffle     // 随机播放列表
}
```

### 定时关闭
```swift
func scheduleStop(after duration: TimeInterval) {
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
        self?.pauseAll()
    }
}
```

## 性能优化

### 资源管理
- 懒加载音频文件
- 复用 AudioChannel
- 及时释放内存

### 内存优化
```swift
// 限制同时播放的声音数量
let maxSimultaneousSounds = 4

// 预加载下一个声音
func preloadNextSound(_ soundId: String) {
    // 预加载到内存
}
```

## 错误处理

| 错误 | 处理 |
|------|------|
| 文件不存在 | 使用默认声音 |
| 解码失败 | 跳过该声音 |
| 播放中断 | 自动恢复 |
| 内存不足 | 释放非必要资源 |
