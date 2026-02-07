# BeatSleep UI/UX 设计规范

> 版本: 1.1.0  
> 更新日期: 2026-02-06  
> 状态: 正式发布

---

## 设计理念

**"优雅、科学、高转化"**

- **优雅**: 深色渐变 + 毛玻璃，夜间使用舒适
- **科学**: 每个交互都有数据支撑，7天看到效果
- **高转化**: 简洁明了，引导用户完成核心路径

---

## 色彩系统

### 主色调

| 颜色名称 | HEX | RGB | 用途 |
|---------|-----|-----|------|
| **背景深** | #0D0D1A | 13, 13, 26 | 主背景 |
| **背景中** | #1A1A3E | 26, 26, 62 | 次级背景 |
| **背景浅** | #2D1B4E | 45, 27, 78 | 渐变终点 |
| **主色** | #8B5CF6 | 139, 92, 246 | 强调色 |
| **辅助色** | #3B82F6 | 59, 130, 246 | 次强调 |
| **成功色** | #10B981 | 16, 185, 129 | 成功状态 |
| **警告色** | #F59E0B | 245, 158, 11 | 警告状态 |
| **错误色** | #EF4444 | 239, 68, 68 | 错误状态 |

### 渐变背景

```swift
let backgroundGradient = LinearGradient(
    colors: [
        Color(hex: "#0D0D1A"),
        Color(hex: "#1A1A3E"),
        Color(hex: "#2D1B4E")
    ],
    startPoint: .top,
    endPoint: .bottom
)
```

---

## 字体系统

### 字体

| 类型 | 字重 | 用途 |
|------|------|------|
| **SF Pro Display** | Bold | 大标题 |
| **SF Pro Display** | Semibold | 标题 |
| **SF Pro Text** | Medium | 正文 |
| **SF Pro Text** | Regular | 辅助文字 |

### 字号

| 类型 | iPhone | Apple Watch |
|------|--------|--------------|
| **大标题** | 34 pt | 28 pt |
| **标题** | 28 pt | 24 pt |
| **副标题** | 22 pt | 20 pt |
| **正文** | 17 pt | 17 pt |
| **辅助** | 15 pt | 14 pt |
| **caption** | 13 pt | 12 pt |

---

## 组件规范

### 卡片

```swift
CardView {
    // 内容
}
.background(
    RoundedRectangle(cornerRadius: 20)
        .fill(.ultraThinMaterial)
)
```

| 属性 | 值 |
|------|-----|
| 圆角 | 20 pt |
| 阴影 | 默认 |
| 背景 | .ultraThinMaterial |
| 内边距 | 16 pt |

### 按钮

```swift
Button(action: {}) {
    HStack {
        Image(systemName: "play.fill")
        Text("开始")
    }
    .font(.headline)
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(
        LinearGradient(
            colors: [Color.purple, Color.blue],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
    .cornerRadius(16)
}
.padding(.horizontal, 20)
```

| 属性 | 值 |
|------|-----|
| 圆角 | 16 pt |
| 高度 | 56 pt |
| 宽度 | 撑满屏幕 |
| 边距 | 水平 20 pt |
| 背景 | 渐变色（方法决定） |
| 图标 | play.fill |

### 播放控制按钮（BreathingSessionView）

| 状态 | 按钮文字 | 图标 | 背景色 |
|------|---------|------|--------|
| 未开始 | 开始 | play.fill | 紫蓝渐变 |
| 播放中 | 暂停 | pause.fill | 橙色 |
| 已暂停 | 继续 | play.fill | 紫色 |
| 已完成 | 完成 | checkmark | 绿色 |

### 标签

```swift
HStack {
    Image(systemName: "icon")
    Text("Label")
}
.font(.caption)
.foregroundColor(.purple)
.padding(.horizontal, 12, .vertical, 6)
.background(
    Capsule()
        .fill(Color.purple.opacity(0.2))
)
```

---

## 动画规范

### 呼吸动画

```swift
Circle()
    .fill(Color.purple.opacity(0.3))
    .frame(width: 200, height: 200)
    .scaleEffect(isRunning ? 1.2 : 1.0)
    .animation(
        .easeInOut(duration: step.duration)
        .repeatForever(autoreverses: true),
        value: isRunning
    )
```

| 属性 | 值 |
|------|-----|
| 动画类型 | easeInOut |
| 重复 | forever |
| 自动反转 | true |

### 页面切换

```swift
.navigationTransition(.zoom(sourceID: id, in: namespace))
```

---

## 图标系统

### SF Symbols

