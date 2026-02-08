import Foundation

/// 播放历史服务
class HistoryService: ObservableObject {
    // MARK: - Singleton
    
    static let shared = HistoryService()
    
    // MARK: - Published Properties
    
    @Published var entries: [HistoryEntry] = []
    @Published var maxEntries: Int = 100
    
    // MARK: - Private Properties
    
    private let userDefaultsKey = "vly_playback_history"
    
    // MARK: - Initialization
    
    private init() {
        loadHistory()
    }
    
    // MARK: - Public Methods
    
    func addEntry(videoId: UUID, title: String, url: URL, watchDuration: TimeInterval, totalDuration: TimeInterval) {
        let entry = HistoryEntry(
            videoId: videoId,
            title: title,
            url: url,
            watchDuration: watchDuration,
            totalDuration: totalDuration
        )
        
        // 移除相同视频的旧记录
        entries.removeAll { $0.videoId == videoId }
        
        // 添加新记录到开头
        entries.insert(entry, at: 0)
        
        // 限制数量
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
        
        saveHistory()
    }
    
    func removeEntry(id: UUID) {
        entries.removeAll { $0.id == id }
        saveHistory()
    }
    
    func removeEntry(at index: Int) {
        guard index >= 0 && index < entries.count else { return }
        entries.remove(at: index)
        saveHistory()
    }
    
    func clearHistory() {
        entries.removeAll()
        saveHistory()
    }
    
    func getEntry(for videoId: UUID) -> HistoryEntry? {
        entries.first { $0.videoId == videoId }
    }
    
    func hasWatched(videoId: UUID) -> Bool {
        entries.contains { $0.videoId == videoId }
    }
    
    func getWatchProgress(videoId: UUID) -> TimeInterval? {
        entries.first { $0.videoId == videoId }?.watchDuration
    }
    
    func updateWatchProgress(videoId: UUID, progress: TimeInterval, totalDuration: TimeInterval) {
        if let index = entries.firstIndex(where: { $0.videoId == videoId }) {
            var entry = entries[index]
            entry = HistoryEntry(
                id: entry.id,
                videoId: entry.videoId,
                title: entry.title,
                url: entry.url,
                watchedAt: Date(),
                watchDuration: progress,
                totalDuration: totalDuration
            )
            entries[index] = entry
            saveHistory()
        }
    }
    
    // MARK: - Statistics
    
    var totalWatchTime: TimeInterval {
        entries.reduce(0) { $0 + $1.watchDuration }
    }
    
    var formattedTotalWatchTime: String {
        let hours = Int(totalWatchTime) / 3600
        let minutes = (Int(totalWatchTime) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)小时 \(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
    
    var completedVideos: Int {
        entries.filter { $0.isCompleted }.count
    }
    
    var uniqueVideos: Int {
        Set(entries.map { $0.videoId }).count
    }
    
    func getRecentlyPlayed(limit: Int = 10) -> [HistoryEntry] {
        Array(entries.prefix(limit))
    }
    
    func getMostWatched(limit: Int = 10) -> [HistoryEntry] {
        Array(entries.sorted { $0.watchDuration > $1.watchDuration }.prefix(limit))
    }
    
    // MARK: - Persistence
    
    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save history: \(error)")
        }
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        
        do {
            entries = try JSONDecoder().decode([HistoryEntry].self, from: data)
        } catch {
            print("Failed to load history: \(error)")
            entries = []
        }
    }
    
    func reset() {
        entries.removeAll()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
