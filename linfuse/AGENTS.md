# linfuse AI 行为规范

> **继承**: 全局规范 `workspace/AGENTS.md`
> **本文档**: linfuse 项目特定规范
> **版本**: 1.0.0
> **更新**: 2026-02-07

---

## 项目概述

| 项目 | 值 |
|------|------|
| 名称 | linfuse |
| 描述 | 多平台媒体库管理应用 |
| 平台 | macOS 14.0+ / iOS 17.0+ |
| 状态 | 暂停（未来重要项目） |

---

## 继承规范

| 规范 | 文件 | 说明 |
|------|------|------|
| 全局规范 | `workspace/AGENTS.md` | 最高优先级 |

---

## 文档必读

```
1. README.md (项目概览)
2. ARCHITECTURE.md (架构设计)
3. FEATURE_DESIGN.md (功能设计)
4. DEVELOPMENT_PLAN.md (开发计划)
```

---

## 关键文档

| 内容 | 文件 |
|------|------|
| 架构设计 | `ARCHITECTURE.md` |
| 功能设计 | `FEATURE_DESIGN.md` |
| 开发计划 | `DEVELOPMENT_PLAN.md` |
| App Store | `PHASE8_APPSTORE.md` |

---

## 特殊规则

### 1. 暂停状态

- **不主动开发**此项目
- 只做必要的维护
- 等待未来重启

### 2. 依赖 Vly

- Vly 是为 linfuse 开发的开源播放器
- Vly 的开发优先级更高
- 两个项目代码可能共享

### 3. iCloud 同步

- 复杂功能，涉及 CloudKit
- 修改前必须详细理解架构

---

## 禁止行为

| 行为 | 说明 |
|------|------|
| ❌ 主动重启开发 | 等待用户明确指示 |
| ❌ 忽略 iCloud 复杂性 | 涉及 CloudKit，需要谨慎 |
| ❌ 破坏现有架构 | 遵循 ARCHITECTURE.md |

---

## 相关文档

| 文档 | 位置 |
|------|------|
| 全局规范 | `workspace/AGENTS.md` |
| 项目概览 | `README.md` |
| 架构设计 | `ARCHITECTURE.md` |

---

*本文档由 Mini 创建于 2026-02-07*
*遵循全局规范体系*
