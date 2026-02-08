import Foundation

/// 播放列表模型
struct Playlist: Identifiable, Codable {
    let id: UUID
    var name: String
    var videos: [Video]
    var createdAt: Date
    var updatedAt: Date
    var sortOrder: SortOrder
    var shuffleEnabled: Bool
    var repeatMode: RepeatMode
    
    init(
        id: UUID = UUID(),
        name: String = "新建播放列表",
        videos: [Video] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        sortOrder: SortOrder = .manual,
        shuffleEnabled: Bool = false,
        repeatMode: RepeatMode = .none
    ) {
        self.id = id
        self.name = name
        self.videos = videos
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sortOrder = sortOrder
        self.shuffleEnabled = shuffleEnabled
        self.repeatMode = repeatMode
    }
    
    var videoCount: Int {
        videos.count
    }
    
    var totalDuration: TimeInterval {
        videos.reduce(0) { $0 + $1.duration }
    }
    
    var formattedDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)小时 \(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
    
    var isEmpty: Bool {
        videos.isEmpty
    }
    
    // MARK: - CRUD Operations
    
    mutating func addVideo(_ video: Video) {
        var newVideo = video
        newVideo.currentPosition = 0
        videos.append(newVideo)
        updatedAt = Date()
    }
    
    mutating func addVideos(_ newVideos: [Video]) {
        for video in newVideos {
            addVideo(video)
        }
    }
    
    mutating func removeVideo(at index: Int) {
        guard index >= 0 && index < videos.count else { return }
        videos.remove(at: index)
        updatedAt = Date()
    }
    
    mutating func removeVideo(id: UUID) {
        videos.removeAll { $0.id == id }
        updatedAt = Date()
    }
    
    mutating func moveVideo(from source: IndexSet, to destination: Int) {
        videos.move(fromOffsets: source, toOffset: destination)
        updatedAt = Date()
    }
    
    mutating func updateVideo(_ video: Video) {
        if let index = videos.firstIndex(where: { $0.id == video.id }) {
            videos[index] = video
            updatedAt = Date()
        }
    }
    
    mutating func clear() {
        videos.removeAll()
        updatedAt = Date()
    }
    
    // MARK: - Playback Control
    
    func nextVideo(currentVideoId: UUID?) -> Video? {
        guard let currentIndex = videos.firstIndex(where: { $0.id == currentVideoId }) else {
            return videos.first
        }
        
        let nextIndex: Int
        if shuffleEnabled {
            nextIndex = Int.random(in: 0..<videos.count)
        } else if currentIndex + 1 < videos.count {
            nextIndex = currentIndex + 1
        } else if repeatMode == .all {
            nextIndex = 0
        } else {
            return nil
        }
        
        return videos.indices.contains(nextIndex) ? videos[nextIndex] : nil
    }
    
    func previousVideo(currentVideoId: UUID?) -> Video? {
        guard let currentIndex = videos.firstIndex(where: { $0.id == currentVideoId }) else {
            return videos.first
        }
        
        if currentIndex > 0 {
            return videos[currentIndex - 1]
        } else if repeatMode == .all {
            return videos.last
        }
        return nil
    }
}

/// 排序方式
enum SortOrder: String, Codable, CaseIterable {
    case manual = "manual"
    case nameAsc = "name_asc"
    case nameDesc = "name_desc"
    case dateAdded = "date_added"
    case duration = "duration"
    
    var displayName: String {
        switch self {
        case .manual: return "手动排序"
        case .nameAsc: return "名称 (A-Z)"
        case .nameDesc: return "名称 (Z-A)"
        case .dateAdded: return "添加日期"
        case .duration: return "时长"
        }
    }
}

/// 循环模式
enum RepeatMode: String, Codable, CaseIterable {
    case none = "none"
    case one = "one"
    case all = "all"
    
    var displayName: String {
        switch self {
        case .none: return "关闭"
        case .one: return "单曲循环"
        case .all: return "列表循环"
        }
    }
    
    var iconName: String {
        switch self {
        case .none: return "repeat"
        case .one: return "repeat.1"
        case .all: return "repeat"
        }
    }
}
