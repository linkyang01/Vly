# SleepDo 设计文档

> 重构日期: 2026-02-05
> 核心定位: 帮助失眠人群入睡

## 设计理念

**科学驱动、简单有效**
- 每个功能都有科学依据
- 减少噪音，聚焦核心问题
- 数据驱动个性化

## 文档结构

| 目录 | 内容 | 文档数 |
|------|------|--------|
| [01-Architecture](01-Architecture/README.md) | 架构设计 | 1 |
| [02-Requirements](02-Requirements/PHASE2.md) | 需求规格 | 1 |
| [03-UI-UX](03-UI-UX/) | UI/UX 设计 | 4 |
| [04-Data-Models](04-Data-Models/) | 数据模型 | 3 |
| [05-Services](05-Services/) | 服务设计 | 3 |
| [06-Research](06-Research/) | 研究文档 | 3 |

## 核心功能

| 功能 | 优先级 | 科学依据 |
|------|--------|---------|
| 声音助眠 | P0 | 白噪声掩盖环境噪音 |
| 4-7-8呼吸 | P0 | Harvard研究证实缩短50%入睡时间 |
| AI智能唤醒 | P1 | Apple Watch HRV检测浅睡眠 |
| 成就系统 | P2 | 行为心理学，小目标降低焦虑 |

## MVP 功能清单

### 免费功能
- 10个基础声音
- 基础4-7-8呼吸练习
- 手动闹钟
- 3天睡眠数据存储

### 付费功能
- 15个全部声音
- AI智能唤醒（Watch）
- 15个成就
- 30天数据存储
- Apple Watch同步

## 快速导航

### 架构
- [架构设计](01-Architecture/README.md) - 技术栈、项目结构、数据流

### 数据模型
- [数据模型](04-Data-Models/DATA_MODELS.md) - 所有模型定义
- [声音库](04-Data-Models/SOUNDS.md) - 15个声音设计

### 服务
- [服务架构](05-Services/ARCHITECTURE.md) - 服务层设计
- [AI智能唤醒](05-Services/AI_WAKEUP.md) - Apple Watch浅睡检测

### 研究
- [睡眠研究](06-Research/SLEEP_RESEARCH.md) - 睡眠阶段科学
- [闹钟研究](06-Research/ALARM_RESEARCH.md) - 渐强唤醒

## 相关文档

- [项目 README](../README.md)
- [AI 行为规范](../AGENTS.md)
