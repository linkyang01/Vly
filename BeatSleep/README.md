# BeatSleep

> 帮助快速入睡的 iOS App
> 
> **核心差异化：** 4-7-8 呼吸法 + Watch 数据展示

## 项目信息

| 项目 | 值 |
|------|------|
| App 名 | BeatSleep |
| 副标题 | Fall Asleep Faster |
| Bundle ID | com.beatsleep.app |
| 技术栈 | SwiftUI 4.0, iOS 16.0+ |
| 目标市场 | 美区为主 |

## 核心功能

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 4-7-8呼吸 | P0 | 核心差异化 |
| 渐进式肌肉放松 | P1 | 第二选择 |
| 身体扫描 | P1 | 第三选择 |
| "2-1-6"呼吸 | P2 | 入门 |
| 白噪音 | P2 | 环境辅助 |
| Watch 心率/HRV | P1 | 数据展示 |
| 睡眠记录 | P1 | 效果追踪 |

## 商业模式

| 方案 | 价格 | 市场 |
|------|------|------|
| 月付 | $4.99/月 | 美区 |
| 年付 | $39.99/年 | 美区 |
| 终身 | $99.99 | 美区 |

## 项目结构

```
BeatSleep/
├── Sources/
│   ├── App/           # 应用入口
│   ├── Views/         # UI视图
│   ├── Models/        # 数据模型
│   ├── Services/      # 业务逻辑
│   └── WatchApp/      # Watch应用
├── Resources/         # 资源文件
├── docs/              # 设计文档
└── memory/            # 开发记录
```

## 相关文档

- [设计文档](./docs/README.md)
- [数据模型](./docs/04-Data-Models/DATA_MODELS.md)
- [商业模式](./docs/02-Requirements/MVP_PLAN.md)
