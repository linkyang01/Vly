# 成就系统设计

> 最后更新: 2026-02-05

## 成就分类

### 睡眠成就 (8个)
- 早睡早起、充足睡眠、深度睡眠、睡眠记录员
- 优质睡眠、数据分析、睡眠专家、完美睡眠

### 连续成就 (10个)
- 开始坚持、渐入佳境、一周达人
- 两周坚持、习惯养成、月度挑战
- 百日坚持、全年无休、早起鸟、早睡达人

### 闹钟成就 (7个)
- 第一次闹钟、准时起床、一周准时
- 自然醒、智能睡眠、延后挑战、彻底告别

### 里程碑成就 (10个)
- 新手入门、渐入佳境、成就达人、成就大师
- 睡眠探索、混音大师、分享达人、反馈专家
- 终身会员、两周年

## 数据模型

### Achievement
```swift
struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let targetValue: Int
    let isLifetime: Bool
}
```

### AchievementProgress
```swift
struct AchievementProgress: Identifiable, Codable {
    let id: String
    var currentValue: Int
    var isUnlocked: Bool
    var unlockedAt: Date?
}
```

## 触发机制

### 自动触发
- 睡眠数据记录后检查
- 使用天数统计
- 闹钟响应统计

### 手动触发
- 成就解锁通知
- 成就展示页面

## 奖励机制

### 成就奖励
- 成就徽章展示
- 解锁 Premium 声音
- 积分奖励

### 终身会员专属
- 终身会员成就
- 所有 Premium 资源访问
