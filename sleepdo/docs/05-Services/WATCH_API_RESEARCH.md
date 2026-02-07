# Apple Watch API 和算法技术调研

> 调研日期: 2026-02-05
> 目标: 实现浅睡唤醒功能

---

## 一、Apple Watch 可收集的健康数据

### 1. 心率 (Heart Rate)

```swift
// 数据类型
let heartRateType = HKQuantityType.quantityType(
    forIdentifier: .heartRate)!

// 采样频率
// - 日常: 每5分钟
// - 运动: 每1秒
// - 睡眠期间: 每分钟

// 获取数据
let query = HKSampleQuery(
    sampleType: heartRateType,
    predicate: predicate,
    limit: HKObjectQueryNoLimit,
    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
) { query, samples, error in
    guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
    for sample in heartRateSamples {
        let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        print("心率: \(bpm) BPM")
    }
}
```

### 2. 心率变异性 (HRV)

```swift
// 数据类型 - SDNN (Standard Deviation of NN intervals)
let hrvType = HKQuantityType.quantityType(
    forIdentifier: .heartRateVariabilitySDNN)!

// HRV 是浅睡检测的关键指标
// - 清醒时: HRV 较低
// - 浅睡眠时: HRV 开始上升
// - 深睡眠时: HRV 最高

// 获取最近HRV数据
let hrvQuery = HKSampleQuery(
    sampleType: hrvType,
    predicate: predicate,
    limit: 60,  // 最近60个样本
    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
) { query, samples, error in
    guard let hrvSamples = samples as? [HKQuantitySample] else { return }
    let hrvValues = hrvSamples.map { sample in
        sample.quantity.doubleValue(for: .secondUnit(with: .milli()))
    }
    analyzeHRVTrend(hrvValues)
}
```

### 3. 血氧 (Blood Oxygen)

```swift
let bloodOxygenType = HKQuantityType.quantityType(
    forIdentifier: .bloodOxygenSaturation)!

// 睡眠期间血氧会自然下降
// - 正常范围: 95-100%
// - 睡眠期间: 94-98%
// - 低于90% 需要注意
```

### 4. 皮肤温度

```swift
// iOS 17+ 新增
let wristTemperatureType = HKQuantityType.quantityType(
    forIdentifier: .appleSleepModeWristTemperature)!

// 体温变化与睡眠周期相关
// - 睡前体温下降
// - 睡眠期间最低
// - 醒来前开始回升
```

### 5. 运动数据

```swift
import CoreMotion

let motionManager = CMMotionManager()
motionManager.accelerometerUpdateInterval = 1.0  // 1秒采样

motionManager.startAccelerometerUpdates(to: .mainQueue()) { data, error in
    guard let acceleration = data?.acceleration else { return }
    
    // 计算运动强度
    let motionIntensity = sqrt(
        pow(acceleration.x, 2) + 
        pow(acceleration.y, 2) + 
        pow(acceleration.z, 2)
    )
    
    // 运动强度 > 0.5 可能表示清醒
}
```

---

## 二、浅睡检测算法

### 核心原理

睡眠阶段与生理指标的关系：

| 睡眠阶段 | HRV | 心率 | 运动 | 呼吸 |
|---------|-----|------|-----|------|
| 清醒 | 低 | 高 | 多 | 快 |
| 浅睡眠 | ↑上升 | ↓下降 | 少 | 慢 |
| 深睡眠 | 最高 | 最低 | 无 | 非常慢 |
| REM | 低波动 | 中等 | 突发 | 不规律 |

### 算法实现 (Swift)

