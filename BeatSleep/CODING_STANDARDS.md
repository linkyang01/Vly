# BeatSleep 项目规范

> 版本: 1.0.0  
> 更新日期: 2026-02-06  
> 状态: 正式发布

---

## 文档体系

```
BeatSleep/
├── 📄 本文档 (规范总览)
│
├── 📁 docs/                    # 设计文档
│   ├── 01-Architecture/       # 架构设计
│   ├── 02-Requirements/        # 需求规格
│   ├── 03-UI-UX/              # UI/UX 设计
│   ├── 04-Data-Models/        # 数据模型
│   ├── 05-Services/           # 服务设计
│   └── 06-Research/           # 研究文档
│
├── 📁 Sources/                 # 源代码
│   ├── App/                   # 应用入口
│   ├── Views/                 # UI 视图
│   ├── Models/                # 数据模型
│   ├── Services/              # 业务逻辑
│   └── WatchApp/              # Watch 应用
│
├── 📁 Resources/              # 资源文件
│   ├── Assets.xcassets/       # 资源目录
│   └── Sounds/                # 音频文件
│
├── 📁 scripts/                # 构建脚本
│   └── generate_project.sh    # XcodeGen 生成脚本
│
├── 📁 tests/                  # 测试代码
│
├── 📁 .github/                # CI/CD 配置
│   └── workflows/
│
├── 📄 project.yml              # XcodeGen 项目配置
├── 📄 README.md               # 项目自述
└── 📄 CHANGELOG.md           # 更新日志
```

---

## 命名规范

### 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| Swift 文件 | PascalCase + 功能描述 | `SleepHomeView.swift` |
| 数据模型 | PascalCase + Model/Session | `SleepSession.swift` |
| 服务类 | PascalCase + Service/Manager | `SleepTrackerService.swift` |
| 测试文件 | 被测类名 + Test | `SleepSessionTest.swift` |
| 配置 | snake_case | `project.yml`, `app_config.json` |

### 代码命名

```swift
// 类 - PascalCase
struct SleepSession { ... }
class SleepTrackerService { ... }

// 枚举 - PascalCase
enum SleepQuality { ... }
enum BreathingTechnique { ... }

// 属性/变量 - camelCase
var currentHeartRate: Int?
let sessionDuration: TimeInterval

// 方法 - camelCase
func saveSession(_ session: SleepSession)
func fetchRecentSessions() -> [SleepSession]
```

---

## 代码规范

### 文件结构顺序

```swift
// 1. 导入
import SwiftUI
import Foundation

// 2. MARK: 注释
// MARK: - 类定义
class MyClass { ... }

// 3. 嵌套类型
extension MyClass { ... }

// 4. 私有扩展
private extension MyClass { ... }
```

### 注释规范

```swift
/// 单行说明（公开 API）
/// 简要描述功能

/// 多行说明
/// 详细描述功能
/// - Parameters:
///   - param1: 参数说明
/// - Returns: 返回值说明
/// - Important: 重要提示
```

### Swift 风格

```swift
// ✅ 正确
struct User {
    let id: UUID
    var name: String
    
    var isActive: Bool {
        lastActiveDate > Date().addingTimeInterval(-3600)
    }
}

// ❌ 错误
struct User{
    let id:UUID
    var name:String
    var isActive:Bool{
        return lastActiveDate>Date().addingTimeInterval(-3600)
    }
}
```

---

## Git 工作流

### 分支命名

| 分支类型 | 命名规范 | 示例 |
|---------|---------|------|
| 主分支 | `main` | 主开发分支 |
| 功能分支 | `feature/功能描述` | `feature/breathing-animation` |
| 修复分支 | `bugfix/问题描述` | `bugfix/fix-crash-on-watch` |
| 发布分支 | `release/v版本号` | `release/v1.0.0` |

### 提交规范

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型：**
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具

**提交示例：**
```
feat(breathing): 添加4-7-8呼吸动画

实现圆形进度条动画
支持暂停/继续
添加语音引导

Closes #123
```

---

## 文档规范

### 文档命名

| 类型 | 命名规范 | 示例 |
|------|---------|------|
| 设计文档 | 功能描述 + 设计类型 | `SLEEP_TRACKING.md` |
| API 文档 | api_功能 | `api_sleep_session.md` |
| 变更记录 | CHANGELOG.md | 更新日志 |

### 文档格式

```markdown
# 文档标题

> 简要描述
> 版本/日期

## 概述
[文档目的]

## 详细说明
[详细内容]

## 相关文档
- [链接到其他文档]
```

---

## 备份策略

### 自动备份

| 类型 | 工具 | 频率 | 存储 |
|------|------|------|------|
| Git 提交 | 手动 | 每次重要变更 | GitHub |
| Time Machine | 系统 | 每小时 | 外置硬盘 |
| iCloud | 系统 | 实时 | 云端 |
| 手动备份 | 脚本 | 每日 | 外部存储 |

### 备份脚本

```bash
#!/bin/bash
# backup.sh - 项目备份脚本

BACKUP_DIR="$HOME/Backups/BeatSleep"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份
tar -czf "$BACKUP_DIR/BeatSleep_$DATE.tar.gz" \
    --exclude='.git' \
    --exclude='build' \
    /Users/yanglin/.openclaw/workspace/BeatSleep

# 保留最近10个备份
ls -t "$BACKUP_DIR"/*.tar.gz | tail -n +11 | xargs rm

echo "Backup created: BeatSleep_$DATE.tar.gz"
```

---

## 发布流程

### 版本号规范

使用 **语义化版本**：`主版本.次版本.修订号`

| 级别 | 规则 | 示例 |
|------|------|------|
| 主版本 | 重大变更 | 2.0.0 |
| 次版本 | 新功能 | 1.1.0 |
| 修订号 | Bug 修复 | 1.0.1 |

### 发布清单

- [ ] 所有测试通过
- [ ] 代码审查完成
- [ ] 文档更新
- [ ] CHANGELOG 记录
- [ ] TestFlight 构建
- [ ] App Store 提交

---

## 审核清单

### 代码提交前检查

- [ ] 代码编译通过
- [ ] 无编译警告
- [ ] 符合命名规范
- [ ] 必要的注释
- [ ] 自测通过
- [ ] 无敏感信息泄露
- [ ] Git 暂存正确

### 文档更新检查

- [ ] 文档格式正确
- [ ] 链接有效
- [ ] 版本号更新
- [ ] 相关文档同步

---

## 相关文档

- [架构设计](docs/01-Architecture/README.md)
- [需求规格](docs/02-Requirements/MVP_PLAN.md)
- [数据模型](docs/04-Data-Models/DATA_MODELS.md)
- [CHANGELOG](CHANGELOG.md)
