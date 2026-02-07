# 混音器设计

> 最后更新: 2026-02-05

## 功能概述

混音器允许用户同时播放多个声音，并独立控制每个声音的音量。

## 数据模型

```swift
struct SoundMixer: Identifiable, Codable {
    let id: UUID
    var name: String
    var sounds: [MixerSound]
    var createdAt: Date
    var isPreset: Bool
}

struct MixerSound: Identifiable, Codable {
    let id: UUID
    let soundId: String
    var volume: Double  // 0.0 - 1.0
    var isPlaying: Bool
}
```

## 功能特性

### 播放控制
- [x] 独立音量滑块
- [x] 单个声音开关
- [x] 全部播放/暂停
- [x] 停止全部

### 声音管理
- [x] 添加声音
- [x] 移除声音
- [x] 调整顺序
- [x] 音量预设

### 预设功能
- [x] 保存当前混音为预设
- [x] 加载预设
- [x] 编辑预设
- [x] 删除预设

## UI 设计

### 主界面
```
┌─────────────────────────────────┐
│ 🎵 混音器                       │
├─────────────────────────────────┤
│ 正在播放                        │
│ ┌─────────────────────────────┐ │
│ │ 🌧️ 雨夜    [━━━│━━━━] 70%  │ │
│ │ 🌊 海浪    [━━│━━━━━] 40%  │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ [添加声音]    [保存为预设]      │
├─────────────────────────────────┤
│ 预设                             │
│ ┌─────────────────────────────┐ │
│ │ 🌧️ 雨天午后  [▶] [✏️] [🗑️] │ │
│ │ 🌊 森林露营  [▶] [✏️] [🗑️] │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

## 技术实现

### 音频混音
```swift
class AudioMixerEngine {
    var channels: [AudioChannel]
    
    func setVolume(channelId: String, volume: Double) {
        // 更新指定通道音量
    }
    
    func playAll() {
        // 播放所有通道
    }
    
    func stopAll() {
        // 停止所有通道
    }
}
```

### 预设管理
```swift
class PresetManager {
    func save(_ mixer: SoundMixer) {
        // 保存到 UserDefaults 或文件
    }
    
    func load(_ presetId: String) -> SoundMixer? {
        // 从存储加载预设
    }
    
    func delete(_ presetId: String) {
        // 删除预设
    }
}
```

## 预设列表

### 默认预设
| 名称 | 声音组合 |
|------|---------|
| 雨天午后 | 雨夜 70% + 海浪 40% |
| 森林露营 | 森林雨 60% + 河流 50% |
| 海浪涛声 | 海浪 80% + 白噪声 30% |
| 壁炉温暖 | 壁炉 70% + 雨声 40% |

### 创建预设
用户可以创建最多 20 个自定义预设。
