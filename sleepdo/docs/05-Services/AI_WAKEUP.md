# SleepDo AI 智能唤醒设计

> 重构日期: 2026-02-05

## 概述

利用 Apple Watch 收集的生理数据，在用户浅睡眠期间触发唤醒，实现自然醒来。

## Apple Watch 数据收集

### 可用数据源

| 数据 | API | 采样频率 | 用途 |
|------|-----|---------|------|
| 心率 | HKQuantityTypeIdentifierHeartRate | 每秒 | HRV计算 |
| 心率变异性 | HKQuantityTypeIdentifierHeartRateVariabilitySDNN | 每分钟 | 睡眠阶段判断 |
| 血氧 | HKQuantityTypeIdentifierBloodOxygenSaturation | 每分钟 | 睡眠质量 |
| 皮肤温度 | HKQuantityTypeIdentifierAppleSleepModeWristTemperature | 每5分钟 | 睡眠周期 |
| 运动 | CMMotionManager | 实时 | 活动检测 |

### Watch App 实现

```swift
class WatchSleepMonitor: ObservableObject {
    private var healthKitManager: HKHealthStore?
    private var motionManager: CMMotionManager?
    
    @Published var currentHRV: Double = 0
    @Published var isInLightSleep: Bool = false
    @Published var wakeupRecommended: Bool = false
    
    // 开始监测
    func startMonitoring() {
        // 1. 启动心率监测
        startHeartRateMonitoring()
        
        // 2. 启动运动监测
        startMotionMonitoring()
        
        // 3. 启动HRV分析
        startHRVAnalysis()
    }
    
    // 心率监测
    private func startHeartRateMonitoring() {
        let query = HKAnchoredObjectQuery(
            type: HKQuantityType.quantityType(
                forIdentifier: .heartRate)!
        ) { query, samples, deletedObjects, anchor, error in
            self.processHeartRate(samples)
        }
        
        query.updateHandler = { query, samples, deletedObjects, anchor, error in
            self.processHeartRate(samples)
        }
        
        healthKitManager?.execute(query)
    }
}
```

## 浅睡检测算法

### 核心原理

睡眠阶段与 HRV（心率变异性）的关系：

| 睡眠阶段 | HRV 特征 | 运动特征 |
|---------|---------|---------|
| 清醒 | 低 HRV，高波动 | 高活动 |
| 浅睡眠 | HRV 上升 ↑ | 低活动 |
| 深睡眠 | 最高 HRV | 无活动 |
| REM | 低 HRV | 突发活动 |

### 算法实现

```python
def analyze_sleep_stage(hrv_samples, motion_samples, time_since_sleep):
    """
    输入: 
      hrv_samples: 最近10分钟的HRV数据
      motion_samples: 最近10分钟的运动数据
      time_since_sleep: 入睡后经过的时间(分钟)
    
    输出: 睡眠阶段和唤醒推荐
    """
    
    # 1. 计算HRV趋势
    hrv_trend = calculate_trend(hrv_samples)  # 上升/平稳/下降
    hrv_baseline = average(hrv_samples[-30:])  # 30分钟基线
    
    # 2. 计算运动强度
    motion_intensity = max(motion_samples)
    
    # 3. 睡眠周期判断
    cycle_number = int(time_since_sleep / 90)  # 90分钟一个周期
    cycle_position = time_since_sleep % 90     # 周期内位置
    
    # 4. 综合判断
    if motion_intensity > MOTION_THRESHOLD:
        return "awake", 0.0
    
    if hrv_trend == "rising" and hrv_trend > hrv_baseline * 1.1:
        if 30 <= cycle_position <= 60:  # 周期中后段
            return "light_sleep", 0.9  # 唤醒推荐
        else:
            return "light_sleep", 0.3  # 继续睡
    
    if hrv_trend == "high_stable" and motion_intensity == 0:
        return "deep_sleep", 0.0  # 不要唤醒
    
    if hrv_trend == "variable":
        return "rem_sleep", 0.1   # 谨慎唤醒
    
    return "unknown", 0.0
```

### 唤醒窗口计算

