# linfuse v1.0 功能设计文档

**版本**: 1.0  
**目标平台**: macOS 14.0+ (Sonoma+)  
**最后更新**: 2026-02-04

---

## 一、核心定位

### 产品定位
**macOS 视频库管理软件** - 专注于本地视频管理，不做服务器/流媒体

### 差异化特色
- 精美 UI 设计（参考 Infuse）
- 本地元数据存储（Core Data）
- 可魔改播放器（开源基础 + 自研）
- 灵活的付费模式（免费 + 订阅 + 买断）

---

## 二、功能模块

### ✅ v1.0 必选功能 (MVP)

| 模块 | 功能 | 数据存储 | 优先级 | 工时预估 |
|------|------|----------|--------|----------|
| **视频库管理** | 文件导入、扫描、分类 | Core Data | P0 | 40h |
| **元数据刮削** | TMDB 自动获取 | Core Data | P0 | 24h |
| **自研播放器** | IINA/VLCKit 魔改 + 解码限制 | - | P0 | 80h |
| **观看历史** | 进度保存、断点续播 | Core Data | P1 | 16h |
| **收藏夹** | 自定义收藏、标签 | Core Data | P1 | 12h |
| **搜索筛选** | 按标题/类型/评分筛选 | Core Data | P1 | 8h |
| **基础 UI** | 侧边栏、网格/列表视图、详情页 | - | P0 | 32h |
| **设置页** | 常规、播放器、刮削设置 | UserDefaults | P1 | 8h |

**MVP 总工时**: ~220h (约 6 周全职)

### ⏳ v1.x 待开发功能 (后续迭代)

| 模块 | 功能 | 触发条件 |
|------|------|----------|
| **网络存储** | SMB/NFS/WebDAV/iCloud/阿里云盘 等 | v1.1 |
| **iCloud 同步** | Core Data + CloudKit | v1.2 |
| **iOS 版本** | iPhone/iPad App | v1.3 |
| **高级解码** | 蓝光原盘、HEVC、杜比视界 | 付费解锁 |

---

## 附录 A：网盘支持清单

> **最后更新**: 2026-02-07

### Infuse 对标支持的网盘服务

#### 国外网盘（✅ 可支持）

| 网盘 | 状态 | API | 技术难度 |
|------|------|-----|----------|
| **iCloud Drive** | ✅ 推荐 | `FileManager` 原生 | ⭐ |
| **Google Drive** | ✅ 可做 | Google Drive API | ⭐⭐ |
| **Dropbox** | ✅ 可做 | Dropbox API | ⭐⭐ |
| **OneDrive** | ✅ 可做 | Microsoft Graph API | ⭐⭐ |
| **Amazon Drive** | ✅ 可做 | Amazon S3 API | ⭐⭐ |
| **Box** | ✅ 可做 | Box SDK | ⭐⭐ |
| **pCloud** | ✅ 可做 | pCloud SDK | ⭐⭐ |
| **SMB/CIFS** | ✅ 推荐 | `Network` Framework | ⭐ |
| **UPnP/DLNA** | ✅ 推荐 | `Network` Framework | ⭐ |
| **NFS** | ✅ 推荐 | `Network` Framework | ⭐ |
| **WebDAV** | ✅ 可做 | 第三方库 | ⭐⭐ |

#### 国内网盘（⚠️ 情况复杂）

| 网盘 | 是否有官方 API | 支持难度 | 优先级 |
|------|---------------|----------|--------|
| **阿里云盘** | ✅ 有 | ⭐⭐ | P1 推荐 |
| **百度网盘** | ✅ 有（限速） | ⭐⭐⭐ 麻烦 | P2 |
| **腾讯微云** | ⚠️ 不清楚 | 未知 | 待调研 |
| **夸克网盘** | ❌ 没有官方 API | ❌ 做不了 | 不支持 |
| **天翼云盘** | ✅ 有 | ⭐⭐ | P2 |
| **坚果云** | ✅ 有（专注同步） | ⭐⭐ | P2 |
| **iCloud（中国）** | ✅ 原生支持 | ⭐ | P0 |

### linfuse 网盘支持优先级

| 优先级 | 网盘 | 类型 | 说明 |
|--------|------|------|------|
| **P0** | **SMB/NFS/UPnP** | 局域网 | 免费、自己能搭 |
| **P0** | **iCloud Drive** | 云盘 | Apple 生态，用户多 |
| **P1** | **阿里云盘** | 云盘 | 国内用户量大 |
| **P1** | **Google Drive** | 云盘 | 国外用户常用 |
| **P1** | **OneDrive** | 云盘 | 办公用户常用 |
| **P2** | Dropbox | 云盘 | 国外用户常用 |
| **P2** | 坚果云 | 云盘 | 同步盘，支持好 |
| **P2** | 百度网盘 | 云盘 | 用户多但 API 麻烦 |

