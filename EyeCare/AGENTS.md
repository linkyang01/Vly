# EyeCare AI 行为规范

> 版本: 1.0.0  
> 更新日期: 2026-02-07

## 核心原则

| 优先级 | 原则 | 说明 |
|--------|------|------|
| P0 | 轻量不打扰 | 功能简单，不做复杂功能 |
| P0 | 数据隐私 | 本地存储，隐私优先 |
| P1 | 温柔提醒 | 不是强制中断，是温和引导 |
| P1 | 系统集成 | 复用系统功能（Screen Time, Night Shift） |

## 设计规范

### 颜色主题

| 元素 | 颜色 | 说明 |
|------|------|------|
| 主色 | `#22C55E` (绿色) | 护眼、健康 |
| 背景 | `#ECFDF5` → `#D1FAE5` | 浅绿渐变 |
| 强调色 | `#10B981` | 成功、达成 |

### 交互原则

- 简单直接，一键操作
- 提醒要温柔，不是警告
- 数据可视化要清晰

## 代码规范

- 遵循 Google Swift Style Guide
- 使用 SwiftUI 4.0
- 最小依赖，优先使用系统框架
- UserNotifications + HealthKit + WatchConnectivity

## 文档规范

| 目录 | 内容 |
|------|------|
| `docs/01-Architecture/` | 架构设计 |
| `docs/02-Requirements/` | 需求文档 |
| `docs/03-UI-UX/` | UI/UX 设计 |
| `docs/04-Data-Models/` | 数据模型 |
| `docs/05-Services/` | 服务实现 |
| `docs/06-Research/` | 竞品/科学调研 |

---

## 相关文档

- [README.md](README.md)
- [docs/06-Research/EYECARE_RESEARCH.md](docs/06-Research/EYECARE_RESEARCH.md)
