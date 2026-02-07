# BeatSleep 声音设计方案

> 版本: 1.0.0  
> 更新日期: 2026-02-06  
> 状态: 正式发布

---

## 声音系统概览

| 类型 | 文件 | 用途 | 优先级 |
|------|------|------|--------|
| **语音引导** | voice_english.mp3 | 英文呼吸指令 | P0 |
| **语音引导** | voice_chinese.mp3 | 中文测试版 | P1 |
| **背景音** | rain.mp3 | 默认背景 | P0 |
| **背景音** | ocean.mp3 | 替代选择 | P0 |
| **背景音** | white_noise.mp3 | 遮噪 | P0 |
| **背景音** | forest.mp3 | 放松 | P1 |
| **背景音** | wind.mp3 | 轻柔 | P1 |
| **提示音** | complete.mp3 | 完成提示 | P0 |
| **提示音** | click.mp3 | 按钮点击 | P1 |

---

## 语音脚本

### 4-7-8 呼吸英文脚本

```text
[00:00] "Welcome to the 4-7-8 breathing exercise."
[00:04] "This technique, developed by Dr. Andrew Weil, can help you relax and fall asleep."
[00:12] "Let's begin. Get comfortable and close your eyes."
[00:18] "Now, breathe in slowly through your nose."
[00:22] "In... two... three... four."
[00:27] "Now hold your breath."
[00:29] "Hold... two... three... four... five... six... seven."
[00:37] "Now exhale slowly through your mouth."
[00:41] "Out... two... three... four... five... six... seven... eight."
[00:50] "Let's do that again."
[01:00] "Breathe in."
[01:04] "...two... three... four."
[01:08] "Hold."
[01:10] "...two... three... four... five... six... seven."
[01:18] "Breathe out."
[01:21] "...two... three... four... five... six... seven... eight."
[01:30] "One more time."
[01:32] "Breathe in."
[01:36] "...two... three... four."
[01:40] "Hold."
[01:42] "...two... three... four... five... six... seven."
[01:50] "Breathe out."
[01:53] "...two... three... four... five... six... seven... eight."
[02:02] "Well done. You can continue this practice as you fall asleep."
[02:08] "Good night."
```

### 2-1-6 呼吸英文脚本

```text
[00:00] "Welcome to the 2-1-6 breathing exercise."
[00:05] "This is a simpler version, great for beginners."
[00:10] "Breathe in slowly."
[00:13] "In... two."
[00:16] "Hold."
[00:18] "...one."
[00:20] "Breathe out."
[00:23] "...two... three... four... five... six."
[00:30] "Again. Breathe in."
[00:33] "...two."
[00:36] "Hold."
[00:38] "...one."
[00:40] "Breathe out."
[00:43] "...two... three... four... five... six."
[00:50] "One more time."
[00:53] "...two."
[00:56] "...one."
[01:00] "...two... three... four... five... six."
[01:08] "Great job. You're doing well."
```

---

## 背景音规格

### 雨声 (rain.mp3)

| 属性 | 值 |
|------|-----|
| 时长 | 循环，5分钟 |
| 格式 | MP3, 128kbps |
| 采样率 | 44.1kHz |
| 音量 | -20dB |
| 特点 | 温和雨声，节律性 |

### 海浪 (ocean.mp3)

| 属性 | 值 |
|------|-----|
| 时长 | 循环，5分钟 |
| 格式 | MP3, 128kbps |
| 采样率 | 44.1kHz |
| 音量 | -20dB |
| 特点 | 远海浪涛，自然节律 |

### 白噪音 (white_noise.mp3)

| 属性 | 值 |
|------|-----|
| 时长 | 循环，10分钟 |
| 格式 | MP3, 128kbps |
| 采样率 | 44.1kHz |
| 音量 | -30dB |
| 特点 | 纯白噪音，无突变 |

### 森林 (forest.mp3)

| 属性 | 值 |
|------|-----|
| 时长 | 循环，5分钟 |
| 格式 | MP3, 128kbps |
| 采样率 | 44.1kHz |
| 音量 | -20dB |
| 特点 | 鸟鸣+微风 |

### 风声 (wind.mp3)

| 属性 | 值 |
|------|-----|
| 时长 | 循环，5分钟 |
| 格式 | MP3, 128kbps |
| 采样率 | 44.1kHz |
| 音量 | -25dB |
| 特点 | 轻柔风声 |

---

## 声音文件结构

```
Resources/
└── Sounds/
    ├── voice/
    │   ├── english_478.mp3
    │   ├── english_216.mp3
    │   └── chinese_test.mp3
    │
    ├── ambient/
    │   ├── rain.mp3
    │   ├── ocean.mp3
    │   ├── white_noise.mp3
    │   ├── forest.mp3
    │   └── wind.mp3
    │
    └── effects/
        ├── complete.mp3
        └── click.mp3
```

---

## 声音管理器

```swift
enum SoundType: String, CaseIterable {
    case rain
    case ocean
    case whiteNoise
    case forest
    case wind
}

class SoundManager {
    static let shared = SoundManager()
    
    private var players: [String: AVAudioPlayer] = [:]
    
    func playAmbient(_ sound: SoundType) {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3") else { return }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1  // 循环播放
            player.volume = 0.5
            player.play()
            players[sound.rawValue] = player
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    func stopAmbient(_ sound: SoundType) {
        players[sound.rawValue]?.stop()
        players[sound.rawValue] = nil
    }
    
    func stopAll() {
        players.values.forEach { $0.stop() }
        players.removeAll()
    }
    
    func setVolume(_ volume: Float, for sound: SoundType) {
        players[sound.rawValue]?.volume = volume
    }
}
```

---

## 语音配置

```swift
enum VoiceLanguage: String, CaseIterable {
    case english = "en-US"
    case chinese = "zh-CN"
}

struct VoiceConfig {
    let language: VoiceLanguage
    let voice: String
    let rate: Float  // 0.5 - 1.0
    let pitch: Float // 0.5 - 2.0
}

let englishVoice = VoiceConfig(
    language: .english,
    voice: "Samantha",  // iOS 默认女声
    rate: 0.5,          // 较慢，放松
    pitch: 1.0
)

let chineseVoice = VoiceConfig(
    language: .chinese,
    voice: "Tingting",
    rate: 0.5,
    pitch: 1.0
)
```

---

## 声音获取建议

| 声音类型 | 推荐来源 | 成本 |
|---------|---------|------|
| 语音 | iOS AVSpeechSynthesizer (免费) | $0 |
| 背景音 | Freesound.org | 免费 |
| 背景音 | Epidemic Sound | $12/月 |
| 背景音 | 付费音效包 | $20-50 |
| 提示音 | iOS 系统音效 | 免费 |

---

## 相关文档

- [架构设计](../01-Architecture/README.md)
- [UI 规范](UI_SPECIFICATION.md)
- [原型设计](PROTOTYPE.md)