### 不能支持的网盘

| 网盘 | 原因 |
|------|------|
| **夸克网盘** | 没有官方 API |
| **某些小众网盘** | 没有官方 API |

### 技术实现参考

#### iOS/macOS 原生支持

| 网盘 | 实现方式 |
|------|----------|
| iCloud Drive | `FileManager` 原生 |
| SMB/NFS/UPnP | `Network` Framework |
| WebDAV | 第三方库（如 DAVKit） |

#### 需要 SDK 的

| 网盘 | SDK |
|------|-----|
| Google Drive | Google Drive API |
| OneDrive | Microsoft Graph API |
| 阿里云盘 | 阿里云盘 Open API |
| 百度网盘 | 百度网盘 SDK |
| Dropbox | Dropbox API |
| Box | Box SDK |

### 注意事项

1. **API 变更风险**: 网盘服务商可能随时变更 API，需要做好适配
2. **限速问题**: 百度网盘等国内网盘有下载限速，需要处理
3. **认证方式**: OAuth 2.0 是主流，需要实现登录流程
4. **缓存策略**: 大文件需要实现增量下载和缓存管理 |

---

## 三、数据架构

### 本地存储 (v1.0)

```
linfuse v1.0 数据目录
~/Library/Application Support/linfuse/
├── Core Data/
│   ├── linfuse.sqlite          # 主数据库
│   └── linfuse.sqlite-shm      # 共享内存
├── Cache/
│   ├── Posters/                # 海报图缓存
│   ├── Backdrops/              # 背景图缓存
│   └── Thumbnails/             # 缩略图缓存
├── Exports/
│   └── backups/                # 数据库备份
└── Logs/
    └── app.log                 # 日志文件
```

### Core Data 数据模型

#### Movie 实体
```swift
@objc(Movie)
public class Movie: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String                    // 标题
    @NSManaged public var originalTitle: String?           // 原标题
    @NSManaged public var overview: String?                // 简介
    @NSManaged public var releaseDate: Date?               // 上映日期
    @NSManaged public var runtime: Int32                   // 时长(分钟)
    @NSManaged public var rating: Double                  // 评分
    @NSManaged public var voteCount: Int32                // 评分人数
    @NSManaged public var posterPath: String?             // 海报URL
    @NSManaged public var backdropPath: String?           // 背景URL
    @NSManaged public var tmdbID: Int32?                  // TMDB ID
    
    // 文件信息
    @NSManaged public var fileURL: URL                   // 文件路径
    @NSManaged public var fileSize: Int64                 // 文件大小
    @NSManaged public var duration: Double               // 视频时长(秒)
    @NSManaged public var resolution: String?            // 分辨率 (1080p, 4K)
    @NSManaged public var codec: String?                 // 编码 (H.264, HEVC)
    @NSManaged public var fileName: String               // 文件名
    
    // 观看状态
    @NSManaged public var currentPosition: Double        // 当前播放位置
    @NSManaged public var isWatched: Bool               // 是否已看
    @NSManaged public var watchCount: Int32             // 观看次数
    @NSManaged public var lastWatchedDate: Date?        // 最后观看时间
    
    // 收藏
    @NSManaged public var isFavorite: Bool              // 是否收藏
    @NSManaged public var tags: String?                 // 自定义标签
    
    // 元数据
    @NSManaged public var metadataFetched: Bool          // 是否已刮削
    @NSManaged public var addedDate: Date               // 添加日期
    @NSManaged public var sortTitle: String?            // 排序标题
    
    // 关系
    @NSManaged public var genres: Set<Genre>?
    @NSManaged public var cast: Set<CastMember>?
    @NSManaged public var crew: Set<CrewMember>?
}
```

#### Genre 实体
```swift
@objc(Genre)
public class Genre: NSManagedObject, Identifiable {
    @NSManaged public var id: Int32
    @NSManaged public var name: String                  // 名称
    @NSManaged public var tmdbID: Int32                // TMDB ID
}
```

#### CastMember 实体
```swift
@objc(CastMember)
public class CastMember: NSManagedObject, Identifiable {
    @NSManaged public var id: Int32
    @NSManaged public var name: String                  // 名称
    @NSManaged public var character: String?            // 饰演角色
    @NSManaged public var profilePath: String?          # 头像URL
    @NSManaged public var order: Int32                  # 排序
}
```

#### WatchHistoryEntry 实体
```swift
@objc(WatchHistoryEntry)
public class WatchHistoryEntry: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var movie: Movie                  // 关联电影
    @NSManaged public var position: Double              // 播放位置
    @NSManaged public var timestamp: Date              # 记录时间
    @NSManaged public var duration: Double             # 观看时长
}
```

---

## 四、播放器设计

### 播放器选择

