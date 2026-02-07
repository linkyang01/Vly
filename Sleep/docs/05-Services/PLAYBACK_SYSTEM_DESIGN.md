# 播放系统设计

> 版本: 1.0  
> 更新日期: 2026-02-06  
> 状态: 设计完成

---

## 问题背景

5个助眠方法的播放模式不同：
- 呼吸法使用 TTS 实时语音合成
- 疗法使用预录制的音频文件
- 白噪音使用背景音循环播放

**核心**：3矛盾种播放模式如何统一管理？

---

## 设计目标

1. **统一入口** - 所有播放通过 GlobalPlayer 一个入口
2. **模式清晰** - 2 种播放模式，覆盖所有场景
3. **状态可观测** - 暂停/继续/停止统一控制
4. **易于扩展** - 新增方法只需选择模式

---

## 播放模式定义

### 模式 1：呼吸法（VoiceGuide）
| 方法 | 语音 | 背景音 | 技术 |
|------|------|--------|------|
| 4-7-8 呼吸 | TTS 实时合成 | 无 | AVSpeechSynthesizer |
| 2-1-6 呼吸 | TTS 实时合成 | 无 | AVSpeechSynthesizer |

### 模式 2：音频播放（AudioPlayback）
| 方法 | 语音 | 背景音 | 技术 |
|------|------|--------|------|
| 渐进式肌肉放松 | 预录 mp3 | 可选白噪音 | AVAudioPlayer |
| 身体扫描 | 预录 mp3 | 可选白噪音 | AVAudioPlayer |
| 白噪音 | 无 | 单声音/混音 | AVAudioPlayer |

---

## 统一接口设计

### PlaybackMode 枚举

```swift
enum PlaybackMode {
    case breathing(method: BreathingTechnique)   // 呼吸法：TTS
    case guidedAudio(type: TherapyType)          // 疗法：预录音
    case whiteNoise(sound: WhiteNoiseType?)      // 白噪音：背景音
}
```

### PlaybackState 状态

```swift
enum PlaybackState {
    case idle
    case preparing      // 准备中
    case playing        // 播放中
    case paused         // 已暂停
    case completed      // 已完成
}
```

### GlobalPlayer 单例

```swift
class GlobalPlayer: ObservableObject {
    static let shared = GlobalPlayer()
    
    @Published private(set) var state: PlaybackState = .idle
    @Published private(set) var currentMode: PlaybackMode?
    @Published private(set) var timeRemaining: TimeInterval = 0
    @Published private(set) var isExpanded: Bool = false
    
    // 统一控制接口
    func play(_ mode: PlaybackMode, duration: TimeInterval)
    func pause()
    func resume()
    func stop()
    func toggleExpanded()
}
```

---

## 内部实现

### 1. 呼吸法播放器（BreathingPlayer）

```swift
class BreathingPlayer: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentStep: String = ""
    
    func play(technique: BreathingTechnique) {
        // 使用 AVSpeechSynthesizer 实时合成
        speak("准备开始 \(technique.displayName)")
        // ... 循环各步骤
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        synthesizer.speak(utterance)
    }
}
```

### 2. 音频播放器（AudioPlayer）

```swift
class AudioPlayer: NSObject, ObservableObject {
    @Published var isPlaying = false
    
    func play(audioURL: URL, backgroundSound: WhiteNoiseType? = nil, volume: Double = 0.7) {
        // 播放引导语
        guidePlayer.play(url: audioURL)
        
        // 如果有背景音，引导语结束后开始
        if let sound = backgroundSound {
            whiteNoisePlayer.play(sound: sound)
            // 引导语约60秒后，背景音淡入
        }
    }
}
```

---

## 状态流程

```
用户点击方法
     │
     ▼
GlobalPlayer.play(.breathing/.guidedAudio/.whiteNoise)
     │
     ├──► BreathingPlayer ──► TTS 实时语音
     │
     └──► AudioPlayer ──────► 预录音/白噪音
     │
     ▼
PlaybackState.playing
     │
     ├──► pause() ──► PlaybackState.paused
     │
     ├──► resume() ─► PlaybackState.playing
     │
     └──► stop() ───► PlaybackState.idle
```

---

## 文件结构

```
Sources/
├── Services/
│   ├── GlobalPlayer.swift        # 统一播放器入口 ⭐
│   ├── BreathingPlayer.swift     # 呼吸法播放
│   └── AudioPlayer.swift         # 音频播放（复用）
│
├── Models/
│   ├── PlaybackMode.swift        # 播放模式枚举
│   └── PlaybackState.swift       # 播放状态枚举
│
└── Views/
    └── Components/
        └── GlobalPlayerView.swift  # 播放器 UI
```

---

## GlobalPlayerView UI

```
紧凑状态                    展开状态
┌─────────────┐         ┌─────────────────────┐
│ 🌬️ 4-7-8 │         │ 🌬️ 4-7-8 呼吸       │
│ 2:30  🔵   │         │ 2:30 / 3:00          │
└─────────────┘         │ ─────────────────── │
                        │    ⏸️ 暂停   ⏹️ 停止 │
                        └─────────────────────┘
```

---

## 待办

| 任务 | 状态 |
|------|------|
| 创建 PlaybackMode.swift | 待实现 |
| 创建 PlaybackState.swift | 待实现 |
| 重构 GlobalPlayer.swift | 待实现 |
| 创建 BreathingPlayer.swift | 待实现 |
| 创建 AudioPlayer.swift | 待实现 |
| 创建 GlobalPlayerView.swift | 待实现 |
| 集成到各页面 | 待实现 |

---

## 兼容性说明

| 方法 | 原实现 | 新实现 |
|------|--------|--------|
| 4-7-8 呼吸 | 无 | BreathingPlayer |
| 2-1-6 呼吸 | 无 | BreathingPlayer |
| 渐进式肌肉放松 | TherapyPlayer | AudioPlayer |
| 身体扫描 | TherapyPlayer | AudioPlayer |
| 白噪音 | WhiteNoisePlayer | AudioPlayer |

---

*最后更新: 2026-02-06*
