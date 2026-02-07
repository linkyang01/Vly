# Vly 设计文档

> 简洁优雅的 macOS/iOS 开源视频播放器

## 文档结构

| 目录 | 内容 | 说明 |
|------|------|------|
| [01-Architecture](01-Architecture/README.md) | 架构设计 | 技术栈、模块设计、数据流 |
| [02-Requirements](02-Requirements/FEATURES.md) | 功能需求 | MVP 功能、扩展功能 |
| [03-UI-UX](03-UI-UX/DESIGN.md) | UI/UX 设计 | 界面布局、交互设计 |
| [04-Data-Models](04-Data-Models/MODELS.md) | 数据模型 | Video、Playlist、PlaybackState |
| [05-Services](05-Services/SERVICES.md) | 服务设计 | PlayerService、PlaylistService |
| [06-Research](06-Research/KSPLAYER_INTEGRATION.md) | 研究文档 | KSPlayer 集成问题 |
| [06-Research](06-Research/KSPLAYER_AND_IINA_REFERENCE.md) | **KSPlayer + IINA 参考** | 源码分析、UI 设计规范 |
| [06-Research](06-Research/IMPLEMENTATION_PLAN.md) | **完整实施方案** | 步骤、时间安排、验收标准 |

## 快速导航

### 新增功能

1. 在 `docs/02-Requirements/FEATURES.md` 添加功能描述
2. 在 `docs/04-Data-Models/MODELS.md` 定义数据模型
3. 在 `docs/05-Services/SERVICES.md` 设计服务接口
4. 在 `Sources/` 实现代码

### 修改架构

1. 更新 `docs/01-Architecture/README.md`
2. 更新相关设计文档
3. 更新项目结构注释

### 集成新依赖

1. 在 `docs/06-Research/` 添加研究文档
2. 更新 `project.yml` 和 `Package.swift`
3. 更新 `docs/01-Architecture/` 依赖说明

## 相关链接

- [项目 README](../README.md)
- [KSPlayer GitHub](https://github.com/kingslay/KSPlayer)
