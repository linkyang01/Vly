# SleepDo 设计文档

> **重要**: 此文件内容已与 `sleepdo/README.md` 和 `sleepdo/docs/` 同步更新。
> 详细文档请查看：
> - 项目介绍: `sleepdo/README.md`
> - 设计文档: `sleepdo/docs/README.md`
> - AI 行为规范: `sleepdo/AGENTS.md`

## 项目信息

| 项目 | 值 |
|------|------|
| 中文名 | 木木眠 |
| 英文名 | SleepDo |
| Bundle ID | com.sleepdo.app |
| 技术栈 | SwiftUI 4.0, iOS 16.0+ |

## 核心功能

- 🎵 声音播放（42个声音）
- ⏰ 智能闹钟（渐强唤醒 + 浅睡唤醒）
- 📊 睡眠追踪（HealthKit + Apple Watch）
- 🏆 成就系统（35个成就）
- 💰 订阅模式（7天试用 + 终身$49.99）

## 项目结构规范

| 目录 | 用途 |
|------|------|
| `Sources/` | 源代码（App/ Views/ Models/ Services/ Cells/） |
| `Resources/` | 资源文件 |
| `scripts/` | 工具脚本 |
| `docs/` | 设计文档（01-Architecture 到 06-Research） |
| `deprecated/` | 已废弃代码 |
| `archive/` | 历史版本 |

## AI 行为规范

所有处理 SleepDo 项目的 AI 必须：
1. 首次会话读取 `sleepdo/AGENTS.md`
2. 遵循 Google Swift Style Guide
3. 使用紫色渐变背景（`#0D0D1A → #1A1A3E → #2D1B4E`）
4. 文档按 01-06 分类存放

---

## 2026-02-05 TabBar 设计更新 ✅

### TabBar 重新设计
- **简洁风格**: 图标 + 文字，无横线/圆点
- **毛玻璃椭圆框**: `.ultraThinMaterial` 胶囊背景，居中显示
- **Tab 间距**: 0pt（按钮紧贴在一起）
- **椭圆内边距**: 水平 24pt，垂直 16pt
- **TabBar 宽度**: 屏幕宽度的一半
- **悬浮位置**: `padding(.bottom, 34)`

### 页面内容优化
- **透明背景**: 所有页面背景改为 `Color.clear`（显示系统壁纸）
- **60pt 黑色条**: 添加在 ScrollView 底部，随内容一起下滑/上移
- **应用页面**: SleepHomeView, SoundsView, AlarmView, StatsView, SettingsView

### SoundsView 重构
- 去掉外层 ScrollView（解决嵌套滚动问题）
- 背景改为透明
- 使用 VStack 作为主容器
- 搜索栏与 Tab 栏间距 16pt
- TabView 无固定高度限制

### 设置页面修复
- 所有设置页面背景改为透明
- 添加底部 60pt 黑色条
- 定时器弹窗改为全屏 `presentationDetents([.large])`

### 设计文档
- `docs/03-UI-UX/TABBAR_IOS26_IMPLEMENTATION.md` - 完整实现规格

---

## Watch 设计缺口（已补充 ✅）

已创建 `docs/05-Services/WATCH_DESIGN.md`，包含：
- Watch App 功能设计（睡眠卡片、闹钟控制、晨间挑战）
- 心率辅助浅睡唤醒算法
- 震动唤醒模式（渐强震动）
- WatchConnectivity 数据同步
- 实现优先级（Phase 1-3）

## 睡前仪式设计（新增 ✅）

已创建 `docs/03-UI-UX/BEDTIME_ROUTINE_DESIGN.md`，包含：
- 💨 4-7-8 呼吸练习（圆形动画 + 3分钟）
- 🧘 5 分钟冥想（身体扫描、感恩练习、呼吸冥想、白日梦）
- 🔊 助眠声音（42种声音 + 混音 + 定时关闭）
- 集成到睡眠首页的卡片设计
- 数据模型与成就关联
- 实现优先级（Phase 1-3）

---

*最后更新: 2026-02-05*
