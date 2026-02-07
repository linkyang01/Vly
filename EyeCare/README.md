# EyeCare - 眼疲劳缓解 App

> 中文名： EyeCare  
> 英文名： EyeCare  
> Bundle ID: `com.eyecare.app`  
> 技术栈: SwiftUI 4.0, iOS 16.0+  
> 状态: 调研完成，待开发

---

## 核心功能

| 功能 | 描述 | 优先级 |
|------|------|--------|
| ⏰ 定时提醒 | 每 20 分钟提醒休息 | P0 |
| 📊 用眼统计 | 今日/本周用眼时长 | P0 |
| 👁️ 20-20-20 引导 | 引导看远处 20 秒 | P1 |
| 🌙 护眼模式 | 屏幕色调调节 | P1 |
| ⌚ Apple Watch 联动 | 手表震动提醒 | P2 |
| 📈 用眼热力图 | 疲劳时段分析 | P2 |

---

## 差异化定位

- **和 BeatSleep 形成闭环**: 白天护眼 → 晚上助眠
- **比系统功能更主动**: 不是只统计，而是主动引导
- **轻量不打扰**: 温柔提醒，不打断工作流

---

## 项目结构

```
EyeCare/
├── Sources/
│   ├── App/
│   ├── Views/
│   ├── Models/
│   ├── Services/
│   └── Cells/
├── Resources/
├── scripts/
├── docs/
│   ├── 01-Architecture/
│   ├── 02-Requirements/
│   ├── 03-UI-UX/
│   ├── 04-Data-Models/
│   ├── 05-Services/
│   └── 06-Research/
├── deprecated/
└── archive/
```

---

## 研究文档

- [眼疲劳研究](docs/06-Research/EYECARE_RESEARCH.md)

---

## 下一步

1. [ ] 架构设计 (01-Architecture)
2. [ ] 需求文档 (02-Requirements)
3. [ ] UI/UX 设计 (03-UI-UX)
4. [ ] 数据模型 (04-Data-Models)
5. [ ] 服务实现 (05-Services)

---

## AI 行为规范

所有处理 EyeCare 项目的 AI 必须：
1. 首次会话读取 `EyeCare/AGENTS.md`
2. 遵循 Google Swift Style Guide
3. 使用蓝色/绿色渐变背景（护眼主题）
4. 文档按 01-06 分类存放
