# Vly 服务层设计

> 版本: 1.0
> 更新日期: 2026-02-06

## 1. 概述

本文档定义 Vly 视频播放器的服务层架构。

## 2. 服务列表

| 服务 | 职责 | 状态 |
|------|------|------|
| PlayerService | 播放器核心控制 | ✅ |
| PlaylistService | 播放列表管理 | ⏳ |
| FileService | 文件管理 | ⏳ |
| SubtitleService | 字幕管理 | ⏳ |
| SettingsService | 设置管理 | ⏳ |
| HistoryService | 播放历史 | ❌ |

## 3. PlayerService

### 3.1 接口定义

```swift
import Foundation
import Combine

/// 播放器服务协议
protocol PlayerServiceProtocol {
    var state: PlaybackState { get }
    var currentVideo: Video? { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var isPlaying: Bool { get }
    
    func load(video: Video)
    func play()
    func pause()
    func togglePlayPause()
    func seek(to time: TimeInterval)
    func seek(relative offset: TimeInterval)
    func setPlaybackRate(_ rate: Float)
    func setVolume(_ volume: Float)
    func setMuted(_ muted: Bool)
    func enterFullscreen()
    func exitFullscreen()
    func togglePictureInPicture()
}

/// 播放器服务实现
final class PlayerService: PlayerServiceProtocol, ObservableObject {
    @Published private(set) var state: PlaybackState = .idle
    @Published private(set) var currentVideo: Video?
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isFullscreen: Bool = false
    @Published private(set) var isPiPActive: Bool = false
    
    private var player: VideoPlayerProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupPlayer()
    }
    
    private func setupPlayer() {
        // 初始化 KSPlayer 适配器
        player = VideoPlayerFactory.create()
        
        // 绑定状态
        player?.$state
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
        
        player?.$currentTime
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentTime)
        
        player?.$duration
            .receive(on: DispatchQueue.main)
            .assign(to: &$duration)
        
        player?.$isPlaying
            .receive(on: DispatchQueue.main)
            .assign(to: &$isPlaying)
    }
    
    func load(video: Video) {
        currentVideo = video
        player?.load(url: video.url)
        state = .loading
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func togglePlayPause() {
        isPlaying ? pause() : play()
    }
    
    func seek(to time: TimeInterval) {
        player?.seek(to: time)
    }
    
    func seek(relative offset: TimeInterval) {
        let newTime = max(0, min(duration, currentTime + offset))
        seek(to: newTime)
    }
    
    func setPlaybackRate(_ rate: Float) {
        player?.setPlaybackRate(rate)
    }
    
    func setVolume(_ volume: Float) {
        player?.setVolume(volume)
    }
    
    func setMuted(_ muted: Bool) {
        player?.setMuted(muted)
    }
    
    func enterFullscreen() {
        isFullscreen = true
    }
    
    func exitFullscreen() {
        isFullscreen = false
    }
    
    func togglePictureInPicture() {
        player?.togglePiP()
        isPiPActive.toggle()
    }
}
```

## 4. PlaylistService

```swift
import Foundation
import Combine

/// 播放列表服务
final class PlaylistService: ObservableObject {
    @Published private(set) var playlists: [Playlist] = []
    @Published private(set) var currentPlaylist: Playlist?
    
    private let fileManager = FileManager.default
    private let playlistPath: URL
    
    init() {
        // 初始化存储路径
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDirectory)[0]
        playlistPath = appSupport.appendingPathComponent("Vly", isDirectory: true)
        createDirectoryIfNeeded()
        loadPlaylists()
    }
    
    private func createDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: playlistPath.path) {
            try? fileManager.createDirectory(at: playlistPath, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - CRUD 操作
    
    func createPlaylist(name: String) -> Playlist {
        let playlist = Playlist(name: name)
        playlists.append(playlist)
        savePlaylists()
        return playlist
    }
    
    func deletePlaylist(id: UUID) {
        playlists.removeAll { $0.id == id }
        if currentPlaylist?.id == id {
            currentPlaylist = nil
        }
        savePlaylists()
    }
    
    func renamePlaylist(id: UUID, newName: String) {
        guard let index = playlists.firstIndex(where: { $0.id == id }) else { return }
        playlists[index].name = newName
        savePlaylists()
    }
    
    func addVideo(_ video: Video, to playlistID: UUID) {
        guard let index = playlists.firstIndex(where: { $0.id == playlistID }) else { return }
        playlists[index].addVideo(video)
        savePlaylists()
    }
    
    func removeVideo(at index: Int, from playlistID: UUID) {
        guard let pIndex = playlists.firstIndex(where: { $0.id == playlistID }) else { return }
        playlists[pIndex].removeVideo(at: index)
        savePlaylists()
    }
    
    func moveVideo(from source: IndexSet, to destination: Int, in playlistID: UUID) {
        guard let index = playlists.firstIndex(where: { $0.id == playlistID }) else { return }
        playlists[index].moveVideo(from: source, to: destination)
        savePlaylists()
    }
    
    // MARK: - 持久化
    
    private func loadPlaylists() {
        let fileURL = playlistPath.appendingPathComponent("playlists.json")
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Playlist].self, from: data) else {
            playlists = []
            return
        }
        playlists = decoded
    }
    
    private func savePlaylists() {
        let fileURL = playlistPath.appendingPathComponent("playlists.json")
        guard let encoded = try? JSONEncoder().encode(playlists) else { return }
        try? encoded.write(to: fileURL)
    }
}
```

