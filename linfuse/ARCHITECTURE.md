# Multi-Platform Architecture with iCloud Sync

## Executive Summary

Transforming linfuse from a **macOS-only** application to a **cross-platform solution** supporting both **macOS 14+** and **iOS 17+** with **iCloud synchronization**.

## Core Design Principles

1. **Single Codebase, Two Platforms** - SwiftUI with conditional compilation
2. **Cloud-First Data Layer** - Core Data + CloudKit for seamless sync
3. **Adaptive UI** - Platform-aware interfaces
4. **Progressive Web App (PWA) Ready** - Future web expansion

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      Shared Business Logic                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │ ViewModels   │  │ Services    │  │ Utilities              │  │
│  │ (Shared)    │  │ (Shared)     │  │ (Shared)                │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Data Layer                               │
│  ┌──────────────────────┐  ┌──────────────────────────────────┐ │
│  │ Core Data + CloudKit │  │ TMDB API Service                 │ │
│  │ (iCloud Sync)        │  │ (Network)                        │ │
│  └──────────────────────┘  └──────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
              │                                      │
              ▼                                      ▼
┌─────────────────────────────┐     ┌─────────────────────────────┐
│         macOS Target        │     │          iOS Target         │
│  ┌───────────────────────┐  │     │  ┌───────────────────────┐   │
│  │ SwiftUI + AppKit      │  │     │  │ SwiftUI + UIKit       │   │
│  │ (Mouse/Keyboard)      │  │     │  │ (Touch)               │   │
│  └───────────────────────┘  │     │  └───────────────────────┘   │
└─────────────────────────────┘     └─────────────────────────────┘
```

---

## 1. Project Configuration

### `project.yml` - Multi-Platform Setup

```yaml
name: linfuse
options:
  bundleIdPrefix: com.linfuse
  deploymentTarget:
    iOS: "17.0"
    macOS: "14.0"
  xcodeVersion: "15.0"
  generateEmptyDirectories: true
  groupSortPosition: top

settings:
  base:
    SWIFT_VERSION: "5.9"
    MARKETING_VERSION: "1.0.0"
    CURRENT_PROJECT_VERSION: "1"
    DEVELOPMENT_TEAM: ""
    CODE_SIGN_STYLE: Automatic
    
packages:
  Kingfisher:
    url: https://github.com/onevcat/Kingfisher.git
    from: "7.10.0"
  Lottie:
    url: https://github.com/airbnb/lottie-ios.git
    from: "4.3.0"
  CloudKit:
    url: https://github.com/apple/swift-cloudkit.git
    from: "1.0.0"

targets:
  # ==================== iOS App ====================
  linfuse-iOS:
    type: application
    platform: iOS
    sources:
      - path: Sources
        excludes:
          - "**/.DS_Store"
          - "**/MacOnly/**"
        variants:
          - iOS
      - path: Resources-iOS
      - path: Resources/Shared
    resources:
      - path: Resources/Assets.xcassets
      - path: Resources/Localizations
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.linfuse.app
        INFOPLIST_FILE: Resources-iOS/Info.plist
        PRODUCT_NAME: linfuse
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        TARGETED_DEVICE_FAMILY: "1,2"
        SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD: YES
        CODE_SIGN_ENTITLEMENTS: Resources-iOS/linfuse-iOS.entitlements
    dependencies:
      - package: Kingfisher
      - package: Lottie
      - package: CloudKit

  # ==================== macOS App ====================
  linfuse-macOS:
    type: application
    platform: macOS
    sources:
      - path: Sources
        excludes:
          - "**/.DS_Store"
          - "**/iOSOnly/**"
        variants:
          - macOS
      - path: Resources-macOS
      - path: Resources/Shared
    resources:
      - path: Resources/Assets.xcassets
      - path: Resources/Localizations
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.linfuse.app
        INFOPLIST_FILE: Resources-macOS/Info.plist
        PRODUCT_NAME: linfuse
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        LD_RUNPATH_SEARCH_PATHS: "$(inherited) @executable_path/../Frameworks"
        COMBINE_HIDPI_IMAGES: YES
        CODE_SIGN_ENTITLEMENTS: Resources-macOS/linfuse-macOS.entitlements
    dependencies:
      - package: Kingfisher
      - package: Lottie
      - package: CloudKit

  # ==================== Shared Tests ====================
  linfuseTests:
    type: bundle.unit-test
    platform: [iOS, macOS]
    sources:
      - path: Tests/UnitTests
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.linfuse.app.tests
    dependencies:
      - target: linfuse

