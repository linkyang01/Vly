# TabBar iOS 26 实现规格

> 最后更新: 2026-02-05

## 设计概述

采用简洁风格设计，与 iOS 26 系统原生设计语言保持一致。

## TabBar 规格

### 布局参数
| 参数 | 值 |
|------|-----|
| Tab 数量 | 5 |
| Tab 间距 | 0pt（按钮紧贴） |
| TabBar 宽度 | 屏幕宽度的一半 |
| 悬浮位置 | `padding(.bottom, 34)` |

### 容器样式
```swift
RoundedRectangle(cornerRadius: 28)
    .fill(.ultraThinMaterial)
    .padding(.horizontal, 20)
    .padding(.bottom, 8)
```

### 椭圆内边距
- 水平: 24pt
- 垂直: 16pt

### Tab 内容
- 图标 + 文字
- 无横线/圆点装饰
- 图标大小: 20pt
- 文字大小: 10pt
- 选中颜色: 白色
- 未选中颜色: 灰色 (opacity 0.6)

## 页面内容优化

### 透明背景
所有页面背景改为 `Color.clear`（显示系统壁纸）

### 底部黑色条
- 高度: 60pt
- 颜色: 黑色
- 位置: ScrollView 底部，随内容一起下滑/上移

### 页面列表
- SleepHomeView
- SoundsView
- AlarmView
- StatsView
- SettingsView

## SoundsView 重构

### 变更
- 去掉外层 ScrollView（解决嵌套滚动问题）
- 背景改为透明
- 使用 VStack 作为主容器
- 搜索栏与 Tab 栏间距 16pt
- TabView 无固定高度限制

## 设置页面修复

- 所有设置页面背景改为透明
- 添加底部 60pt 黑色条
- 定时器弹窗改为全屏 `presentationDetents([.large])`

## 紫色渐变背景

全局使用:
```swift
LinearGradient(
    colors: [
        Color(red: 0.05, green: 0.05, blue: 0.1),    // #0D0D1A
        Color(red: 0.1, green: 0.1, blue: 0.2),      // #1A1A3E  
        Color(red: 0.18, green: 0.1, blue: 0.3)      // #2D1B4E
    ],
    startPoint: .top,
    endPoint: .bottom
)
```

## 紫色强调色

```swift
Color(red: 139/255, green: 92/255, blue: 246/255)  // #8B5CF6
```
