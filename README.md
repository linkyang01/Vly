# Vly

Vly 是一个重新启动的 Apple 生态媒体播放器项目，目标是做成类似 Infuse 的全能播放器体验，覆盖本地视频、家庭媒体库、NAS、网盘、字幕音轨、播放进度同步等场景。

## 重启原则

本项目不再沿用旧的“简单播放器”定位，而是从需求层重新开始。

核心原则：

1. 先验证播放内核，再做复杂界面。
2. 第一阶段只做 macOS，不同时展开 iOS、iPadOS、tvOS。
3. 播放能力优先于媒体库和 UI 美化。
4. 必须使用 KSPlayer 与 FFmpeg 相关能力，不允许只用 AVPlayer 冒充全能播放器。
5. 每个阶段都必须有可运行、可验证的交付物。

## 产品定位

Vly 是面向 Apple 生态的全能媒体播放器，长期目标包括：

- 本地视频播放；
- 多格式视频解码；
- 外挂字幕与内嵌字幕；
- 多音轨切换；
- 播放列表与播放队列；
- 本地媒体库和海报墙；
- 电影、电视剧、季集识别；
- NAS、SMB、WebDAV、DLNA、URL Stream；
- 播放历史和继续观看；
- iCloud 同步播放进度和偏好设置；
- 后续扩展到 iOS、iPadOS、tvOS。

## 第一阶段 MVP

第一阶段只完成 macOS 最小可运行播放器。

必须实现：

- 打开本地视频文件；
- 拖拽文件播放；
- KSPlayer 播放适配层；
- MP4 与 MKV 基础播放验证；
- 播放、暂停、进度、音量、全屏；
- 基础错误提示。

暂不实现：

- 媒体库海报墙；
- TMDB 元数据刮削；
- SMB / WebDAV / DLNA；
- iCloud 同步；
- iOS / iPadOS / tvOS；
- 复杂设置中心。

## 文档

- `docs/PRD.md`：产品需求文档
- `docs/TECHNICAL_ARCHITECTURE.md`：技术架构设计
- `docs/ROADMAP.md`：开发路线图
- `docs/FORMAT_SUPPORT.md`：格式支持清单
- `docs/MVP_SCOPE.md`：MVP 范围定义

## 当前状态

项目进入重启阶段。当前优先工作是完成需求、架构、路线图和格式支持清单，然后再开始最小播放器 Demo。
