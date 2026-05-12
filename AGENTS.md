# AGENTS.md - Vly 项目 AI 开发规范

## 项目重启状态

Vly 已重启为 Apple 生态全能媒体播放器项目，目标是做类似 Infuse 的本地与网络媒体播放体验。

当前阶段不是继续修旧代码，而是重新建立需求、架构、MVP 范围和最小播放器 Demo。

## 最高优先级原则

1. 播放内核优先于 UI 美化。
2. 第一阶段只做 macOS。
3. 不允许只用 AVPlayer 作为核心播放器。
4. 必须围绕 KSPlayer 与 FFmpeg 能力建立播放内核适配层。
5. 不要一开始做媒体库、海报墙、iCloud 同步和多平台适配。
6. 每个阶段必须有明确验收标准。
7. 代码变更必须同步更新文档。
8. 高风险删除、重构、依赖调整必须先说明影响。

## 产品方向

Vly 长期目标包括：

- 多格式视频播放；
- 本地文件与文件夹播放；
- 字幕加载与切换；
- 多音轨切换；
- 播放列表与播放队列；
- 本地媒体库与海报墙；
- 电影、电视剧、季集识别；
- SMB、WebDAV、DLNA、URL Stream；
- iCloud 同步播放进度和偏好；
- 后续扩展到 iOS、iPadOS、tvOS。

## 第一阶段 MVP 约束

第一阶段只做 macOS 本地播放器 Demo。

必须包含：

- 打开本地视频文件；
- 拖拽文件播放；
- KSPlayer 播放适配；
- MP4 与 MKV 基础播放验证；
- 播放、暂停、进度、音量、全屏；
- 基础错误提示。

暂不包含：

- 媒体库；
- 海报墙；
- TMDB 元数据；
- SMB / WebDAV / DLNA；
- iCloud 同步；
- iOS / iPadOS / tvOS；
- 商业化功能。

## 技术规范

- 语言：Swift
- UI：SwiftUI
- 平台：macOS first
- 架构：MVVM + PlayerCore Adapter
- 播放内核：KSPlayer + FFmpeg 能力
- 项目管理：优先使用 XcodeGen 或 Swift Package Manager，具体以技术验证结果确定

## 建议目录结构

```text
Vly/
├── Sources/
│   ├── App/
│   ├── PlayerCore/
│   ├── Models/
│   ├── Services/
│   ├── Views/
│   └── Utilities/
├── Resources/
├── docs/
│   ├── PRD.md
│   ├── TECHNICAL_ARCHITECTURE.md
│   ├── ROADMAP.md
│   ├── FORMAT_SUPPORT.md
│   └── MVP_SCOPE.md
├── scripts/
├── project.yml
└── README.md
```

## 开发顺序

1. 完成需求文档。
2. 完成技术架构文档。
3. 完成格式支持清单。
4. 建立 macOS 最小播放器工程。
5. 集成 KSPlayer。
6. 验证 MP4 / MKV 播放。
7. 加基础播放控制。
8. 再进入字幕、音轨、播放列表。

## 禁止行为

- 不要只用 AVPlayer 交付全能播放器能力。
- 不要先做复杂媒体库。
- 不要先做 iOS / tvOS。
- 不要直接复制旧结构继续修补。
- 不要把不能运行的空架构当作完成。
- 不要忽略许可证风险。
- 不要修改第三方播放器源码，优先使用适配层。

## PR 要求

每个 PR 必须说明：

1. 本次修改内容；
2. 影响范围；
3. 是否涉及播放内核；
4. 是否涉及依赖或许可证；
5. 如何验证；
6. 风险点和后续工作。
