# Sleep AI 行为规范

> **继承**: 全局规范 `workspace/AGENTS.md`
> **本文档**: Sleep 项目特定规范（BeatSleep 克隆）
> **版本**: 1.0.0
> **更新**: 2026-02-07

---

## 项目概述

| 项目 | 值 |
|------|------|
| 名称 | Sleep |
| 描述 | BeatSleep 克隆，用于验证 |
| 来源 | 基于 BeatSleep 代码 |
| 目的 | 功能验证和测试 |

---

## 继承规范

| 规范 | 文件 | 说明 |
|------|------|------|
| 全局规范 | `workspace/AGENTS.md` | 最高优先级 |
| BeatSleep 编码 | `../BeatSleep/CODING_STANDARDS.md` | 代码风格 |

---

## 与 BeatSleep 的关系

```
Sleep  ← 复制自 BeatSleep
├── 目的: 功能验证
├── 特点: 轻量、干净
└── 原则: 保持与 BeatSleep 同步
```

### 同步规则

| 组件 | 同步方式 |
|------|----------|
| 源代码 | 复制/同步 |
| 设计文档 | 复制 |
| 资源文件 | 复制 |

---

## 特殊规则

### 1. 验证优先

- 先在 Sleep 验证功能
- 验证成功后同步到 BeatSleep
- Sleep 作为"测试环境"

### 2. 轻量原则

- 不添加多余功能
- 只保留核心逻辑
- 保持代码干净

### 3. 文档简化

- 只保留必要的 README
- 不重复造文档

---

## 禁止行为

| 行为 | 说明 |
|------|------|
| ❌ 添加 BeatSleep 没有的功能 | 保持克隆一致性 |
| ❌ 跳过验证直接开发 | 验证优先原则 |
| ❌ 独立发展分支 | 保持与 BeatSleep 同步 |

---

## 相关文档

| 文档 | 位置 |
|------|------|
| 全局规范 | `workspace/AGENTS.md` |
| BeatSleep 规范 | `../BeatSleep/AGENTS.md` |
| BeatSleep 编码 | `../BeatSleep/CODING_STANDARDS.md` |

---

*本文档由 Mini 创建于 2026-02-07*
*遵循全局规范体系*
