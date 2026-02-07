# SleepDo 声音库设计

> 重构日期: 2026-02-05

## 设计理念

**声音数量精简，质量优先。**
- 核心：15个经过科学验证的助眠声音
- 特点：每个声音都有明确的功能定位
- 策略：少而精，通过混音创造变化

## 声音分类

| 类别 | 数量 | 功能定位 |
|------|------|---------|
| 自然 | 6 | 白噪声掩盖、环境音放松 |
| 白噪声 | 3 | 屏蔽环境突变噪音 |
| 环境 | 4 | 熟悉感触发放松反应 |
| 冥想 | 2 | 引导专注、降低心率 |

## 声音列表

### 自然声音 (6个)
| ID | 名称 | 图标 | 功能 | 是否Premium |
|------|------|------|------|------------|
| rain | 雨夜 | cloud.rain.fill | 最经典助眠声 | ❌ |
| forest_rain | 森林雨 | leaf.fill | 层次感雨声 | ❌ |
| ocean | 海浪 | water.waves.fill | 节律性放松 | ❌ |
| thunder | 雷雨 | cloud.bolt.fill | 深度放松 | ✅ |
| waterfall | 瀑布 | waterfall.fill | 自然白噪音 | ✅ |
| wind | 微风 | wind | 轻柔背景 | ✅ |

### 白噪声 (3个)
| ID | 名称 | 图标 | 功能 | 是否Premium |
|------|------|------|------|------------|
| white_noise | 白噪声 | circle.hexagongrid.fill | 基础遮噪 | ❌ |
| pink_noise | 粉红噪声 | circle.fill | 柔和遮噪 | ❌ |
| brown_noise | 布朗噪声 | waveform | 深度遮噪 | ❌ |

### 环境声音 (4个)
| ID | 名称 | 图标 | 功能 | 是否Premium |
|------|------|------|------|------------|
| fireplace | 壁炉 | flame.fill | 温暖安全感 | ❌ |
| cafe | 咖啡厅 | cup.and.saucer.fill | 熟悉白噪音 | ✅ |
| library | 图书馆 | book.fill | 安静氛围 | ✅ |
| train | 火车 | tram.fill | 节律性催眠 | ✅ |

### 冥想声音 (2个)
| ID | 名称 | 图标 | 功能 | 是否Premium |
|------|------|------|------|------------|
| singing_bowl | 颂钵 | sparkles | 心率引导 | ✅ |
| om | OM唱诵 | waveform.path.ecg | 深度放松 | ✅ |

## 解锁策略

### 默认解锁 (10个)
所有用户可用：
- rain, forest_rain, ocean
- white_noise, pink_noise, brown_noise
- fireplace

### 成就解锁 (5个)
通过睡眠成就解锁：
- thunder, waterfall, wind, cafe, library

### 会员解锁 (全部)
终身会员/订阅用户可用全部

## 声音推荐算法

```swift
class SoundRecommender {
    func recommend(for user: UserProfile, 
                   context: SleepContext) -> [String] {
        // 输入: 用户历史偏好 + 当前场景
        // 输出: 推荐声音ID列表
        
        let history = getUserHistory(user.id)
        let preferred = history.mostPlayedSounds()
        
        if context.isBedtime {
            return preferred.take(3)
        } else if context.usingBreathing {
            return ["white_noise", "singing_bowl"]
        }
        
        return preferred
    }
}
```

## 播放功能

### 基础功能
- 单个声音播放
- 混音播放（最多4个同时）
- 独立音量控制
- 渐强/渐弱

### 定时功能
- 定时关闭（15/30/45/60分钟）
- 定时播放（唤醒）

### 渐变效果
```swift
func fadeIn(soundId: String, duration: TimeInterval) {
    let steps = 20
    let stepDuration = duration / Double(steps)
    
    for i in 1...steps {
        let volume = Double(i) / Double(steps)
        delay(Double(i) * stepDuration) {
            setVolume(soundId: soundId, volume: volume)
        }
    }
}
```
