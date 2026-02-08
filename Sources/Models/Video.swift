import Foundation

/// 视频文件模型
struct Video: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var url: URL
    var localPath: String?
    var duration: TimeInterval
    var currentPosition: TimeInterval
    var thumbnailURL: URL?
    var format: VideoFormat
    var resolution: VideoResolution
    var fileSize: Int64
    var dateAdded: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        localPath: String? = nil,
        duration: TimeInterval = 0,
        currentPosition: TimeInterval = 0,
        thumbnailURL: URL? = nil,
        format: VideoFormat = .unknown,
        resolution: VideoResolution = .unknown,
        fileSize: Int64 = 0,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.localPath = localPath
        self.duration = duration
        self.currentPosition = currentPosition
        self.thumbnailURL = thumbnailURL
        self.format = format
        self.resolution = resolution
        self.fileSize = fileSize
        self.dateAdded = dateAdded
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var formattedProgress: String {
        let current = Int(currentPosition)
        let hours = current / 3600
        let minutes = (current % 3600) / 60
        let seconds = current % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var progressPercentage: Double {
        guard duration > 0 else { return 0 }
        return currentPosition / duration
    }
}

/// 视频格式
enum VideoFormat: String, Codable, CaseIterable {
    case mp4 = "mp4"
    case mkv = "mkv"
    case avi = "avi"
    case flv = "flv"
    case webm = "webm"
    case mov = "mov"
    case m4v = "m4v"
    case ts = "ts"
    case m3u8 = "m3u8"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .mp4: return "MP4"
        case .mkv: return "MKV"
        case .avi: return "AVI"
        case .flv: return "FLV"
        case .webm: return "WebM"
        case .mov: return "MOV"
        case .m4v: return "M4V"
        case .ts: return "TS"
        case .m3u8: return "M3U8"
        case .unknown: return "未知"
        }
    }
    
    var isStream: Bool {
        switch self {
        case .m3u8, .ts: return true
        default: return false
        }
    }
}

/// 视频分辨率
enum VideoResolution: String, Codable, CaseIterable {
    case unknown = "unknown"
    case sd480p = "480p"
    case hd720p = "720p"
    case fhd1080p = "1080p"
    case uhd4k = "4k"
    case uhd8k = "8k"
    
    var displayName: String {
        switch self {
        case .unknown: return "未知"
        case .sd480p: return "480p"
        case .hd720p: return "720p"
        case .fhd1080p: return "1080p"
        case .uhd4k: return "4K"
        case .uhd8k: return "8K"
        }
    }
    
    var height: Int {
        switch self {
        case .unknown: return 0
        case .sd480p: return 480
        case .hd720p: return 720
        case .fhd1080p: return 1080
        case .uhd4k: return 2160
        case .uhd8k: return 4320
        }
    }
}

/// 视频来源
enum VideoSource: String, Codable {
    case local = "local"
    case network = "network"
    case stream = "stream"
}
