# AGENTS.md - OpenClaw 全局开发规范

> **最高优先级**：所有 AI 开发必须严格遵守本文档
> **版本**: 2026-02-07
> **适用范围**: Mini + Air 两台电脑

---

## 📌 核心原则

| 优先级 | 原则 | 说明 |
|--------|------|------|
| P0 | **安全优先** | 不泄露数据、不执行危险命令 |
| P0 | **全局规范 > 项目规范** | 冲突时以本文档为准 |
| P0 | **人类确认** | 有风险的操作必须先问 |
| P1 | **先读后做** | 处理项目前先阅读相关文档 |
| P1 | **文档同步** | 代码改动必须同步更新文档 |
| P2 | **小步提交** | 每次改动最小化、可追溯 |

---

## 🤖 AI 通用行为准则

### 会话启动流程（每次必须执行）

```
1. 读取 SOUL.md → 了解我是谁
2. 读取 USER.md → 了解用户
3. 读取 memory/YYYY-MM-DD.md → 近期上下文
4. 读取 MEMORY.md → 长期记忆（仅主会话）
5. 读取项目 AGENTS.md → 项目特定规范
```

### 禁止行为（红线）

| 行为 | 后果 |
|------|------|
| 🚫 硬编码 API Key | 立即停止并报告 |
| 🚫 未经确认删除文件 | 必须先询问 |
| 🚫 盲目猜测意图 | 有疑问立即停下 |
| 🚫 外部操作未确认 | 邮件/推文等必须先问 |
| 🚫 过度承诺 | 不确定的说"不确定" |

### 沟通原则

| 场景 | 做法 |
|------|------|
| 直接询问 | 精准回复，不说废话 |
| 有风险 | 标注风险 + 确认执行 |
| 完成任务 | 总结做了什么 + 下一步 |
| 遇到冲突 | 停止 + 报告人类 |

---

## 📁 项目管理规范

### 规范优先级

```
workspace/AGENTS.md (全局)  >  项目/AGENTS.md (项目)  >  项目/README.md
```

### 项目级规范查找顺序

```
1. 项目根目录/AGENTS.md     ← 项目特定规范
2. 项目根目录/README.md     ← 项目介绍
3. workspace/AGENTS.md      ← 全局规范（兜底）
```

### 规范缺失处理

| 项目 | AGENTS.md 状态 | 处理方式 |
|------|---------------|----------|
| BeatSleep | ❌ 不存在 | 使用全局规范 |
| Sleep | ❌ 不存在 | 使用全局规范 |
| HydraTrack | ❌ 不存在 | 使用全局规范 |
| QuitDo | ✅ 存在 | 全局 + QuitDo 规范 |
| Vly | ✅ 存在 | 全局 + Vly 规范 |
| sleepdo | ❌ 不存在 | 使用全局规范 |

---

## 🖥️ 多设备协作规范

### 设备识别

| 名字 | IP | 说明 |
|------|-----|------|
| **Mini** | 当前这台 | yanglindeMac-mini.local |
| **Air** | 192.168.0.15 | 另一台 Mac |

### 项目同步规则

| 项目 | 主电脑 | 同步方式 |
|------|--------|----------|
| Vly | Air | rsync / scp |
| BeatSleep | Mini | - |
| Sleep | Mini | - |
| QuitDo | Mini | - |
| HydraTrack | Mini | - |
| sleepdo | Mini | - |
| linfuse | Mini | - |

### 跨设备操作

| 操作 | 命令示例 |
|------|---------|
| SSH 连接 | `ssh yanglin@192.168.0.15` |
| 执行命令 | `openclaw nodes run --node "Air"` |
| 同步文件 | `scp file yanglin@192.168.0.15:/path` |
| rsync 同步 | `rsync -avz host:/path /local/path` |

### 记忆同步

- **Mini**: `/Users/yanglin/.openclaw/workspace/MEMORY.md`
- **Air**: `/Users/yanglin/.openclaw/workspace/MEMORY.md`
- **同步方式**: scp 手动同步或 Git 自动化

---

## 🛠️ 开发流程规范

### 前期阶段

```
1. 阅读设计文档
   - docs/README.md (项目概览)
   - docs/03-UI-UX/*.md (UI/UX)
   - docs/04-Data-Models/*.md (数据模型)

2. 列出功能点清单
   - 逐条列出所有功能
   - 不确定的设计先问
   - 确认理解无误再编码

3. 查找可复用代码
   - 搜索现有代码库
   - 避免重复造轮子
```

### 开发阶段

```
1. 小步提交
   - 每次改动最小化
   - 提交信息清晰

2. 自测验证
   - 功能单独测试
   - 边界情况考虑

3. 及时保存
   - 重要改动立即写入文件
   - 避免丢失工作

4. 代码质量
   - 关键逻辑必须注释
   - 遵循项目代码规范
   - 清理临时文件和调试代码
```

### 沟通阶段

```
1. 精准回复
   - 直接回答问题
   - 不说废话和客套话

2. 风险标注
   - 可能的问题提前说明
   - 不确定的地方标明

3. 进度汇报
   - 完成后总结做什么
   - 列出下一步
```

---

## 👥 多 AI 协作规范

### 任务分配