```python
def calculate_wake_window(target_wake_time, sleep_quality_data):
    """
    在目标起床时间前30分钟窗口内找到浅睡眠时机
    """
    window_start = target_wake_time - 30 * 60  # 30分钟前
    
    # 在窗口内搜索最佳时机
    for minute_offset in range(30):
        check_time = window_start + minute_offset * 60
        sleep_stage, confidence = predict_stage_at(check_time)
        
        if sleep_stage == "light_sleep" and confidence > 0.7:
            return {
                "wake_time": check_time,
                "confidence": confidence,
                "method": "AI智能检测"
            }
    
    # 没找到理想时机，在目标时间唤醒
    return {
        "wake_time": target_wake_time,
        "confidence": 0.5,
        "method": "时间唤醒"
    }
```

## iOS 端实现

### SleepTracker 服务

```swift
class SleepTracker: ObservableObject {
    @Published var currentSleepStage: SleepStageType = .unknown
    @Published var wakeupRecommended: Bool = false
    @Published var recommendedWakeTime: Date?
    
    private var watchConnector: WatchConnectivityManager
    private var analysisTimer: Timer?
    
    // MARK: - 接收 Watch 数据
    
    func receiveWatchData(_ data: [String: Any]) {
        guard let hrv = data["hrv"] as? Double,
              let motion = data["motion"] as? Double else { return }
        
        analyzeSleepStage(hrv: hrv, motion: motion)
    }
    
    // MARK: - 睡眠分析
    
    private func analyzeSleepStage(hrv: Double, motion: Double) {
        let hrvTrend = calculateHRVTrend(recentHRVData)
        let motionLevel = classifyMotion(motion)
        
        // 判断睡眠阶段
        currentSleepStage = determineStage(hrvTrend, motionLevel)
        
        // 检查是否应该唤醒
        if shouldWakeUser() {
            wakeupRecommended = true
            NotificationManager.shared.sendWakeNotification()
        }
    }
    
    // MARK: - 唤醒窗口
    
    func calculateOptimalWakeWindow(targetTime: Date) -> WakeWindow {
        let calendar = Calendar.current
        let windowStart = calendar.date(byAdding: .minute, value: -30, to: targetTime)!
        
        // 搜索最佳唤醒时机
        for minuteOffset in 0..<30 {
            let checkTime = calendar.date(byAdding: .minute, value: minuteOffset, to: windowStart)!
            let stage = predictStage(at: checkTime)
            
            if stage == .lightSleep {
                return WakeWindow(
                    time: checkTime,
                    confidence: 0.85,
                    method: "AI智能检测"
                )
            }
        }
        
        return WakeWindow(
            time: targetTime,
            confidence: 0.5,
            method: "时间唤醒"
        )
    }
}
```

## 用户体验设计

### 唤醒流程

```
1. 用户设置起床时间 7:00
2. 系统计算最佳唤醒窗口
3. 在浅睡眠期间触发唤醒
4. 渐强音量 + 渐强震动
5. 显示"你在浅睡眠中醒来，精神更好"
```

### 渐强唤醒效果

```swift
class WakeUpEngine {
    func startGradualWakeup(type: WakeUpType) {
        switch type {
        case .audio:
            startGradualVolume()
        case .haptic:
            startGradualHaptic()
        case .both:
            startGradualVolume()
            startGradualHaptic()
        }
    }
    
    private func startGradualVolume() {
        let steps = 10
        let stepDuration: TimeInterval = 5  // 每5秒增加
        
        for i in 1...steps {
            let volume = 0.3 + (Double(i) / Double(steps)) * 0.7
            delay(Double(i) * stepDuration) {
                AudioPlayer.setVolume(volume)
            }
        }
    }
    
    private func startGradualHaptic() {
        let intervals: [TimeInterval] = [0, 5, 10, 15, 20, 25, 30]
        for (index, delay) in intervals.enumerated() {
            delay(Double(delay)) {
                let intensity = Double(index) / Double(intervals.count - 1)
                WKInterfaceDevice.current().play(
                    .notification, 
                    delay: 0, 
                    withIntensity: intensity
                )
            }
        }
    }
}
```

## 数据模型

```swift
struct LightSleepWindow {
    let startTime: Date
    let confidence: Double  // 0-1
    let method: String      // "AI智能检测" 或 "时间唤醒"
}

struct WakeWindow {
    let time: Date
    let confidence: Double
    let method: String
}

enum WakeUpType {
    case audio
    case haptic
    case both
}
```

## 效果评估

### 评估指标
- 用户主观清醒感评分 (1-5)
- 唤醒后30分钟内的疲劳感
- 对比固定时间唤醒的改善

### A/B 测试
```swift
// 分组: A组 = 智能唤醒, B组 = 固定时间
// 测量: 清醒时间、主观评分、再次入睡率
```
