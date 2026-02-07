# QuitDo AI 行为规范

> **继承**: 全局规范 `workspace/AGENTS.md`
> **本文档**: QuitDo 项目特定规范
> **版本**: 1.1.0
> **更新**: 2026-02-07

---

## 项目概述

| 项目 | 值 |
|------|------|
| 名称 | 戒烟宝 (QuitDo) |
| 描述 | AI 驱动的极简戒烟助手 |
| 技术栈 | SwiftUI 4.0, iOS 16.0+ |
| 目标用户 | 中国 3 亿烟民 |

---

## 继承规范

| 规范 | 文件 | 说明 |
|------|------|------|
| 全局规范 | `workspace/AGENTS.md` | 最高优先级 |

---

## 文档必读

```
1. README.md (项目概览)
2. docs/README.md (设计文档)
3. 遵循代码规范
```

---

## 常用命令

```bash
# 构建项目
xcodebuild -project QuitDo.xcodeproj -scheme QuitDo -configuration Debug build

# 运行测试
xcodebuild test -project QuitDo.xcodeproj -scheme QuitDo
```

---

## 禁止行为

| 行为 | 说明 |
|------|------|
| 🚫 硬编码 API Key | 使用配置文件 |
| 🚫 提交测试代码到主分支 | 保持主分支干净 |
| 🚫 修改其他模块未经确认 | 遵循模块边界 |

---

## 相关文档

| 文档 | 位置 |
|------|------|
| 全局规范 | `workspace/AGENTS.md` |

---

*更新时间: 2026-02-07*
*遵循全局规范体系*