## 5. FileService

```swift
import Foundation

/// 文件服务
final class FileService {
    static let shared = FileService()
    
    private let fileManager = FileManager.default
    
    // MARK: - 支持的格式
    
    static let supportedVideoFormats: Set<String> = [
        "mp4", "mkv", "avi", "mov", "webm", "flv", "wmv"
    ]
    
    static let supportedSubtitleFormats: Set<String> = [
        "srt", "ass", "ssa", "vtt", "sub"
    ]
    
    // MARK: - 文件操作
    
    func scanDirectory(_ url: URL) -> [Video] {
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        var videos: [Video] = []
        
        for case let fileURL as URL in enumerator {
            guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                  let isRegular = attributes[.type] as? FileAttributeType,
                  isRegular == FileAttributeType.typeRegular,
                  let ext = fileURL.pathExtension.lowercased(),
                  Self.supportedVideoFormats.contains(ext) else {
                continue
            }
            
            let video = Video(
                title: fileURL.deletingPathExtension().lastPathComponent,
                url: fileURL,
                duration: 0, // 需要加载后获取
                format: VideoFormat(rawValue: ext) ?? .unknown
            )
            videos.append(video)
        }
        
        return videos
    }
    
    func loadVideoMetadata(from url: URL) -> Video? {
        // 使用 KSPlayer 或 AVAsset 获取视频元数据
        return nil
    }
    
    func importVideo(from sourceURL: URL, to destinationFolder: URL) throws -> URL {
        let fileName = sourceURL.lastPathComponent
        let destinationURL = destinationFolder.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            // 如果文件已存在，添加序号
            var counter = 1
            var newURL = destinationURL
            while fileManager.fileExists(atPath: newURL.path) {
                let name = sourceURL.deletingPathExtension().lastPathComponent
                let ext = sourceURL.pathExtension
                newURL = destinationFolder.appendingPathComponent("\(name)_\(counter).\(ext)")
                counter += 1
            }
            try fileManager.copyItem(at: sourceURL, to: newURL)
            return newURL
        } else {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        }
    }
}
```

## 6. SettingsService

```swift
import Foundation
import Combine

/// 设置服务
final class SettingsService: ObservableObject {
    static let shared = SettingsService()
    
    @Published var general = GeneralSettings()
    @Published var playback = PlaybackSettings()
    @Published var subtitle = SubtitleSettings()
    @Published var appearance = AppearanceSettings()
    
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.vly.app") {
            self.userDefaults = sharedDefaults
        } else {
            self.userDefaults = .standard
        }
        loadSettings()
    }
    
    // MARK: - 保存/加载
    
    private func loadSettings() {
        if let data = userDefaults.data(forKey: "generalSettings"),
           let settings = try? decoder.decode(GeneralSettings.self, from: data) {
            general = settings
        }
        // 加载其他设置...
    }
    
    func saveSettings() {
        if let data = try? encoder.encode(general) {
            userDefaults.set(data, forKey: "generalSettings")
        }
        // 保存其他设置...
    }
}

/// 通用设置
struct GeneralSettings: Codable {
    var openLastPlaylist: Bool = true
    var rememberPlaybackPosition: Bool = true
    var autoPlayNext: Bool = false
    var defaultFolder: URL?
}

/// 播放设置
struct PlaybackSettings: Codable {
    var defaultVolume: Float = 1.0
    var defaultPlaybackRate: Float = 1.0
    var rememberVolume: Bool = true
    var skipForwardInterval: TimeInterval = 15
    var skipBackwardInterval: TimeInterval = 15
    var autoSwitchFullscreen: Bool = true
}

/// 字幕设置
struct SubtitleSettings: Codable {
    var enabled: Bool = true
    var defaultFontSize: CGFloat = 16
    var defaultFontColor: String = "#FFFFFF"
    var defaultEncoding: String = "UTF-8"
    var autoLoadSubtitle: Bool = true
}

/// 外观设置
struct AppearanceSettings: Codable {
    var colorScheme: ColorScheme = .system
    var accentColor: AccentColor = .blue
}

enum ColorScheme: String, Codable, CaseIterable {
    case light, dark, system
}

enum AccentColor: String, Codable, CaseIterable {
    case blue, purple, pink, red, orange, yellow, green, gray
}
```

## 7. 相关文档

- [架构设计](../01-Architecture/README.md)
- [数据模型](../04-Data-Models/MODELS.md)
- [KSPlayer 集成研究](../06-Research/KSPLAYER_INTEGRATION.md)