schemes:
  linfuse-iOS:
    build:
      targets:
        linfuse-iOS: all
        linfuseTests: [test]
    run:
      config: Debug
    test:
      config: Debug
    profile:
      config: Release
    archive:
      config: Release

  linfuse-macOS:
    build:
      targets:
        linfuse-macOS: all
        linfuseTests: [test]
    run:
      config: Debug
    test:
      config: Debug
    profile:
      config: Release
    archive:
      config: Release
```

---

## 2. Data Layer Architecture

### Core Data + CloudKit Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                    Core Data Stack                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 NSPersistentCloudKitContainer            │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │   │
│  │  │ Local Store │──│ iCloud Sync │──│ Remote Store    │  │   │
│  │  │ (SQLite)    │  │ (CKRecords) │  │ (CloudKit)      │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Updated Core Data Model

```swift
// MARK: - Movie Entity (CloudKit-Ready)

@objc(Movie)
public class Movie: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var originalTitle: String?
    @NSManaged public var overview: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var runtime: Int32
    @NSManaged public var rating: Double
    @NSManaged public var posterPath: String?
    @NSManaged public var backdropPath: String?
    
    // File references (platform-specific handling)
    @NSManaged public var filePath: URL?
    @NSManaged public var fileBookmark: Data?  // For security-scoped bookmarks on macOS
    @NSManaged public var fileSize: Int64
    @NSManaged public var duration: Double
    @NSManaged public var currentPosition: Double
    @NSManaged public var isWatched: Bool
    @NSManaged public var watchCount: Int32
    @NSManaged public var lastWatchedDate: Date?
    @NSManaged public var addedDate: Date
    @NSManaged public var metadataFetched: Bool
    @NSManaged public var sortTitle: String?
    @NSManaged public var backdropData: Data?
    @NSManaged public var posterData: Data?
    
    // CloudKit Sync Metadata
    @NSManaged public var cloudKitRecordID: String?
    @NSManaged public var syncStatus: SyncStatus
    @NSManaged public var lastSyncDate: Date?
    @NSManaged public var deviceModifiedDate: Date
    
    // Relationships
    @NSManaged public var genres: Set<Genre>?
    @NSManaged public var cast: Set<CastMember>?
    @NSManaged public var crew: Set<CrewMember>?
    @NSManaged public var collection: MovieCollection?
    @NSManaged public var watchHistory: Set<WatchHistoryEntry>?
}

public enum SyncStatus: Int16 {
    case synced = 0
    case pendingUpload = 1
    case conflict = 2
    case deleted = 3
}
```

### CloudKit Container Setup

```swift
import CloudKit

struct CloudKitConfiguration {
    static let containerID = "iCloud.com.linfuse.app"
    static let zoneID = CKRecordZone.ID(zoneName: "LinfuseZone", ownerName: CKCurrentUserDefaultName)
    static let subscriptionID = "LinfuseChanges"
    
    static var container: CKContainer {
        CKContainer(identifier: containerID)
    }
    
    static var zone: CKRecordZone {
        CKRecordZone(zoneID: zoneID)
    }
}
```

### Sync Manager Service

```swift
class CloudSyncManager: ObservableObject {
    static let shared = CloudSyncManager()
    
    @Published var syncStatus: SyncState = .idle
    @Published var lastSyncDate: Date?
    @Published var conflictCount: Int = 0
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private var zoneSubscription: CKSubscription?
    
    enum SyncState {
        case idle
        case syncing
        case error(String)
    }
    
    func setup() {
        // Create custom zone for app data
        // Setup zone subscription for push notifications
        // Initialize sync context
    }
    
    func performSync() async throws {
        // Fetch changes from CloudKit
        // Resolve conflicts
        // Upload local changes
        // Update sync metadata
    }
    
    func resolveConflict(local: Movie, remote: Movie) -> Movie {
        // Use lastModifiedDate to determine winner
        // Or merge strategy: keep higher watch count, latest position
    }
}
```

---

## 3. Adaptive UI Architecture

### Platform Detection Utilities

```swift
import Foundation
import SwiftUI

enum Platform {
    case macOS
    case iOS
    case iPadOS
    
    static var current: Platform {
        #if os(macOS)
        return .macOS
        #elseif os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? .iPadOS : .iOS
        #endif
    }
    
