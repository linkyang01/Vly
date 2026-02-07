# 订阅系统设计

> 最后更新: 2026-02-05

## 订阅方案

| 方案 | 价格 | 说明 |
|------|------|------|
| 终身会员 | $49.99 | 一次购买，终身使用 |
| 年付 | $19.99/年 | 自动续订 |
| 月付 | $3.99/月 | 自动续订 |

## 试用政策

- 新用户 7 天完整功能试用
- 试用期结束后需付费解锁
- 试用期可解锁 34 个成就

## 功能对比

| 功能 | 试用用户 | 终身会员 |
|------|---------|---------|
| 42个声音播放 | ✅ | ✅ |
| 闹钟功能 | ✅ | ✅ |
| 睡眠追踪 | ✅ | ✅ |
| 成就解锁 | 34/35 | 全部35 |
| 奖励资源 | ❌ | ✅ |
| Apple Watch | ✅ | ✅ |
| 导出数据 | ❌ | ✅ |

## 用户状态

```swift
enum SubscriptionStatus {
    case trial(daysRemaining: Int)
    case active(plan: SubscriptionPlan)
    case expired
    
    var canAccessPremium: Bool {
        switch self {
        case .trial: return true
        case .active: return true
        case .expired: return false
        }
    }
}

enum SubscriptionPlan {
    case lifetime
    case yearly
    case monthly
}
```

## 购买流程

### 升级界面
```
┌─────────────────────────────────┐
│ 升级到终身会员                  │
├─────────────────────────────────┤
│                                 │
│ 终身会员                        │
│ $49.99                          │
│ 一次购买 · 永久使用              │
│                                 │
│ ─────────────────────────────   │
│                                 │
│ 年付                             │
│ $19.99/年                        │
│                                 │
│ ─────────────────────────────   │
│                                 │
│ 月付                             │
│ $3.99/月                         │
│                                 │
├─────────────────────────────────┤
│ [7天免费试用 · 然后 $49.99]     │
│                                 │
│ [恢复购买]                       │
└─────────────────────────────────┘
```

## 状态管理

```swift
class SubscriptionManager: ObservableObject {
    @Published var status: SubscriptionStatus = .trial(daysRemaining: 7)
    @Published var isLoading = false
    
    func checkSubscription() async {
        // 检查 StoreKit 状态
    }
    
    func purchaseLifetime() async throws {
        // 发起购买
    }
    
    func restorePurchases() async throws {
        // 恢复购买
    }
}
```

## StoreKit 配置

### Products
| Product ID | 类型 | 描述 |
|------------|------|------|
| com.sleepdo.lifetime | 非消耗品 | 终身会员 |
| com.sleepdo.yearly | 自动续订 | 年付 |
| com.sleepdo.monthly | 自动续订 | 月付 |

### 试用配置
- 7 天免费试用
- 试用结束后自动扣款
- 用户可随时取消

## 奖励资源

终身会员专属 10 个 Premium 声音：
1. 森林 (forest)
2. 雷雨 (thunder)
3. 河流 (river)
4. 咖啡厅 (cafe)
5. 图书馆 (library)
6. 布朗噪声 (brown_noise)
7. Delta波 (delta)
8. Gamma波 (gamma)
9. 钢琴 (piano)
10. OM唱诵 (om)
