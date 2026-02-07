# BeatSleep AI 行为规范

> **继承**: 全局规范 `workspace/AGENTS.md`
> **本文档**: BeatSleep 项目特定规范
> **版本**: 1.0.0
> **更新**: 2026-02-07

---

## 项目概述

| 项目 | 值 |
|------|------|
| 名称 | BeatSleep |
| 描述 | iOS 助眠 App |
| 技术栈 | SwiftUI 4.0, iOS 16.0+ |
| 核心功能 | 4-7-8 呼吸法、渐进式肌肉放松、身体扫描 |

---

## 继承规范

处理 BeatSleep 项目时，**必须**同时遵守：

| 规范 | 文件 | 说明 |
|------|------|------|
| 全局规范 | `workspace/AGENTS.md` | 最高优先级 |
| 项目编码 | `CODING_STANDARDS.md` | 代码风格 |
| 项目概览 | `README.md` | 核心功能说明 |

---

## 文档必读

### 处理 BeatSleep 前，必须阅读：

```
1. README.md
2. CODING_STANDARDS.md
3. docs/README.md
4. 相关的设计文档（根据任务）
```

### 关键文档位置

| 内容 | 文件 |
|------|------|
| 架构设计 | `docs/01-Architecture/` |
| 功能需求 | `docs/02-Requirements/` |
| UI/UX 设计 | `docs/03-UI-UX/` |
| 数据模型 | `docs/04-Data-Models/` |

---

## 项目特定规则

### Git 分支规范

```
├── main              (主干)
└── feature/xxx       (功能分支)
```

### 提交规范

```
<type>(<scope>): <subject>

Types: feat, fix, docs, refactor, test, chore
Example: feat(breathing): 添加4-7-8呼吸动画
```

---

## 禁止行为

| 行为 | 说明 |
|------|------|
| ❌ 跳过 CODING_STANDARDS.md | 必须遵循项目编码规范 |
| ❌ 不读设计文档直接编码 | 必须先理解需求 |
| ❌ 修改 watchOS 代码未测试 | Apple Watch 需要真机测试 |
| ❌ 硬编码 API Keys | 使用配置文件 |

---

## 常用命令

```bash
# 生成项目
cd BeatSleep
./scripts/generate_project.sh

# 构建
xcodebuild -project BeatSleep.xcodeproj -scheme BeatSleep build

# 测试
xcodebuild test -project BeatSleep.xcodeproj -scheme BeatSleep
```

---

## 相关文档

| 文档 | 位置 |
|------|------|
| 全局规范 | `workspace/AGENTS.md` |
| 编码规范 | `CODING_STANDARDS.md` |
| 项目概览 | `README.md` |
| 设计文档 | `docs/README.md` |

---

*本文档由 Mini 创建于 2026-02-07*
*遵循全局规范体系*