| 方案 | 优先级 | 许可证 | 说明 |
|------|--------|--------|------|
| **首选: IINA 魔改** | P0 | GPL 3.0 | macOS 原生 UI，基于 MPV |
| **备选: VLCKit** | P1 | LGPL 2.1 | 格式支持最广，可商用 |

### 解码限制策略

#### 免费版解码能力

| 格式 | 状态 | 说明 |
|------|------|------|
| MP4/MOV | ✅ 免费 | H.264, H.265 |
| MKV | ✅ 免费 | H.264 编码 |
| AVI | ✅ 免费 | H.264 编码 |
| WebM | ✅ 免费 | VP8/VP9 |
| **蓝光原盘 (BDMV)** | 🔒 付费 | - |
| **HEVC (4K)** | 🔒 付费 | - |
| **杜比视界** | 🔒 付费 | - |
| **杜比全景声** | 🔒 付费 | - |

#### 付费版解锁

| 功能 | 解锁条件 |
|------|----------|
| 蓝光原盘播放 | 付费后解锁 |
| 4K HEVC 解码 | 付费后解锁 |
| 杜比视界 | 付费后解锁 |
| 高级音频解码 | 付费后解锁 |

### 播放器界面设计

```swift
// 播放器功能
protocol LinfusePlayer {
    // 基本播放
    func play(url: URL) throws
    func pause()
    func resume()
    func seek(to: Double)
    
    // 播放控制
    var isPlaying: Bool { get }
    var currentPosition: Double { get }
    var duration: Double { get }
    
    // 解码限制检查
    func canPlay(url: URL) -> Bool
    
    // UI
    func showControls()
    func hideControls()
    func toggleFullscreen()
}
```

### 播放器 UI 组件

```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │                    视频画面                          │   │
│  │                                                     │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ⏮  ▶️  ⏭          ─────────────────────           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 00:12:34 / 02:15:22                        🔊 🌙 🔗  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🅿️ 解码受限: 蓝光原盘需要升级              [升级 Pro] │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 五、商业化设计

### 定价策略

| 版本 | 价格 | 包含功能 |
|------|------|----------|
| **免费版** | ¥0 | 基础解码 (MP4/MKV/AVI)、完整管理功能 |
| **年度订阅** | ¥38/年 | 解锁所有解码功能 + 未来新功能 |
| **永久买断** | ¥58 一次性 | 终身所有解码功能 (不含未来大版本) |

### 产品 ID (App Store Connect)

| 产品 | ID | 类型 |
|------|-----|------|
| 年度订阅 | `linfuse.yearly` | 自动续订订阅 |
| 永久买断 | `linfuse.lifetime` | 非消耗型 |

### 功能对比

| 功能 | 免费版 | 年度订阅 | 永久买断 |
|------|--------|----------|----------|
| 视频库管理 | ✅ | ✅ | ✅ |
| 元数据刮削 | ✅ | ✅ | ✅ |
| 播放器 (基础) | ✅ | ✅ | ✅ |
| 播放器 (蓝光) | ❌ | ✅ | ✅ |
| 播放器 (4K HEVC) | ❌ | ✅ | ✅ |
| 播放器 (杜比视界) | ❌ | ✅ | ✅ |
| 未来更新 | ❌ | ✅ (订阅期内) | ❌ |

---

## 六、技术架构

### 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ SwiftUI     │  │ AppKit      │  │ Player UI           │ │
│  │ Views       │  │ Menu/Toolbar│  │ (IINA/VLCKit)      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Business Logic                          │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐ │
│  │ LibraryManager │  │ MetadataService│  │ PlayerManager│ │
│  │  - 文件导入    │  │  - TMDB 刮削   │  │  - 解码限制  │ │
│  │  - 分类管理    │  │  - 图片缓存    │  │  - 播放控制  │ │
│  └────────────────┘  └────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌────────────────────┐  ┌────────────────────────────────┐ │
│  │ Core Data          │  │ FileSystem                     │ │
│  │  - Movie 实体      │  │  - 视频文件                     │ │
│  │  - 观看历史        │  │  - 封面图缓存                   │ │
│  │  - 收藏夹          │  │  - 缩略图缓存                   │ │
│  └────────────────────┘  └────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 项目结构

```
linfuse/
├── project.yml                    # XcodeGen 配置
├── Sources/
│   ├── App/
│   │   ├── LinfuseApp.swift      # App 入口
│   │   ├── AppDelegate.swift     # 生命周期
│   │   └── ContentView.swift     # 主视图
│   ├── Models/
│   │   ├── CoreData/
│   │   │   ├── Linfuse.xcdatamodeld  # Core Data 模型
│   │   │   └── Entities.swift    # 实体定义
│   │   └── DTO/
│   │       └── TMDBModels.swift  # API 数据模型
│   ├── ViewModels/
│   │   ├── LibraryViewModel.swift # 库管理逻辑
│   │   ├── PlayerViewModel.swift  # 播放器逻辑
│   │   └── SettingsViewModel.swift # 设置逻辑
│   ├── Services/
│   │   ├── FileScanner.swift      # 文件扫描
│   │   ├── TMDBService.swift     # TMDB API
│   │   ├── MetadataCache.swift    # 元数据缓存
│   │   └── PlayerEngine.swift    # 播放器引擎
│   ├── Utilities/
│   │   ├── Extensions/           # 扩展
│   │   └── Helpers/              # 辅助工具
│   └── Views/
│       ├── MainWindow/
│       │   ├── ContentView.swift
│       │   ├── SidebarView.swift
│       │   └── ToolbarView.swift
│       ├── Library/
│       │   ├── MovieGridView.swift
│       │   ├── MovieListView.swift
│       │   └── MovieDetailView.swift
│       ├── Player/
│       │   ├── PlayerView.swift
│       │   └── PlayerControls.swift
│       └── Settings/
│           └── SettingsView.swift
├── Resources/
│   ├── Assets.xcassets/
│   └── Localizations/
└── README.md
```

---

## 七、依赖管理

### Swift Package Manager

| 包 | 版本 | 用途 |
|----|------|------|
| **Kingfisher** | 7.10.0+ | 图片加载/缓存 |
| **Lottie** | 4.3.0+ | 动画 |
| **IINA** | (子模块) | 播放器 UI/逻辑参考 |
| **VLCKit** | 3.8.0+ | (备选) 播放器 |

### 播放器依赖策略

```
// project.yml