| 功能 | 图标 | 用途 |
|------|------|------|
| 睡眠 | `moon.fill` | 首页 |
| 呼吸 | `wind` | 呼吸页面 |
| 心率 | `heart.fill` | Watch 页面 |
| 设置 | `gear` | 设置页面 |
| 播放 | `play.fill` | 开始按钮 |
| 暂停 | `pause.fill` | 暂停按钮 |

---

## 页面规范

### TechniquesView（方法选择页）

```
┌─────────────────────────────────────┐
│         选择助眠方法                  │
├─────────────────────────────────────┤
│                                     │
│     4-7-8 呼吸                       │
│     推荐：紧张焦虑                    │
│     难度：简单                       │
│     ━━━━━━━━━━━━━━━━━━━━━━━        │
│     [         开 始          ]       │
│                                     │
├─────────────────────────────────────┤
│                                     │
│     2-1-6 呼吸                       │
│     推荐：快速放松                    │
│     难度：中等                       │
│     ━━━━━━━━━━━━━━━━━━━━━━━        │
│     [         开 始          ]       │
│                                     │
├─────────────────────────────────────┤
│                                     │
│     🌧️ 白噪音                        │
│     选择声音：雨声                   │
│     ━━━━━━━━━━━━━━━━━━━━━━━        │
│     [         开 始          ]       │
│                                     │
├─────────────────────────────────────┤
│                                     │
│     🧘 渐进式肌肉放松                │
│     推荐：身体紧绷                   │
│     ━━━━━━━━━━━━━━━━━━━━━━━        │
│     [         开 始          ]       │
│                                     │
├─────────────────────────────────────┤
│                                     │
│     🔍 身体扫描                      │
│     推荐：思绪繁多                   │
│     ━━━━━━━━━━━━━━━━━━━━━━━        │
│     [         开 始          ]       │
│                                     │
└─────────────────────────────────────┘
```

**设计要点：**
- 卡片式布局，圆角 16pt
- 卡片背景：`Color.white.opacity(0.05)`
- 开始按钮：撑满宽度，左右留 20pt
- 进入后自动开始播放（呼吸类）
- 白噪音可选择声音类型

### BreathingSessionView（呼吸练习页）

```
┌─────────────────────────────────────┐
│           4-7-8 呼吸                 │
├─────────────────────────────────────┤
│                                     │
│            ┌─────────┐             │
│            │  ○ 动画 │             │
│            │   吸气   │             │
│            │  4秒    │             │
│            └─────────┘             │
│                                     │
│              ⏱️ 3:45                │
│              ━━━━━━━━━             │
│                                     │
│        [      暂 停       ]         │
│                                     │
└─────────────────────────────────────┘
```

**设计要点：**
- 无返回按钮（导航栏透明）
- 进入页面自动开始
- 中央呼吸动画（圆形缩放）
- 底部控制按钮（暂停/继续）
- 左上角可选：取消/放弃

### TherapyPlayerPage（渐进式/身体扫描播放页）

```
┌─────────────────────────────────────┐
│                                     │
│            ┌─────────┐             │
│            │  🧘 图标 │             │
│            └─────────┘             │
│                                     │
│         渐进式肌肉放松                │
│                                     │
│         🔊 引导语播放中               │
│                                     │
│              ⏱️ 9:30                │
│              ━━━━━━━━━             │
│                                     │
│        [      暂 停       ]         │
│                                     │
└─────────────────────────────────────┘
```

**设计要点：**
- 无返回按钮
- 顶部显示疗法图标
- 引导语播放状态指示
- 倒计时显示
- 暂停/播放控制

---

## 深色模式

所有页面强制深色模式：

```swift
.environment(\.colorScheme, .dark)
.preferredColorScheme(.dark)
```

---

## 交互反馈

| 交互 | 反馈 | Haptic |
|------|------|--------|
| 点击按钮 | 颜色变化 | Success |
| 开始练习 | 动画开始 | Light |
| 完成练习 | 成功提示 | Success |
| 删除项目 | 滑动删除 | Warning |

---

## 响应式设计

| 设备 | 最小边距 | 最大宽度 |
|------|---------|---------|
| iPhone SE | 16 pt | 320 pt |
| iPhone 14/15 | 20 pt | 390 pt |
| iPhone Pro Max | 24 pt | 430 pt |
| Apple Watch | 8 pt | 全宽 |

---

## 相关文档

- [架构设计](../01-Architecture/README.md)
- [数据模型](../04-Data-Models/DATA_MODELS.md)
- [原型设计](PROTOTYPE.md)
