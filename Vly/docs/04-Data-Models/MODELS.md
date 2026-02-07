# Vly 数据模型

> 版本: 1.0
> 更新日期: 2026-02-06

## 1. 概述

本文档定义 Vly 视频播放器的数据模型。

## 2. 核心模型

### 2.1 Video (视频)

```swift
import Foundation

/// 视频模型
struct Video: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var url: URL
    var localPath: URL?
    var duration: TimeInterval
    var thumbnailURL: URL?
    var fileSize: Int64?
    var format: VideoFormat
    var resolution: VideoResolution?
    var bitrate: Int?
    var creationDate: Date?
    var lastPlayedDate: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        localPath: URL? = nil,
        duration: TimeInterval = 0,
        thumbnailURL: URL? = nil,
        fileSize: Int64? = nil,
        format: VideoFormat = .unknown,
        resolution: VideoResolution? = nil,
        bitrate: Int? = nil,
        creationDate: Date? = nil,
        lastPlayedDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.localPath = localPath
        self.duration = duration
        self.thumbnailURL = thumbnailURL
        self.fileSize = fileSize
        self.format = format
        self.resolution = resolution
        self.bitrate = bitrate
        self.creationDate = creationDate
        self.lastPlayedDate = lastPlayedDate
    }
}

/// 视频格式
enum VideoFormat: String, Codable, CaseIterable {
    case mp4 = "mp4"
    case mkv = "mkv"
    case avi = "avi"
    case mov = "mov"
    case webm = "webm"
    case flv = "flv"
    case wmv = "wmv"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .mp4: return "MP4"
        case .mkv: return "MKV"
        case .avi: return "AVI"
        case .mov: return "MOV"
        case .webm: return "WebM"
        case .flv: return "FLV"
        case .wmv: return "WMV"
        case .unknown: return "Unknown"
        }
    }
}

/// 视频分辨率
struct VideoResolution: Codable, Hashable {
    let width: Int
    let height: Int
    
    var displayName: String {
        switch height {
        case 2160: return "4K"
        case 1080: return "1080p"
        case 720: return "720p"
        case 480: return "480p"
        case 360: return "360p"
        default: return "\(width)x\(height)"
        }
    }
    
    static let hd = VideoResolution(width: 1920, height: 1080)
    static let uhd = VideoResolution(width: 3840, height: 2160)
}
```

### 2.2 Playlist (播放列表)

```swift
import Foundation

/// 播放列表模型
struct Playlist: Identifiable, Codable {
    let id: UUID
    var name: String
    var videos: [Video]
    var coverImageURL: URL?
    var creationDate: Date
    var modificationDate: Date
    var playbackPosition: [UUID: TimeInterval] // 视频 ID -> 播放位置
    
    init(
        id: UUID = UUID(),
        name: String,
        videos: [Video] = [],
        coverImageURL: URL? = nil,
        creationDate: Date = Date(),
        modificationDate: Date = Date(),
        playbackPosition: [UUID: TimeInterval] = [:]
    ) {
        self.id = id
        self.name = name
        self.videos = videos
        self.coverImageURL = coverImageURL
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.playbackPosition = playbackPosition
    }
    
    var videoCount: Int { videos.count }
    var totalDuration: TimeInterval {
        videos.reduce(0) { $0 + $1.duration }
    }
    
    mutating func addVideo(_ video: Video) {
        videos.append(video)
        modificationDate = Date()
    }
    
    mutating func removeVideo(at index: Int) {
        guard index < videos.count else { return }
        videos.remove(at: index)
        modificationDate = Date()
    }
    
    mutating func moveVideo(from source: IndexSet, to destination: Int) {
        videos.move(fromOffsets: source, toOffset: destination)
        modificationDate = Date()
    }
}
```

### 2.3 PlaybackState (播放状态)