    var isMac: Bool { self == .macOS }
    var isTouch: Bool { self == .iOS || self == .iPadOS }
}

extension View {
    @ViewBuilder
    func adaptUI() -> some View {
        if Platform.current.isMac {
            self_macOS()
        } else {
            self_iOS()
        }
    }
    
    @ViewBuilder
    func self_macOS() -> some View {
        self
    }
    
    @ViewBuilder
    func self_iOS() -> some View {
        self
    }
}
```

### Unified Navigation (NavigationSplitView for iOS, Sidebar for macOS)

```swift
import SwiftUI

struct MainNavigationView: View {
    @StateObject var libraryViewModel = LibraryViewModel()
    @State private var selectedTab: LibraryTab = .movies
    @State private var selectedSidebarItem: String?
    @State private var isSidebarVisible = true
    
    var body: some View {
        Group {
            #if os(iOS)
            NavigationSplitView {
                SidebarView_iOS(
                    selectedTab: $selectedTab,
                    selectedSidebarItem: $selectedSidebarItem
                )
            } detail: {
                ContentAreaView(
                    viewModel: libraryViewModel,
                    selectedTab: selectedTab
                )
            }
            .navigationSplitViewStyle(.balanced)
            #else
            NavigationSplitView(columnVisibility: .constant($isSidebarVisible)) {
                SidebarView_Mac(
                    selectedTab: $selectedTab,
                    selectedSidebarItem: $selectedSidebarItem
                )
            } content: {
                ContentAreaView(
                    viewModel: libraryViewModel,
                    selectedTab: selectedTab
                )
            } detail: {
                MovieDetailView()
            }
            .navigationSplitViewStyle(.balanced)
            #endif
        }
    }
}
```

### Platform-Specific Sidebar

```swift
// MARK: - iOS Sidebar (Compact)
#if os(iOS)
struct SidebarView_iOS: View {
    @Binding var selectedTab: LibraryTab
    @Binding var selectedSidebarItem: String?
    
