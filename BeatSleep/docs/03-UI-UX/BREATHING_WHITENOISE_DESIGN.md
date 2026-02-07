# 呼吸法与白噪音设计文档

> 版本: 1.0.0  
> 更新日期: 2026-02-06  
> 状态: 设计完成，待开发

---

## 1. 4-7-8 呼吸法

### 1.1 设计理念
用户闭眼跟随语音引导，无需看屏幕。TTS 实时播报，动画作为可选视觉辅助。

### 1.2 音频设计

| 阶段 | 内容 | 时长 | 语音 | 背景音 |
|------|------|------|------|--------|
| 准备 | "准备开始 4-7-8 呼吸法" | 3秒 | ✅ | 🔇 |
| 吸气 | "吸气... 1... 2... 3... 4" | 4秒 | ✅ | 🔇 |
| 屏息 | "屏息... 5... 6... 7" | 3秒 | ✅ | 🔇 |
| 呼气 | "呼气... 1... 2... 3... 4... 5... 6... 7... 8" | 8秒 | ✅ | 🔇 |
| 循环 | 重复 4 次 | - | ✅ | 🔇 |
| 结束 | "练习完成，祝你晚安" | 2秒 | ✅ | 🔇 |

**总时长**: 约 68 秒（1次准备 + 4次循环 + 结束）

### 1.3 视觉设计（可选）

```
┌─────────────────────────┐
│                         │
│      ◉ 圆形动画          │
│                         │
│      吸气 → 扩大         │
│      屏息 → 保持         │
│      呼气 → 缩小         │
│                         │
│      ⏱️  0:68           │
│      🔄  循环 1/4       │
│                         │
└─────────────────────────┘
```

### 1.4 技术实现

- **语音**: `AVSpeechSynthesizer` 实时合成
- **计时**: `Timer` 同步各阶段
- **动画**: `CABasicAnimation` 呼吸圆
- **状态管理**: `@StateObject private var player`

---

## 2. 2-1-6 呼吸法

### 2.1 设计理念
同 4-7-8，适用于无法完成 4-7-8 的用户（入门级）。

### 2.2 音频设计

| 阶段 | 内容 | 时长 |
|------|------|------|
| 准备 | "准备开始 2-1-6 呼吸法" | 3秒 |
| 吸气 | "吸气... 1... 2" | 2秒 |
| 屏息 | "屏息... 1" | 1秒 |
| 呼气 | "呼气... 1... 2... 3... 4... 5... 6" | 6秒 |
| 循环 | 重复 4 次 | - |
| 结束 | "练习完成，祝你晚安" | 2秒 |

**总时长**: 约 48 秒

### 2.3 视觉设计
同 4-7-8

### 2.4 技术实现
同 4-7-8，复用 `BreathingPlayer` 类

---

## 3. 白噪音

### 3.1 功能概述
独立的背景音功能，帮助掩盖环境噪音，提升睡眠环境质量。

### 3.2 声音类型

| # | 声音 | 文件名 | 颜色 | 图标 |
|---|------|--------|------|------|
| 1 | 雨声 | `rain.mp3` | #3B82F6 | ☁️ |
| 2 | 海浪 | `ocean.mp3` | #06B6D4 | 🌊 |
| 3 | 风声 | `wind.mp3` | #14B8A6 | 💨 |
| 4 | 壁炉 | `fire.mp3` | #F97316 | 🔥 |
| 5 | 森林 | `forest.mp3` | #22C55E | 🌲 |
| 6 | 河流 | `river.mp3` | #3B82F6 | 💧 |

### 3.3 资源位置
```
Resources/sounds/
├── rain.mp3
├── ocean.mp3
├── wind.mp3
├── fire.mp3
├── forest.mp3
└── river.mp3
```

### 3.4 使用流程

#### 入口页面
```
┌─────────────────────────────────────────┐
│           🌧️  白噪音                     │
│                                         │
│   柔和的雨声，掩盖突发噪音                │
│                                         │
├─────────────────────────────────────────┤
│   🔊 选择声音                            │
│   ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐│
│   │ 🌧 │ │ 🌊 │ │ 💨 │ │ 🔥 │ │ 🌲 │ │ 💧││
│   └───┘ └───┘ └───┘ └───┘ └───┘ └───┘│
│                                         │
├─────────────────────────────────────────┤
│   🕐 时长                    [5 分钟 >] │
│                                         │
├─────────────────────────────────────────┤
│         [ ▶️ 播放 5:00 ]               │
│                                         │
└─────────────────────────────────────────┘
```