```swift
class SleepStageAnalyzer {
    
    // MARK: - HRV 分析
    
    func analyzeHRVTrend(_ hrvValues: [Double]) -> HRVTrend {
        guard hrvValues.count >= 10 else { return .insufficientData }
        
        // 最近5个值的平均值
        let recent = hrvValues.prefix(5).reduce(0, +) / 5
        
        // 较早5个值的平均值
        let earlier = hrvValues.suffix(5).reduce(0, +) / 5
        
        // 计算趋势
        let change = (recent - earlier) / earlier
        
        if change > 0.15 {
            return .rising  // HRV上升，可能进入浅睡
        } else if change < -0.15 {
            return .falling  // HRV下降，可能进入深睡
        } else {
            return .stable
        }
    }
    
    // MARK: - 运动分析
    
    func analyzeMotion(_ motionValues: [Double]) -> MotionLevel {
        let avg = motionValues.reduce(0, +) / Double(motionValues.count)
        
        if avg < 0.1 {
            return .none  // 无运动，深睡可能
        } else if avg < 0.3 {
            return .low   // 低运动，浅睡可能
        } else {
            return .high  // 高运动，清醒可能
        }
    }
    
    // MARK: - 综合判断
    
    func determineSleepStage(
        hrvTrend: HRVTrend,
        motionLevel: MotionLevel,
        timeInBed: TimeInterval  // 入睡后经过时间
    ) -> SleepStage {
        
        // 睡眠周期计算 (约90分钟一个周期)
        let cycleNumber = Int(timeInBed / 5400)  // 90分钟 = 5400秒
        let cyclePosition = timeInBed.truncatingRemainder(dividingBy: 5400)
        
        // 综合判断
        if motionLevel == .high {
            return .awake
        }
        
        if motionLevel == .low && hrvTrend == .rising {
            // 低运动 + HRV上升 = 浅睡眠窗口
            if cyclePosition > 1800 && cyclePosition < 3600 {  // 30-60分钟在一个周期内
                return .lightSleepWindow  // 最佳唤醒时机
            }
            return .lightSleep
        }
        
        if motionLevel == .none && hrvTrend == .stable {
            return .deepSleep
        }
        
        if hrvTrend == .falling {
            return .deepSleep
        }
        
        return .unknown
    }
}

// MARK: - 类型定义

enum HRVTrend {
    case rising      // HRV上升
    case falling     // HRV下降
    case stable      // 稳定
    case insufficientData
}

enum MotionLevel {
    case none        // 无运动
    case low         // 低运动
    case high        // 高运动
}

enum SleepStage {
    case awake
    case lightSleep
    case lightSleepWindow  // 最佳唤醒时机
    case deepSleep
    case rem
    case unknown
}
```

### Python 算法原型（便于理解）

```python
import numpy as np
from typing import List, Tuple

def detect_light_sleep_window(
    hrv_samples: List[float],
    motion_samples: List[float],
    time_since_bed: float
) -> Tuple[str, float]:
    """
    检测是否处于浅睡眠窗口
    
    Args:
        hrv_samples: 最近10分钟的HRV数据 (每分钟1个)
        motion_samples: 最近10分钟的运动强度数据
        time_since_bed: 入睡后经过的秒数
    
    Returns:
        (睡眠阶段, 置信度)
    """
    
    # 1. HRV 趋势分析
    hrv_trend = calculate_hrv_trend(hrv_samples)
    
    # 2. 运动强度分析
    motion_level = calculate_motion_level(motion_samples)
    
    # 3. 睡眠周期位置
    cycle_position = time_since_bed % 5400  # 90分钟周期
    
    # 4. 综合判断逻辑
    if motion_level > 0.3:
        return "awake", 0.95
    
    if motion_level < 0.1 and hrv_trend == "rising":
        if 1800 < cycle_position < 3600:  # 周期30-60分钟位置
            return "light_sleep_window", 0.85  # 最佳唤醒时机
        return "light_sleep", 0.70
    
    if motion_level == 0 and hrv_trend in ["stable", "falling"]:
        return "deep_sleep", 0.80
    
    return "unknown", 0.0


def calculate_hrv_trend(hrv_samples: List[float]) -> str:
    """计算HRV趋势"""
    if len(hrv_samples) < 10:
        return "unknown"
    
    recent = np.mean(hrv_samples[-5:])   # 最近5分钟
    earlier = np.mean(hrv_samples[:5])   # 较早5分钟
    
    change = (recent - earlier) / earlier
    
    if change > 0.15:
        return "rising"
    elif change < -0.15:
        return "falling"
    else:
        return "stable"


def calculate_motion_level(motion_samples: List[float]) -> float:
    """计算平均运动强度 (0-1)"""
    if not motion_samples:
        return 0.0
    return np.mean(motion_samples)


def calculate_wake_window(
    target_wake_time: float,
    sleep_quality_data: dict
) -> dict:
    """
    计算最佳唤醒窗口
    
    策略: 在目标时间前30分钟窗口内搜索浅睡眠时机
    """
    window_start = target_wake_time - 1800  # 30分钟前
    
    # 简化实现: 返回目标时间
    # 实际应该结合历史数据预测
    
    return {
        "wake_time": target_wake_time,
        "confidence": 0.7,
        "method": "time_based",
        "note": "需要更多睡眠数据来优化唤醒时机"
    }
```

