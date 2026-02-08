import Foundation

/// 播放状态管理
class PlaybackState: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var bufferProgress: Double = 0
    @Published var playbackRate: PlaybackSpeed = .normal
    @Published var volume: Double = 1.0
    @Published var isMuted: Bool = false
    @Published var isFullscreen: Bool = false
    @Published var isPiPEnabled: Bool = false
    
    @Published var currentQuality: VideoQuality = .auto
    @Published var availableQualities: [VideoQuality] = []
    @Published var currentBitrate: Double = 0
    
    @Published var subtitleTracks: [SubtitleTrack] = []
    @Published var currentSubtitleTrack: SubtitleTrack?
    @Published var subtitleStyle: SubtitleStyle = SubtitleStyle()
    @Published var isSubtitleVisible: Bool = true
    
    var progressPercentage: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    var formattedCurrentTime: String {
        formatTime(currentTime)
    }
    
    var formattedDuration: String {
        formatTime(duration)
    }
    
    var formattedRemainingTime: String {
        let remaining = max(0, duration - currentTime)
        return "-" + formatTime(remaining)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func reset() {
        isPlaying = false
        currentTime = 0
        duration = 0
        bufferProgress = 0
        playbackRate = .normal
        isMuted = false
        isFullscreen = false
    }
}

/// 播放速度
enum PlaybackSpeed: Double, CaseIterable {
    case slowest = 0.5
    case slow = 0.75
    case normal = 1.0
    case fast = 1.25
    case faster = 1.5
    case fastest = 2.0
    
    var displayName: String {
        switch self {
        case .slowest: return "0.5x"
        case .slow: return "0.75x"
        case .normal: return "1.0x"
        case .fast: return "1.25x"
        case .faster: return "1.5x"
        case .fastest: return "2.0x"
        }
    }
    
    var description: String {
        switch self {
        case .slowest: return "最慢"
        case .slow: return "慢速"
        case .normal: return "正常"
        case .fast: return "快速"
        case .faster: return "更快"
        case .fastest: return "最快"
        }
    }
}

/// 视频画质
enum VideoQuality: String, Codable, CaseIterable {
    case auto = "auto"
    case fhd1080p = "1080p"
    case hd720p = "720p"
    case sd480p = "480p"
    case sd360p = "360p"
    
    var displayName: String {
        switch self {
        case .auto: return "自动"
        case .fhd1080p: return "1080p"
        case .hd720p: return "720p"
        case .sd480p: return "480p"
        case .sd360p: return "360p"
        }
    }
    
    var height: Int {
        switch self {
        case .auto: return 0
        case .fhd1080p: return 1080
        case .hd720p: return 720
        case .sd480p: return 480
        case .sd360p: return 360
        }
    }
}

/// 字幕轨道
struct SubtitleTrack: Identifiable, Codable {
    let id: String
    var name: String
    var language: String?
    var isExternal: Bool
    var url: URL?
    
    init(
        id: String = UUID().uuidString,
        name: String,
        language: String? = nil,
        isExternal: Bool = false,
        url: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.language = language
        self.isExternal = isExternal
        self.url = url
    }
    
    static let none = SubtitleTrack(id: "none", name: "关闭字幕", isExternal: false)
}

/// 字幕样式
struct SubtitleStyle: Codable {
    var fontName: String = "-apple-system"
    var fontSize: Double = 16
    var textColor: String = "#FFFFFF"
    var backgroundColor: String = "#000000"
    var backgroundOpacity: Double = 0.5
    var position: SubtitlePosition = .bottom
    var encoding: StringEncoding = .utf8
    
    enum StringEncoding: String, Codable, CaseIterable {
        case utf8 = "UTF-8"
        case gbk = "GBK"
        case big5 = "Big5"
        case shiftJIS = "Shift-JIS"
        
        var displayName: String {
            rawValue
        }
    }
}

/// 字幕位置
enum SubtitlePosition: String, Codable, CaseIterable {
    case top = "top"
    case center = "center"
    case bottom = "bottom"
    
    var displayName: String {
        switch self {
        case .top: return "顶部"
        case .center: return "中间"
        case .bottom: return "底部"
        }
    }
}

/// 视频信息（用于显示）
struct VideoInfo {
    let title: String
    let artist: String?
    let album: String?
    let duration: TimeInterval
    let width: Int
    let height: Int
    let frameRate: Double?
    let bitrate: Double?
    let codec: String?
    let audioCodec: String?
    let fileSize: Int64
    
    static let empty = VideoInfo(
        title: "",
        artist: nil,
        album: nil,
        duration: 0,
        width: 0,
        height: 0,
        frameRate: nil,
        bitrate: nil,
        codec: nil,
        audioCodec: nil,
        fileSize: 0
    )
}
