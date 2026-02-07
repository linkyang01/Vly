# 睡眠科学研究

> 最后更新: 2026-02-05

## 睡眠阶段

### 1. 浅睡眠 (N1)
- 持续时间: 1-5 分钟
- 特征: 入睡过渡期，容易醒来
- 占总睡眠: ~5%

### 2. 中睡眠 (N2)
- 持续时间: 10-25 分钟
- 特征: 心率减慢，体温下降
- 占总睡眠: ~45%

### 3. 深睡眠 (N3)
- 持续时间: 20-40 分钟
- 特征: 身体修复，生长激素分泌
- 占总睡眠: ~25%

### 4. REM 睡眠
- 持续时间: 5-30 分钟
- 特征: 梦境，脑电活跃
- 占总睡眠: ~25%

## 睡眠周期

- 典型周期: 90-110 分钟
- 每晚循环: 4-6 次
- 深睡眠前多后少，REM 前少后多

## 智能唤醒原理

### 最佳唤醒时间
- 在浅睡眠阶段唤醒最自然
- 深睡眠被唤醒会感到疲倦
- 建议在完整周期后醒来

### 算法思路
```swift
func calculateOptimalWakeTime(targetTime: Date) -> Date {
    let cycleDuration: TimeInterval = 90 * 60  // 90分钟
    let searchWindow: TimeInterval = 30 * 60   // 30分钟窗口
    
    // 向前搜索找到浅睡眠窗口
    for i in 0..<6 {
        let checkTime = targetTime.addingTimeInterval(-Double(i) * cycleDuration)
        if isWithinShallowSleepWindow(checkTime) {
            return checkTime
        }
    }
    
    return targetTime
}
```

## 助眠声音原理

### 白噪声
- 均匀覆盖所有频率
- 屏蔽环境噪音
- 帮助大脑放松

### 自然声音
- 熟悉的安抚性声音
- 触发放松反应
- 掩盖突发噪音

## 推荐设置

### 入睡前
- 提前 30 分钟使用助眠声音
- 音量 30-50%
- 选择熟悉的声音

### 闹钟
- 渐强音量 30% → 100%
- 渐强震动配合
- 智能唤醒模式开启