---

## 三、iOS 端实现架构

### Watch App 端

```swift
class WatchSleepMonitor: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    @Published var currentHRV: Double = 0
    @Published var currentMotion: Double = 0
    @Published var isMonitoring: Bool = false
    
    // MARK: - 权限请求
    
    func requestPermissions() async -> Bool {
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
                continuation.resume(returning: success)
            }
        }
    }
    
    // MARK: - 启动监测
    
    func startMonitoring() {
        isMonitoring = true
        
        // 启动HRV监测
        startHRVMonitoring()
        
        // 启动运动监测
        startMotionMonitoring()
        
        // 启动数据发送定时器
        startDataTransmission()
    }
    
    // MARK: - HRV 监测
    
    private func startHRVMonitoring() {
        let query = HKAnchoredObjectQuery(
            type: HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ) { query, samples, deletedObjects, anchor, error in
            self.processHRVSamples(samples)
        }
        
        query.updateHandler = { query, samples, deletedObjects, anchor, error in
            self.processHRVSamples(samples)
        }
        
        healthStore.execute(query)
    }
    
    private func processHRVSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample], let last = samples.last else { return }
        
        let hrv = last.quantity.doubleValue(for: .secondUnit(with: .milli()))
        DispatchQueue.main.async {
            self.currentHRV = hrv
        }
        
        // 发送到 iPhone
        sendToPhone(hrv: hrv, motion: currentMotion)
    }
    
    // MARK: - 运动监测
    
    private func startMotionMonitoring() {
        let manager = CMMotionManager()
        manager.accelerometerUpdateInterval = 60  // 每分钟采样
        
        manager.startAccelerometerUpdates(to: .mainQueue()) { [weak self] data, error in
            guard let data = data, let self = self else { return }
            
            let intensity = sqrt(
                pow(data.acceleration.x, 2) +
                pow(data.acceleration.y, 2) +
                pow(data.acceleration.z, 2)
            )
            
            DispatchQueue.main.async {
                self.currentMotion = intensity
            }
        }
    }
    
    // MARK: - 数据传输
    
    private func sendToPhone(hrv: Double, motion: Double) {
        let message: [String: Any] = [
            "type": "sleepData",
            "hrv": hrv,
            "motion": motion,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        WCSession.default.sendMessage(
            message,
            replyHandler: nil,
            errorHandler: { error in
                print("发送失败: \(error)")
            }
        )
    }
    
    // MARK: - 停止监测
    
    func stopMonitoring() {
        isMonitoring = false
        healthStore.stop(query: hrvQuery)
    }
}
```

### iOS 端数据接收

```swift
class WatchDataManager: NSObject, WCSessionDelegate {
    private let sleepTracker = SleepTracker()
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard message["type"] as? String == "sleepData" else { return }
        
        guard let hrv = message["hrv"] as? Double,
              let motion = message["motion"] as? Double else { return }
        
        // 交给 SleepTracker 分析
        sleepTracker.analyzeWatchData(hrv: hrv, motion: motion)
    }
}
```