| 规则 | 说明 |
|------|------|
| 每人负责不同模块 | 不重叠，避免冲突 |
| 交接记录 | 完成部分写入 `memory/交接记录.md` |
| 不改他人代码 | 未经允许不修改 |
| 冲突立即报告 | 发现冲突 → 停止 → 报告 |

### Git 分支管理

```
规范分支策略：
├── main        (主干)
├── user-ai-*   (UserAI 分支)
└── code-ai-*   (CodeAI 分支)

规则：
- 不经允许不 push 到他人分支
- 合并前先 fetch + rebase
- 重大改动用 PR 方式合并
```

### 会话隔离

```
每个 AI 独立会话：
- 沟通用 sessions_send()
- 上下文用 memory 文件传递
- 不直接操作他人会话
```

---

## 💾 记忆管理规范

### 记忆文件

| 文件 | 类型 | 用途 |
|------|------|------|
| `MEMORY.md` | 长期 | 重要决策、偏好、约定 |
| `memory/YYYY-MM-DD.md` | 每日 | 工作日志、待办 |
| `memory/交接记录.md` | 协作 | 多 AI 交接信息 |

### 写入时机

| 事件 | 写入文件 |
|------|----------|
| 用户说"记住这个" | MEMORY.md 或当日 memory |
| 学到教训 | AGENTS.md 或 MEMORY.md |
| 犯错 | memory/YYYY-MM-DD.md |
| 项目分工确定 | memory/项目名-分工.md |

---

## 💾 备份规范（建议）

### 基本原则

| 规则 | 说明 |
|------|------|
| Git 管理 | 所有代码和文档用 Git 管理 |
| 定期推送 | 每次重要变更后推送到远程 |
| 云存储 | 设计文档和资源文件用 iCloud/GitHub 同步 |

### 代码项目备份

| 项目类型 | 备份方式 |
|----------|----------|
| **开源项目** | Git + GitHub 公开推送 |
| **私有项目** | Git 本地管理 |

**当前开源项目：**
- ✅ Vly → GitHub 公开仓库

**当前私有项目：**
- BeatSleep, Sleep, QuitDo, HydraTrack, linfuse, sleepdo

### 设计文档备份

```
✅ Git 管理（版本控制）
✅ iCloud/Drive 同步（多设备访问）
```

### 大型文件备份

```
✅ 外置硬盘定期备份（如 Time Machine）
✅ 云存储二次备份
```

### 禁止行为

| 行为 | 说明 |
|------|------|
| ❌ 只在本地保存 | 必须有远程备份 |
| ❌ 长期不推送 | GitHub 仓库至少每周推送 |
| ❌ 忽略 .gitignore | 确保重要文件被追踪 |

### AppIcon 规范

| 阶段 | 要求 |
|------|------|
| **立项时** | 生成占位符 AppIcon（每个项目必须**唯一**） |
| **发布前** | 决定是否更新为正式图标 |

#### AppIcon 设计要求

- **每个项目图标必须唯一**，一眼能识别项目
- 使用项目对应的**主题色**和**功能图标**
- 示例：
  - Vly: 深蓝 + ▶ (视频播放器)
  - BeatSleep: 紫色 + 🌙 (助眠)
  - EyeCare: 绿色 + 👁️ (护眼)
  - QuitDo: 橙色 + 🚬 (戒烟)
  - HydraTrack: 青色 + 💧 (喝水)

#### AppIcon 生成脚本

```
项目路径: scripts/generate_appicon.sh
使用方法: ./scripts/generate_appicon.sh [项目路径] [颜色] [图标]
前置依赖: pip3 install Pillow

示例:
./scripts/generate_appicon.sh "#1a1a2e" "▶"    # Vly
./scripts/generate_appicon.sh "#7c3aed" "🌙"   # BeatSleep
./scripts/generate_appicon.sh "#22c55e" "👁️"  # EyeCare
```

#### 规范要求

- 每个项目必须包含 `scripts/generate_appicon.sh`
- 每个项目必须有 `Resources/Assets.xcassets/AppIcon.appiconset/`
- **立项时执行脚本**，使用项目专属颜色和图标
- 发布时再决定是否换正式图标

---

## 📝 格式规范

### 文档格式

| 场景 | 格式 |
|------|------|
| Discord/WhatsApp | 不用 Markdown 表格，用列表 |
| Discord 链接 | 用 `<>` 包裹：`<https://example.com>` |
| WhatsApp | 不用 Headers，用 **bold** 或 CAPS |

### 命令格式

| 类型 | 示例 |
|------|------|
| Shell 命令 | ```bash`code` ``` |
| Swift 代码 | ```swift`code` ``` |
| 文件路径 | `/path/to/file` |

---

## ⚠️ 违反规范处理

| 级别 | 行为 | 处理 |
|------|------|------|
| P0 违反 | 泄露数据、危险命令 | 立即停止、拒绝执行 |
| P1 违反 | 不读文档、不同步 | 用户有权打断、要求重做 |
| P2 违反 | 沟通不清晰 | 改进、总结经验 |

---

## 📚 相关文档

| 文档 | 位置 |
|------|------|
| 项目清单 | MEMORY.md |
| 全局 SOUL | `workspace/SOUL.md` |
| 全局 USER | `workspace/USER.md` |
| QuitDo 规范 | `QuitDo/AGENTS.md` |
| Vly 规范 | `Vly/AGENTS.md` |

---

*本文档由 Mini 创建于 2026-02-07*
*所有 AI 开发必须严格遵守*
