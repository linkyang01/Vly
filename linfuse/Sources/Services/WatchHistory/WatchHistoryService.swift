import Foundation
import CoreData
import Combine

/// 观看历史服务
final class WatchHistoryService: ObservableObject {
    static let shared = WatchHistoryService()
    
    private let context: NSManagedObjectContext
    
    private init() {
        self.context = CoreDataManager.shared.viewContext
    }
    
    // MARK: - Add Entry
    
    /// 添加观看记录
    func addEntry(for movie: Movie, position: Double, duration: Double, completed: Bool = false) {
        let entry = WatchHistoryEntry(context: context)
        entry.id = UUID()
        entry.movie = movie
        entry.position = position
        entry.duration = duration
        entry.timestamp = Date()
        entry.completed = completed
        
        // 更新电影的播放进度
        movie.currentPosition = position
        movie.lastWatchedDate = Date()
        movie.watchCount += 1
        movie.isWatched = completed
        
        saveContext()
    }
    
    // MARK: - Fetch History
    
    /// 获取电影的观看历史
    func fetchHistory(for movie: Movie) -> [WatchHistoryEntry] {
        let request = WatchHistoryEntry.fetchRequest()
        request.predicate = NSPredicate(format: "movie == %@", movie)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WatchHistoryEntry.timestamp, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching watch history: \(error)")
            return []
        }
    }
    
    /// 获取最近观看
    func fetchRecentWatched(limit: Int = 20) -> [Movie] {
        let request = WatchHistoryEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WatchHistoryEntry.timestamp, ascending: false)]
        request.fetchLimit = limit
        
        do {
            let entries = try context.fetch(request)
            var movies: [Movie] = []
            var seenIds = Set<UUID>()
            
            for entry in entries {
                if let movie = entry.movie, !seenIds.contains(movie.id) {
                    movies.append(movie)
                    seenIds.insert(movie.id)
                }
            }
            return movies
        } catch {
            print("Error fetching recent watched: \(error)")
            return []
        }
    }
    
    /// 获取所有观看历史（用于统计）
    func fetchAllHistory() -> [WatchHistoryEntry] {
        let request = WatchHistoryEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WatchHistoryEntry.timestamp, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching all history: \(error)")
            return []
        }
    }
    
    // MARK: - Update Entry
    
    /// 更新播放进度
    func updatePosition(for movie: Movie, position: Double, duration: Double) {
        addEntry(for: movie, position: position, duration: duration)
    }
    
    /// 标记为已看完
    func markAsCompleted(for movie: Movie, position: Double = 0, duration: Double) {
        addEntry(for: movie, position: duration, duration: duration, completed: true)
    }
    
    // MARK: - Delete
    
    /// 删除电影的所有历史
    func deleteHistory(for movie: Movie) {
        let history = fetchHistory(for: movie)
        for entry in history {
            context.delete(entry)
        }
        
        movie.currentPosition = 0
        movie.lastWatchedDate = nil
        movie.watchCount = 0
        movie.isWatched = false
        
        saveContext()
    }
    
    /// 删除单条记录
    func deleteEntry(_ entry: WatchHistoryEntry) {
        context.delete(entry)
        saveContext()
    }
    
    /// 清除所有历史
    func clearAllHistory() {
        let history = fetchAllHistory()
        for entry in history {
            context.delete(entry)
        }
        saveContext()
    }
    
    // MARK: - Statistics
    
    /// 获取观看统计
    func getStatistics() -> WatchStatistics {
        let history = fetchAllHistory()
        
        let totalTime = history.reduce(0.0) { $0 + $1.duration }
        let completedCount = history.filter { $0.completed }.count
        let uniqueMovies = Set(history.compactMap { $0.movie?.id }).count
        
        return WatchStatistics(
            totalEntries: history.count,
            totalWatchTime: totalTime,
            completedCount: completedCount,
            uniqueMoviesWatched: uniqueMovies
        )
    }
    
    // MARK: - Private
    
    private func saveContext() {
        CoreDataManager.shared.saveContext()
    }
}

// MARK: - Statistics Model

struct WatchStatistics {
    let totalEntries: Int
    let totalWatchTime: Double
    let completedCount: Int
    let uniqueMoviesWatched: Int
    
    var formattedWatchTime: String {
        let hours = Int(totalWatchTime / 3600)
        let minutes = Int((totalWatchTime.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
}
