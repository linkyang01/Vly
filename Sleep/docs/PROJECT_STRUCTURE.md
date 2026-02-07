# BeatSleep 项目完整结构

> 版本: 1.0.0  
> 更新日期: 2026-02-06  
> 状态: 正式发布

---

## 项目结构

```
BeatSleep/
│
├── 📄 CODING_STANDARDS.md         # 代码规范（必读）
├── 📄 README.md                   # 项目自述
├── 📄 CHANGELOG.md                # 变更日志
├── 📄 project.yml                 # XcodeGen 配置
│
├── 📁 .github/
│   └── 📁 workflows/
│       └── 📄 ci.yml             # CI/CD 流程
│
├── 📁 scripts/
│   ├── 📄 backup.sh              # 完整备份
│   ├── 📄 quick_backup.sh         # 快速备份
│   ├── 📄 sync.sh                # iCloud 同步
│   └── 📄 restore.sh             # 恢复脚本
│
├── 📁 Sources/
│   ├── 📁 App/
│   │   ├── 📄 BeatSleepApp.swift  # App 入口
│   │   └── 📄 ContentView.swift   # TabView 导航
│   │
│   ├── 📁 Views/
│   │   ├── 📄 SleepHomeView.swift        # 首页
│   │   ├── 📄 TechniquesView.swift       # 方法选择
│   │   ├── 📄 BreathingSessionView.swift # ⭐ 4-7-8 呼吸
│   │   ├── 📄 WatchDataView.swift        # Watch 数据
│   │   └── 📄 SettingsView.swift         # 设置
│   │
│   ├── 📁 Models/
│   │   ├── 📄 BreathingTechnique.swift    # 助眠技术
│   │   └── 📄 SleepSession.swift         # 睡眠会话
│   │
│   ├── 📁 Services/
│   │   ├── 📄 SleepTracker.swift
│   │   ├── 📄 WatchDataManager.swift
│   │   └── 📄 SubscriptionManager.swift
│   │
│   └── 📁 WatchApp/
│       ├── 📄 BeatSleepWatchApp.swift
│       ├── 📄 WatchHomeView.swift
│       ├── 📄 WatchTechniquesView.swift
│       └── 📄 WatchSettingsView.swift
│
├── 📁 Resources/
│   ├── 📄 Info.plist
│   ├── 📁 Assets.xcassets/
│   └── 📁 Sounds/
│
└── 📁 docs/
    ├── 📄 README.md                      # 文档索引
    ├── 📁 01-Architecture/
    │   └── 📄 README.md                  # 架构设计
    ├── 📁 02-Requirements/
    │   └── 📄 MVP_PLAN.md               # MVP 计划
    ├── 📁 03-UI-UX/
    │   ├── 📄 UI_SPECIFICATION.md       # UI 规范
    │   └── 📄 PROTOTYPE.md             # 原型
    ├── 📁 04-Data-Models/
    │   └── 📄 DATA_MODELS.md           # 数据模型
    ├── 📁 05-Services/
    │   └── 📄 SERVICES.md              # 服务设计
    └── 📁 06-Research/
        ├── 📄 SLEEP_RESEARCH.md        # 睡眠研究
        └── 📄 BREATHING_RESEARCH.md   # 呼吸研究
```

---

## 快速导航

| 需求 | 文件 |
|------|------|
| 代码规范 | `CODING_STANDARDS.md` |
| 项目自述 | `README.md` |
| 架构设计 | `docs/01-Architecture/README.md` |
| MVP 计划 | `docs/02-Requirements/MVP_PLAN.md` |
| 数据模型 | `docs/04-Data-Models/DATA_MODELS.md` |
| CI/CD 配置 | `.github/workflows/ci.yml` |
| 备份脚本 | `scripts/backup.sh` |

---

## 开发流程

### 日常开发

```bash
# 1. 开始工作前
cd ~/workspace/BeatSleep

# 2. 创建功能分支
git checkout -b feature/xxx

# 3. 开发
# ... 编辑代码 ...

# 4. 运行备份（重要！）
./scripts/quick_backup.sh

# 5. 提交
git add .
git commit -m "feat(xxx): description"

# 6. 推送
git push
```

### 发布流程

```bash
# 1. 创建发布分支
git checkout -b release/v1.0.0

# 2. 更新版本号
# ... 编辑 project.yml ...

# 3. 更新 CHANGELOG
# ... 编辑 CHANGELOG.md ...

# 4. 提交
git commit -m "chore(release): v1.0.0"
git tag v1.0.0
```

---

## 备份策略

### 自动备份（每日）

```bash
# 每日运行
./scripts/quick_backup.sh
```

### 完整备份（每周）

```bash
# 每周运行
./scripts/backup.sh
```

### iCloud 同步

```bash
# 同步到 iCloud
./scripts/sync.sh
```

---

## 常见问题

### Q: 如何生成 Xcode 项目？

```bash
# 安装 XcodeGen
brew install xcodegen

# 生成项目
cd BeatSleep
xcodegen generate
```

### Q: 如何运行测试？

```bash
xcodebuild -project BeatSleep.xcodeproj \
           -scheme BeatSleep \
           -destination 'generic/platform=iOS Simulator' \
           test
```

### Q: 如何备份？

```bash
# 快速备份（推荐每日）
./scripts/quick_backup.sh

# 完整备份
./scripts/backup.sh
```

---

## 相关文档

- [代码规范](CODING_STANDARDS.md)
- [架构设计](docs/01-Architecture/README.md)
- [MVP 计划](docs/02-Requirements/MVP_PLAN.md)
- [数据模型](docs/04-Data-Models/DATA_MODELS.md)
