# OpenClaw 多设备命名约定（2026-02-07）

| 名字 | IP | 说明 |
|------|-----|------|
| **Mini** | 当前这台（yanglindeMac-mini.local） | 我运行的电脑 |
| **Air** | 192.168.0.15 | 另一台 Mac，通过 SSH/OpenClaw 节点控制 |

---

## 项目清单（2026-02-07）

| 项目 | 优先级 | 状态 | 说明 |
|------|--------|------|------|
| **BeatSleep** | ⭐⭐⭐ 最重要 | 开发中 | iOS 助眠 App |
| **Vly** | ⭐⭐ 次重要 | 开发中 | 开源 IINA 播放器，为 linfuse 开发 |
| **Sleep** | 验证用 | 开发中 | BeatSleep 的克隆，验证用 |
| **HydraTrack** | 预备 | 未开始 | 已完成调研和设计 |
| **QuitDo** | 预备 | 未开始 | 已完成调研和设计 |
| **linfuse** | 未来 | 受阻 | 未来重要项目，因困难暂停 |
| **sleepdo** | 停滞 | 设计方向不明 | 设计方向不明，未来不确定 |

### 同步规则
- **Vly** → 开源项目 → 以 Air 为准，GitHub 同步
- **BeatSleep** → 私有项目 → 以 Mini 为准
- **Sleep** → 私有项目 → 以 Mini 为准
- **QuitDo** → 私有项目 → 以 Mini 为准
- **HydraTrack** → 私有项目 → 以 Mini 为准
- **linfuse** → 私有项目 → 以 Mini 为准
- **sleepdo** → 私有项目 → 以 Mini 为准

---

## GitHub 仓库（开源项目）

| 项目 | 仓库地址 | 状态 |
|------|----------|------|
| Vly | https://github.com/linkyang01/Vly | 开源 |

---

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

## BeatSleep 设计决策（2026-02-06）

### 1. 产品定位
- **以听为主，视觉为辅** - 用户闭眼助眠，无需看屏幕
- 语音引导 + 可选动画

### 2. 五种方法的声音设计

| 方法 | 语音引导 | 背景音 | 实现方式 |
|------|---------|-------|---------|
| **4-7-8 呼吸** | ✅ TTS 实时播报 | ❌ | 吸气-屏息-呼气语音提示 |
| **2-1-6 呼吸** | ✅ TTS 实时播报 | ❌ | 吸气-屏息-呼气语音提示 |
| **渐进式肌肉放松** | 🎤 真人录音（待配音） | ✅ 可选白噪音 | 复用现有 6 种白噪音 |
| **身体扫描** | 🎤 真人录音（待配音） | ✅ 可选白噪音 | 复用现有 6 种白噪音 |
| **白噪音** | ❌ | ✅ 已完成 | 6 种声音 + 定时 |

### 3. 呼吸法 TTS 脚本

**4-7-8 呼吸法**：
- 准备: "准备开始 4-7-8 呼吸法"
- 吸气: "吸气... 1... 2... 3... 4"
- 屏息: "屏息... 5... 6... 7"
- 呼气: "呼气... 1... 2... 3... 4... 5... 6... 7... 8"
- 结束: "练习完成，祝你晚安"

**2-1-6 呼吸法**：
- 准备: "准备开始 2-1-6 呼吸法"
- 吸气: "吸气... 1... 2"
- 屏息: "屏息... 1"
- 呼气: "呼气... 1... 2... 3... 4... 5... 6"
- 结束: "练习完成，祝你晚安"

### 4. 白噪音设计 ✅ 已完成

**6 种声音**：
| 声音 | 文件名 | 颜色 | 图标 |
|------|--------|------|------|
| 雨声 | rain.mp3 | #3B82F6 | cloud.rain |
| 海浪 | ocean.mppl | #06B6D4 | water.waves |
| 风声 | wind.mp3 | #14B8A6 | wind |
| 壁炉 | fire.mp3 | #F97316 | flame.fill |
| 森林 | forest.mp3 | #22C55E | leaf |
| 河流 | river.mp3 | #3B82F6 | drop.fill |

**使用流程**：
1. 选择声音（6选1）
2. 选择时长（5/10/15/30/60分钟）
3. 点击播放 → 进入播放页面
4. 播放页面：波形动画 + 倒计时 + 暂停/停止

**文件位置**：`Resources/sounds/`（folder reference）

### 5. 待开发功能

| 功能 | 状态 | 说明 |
|------|------|------|
| 4-7-8 TTS 语音 | 待开发 | `BreathingPlayer` + `AVSpeechSynthesizer` |
| 2-1-6 TTS 语音 | 待开发 | 复用 `BreathingPlayer` |
| 呼吸法动画 | 待开发 | 圆形呼吸动画 |
| 渐进式引导语 | 待配音 | 需要专业配音 |
| 身体扫描引导语 | 待配音 | 需要专业配音 |

### 6. 设计文档
- `BeatSleep/docs/03-UI-UX/BREATHING_WHITENOISE_DESIGN.md`

---

*最后更新: 2026-02-06*

---

## BeatSleep 项目本地化（2026-02-06）

### 项目信息
- **项目路径**: `/Users/yanglin/.openclaw/workspace/BeatSleep/`
- **Bundle ID**: `com.beatsleep.app`
- **模拟器**: iPhone Air (iOS 26.2)

### 本地化状态
已完成所有页面的双语本地化：
- ✅ OnboardingView（引导页）
- ✅ SleepHomeView（首页）
- ✅ TechniquesView（方法选择）
- ✅ BreathingSessionView（呼吸练习）
- ✅ SettingsView（设置）
- ✅ PaywallView（付费墙）
- ✅ WatchHomeView、WatchTechniquesView、WatchSettingsView
- ✅ WatchDataView（Watch 数据页面）
- ✅ PlaceholderTherapyView（渐进/身体/白噪音页面）

### 技术实现
- 使用 `.localized()` 扩展方法
- Localizable.strings 文件管理所有翻译
- 系统语言为简体中文时显示中文，其他语言显示英文

### 新增本地化键值
- `therapy_ready` = "准备" / "Ready"
- `therapy_start` = "开始" / "Start"
- `therapy_stop` = "停止" / "Stop"
- `therapy_playing` = "播放中..." / "Playing..."

### 图标修复
- 身体扫描图标：`figure.scan` → `figure.stand`（iOS 26 兼容）

### 关键文件
- 英文字符串：`BeatSleep/Resources/en.lproj/Localizable.strings`
- 中文字符串：`BeatSleep/Resources/zh-Hans.lproj/Localizable.strings`
- 扩展方法：`BeatSleep/Sources/Extensions/String+Localization.swift`

---

*最后更新: 2026-02-06*