#### 播放页面
```
┌─────────────────────────────────────────┐
│           🌧️  雨声                     │
│                                         │
│            🎵 波形动画                  │
│                                         │
│              4:32                       │
│                                         │
│   正在播放：雨声                       │
│                                         │
├─────────────────────────────────────────┤
│   ┌─────────────────────────────────┐ │
│   │ ▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░│ │
│   │          5:00                   │ │
│   └─────────────────────────────────┘ │
│                                         │
│         [ ⏸️ 暂停 ]  [ ⏹️ 停止 ]       │
│                                         │
└─────────────────────────────────────────┘
```

### 3.5 技术实现

#### WhiteNoisePlayer.swift
```swift
class WhiteNoisePlayer: ObservableObject {
    static let shared = WhiteNoisePlayer()
    
    @Published var isPlaying = false
    @Published var currentSoundType: WhiteNoiseType?
    @Published var currentVolume: Double = 0.5
    
    func play(type: WhiteNoiseType, volume: Double = 0.8)
    func stop()
    func setVolume(_ volume: Double)
}
```

#### WhiteNoiseType 枚举
```swift
enum WhiteNoiseType: String, CaseIterable, Identifiable {
    case rain, ocean, wind, fire, forest, river
    var icon: String
    var displayName: String
    var accentColor: String
}
```

#### 资源引用
```swift
Bundle.main.url(forResource: type.rawValue, withExtension: "mp3", subdirectory: "sounds")
```

### 3.6 时长选项

| 页面 | 可选时长 |
|------|---------|
| 入口页面 | 5 / 10 / 15 / 30 / 60 分钟 |
| 播放页面 | 倒计时显示，结束后自动停止 |

### 3.7 状态持久化

| 键 | 类型 | 说明 |
|---|------|------|
| `selectedSoundType` | String | 最后选择的声音 |
| `whiteNoiseVolume` | Double | 最后音量 (0.0-1.0) |

---

## 4. 渐进式肌肉放松

### 4.1 音频设计

| 文件 | 状态 | 位置 |
|------|------|------|
| `progressive_en.mp3` | ✅ 已就位 | `Resources/audio/` |
| `progressive_cn.mp3` | ⏳ 待生成 | - |

**播放逻辑：**
1. 用户选择是否开启背景音（6种白噪音可选）
2. 播放引导语
3. 引导语结束后继续播放背景音至定时结束

### 4.2 资源位置
```
Resources/audio/
├── progressive_en.mp3   ✅
└── progressive_cn.mp3   ⏳
```

### 4.3 实现依赖
- 复用 `WhiteNoisePlayer` 背景音
- 新建 `TherapyPlayer` 管理引导语 + 背景音混合

---

## 5. 身体扫描

### 5.1 音频设计

| 文件 | 状态 | 位置 |
|------|------|------|
| `bodyscan_en.mp3` | ✅ 已就位 | `Resources/audio/` |
| `bodyscan_cn.mp3` | ⏳ 待生成 | - |

### 5.2 资源位置
```
Resources/audio/
├── bodyscan_en.mp3   ✅
└── bodyscan_cn.mp3   ⏳
```

### 5.3 实现依赖
同渐进式肌肉放松

---

## 6. 技术架构

### 6.1 文件结构
```
Sources/
├── Services/
│   ├── WhiteNoisePlayer.swift    # 白噪音播放
│   └── BreathingPlayer.swift     # 呼吸法播放（TTS）
├── Models/
│   └── WhiteNoiseType.swift      # 声音类型枚举
└── Views/
    ├── WhiteNoisePlayerPage.swift    # 白噪音播放页面
    └── BreathingSessionView.swift     # 呼吸法页面
```

### 6.2 音频会话配置
```swift
AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
```

---

## 7. 待办事项

| 功能 | 状态 | 说明 |
|------|------|------|
| 4-7-8 TTS 语音 | 待开发 | `BreathingPlayer` + `AVSpeechSynthesizer` |
| 2-1-6 TTS 语音 | 待开发 | 复用 `BreathingPlayer` |
| 呼吸法动画 | 待开发 | 圆形呼吸动画 |
| 渐进式引导语 | 待配音 | 需要专业配音 |
| 身体扫描引导语 | 待配音 | 需要专业配音 |

---

*最后更新: 2026-02-06*
