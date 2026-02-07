# 声音库详细设计

> 最后更新: 2026-02-05

## 数据模型

### Sound 模型
```swift
struct Sound: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let category: SoundCategory
    let description: String
    let isPremium: Bool
    let unlockAchievementId: String?
}
```

### SoundCategory 枚举
```swift
enum SoundCategory: String, Codable, CaseIterable {
    case natural = "自然"
    case ambient = "环境"
    case whiteNoise = "白噪声"
    case meditation = "冥想"
    case music = "音乐"
    case urban = "城市"
    case other = "其他"
}
```

## 声音管理

### 解锁状态
- 默认解锁: 所有非 Premium 声音
- 成就解锁: Premium 声音通过成就解锁
- 购买解锁: 终身会员解锁全部

### 播放控制
- 单个声音播放
- 混音播放（多个声音混合）
- 音量独立控制
- 定时关闭

## 音频引擎

### 支持格式
- MP3
- AAC
- WAV
- CAF

### 播放功能
- 循环播放
- 音量渐变
- 交叉淡入淡出