packages:
  Kingfisher:
    url: https://github.com/onevcat/Kfither.git
    from: "7.10.0"
  Lottie:
    url: https://github.com/airbnb/lottie-ios.git
    from: "4.3.0"

targets:
  linfuse:
    type: application
    platform: macOS
    sources:
      - path: Sources
    dependencies:
      - package: Kingfisher
      - package: Lottie
    settings:
      base:
        SWIFT_VERSION: "5.9"
        TARGETED_DEVICE_FAMILY: "2"  # macOS only
```

---

## 八、里程碑规划

### 开发阶段

| 阶段 | 内容 | 工时 | 目标 |
|------|------|------|------|
| **Phase 0** | 项目初始化 (XcodeGen、Core Data、基础架构) | 24h | 可编译运行 |
| **Phase 1** | 视频库核心 (文件扫描、导入、分类) | 40h | 可导入视频 |
| **Phase 2** | 元数据刮削 (TMDB 集成、缓存) | 24h | 自动获取海报 |
| **Phase 3** | 播放器集成 (IINA 魔改/解码限制) | 80h | 可播放视频 |
| **Phase 4** | UI/UX (侧边栏、详情页、设置页) | 32h | UI 完成 |
| **Phase 5** | 商业化 (StoreKit、iap) | 16h | 可购买 |
| **Phase 6** | 测试 & 优化 | 24h | 上架准备 |

**总工时**: ~240h (约 6 周全职)

### 里程碑

| 里程碑 | 目标日期 | 说明 |
|--------|----------|------|
| **M0** | Week 1 | 项目可编译，基础架构完成 |
| **M1** | Week 2 | 可导入视频文件 |
| **M2** | Week 3 | 自动获取海报和简介 |
| **M3** | Week 5 | 可播放视频 (基础格式) |
| **M4** | Week 6 | UI 完成，可提交审核 |

---

## 九、开源许可证注意事项

### IINA (GPL 3.0)

**问题**: IINA 使用 GPL 3.0 许可证，商业使用需要遵守:
1. 任何修改必须开源
2. 必须提供源代码
3. 必须声明使用了 IINA

### VLCKit (LGPL 2.1)

**优势**: 
- 可以商业使用
- 可以修改代码
- 不要求开源修改版本

**要求**:
- 必须保留 LGPL 声明
- 如果修改了 VLCKit 源码，建议开源

### 建议

| 方案 | 风险 | 建议 |
|------|------|------|
| **使用 IINA** | 高 (GPL 3.0) | 仅用于学习参考，不直接集成代码 |
| **使用 VLCKit** | 低 (LGPL 2.1) | ✅ 推荐，可商业使用 |
| **自研播放器** | 无 | 长期方案，短期用 VLCKit |

---

## 十、后续迭代计划

### v1.1 (上线后 1 个月)
- Bug 修复
- 用户反馈优化
- 性能优化

### v1.2 (上线后 3 个月)
- 网络存储 (SMB/NFS)
- iCloud 同步准备

### v1.3 (上线后 6 个月)
- iOS 版本
- 家庭共享

---

**文档版本**: 1.0  
**创建日期**: 2026-02-04  
**作者**: Nex ✨