    var body: some View {
        List {
            Section("Library") {
                Label("All Movies", systemImage: "film")
                    .onTapGesture { selectedSidebarItem = "all" }
                
                Label("Continue Watching", systemImage: "play.circle")
                    .onTapGesture { selectedSidebarItem = "continueWatching" }
                
                Label("Watchlist", systemImage: "bookmark")
                    .onTapGesture { selectedSidebarItem = "watchlist" }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Library")
    }
}
#endif

// MARK: - macOS Sidebar (Full-featured)
#if os(macOS)
struct SidebarView_Mac: View {
    @Binding var selectedTab: LibraryTab
    @Binding var selectedSidebarItem: String?
    @State private var showingAddFolder = false
    
    var body: some View {
        List(selection: $selectedSidebarItem) {
            Section("Library") {
                // Full sidebar with sorting, filtering options
                // Library folders management
                // Smart collections
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Library")
    }
}
#endif
```

---

## 4. File Management (Platform-Specific)

### macOS File Access

```swift
#if os(macOS)
class FileAccessManager_macOS {
    static let shared = FileAccessManager_macOS()
    
    func importVideos(from urls: [URL]) async throws -> [ImportedVideo] {
        // Use security-scoped bookmarks
        // Access user-selected folders
        // Monitor folder changes with FileSystemEvents
    }
    
    func startFolderMonitoring(urls: [URL]) {
        // Use dispatch sources for file system events
        // Notify when new videos are added
    }
}
#endif
```

### iOS File Access

```swift
#if os(iOS)
class FileAccessManager_iOS {
    static let shared = FileAccessManager_iOS()
    
    func importVideos() async throws -> [ImportedVideo] {
        // Use UIDocumentPickerViewController
        // Import to app's Documents directory
        // Can't monitor external folders on iOS
    }
    
    func getVideoFiles() -> [URL] {
        // List files in app's Documents folder
        // Provide UI for browsing imported videos
    }
}
#endif
```

---

## 5. Shared Business Logic Layer

### ViewModel Architecture

```swift
// MARK: - Shared LibraryViewModel
class LibraryViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var searchText = ""
    @Published var sortOption: SortOption = .dateAdded
    @Published var filterOption: FilterOption = .all
    @Published var viewMode: ViewMode = .grid
    
    // Platform-specific implementations
    #if os(macOS)
    @Published var libraryFolders: [LibraryFolder] = []
    #endif
    
    // iCloud sync awareness
    @Published var syncState: CloudSyncManager.SyncState = .idle
    
    func loadMovies() async {
        // Fetch from Core Data
        // Filter based on search/sort/filter
        // Platform-agnostic
    }
    
    func syncWithCloud() async {
        // Trigger iCloud sync
        // Handle conflicts
    }
}
```

---

## 6. Directory Structure

```
linfuse/
├── project.yml                    # XcodeGen config (multi-platform)
├── Sources/
│   ├── App/
│   │   ├── linfuseApp.swift       # App entry point
│   │   ├── AppDelegate.swift       # Platform-specific delegate
│   │   └── ContentView.swift      # Root view
│   ├── ViewModels/
│   │   └── LibraryViewModel.swift # Shared business logic
│   ├── Models/
│   │   ├── CoreData/
│   │   │   ├── Entities.swift      # Core Data entities
│   │   │   └── Linfuse.xcdatamodeld # Data model file
│   │   └── DTO/
│   │       └── TMDBModels.swift    # API models
│   ├── Services/
│   │   ├── CloudSyncManager.swift # iCloud sync logic
│   │   ├── TMDBService.swift       # API calls
│   │   ├── FileAccessManager.swift # Platform-specific file ops
│   │   └── ImageCacheService.swift # Image caching
│   ├── Utilities/
│   │   ├── PlatformDetection.swift
│   │   └── Extensions/
│   ├── Views/
│   │   ├── MainWindow/
│   │   │   ├── ContentAreaView.swift
│   │   │   ├── SidebarView.swift    # Platform-specific implementations
│   │   │   └── ToolbarView.swift
│   │   ├── Library/
│   │   │   ├── MovieGridView.swift
│   │   │   ├── MovieListView.swift
│   │   │   ├── HeroContentView.swift
│   │   │   └── VideoImporterView.swift
│   │   ├── Detail/
│   │   │   └── MovieDetailView.swift
│   │   └── Settings/
│   │       └── SettingsView.swift
│   └── Shared/                     # Shared components
│       ├── MovieCard.swift
│       └── LoadingIndicator.swift
├── Resources/
│   ├── Assets.xcassets/
│   └── Localizations/
├── Resources-macOS/                # macOS-specific
│   ├── Info.plist
│   ├── linfuse-macOS.entitlements
│   └── MainMenu.xib
├── Resources-iOS/                  # iOS-specific
│   ├── Info.plist
│   ├── linfuse-iOS.entitlements
│   └── LaunchScreen.storyboard
├── Tests/
└── Documentation/
    ├── README.md
    ├── ARCHITECTURE.md
    └── DAILY.md
```

---

## 7. Entitlements Configuration

### macOS Entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.linfuse.app</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
    <key>com.apple.developer.ubiquity-kvstore-identifier</key>
    <string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>
</dict>
</plist>
```

### iOS Entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.linfuse.app</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
    <key>com.apple.developer.ubiquity-kvstore-identifier</key>
    <string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>
</dict>
</plist>
```

---

## 8. iCloud Data Model (.xcdatamodeld)

### CloudKit-Enabled Data Model

1. **Enable CloudKit** in Core Data model
2. **Add sync metadata** to all entities:
   - `cloudKitRecordID: String`
   - `syncStatus: Int16`
   - `lastSyncDate: Date`
   - `deviceModifiedDate: Date`
3. **Configure zone** for efficient sync
4. **Set up relationships** with cascade delete rules

---

## Implementation Timeline

### Phase 1: Foundation (Week 1)
- [ ] Update `project.yml` for multi-platform
- [ ] Create platform-specific resource folders
- [ ] Configure CloudKit entitlements
- [ ] Set up Core Data + CloudKit integration

### Phase 2: Core Data Migration (Week 2)
- [ ] Add sync metadata to entities
- [ ] Create CloudSyncManager
- [ ] Implement conflict resolution logic
- [ ] Test local-to-cloud sync

### Phase 3: Adaptive UI (Week 3)
- [ ] Create unified NavigationSplitView
- [ ] Implement platform-specific Sidebar
- [ ] Adapt toolbar for touch interface
- [ ] Add size class awareness

### Phase 4: File Management (Week 4)
- [ ] Implement iOS document picker
- [ ] Create macOS folder monitor
- [ ] Handle file path resolution
- [ ] Test cross-platform import

### Phase 5: Testing & Polish (Week 5)
- [ ] Test iCloud sync on both platforms
- [ ] Verify conflict resolution
- [ ] Optimize performance
- [ ] Complete documentation

---

## Key Challenges & Solutions

### 1. **File Path Incompatibility**
- **Problem**: macOS uses POSIX paths, iOS uses app sandbox
- **Solution**: Store file metadata only in iCloud, keep local file references platform-specific

### 2. **Large Data Sync**
- **Problem**: Movie posters/backdrops consume bandwidth
- **Solution**: Sync metadata by default, images on demand or via CloudKit asset references

### 3. **Conflict Resolution**
- **Problem**: Same movie updated on both devices
- **Solution**: Use lastModifiedDate with merge strategy for watch progress

### 4. **Performance on iOS**
- **Problem**: Large libraries slow on mobile
- **Solution**: Implement pagination, lazy loading, Core Data batch fetching

---

## Success Criteria

✅ **Platform Support**
- macOS 14+ app builds and runs
- iOS 17+ app builds and runs
- Both targets share 85%+ code

✅ **iCloud Sync**
- Movie metadata syncs within 30 seconds
- Watch progress syncs in real-time
- Conflict resolution works correctly

✅ **User Experience**
- Adaptive UI works on all devices
- Import flow is intuitive on both platforms
- Performance is acceptable on iPhone

✅ **Data Integrity**
- No data loss during sync
- Consistent state across devices
- Proper error handling for offline scenarios

---

---

## 附录三：开源代码复用（Open Source Code Reuse）

本项目优先使用开源代码加速开发，避免重复造轮子。

### 视频播放引擎（开源）

| 项目 | 说明 | 许可证 | 可用性 |
|------|------|--------|--------|
| **VLC (libvlc)** | 最强格式支持，跨平台 | LGPL 2.1 | ✅ 推荐 |
| **IINA** | macOS 原生播放器，MPV 前端 | GPL 3.0 | 学习参考 |
| **MPV** | 轻量播放器引擎 | GPL 3.0/LGPL 2.1 | ✅ libmpv 可用 |
| **AVFoundation** | Apple 原生框架 | Apple | ✅ 优先使用 |

### 元数据刮削（开源）

| 项目 | 说明 | 许可证 | 可用性 |
|------|------|--------|--------|
| **TMDB API** | 官方 API | Free | ✅ 直接使用 |
| **OMDb API** | 电影数据库 | Free tier | ✅ 备用 |
| **TheMovieDB Swift** | TMDB Swift SDK | MIT | ✅ 集成 |
| **铎M-Assistant** | 中文化刮削 | MIT | ✅ 参考 |

### 网络存储（开源）

| 项目 | 说明 | 许可证 | 可用性 |
|------|------|--------|--------|
| **SMBKit** | SMB/CIFS 客户端 | MIT | ✅ 推荐 |
| **CocoaSSDP** | DLNA/UPnP 发现 | MIT | ✅ 推荐 |
| **NMSSH** | SSH/SFTP | MIT | 备用方案 |

### 数据持久化（开源）

| 项目 | 说明 | 许可证 | 可用性 |
|------|------|--------|--------|
| **Core Data** | Apple 原生 | Apple | ✅ 优先使用 |
| **Realm** | 跨平台数据库 | GPL/Commercial | 考虑使用 |
| **GRDB.swift** | SQLite 封装 | MIT | ✅ 轻量替代 |

### UI 组件（开源）

| 项目 | 说明 | 许可证 | 可用性 |
|------|------|--------|--------|
| **Kingfisher** | 图片缓存 | MIT | ✅ 已集成 |
| **Lottie** | 动画 | Apache 2.0 | ✅ 已集成 |
| **SwiftUI** | Apple 原生 | Apple | ✅ 优先使用 |

### 代码复用策略

#### 1. 视频播放器选择

```swift
// 优先使用 AVFoundation
import AVFoundation

let player = AVPlayer(url: videoURL)
player.play()

// 需要强格式支持时使用 VLCKit
import VLCKit

let player = VLCMediaPlayer()
player.media = VLCMedia(url: videoURL)
player.play()
```

#### 2. 元数据刮削

```swift
// 使用 TMDB Swift SDK
import TMDBKit

let tmdb = TMDB(apiKey: "YOUR_KEY")
let movie = try await tmdb.movie(id: tmdbID)
```

#### 3. SMB 连接

```swift
// 参考 SMBKit 架构
import SMBKit

let client = SMB2Connection(host: serverAddress)
try await client.connect(share: "Videos")
```

### 开源合规性

| 类型 | 处理方式 |
|------|----------|
| **MIT/Apache/BSD** | ✅ 直接使用 |
| **LGPL 2.1 (VLC)** | ✅ 动态链接可用 |
| **GPL 3.0 (MPV)** | ⚠️ 仅参考架构，不直接嵌入 |
| **Apple 原生** | ✅ 优先使用 |

### 参考学习的开源项目

| 项目 | 学习价值 |
|------|----------|
| **IINA** (https://github.com/iina/iina) | macOS 原生 UI 设计、MPV 集成 |
| **Infuse** | UI/UX 设计参考（闭源） |
| **Plex** | 媒体库架构、网络流媒体 |
| **Kodi** | 插件系统、皮肤引擎 |

---

## References

- [Apple's CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [NSPersistentCloudKitContainer](https://developer.apple.com/documentation/coredata/nspersistentcloudkitcontainer)
- [SwiftUI NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview)
- [XcodeGen Multi-Platform Targets](https://github.com/yonaskolb/XcodeGen)

---

## 附录一：竞品痛点分析与 linfuse 解决方案

### 同类软件痛点总结

| 痛点 | 说明 | 涉及软件 |
|------|------|----------|
| **臃肿** | 功能太多，启动慢，资源占用高 | Plex、Emby |
| **复杂** | 设置项多，学习成本高，上手难 | Plex、Infuse Pro |
| **同步差** | 多设备间数据不同步 | Infuse、Vidhub |
| **限平台** | 只支持单一平台 | IINA（仅Mac）、VLC（无同步） |
| **网络弱** | SMB 连接不稳定 | 多款软件 |
| **刮削慢** | 元数据下载慢，服务器在国外 | 多款软件 |
| **字幕烦** | 字幕匹配困难，编码问题 | 多款软件 |
| **订阅贵** | 订阅制涨价，永久买断少 | Infuse |
| **广告多** | 免费版广告多 | Plex 免费版 |
| **开源少** | 不开源，无法自定义 | Infuse、Plex |
| **中文差** | 界面或刮削不支持中文 | 多款软件 |

### linfuse 解决方案

| 痛点 | 解决方案 |
|------|----------|
| **臃肿** | 极简设计，核心功能优先，拒绝臃肿 |
| **复杂** | 零配置优先，智能默认值，高级设置可选 |
| **同步差** | **iCloud 实时同步**（核心特色） |
| **限平台** | **macOS + iOS 双平台**，同一代码库 |
| **网络弱** | 优化 SMB 连接池，自动重连，断点续扫 |
| **刮削慢** | 多源刮削（TMDB + 本土源），本地缓存 |
| **字幕烦** | 智能匹配算法，自动转码，偏好设置 |
| **订阅贵** | **订阅 + 永久买断双模式**，用户选择 |
| **广告多** | **零广告**，尊重用户 |
| **开源少** | **核心开源**，用户可自建 |
| **中文差** | **原生中文界面**，中文刮削优化 |

### linfuse 核心特色

#### 1. 轻量化优先
```
- 冷启动 < 3 秒
- 内存占用 < 200MB（万部影片库）
- 后台扫描不影响前台操作
- 按需加载，不预加载全部数据
```

#### 2. 零配置上手
```
- 首次启动自动扫描用户媒体文件夹
- 智能识别视频格式，无需手动配置
- 一键添加 SMB/NFS 服务器
- 默认使用 TMDB 中文刮削
```

#### 3. 极速同步
```
- iCloud Core Data，毫秒级同步
- 观看进度实时同步
- 跨设备无缝切换
- 离线优先，离线也能浏览
```

#### 4. 网络连接优化
```
- SMB2/3 协议优化
- 连接池管理
- 自动重连（断电/休眠后）
- 大文件断点续传
```

#### 5. 字幕智能系统
```
- 自动匹配同名字幕文件
- 智能识别语言
- UTF-8/GBK/Big5 自动转码
- 内嵌字幕优先
- 外部字幕列表选择
```

#### 6. 灵活的付费模式
```
- 免费版：本地功能全部可用
- Pro 订阅：月度/年度
- 永久买断：一次性付款，终身使用
- 家庭共享：5 台设备
```

---

## 附录二：竞品分析（Competitive Analysis）

### 对标软件

| 软件 | 平台 | 特点 | 可借鉴点 |
|------|------|------|----------|
| **Infuse** | macOS/iOS/tvOS | 格式支持广、刮削强、UI精美 | UI 设计、元数据展示、格式支持 |
| **Vidhub** | macOS/iOS | SMB 稳定、界面简洁 | SMB 连接管理、离线缓存 |
| **Plex** | 全平台 | 媒体服务器、远程访问 | 服务器架构、用户系统 |
| **Emby/Jellyfin** | 全平台 | 开源、插件丰富 | 插件系统、可扩展性 |
| **VLC** | 全平台 | 格式无敌、免费 | 解码器兼容、字幕支持 |
| **IINA** | macOS | 原生 UI、MPV 引擎 | macOS 专用优化 |

### 功能对比矩阵

| 功能 | Infuse | Vidhub | Plex | linfuse |
|------|--------|--------|------|---------|
| 本地视频 | ✅ | ✅ | ✅ | ✅ |
| SMB 共享 | ✅ | ✅ | ✅ | ✅ |
| NFS | ✅ | ❌ | ✅ | ✅ |
| WebDAV | ✅ | ❌ | ✅ | ✅ |
| DLNA | ✅ | ❌ | ✅ | ⏳ |
| iCloud 同步 | ❌ | ❌ | ❌ | ✅ |
| 多平台 | ✅ | ✅ | ✅ | ✅ |
| 格式支持 | 广 | 中 | 中 | 广 |
| 字幕支持 | 强 | 中 | 中 | 强 |
| 元数据刮削 | 强 | 中 | 强 | ✅ |
| 订阅制 | ✅ | ✅ | ✅ | ✅ |
| 一次性买断 | ✅ | ✅ | ❌ | ✅ |
| 开源 | ❌ | ❌ | 部分 | ⏳ |

### 核心差异化

| 特点 | 说明 |
|------|------|
| **iCloud 同步** | 核心差异点，数据无缝跨设备 |
| **中文优化** | 中文界面、本土刮削源支持 |
| **简洁设计** | 轻量不臃肿，专注核心功能 |
| **开放架构** | 插件系统，可扩展 |

### 参考实现的功能

#### 1. Infuse 特点借鉴

```
- 精美的封面展示（Hero view）
- 自动剧集识别（季/集结构）
- 智能分类（4K、HDR、Dolby Vision）
- 跳过片头片尾
- 音轨/字幕选择界面
- AirPlay / Chromecast 投射
- 家庭共享（Family Sharing）
```

#### 2. Vidhub 特点借鉴

```
- 简洁的 SMB 连接管理
- 离线元数据缓存
- 快速文件夹扫描
- 黑暗模式优化
- iOS/macOS 原生体验
```

#### 3. Plex/Emby 特点借鉴（未来）

```
- 媒体服务器模式（远程访问）
- 用户账户系统
- 评分/评论功能
- 观看列表分享
- 插件市场
```

---

## 附录二：局域网存储支持（LAN Storage Support）

### 支持的网络协议

| 协议 | 说明 | 优先级 |
|------|------|--------|
| **SMB/CIFS** | Windows 共享、macOS 共享 | ⭐⭐⭐ |
| **NFS** | Linux/Unix 网络文件系统 | ⭐⭐⭐ |
| **WebDAV** | HTTP 协议的网络共享 | ⭐⭐ |
| **DLNA/UPnP** | 媒体服务器发现 | ⭐ |

### 架构设计

```
┌─────────────────────────────────────────────────────────────────┐
│                     Network Storage Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │ SMB Client  │  │ NFS Client  │  │ WebDAV Client          │  │
│  │ (SMBKit)    │  │ (NFSD)      │  │ (URLSession)           │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              NetworkStorageManager                       │    │
│  │  - 连接管理                                              │    │
│  │  - 凭据存储                                              │    │
│  │  - 挂载/卸载                                             │    │
│  │  - 状态监控                                              │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### 核心功能

1. **服务器发现**
   - 自动扫描局域网 SMB/NFS 服务器
   - DLNA/UPnP 媒体服务器发现
   - 手动添加服务器（地址 + 凭据）

2. **连接管理**
   - 保存连接历史
   - 自动重连
   - 连接状态监控
   - 凭据安全存储（Keychain）

3. **文件浏览**
   - 远程目录遍历
   - 文件夹树形结构
   - 缩略图预览
   - 视频文件筛选

4. **视频扫描**
   - 扫描网络路径下的视频文件
   - 支持递归扫描
   - 断点续扫
   - 后台扫描

### 第三方库建议

| 功能 | 推荐库 |
|------|--------|
| SMB 客户端 | [SMBKit](https://github.com/insidegui/SMBKit) |
| NFS | Apple Network.framework（原生） |
| WebDAV | URLSession（原生） |
| DLNA/UPnP | [CocoaSSDP](https://github.com/benjaminmayo/CocoaSSDP) |
| 凭据管理 | Security Framework（Keychain） |

### 数据模型扩展

```swift
// MARK: - Network Server Entity

@objc(NetworkServer)
public class NetworkServer: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var address: String
    @NSManaged public var port: Int32
    @NSManaged public var protocolType: NetworkProtocol
    @NSManaged public var sharePath: String?
    @NSManaged public var isConnected: Bool
    @NSManaged public var lastConnectedDate: Date?
    @NSManaged public var createdDate: Date
    
    // 凭据引用（Keychain 存储，不存原始数据）
    @NSManaged public var credentialID: String?
    
    // 关系
    @NSManaged public var folders: Set<NetworkFolder>?
}

public enum NetworkProtocol: Int16 {
    case smb = 0
    case nfs = 1
    case webdav = 2
    case dlna = 3
}

// MARK: - Network Folder Entity

@objc(NetworkFolder)
public class NetworkFolder: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var path: String
    @NSManaged public var name: String
    @NSManaged public var isIncluded: Bool  // 是否包含在扫描范围
    @NSManaged public var server: NetworkServer
}
```

### 用户界面

1. **服务器管理**
   - 侧边栏新增"网络"分类
   - 服务器列表（可折叠）
   - 添加/编辑/删除服务器
   - 连接状态指示器

2. **连接流程**
   - 选择协议类型
   - 输入服务器地址、端口
   - 输入用户名、密码（可选）
   - 浏览共享文件夹
   - 选择要扫描的目录

3. **离线处理**
   - 网络路径转换为本地书签
   - 断线后标记为不可用
   - 重连后自动恢复

### 实现优先级

| 阶段 | 功能 | 优先级 |
|------|------|--------|
| v1.0 | SMB 支持（手动添加） | ⭐⭐⭐ |
| v1.0 | 凭据 Keychain 存储 | ⭐⭐⭐ |
| v1.1 | NFS 支持 | ⭐⭐⭐ |
| v1.1 | 服务器发现 | ⭐⭐ |
| v1.2 | WebDAV 支持 | ⭐⭐ |
| v1.3 | DLNA/UPnP 发现 | ⭐ |

### 注意事项

1. **macOS 沙盒限制**
   - 需要用户授权才能访问网络文件夹
   - 使用 `NSOpenPanel` 获取书签权限

2. **iOS 限制**
   - 无法后台挂载网络卷
   - 需要用户每次选择文件夹（使用 `UIDocumentPicker`）

3. **性能考虑**
   - 大型网络文件夹使用渐进式加载
   - 缩略图缓存到本地
   - 扫描任务在后台线程执行

---

**文档版本**: 1.2  
**更新日期**: 2026-02-04  
**更新内容**: 
- 完整功能恢复，所有模块已启用
- 修复 SwiftUI macOS 兼容性问题
- 修复 StoreKit API 变更
- 修复网络存储客户端
- DMG 打包完成 (2.9MB)

## 当前项目状态 (2026-02-04)

### ✅ 已完成
- ✅ 完整编译成功
- ✅ 所有源文件模块已启用
- ✅ DMG 安装包已生成
- ✅ 视频库管理
- ✅ 文件扫描与监控
- ✅ 元数据刮削 (TMDB)
- ✅ 网络存储 (SMB, NFS, WebDAV, DLNA)
- ✅ 收藏夹管理
- ✅ 观看历史
- ✅ 智能分类
- ✅ 云同步 (CloudKit)
- ✅ StoreKit 订阅

### 待完成 (后续迭代)
- ⏳ App Store 签名配置
- ⏳ 公证 (Notarization)
- ⏳ TestFlight 发布
- ⏳ iOS 版本开发
- ⏳ PWA 扩展