```swift
import Foundation

/// 播放状态
enum PlaybackState: Equatable {
    case idle
    case loading
    case playing
    case paused
    case buffering(progress: Double)
    case failed(Error)
    case finished
}

/// 播放模式
enum PlaybackMode: String, CaseIterable {
    case single       // 单曲播放
    case loop         // 单曲循环
    case queueLoop    // 列表循环
    case shuffle      // 随机播放
    
    var displayName: String {
        switch self {
        case .single: return "Single"
        case .loop: return "Loop"
        case .queueLoop: return "Queue Loop"
        case .shuffle: return "Shuffle"
        }
    }
}

/// 播放器状态
final class PlaybackStateModel: ObservableObject {
    @Published var currentState: PlaybackState = .idle
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isPlaying: Bool = false
    @Published var volume: Float = 1.0
    @Published var playbackRate: Float = 1.0
    @Published var isMuted: Bool = false
    @Published var isFullscreen: Bool = false
    @Published var isPiPActive: Bool = false
    @Published var currentQuality: VideoQuality = .auto
    @Published var subtitleEnabled: Bool = false
    @Published var currentSubtitle: SubtitleTrack?
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    var bufferedTime: TimeInterval = 0
    
    var formattedCurrentTime: String {
        TimeFormatter.format(currentTime)
    }
    
    var formattedDuration: String {
        TimeFormatter.format(duration)
    }
    
    var remainingTime: String {
        TimeFormatter.format(duration - currentTime)
    }
}
```

### 2.4 VideoQuality (画质)

```swift
import Foundation

/// 视频画质
enum VideoQuality: String, CaseIterable, Identifiable {
    case auto = "auto"
    case best = "best"
    case hd1080 = "1080p"
    case hd720 = "720p"
    case sd480 = "480p"
    case sd360 = "360p"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .auto: return "Auto"
        case .best: return "Best"
        case .hd1080: return "1080p"
        case .hd720: return "720p"
        case .sd480: return "480p"
        case .sd360: return "360p"
        }
    }
    
    var bitrate: Int? {
        switch self {
        case .best: return nil
        case .hd1080: return 8_000_000
        case .hd720: return 5_000_000
        case .sd480: return 2_500_000
        case .sd360: return 1_000_000
        case .auto: return nil
        }
    }
}
```

### 2.5 Subtitle (字幕)

```swift
import Foundation

/// 字幕轨道
struct SubtitleTrack: Identifiable, Hashable {
    let id: UUID
    var name: String
    var language: String?
    var url: URL?
    var isEmbedded: Bool
    var isSelected: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        language: String? = nil,
        url: URL? = nil,
        isEmbedded: Bool = false,
        isSelected: Bool = false
    ) {
        self.id = id
        self.name = name
        self.language = language
        self.url = url
        self.isEmbedded = isEmbedded
        self.isSelected = isSelected
    }
}

/// 字幕样式
struct SubtitleStyle: Codable {
    var fontSize: CGFloat = 16
    var fontColor: String = "#FFFFFF"
    var backgroundColor: String = "#000000"
    var backgroundOpacity: Double = 0.5
    var position: SubtitlePosition = .bottom
    var encoding: String = "UTF-8"
    
    static let `default` = SubtitleStyle()
}

/// 字幕位置
enum SubtitlePosition: String, Codable, CaseIterable {
    case top = "top"
    case center = "center"
    case bottom = "bottom"
    
    var displayName: String {
        rawValue.capitalized
    }
}
```

## 3. 模型关系

```
Video
  ├── Playlist (一对多)
  └── PlaybackStateModel (关联当前播放)
  
Playlist
  └── Video (一对多)

PlaybackStateModel
  └── Video (当前播放)
```

## 4. 存储

### 4.1 本地存储

- 播放列表: JSON 文件 (`~/Library/Application Support/Vly/playlists.json`)
- 播放历史: JSON 文件 (`~/Library/Application Support/Vly/history.json`)
- 用户设置: UserDefaults 或 JSON

### 4.2 存储格式

```swift
// playlist.json 格式
{
  "id": "uuid",
  "name": "我的播放列表",
  "videos": [
    {
      "id": "uuid",
      "title": "视频标题",
      "url": "file:///path/to/video.mp4",
      "duration": 3600,
      "format": "mp4",
      "resolution": {
        "width": 1920,
        "height": 1080
      }
    }
  ],
  "creationDate": "2026-02-06T00:00:00Z",
  "modificationDate": "2026-02-06T00:00:00Z"
}
```

## 5. 相关文档

- [架构设计](../01-Architecture/README.md)
- [功能需求](../02-Requirements/FEATURES.md)
- [KSPlayer 集成研究](../06-Research/KSPLAYER_INTEGRATION.md)
