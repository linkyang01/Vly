# HealthKit 集成设计

> 最后更新: 2026-02-05

## 概述

通过 HealthKit 读取和存储睡眠数据。

## 数据类型

### 读取权限
| 类型 | 用途 |
|------|------|
| HKQuantityTypeIdentifier.sleepDuration | 睡眠时长 |
| HKCategoryTypeIdentifier.sleepAnalysis | 睡眠分析 |
| HKQuantityTypeIdentifier.heartRate | 心率 |

### 写入权限
| 类型 | 用途 |
|------|------|
| HKCategoryTypeIdentifier.sleepAnalysis | 存储睡眠数据 |

## 服务设计

```swift
class HealthKitService {
    static let shared = HealthKitService()
    
    // 请求权限
    func requestAuthorization() async -> Bool
    
    // 获取睡眠数据
    func fetchSleepData(from startDate: Date, to endDate: Date) async -> [SleepData]
    
    // 获取心率数据
    func fetchHeartRate(from startDate: Date, to endDate: Date) async -> [HeartRateSample]
    
    // 保存睡眠数据
    func saveSleepData(_ sleepData: SleepData) async throws
    
    // 获取今日睡眠时长
    func getTodaySleepDuration() async -> TimeInterval
}
```

## 睡眠数据映射

### HealthKit → App Model
```swift
func mapToSleepData(_ sample: HKSample) -> SleepData? {
    guard let categorySample = sample as? HKCategorySample else { return nil }
    
    return SleepData(
        date: categorySample.startDate,
        sleepStartTime: categorySample.startDate,
        sleepEndTime: categorySample.endDate,
        // ...
    )
}
```

## 数据同步

### 同步策略
- App 启动时同步最近 30 天数据
- 后台定期同步新数据
- 用户手动刷新

### 数据刷新
```swift
// 下拉刷新
func refreshData() async {
    let endDate = Date()
    let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!
    sleepData = await fetchSleepData(from: startDate, to: endDate)
}
```

## 权限请求

### 请求 UI
```
┌─────────────────────────────────┐
│ 健康数据访问                    │
├─────────────────────────────────┤
│ 木木眠 需要访问以下数据：        │
│                                 │
│ ✅ 睡眠数据                     │
│    读取和记录您的睡眠信息        │
│                                 │
│ ✅ 心率                         │
│    辅助浅睡唤醒算法              │
│                                 │
│ [取消]         [允许访问]       │
└─────────────────────────────────┘
```

## 错误处理

| 错误 | 处理 |
|------|------|
| 权限被拒绝 | 显示引导用户去设置中开启 |
| 网络错误 | 重试机制 |
| 数据为空 | 显示暂无数据 |