---

## 四、唤醒触发逻辑

```swift
class WakeUpEngine {
    private var isArmed: Bool = false
    private var targetWakeTime: Date?
    private var analysisTimer: Timer?
    
    // 设定唤醒目标
    func setWakeTarget(_ time: Date) {
        targetWakeTime = time
        isArmed = true
        
        // 在目标时间前30分钟开始监测
        let monitorStart = time.addingTimeInterval(-30 * 60)
        let delay = monitorStart.timeIntervalSinceNow
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.startWakeMonitoring()
        }
    }
    
    // 开始唤醒监测
    private func startWakeMonitoring() {
        guard isArmed else { return }
        
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkForWakeWindow()
        }
    }
    
    // 检查是否在浅睡眠窗口
    private func checkForWakeWindow() {
        let stage = sleepTracker.currentStage
        let timeUntilWake = targetWakeTime!.timeIntervalSinceNow
        
        // 条件1: 在唤醒窗口内（目标时间前30分钟）
        guard timeUntilWake <= 30 * 60 && timeUntilWake > 0 else {
            // 超过窗口，直接唤醒
            triggerWakeUp(method: .timeBased)
            return
        }
        
        // 条件2: 处于浅睡眠窗口
        if stage == .lightSleepWindow {
            triggerWakeUp(method: .aiBased)
        }
    }
    
    // 触发唤醒
    private func triggerWakeUp(method: WakeUpMethod) {
        isArmed = false
        analysisTimer?.invalidate()
        
        // 渐强唤醒
        startGradualWakeUp()
        
        // 发送通知
        NotificationManager.shared.sendWakeNotification(
            method: method,
            sleepQuality: sleepTracker.lastSleepQuality
        )
    }
    
    // 渐强唤醒
    private func startGradualWakeUp() {
        // 音量渐强
        AudioPlayer.fadeIn(duration: 30)  // 30秒渐强
        
        // 震动渐强
        HapticEngine.gradualPulse(duration: 30)
    }
}

// MARK: - 类型

enum WakeUpMethod {
    case aiBased    // AI检测到浅睡
    case timeBased  // 时间到
}
```

---

## 五、所需权限配置

### Info.plist (Watch App)

```xml
<key>NSHealthShareUsageDescription</key>
<string>SleepDo 需要访问心率数据来检测您的睡眠阶段，并在最佳时机唤醒您。</string>

<key>NSHealthUpdateUsageDescription</key>
<string>SleepDo 需要保存睡眠数据以提供睡眠分析报告。</string>
```

### entitlements

```xml
<key>com.apple.developer.healthkit</key>
<true/>
<key>com.apple.developer.healthkit.access</key>
<array/>
```

---

## 六、总结

### 可行性评估

| 能力 | Apple Watch 支持 | SleepDo 实现 |
|------|-----------------|-------------|
| 心率采集 | ✅ 原生支持 | 简单 |
| HRV采集 | ✅ 原生支持 | 简单 |
| 运动检测 | ✅ 原生支持 | 简单 |
| 浅睡算法 | ✅ 基于数据 | 中等复杂度 |
| 渐强唤醒 | ✅ 原生支持 | 简单 |

### 实现优先级

| 阶段 | 功能 | 工作量 |
|------|------|--------|
| Phase 1 | 基础数据采集 | 3天 |
| Phase 2 | HRV趋势分析 | 5天 |
| Phase 3 | 浅睡检测算法 | 7天 |
| Phase 4 | 渐强唤醒 | 3天 |

### 注意事项

1. **隐私合规** - 需要明确获取用户同意
2. **电量考虑** - 高频采样影响续航
3. **算法优化** - 需要用户数据持续改进
4. **兼容性** - 不同表款传感器精度不同
