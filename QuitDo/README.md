# QuitDo 设计文档

> **重要**: 此文件内容已与 `docs/` 目录同步更新。
> 详细文档请查看：
> - 项目介绍: `docs/01-Overview/PROJECT.md`
> - 设计文档: `docs/README.md`
> - AI 行为规范: `AGENTS.md`

## 项目信息

| 项目 | 值 |
|------|------|
| 中文名 | 戒烟宝 |
| 英文名 | QuitDo |
| Bundle ID | com.quitdo.app |
| 技术栈 | SwiftUI 4.0, iOS 16.0+ |

## 核心功能

- 📊 戒烟打卡（天数/省钱/健康恢复）
- 🤖 AI 教练（MiniMax 2.1 驱动）
- 🏆 成就系统（35+ 成就）
- 💰 省钱计算器
- 📈 数据可视化（HealthKit + Apple Watch）

## 项目结构规范

| 目录 | 用途 |
|------|------|
| `Sources/` | 源代码（App/ Views/ Models/ Services/ Cells/） |
| `Resources/` | 资源文件 |
| `scripts/` | 工具脚本 |
| `docs/` | 设计文档（01-Overview 到 06-Research） |
| `tests/` | 测试文件 |

## AI 行为规范

所有处理 QuitDo 项目的 AI 必须：
1. 首次会话读取 `AGENTS.md`
2. 遵循 Google Swift Style Guide
3. 使用紫色渐变背景（`#0D0D1A → #1A1A3E → #2D1B4E`）
4. 文档按 01-06 分类存放

---

*最后更新: 2026-02-06*
