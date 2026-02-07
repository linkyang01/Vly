# SleepDo 原型图设计

> 最后更新: 2026-02-05

## 原型图链接

[查看 Figma 原型图](https://figma.com/file/xxxxx/sleepdo-prototype)

## 页面列表

### 1. 睡眠首页 (SleepHome)
- 睡眠状态卡片
- 睡眠目标进度
- 睡前仪式入口
- 快捷操作按钮

### 2. 声音发现 (Sounds)
- 推荐Tab - 精选合集、成就进度
- 声音Tab - 6个分类、42个声音网格
- 故事Tab - 冥想引导列表
- 录制Tab - 录音功能

### 3. 闹钟设置 (Alarm)
- 智能唤醒卡片
- 闹钟列表
- 添加/编辑闹钟

### 4. 睡眠统计 (Stats)
- 睡眠概览（时长、入睡时间、清醒次数）
- 睡眠阶段分布（深睡、浅睡、REM、清醒）
- 睡眠趋势图表
- 每日睡眠记录
- 成就进度

### 5. 设置 (Settings)
- 用户信息
- 通知设置
- 睡眠设置
- 声音设置
- 健康数据
- 隐私政策
- 关于

### 6. 混音器 (SoundMixer)
- 当前播放声音音量控制
- 添加声音
- 预设管理

### 7. 睡前仪式 (BedtimeRoutine)
- 4-7-8 呼吸练习
- 冥想练习（身体扫描、感恩、呼吸冥想）
- 助眠声音混音

## 设计规范

### 颜色方案
```swift
// 背景渐变
LinearGradient(
    colors: [
        Color(red: 0.05, green: 0.05, blue: 0.1),    // #0D0D1A
        Color(red: 0.1, green: 0.1, blue: 0.2),      // #1A1A3E
        Color(red: 0.18, green: 0.1, blue: 0.3)      // #2D1B4E
    ],
    startPoint: .top,
    endPoint: .bottom
)

// 强调色
Color(red: 139/255, green: 92/255, blue: 246/255)  // #8B5CF6
```

### 字体
- 标题: 28pt, Bold
- 副标题: 16pt, Medium
- 正文: 14pt, Regular
- _caption: 12pt, Regular
- 小字: 10pt, Regular

### 圆角
- 大卡片: 20pt
- 中卡片: 16pt
- 小卡片: 12pt
- 按钮: 12pt

### 间距
- 页面边距: 20pt
- 卡片内边距: 20pt
- 元素间距: 16pt
- 列表间距: 12pt

## 组件库

### 基础组件
- PrimaryButton - 主要按钮
- SecondaryButton - 次要按钮
- Card - 卡片容器
- IconRow - 图标+文字行

### 业务组件
- SleepCard - 睡眠卡片
- SoundGridItem - 声音网格项
- AchievementProgressRow - 成就进度行
- TabBar - 自定义TabBar

## 交互规范

### Tab 切换
- 点击切换，无动画
- 选中状态高亮

### 卡片点击
- 触觉反馈
- 适当缩放效果

### 列表滚动
- 平滑滚动
- 顶部下拉刷新

## 设计资源

### 图标
使用 SF Symbols:
- sleep.symbolsSet
- alarm.symbolsSet
- chart.symbolsSet

### 颜色
- 紫色渐变背景
- 紫色强调色
- 白色主文字
- 灰色副文字

## 原型状态

| 页面 | 状态 | 说明 |
|------|------|------|
| 睡眠首页 | ✅ 完成 | 可交互原型 |
| 声音发现 | ✅ 完成 | 包含所有Tab |
| 闹钟设置 | ✅ 完成 | 智能唤醒卡片 |
| 睡眠统计 | ✅ 完成 | 图表已完成 |
| 设置 | ✅ 完成 | 基础框架 |
| 混音器 | ✅ 完成 | 音量控制 |
| 睡前仪式 | ✅ 完成 | 呼吸+冥想 |
