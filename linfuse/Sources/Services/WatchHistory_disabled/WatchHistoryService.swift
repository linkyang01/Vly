import Foundation
import CoreData

/// 观看历史服务 - 进度追踪、断点续播、统计报告
final class WatchHistoryService {
    static let shared = WatchHistoryService()
    
    private init() {}
    
    // MARK: - Progress Tracking
    
    /// 保存观看进度
    func saveProgress(for movie: Movie, position: Double, duration: Double) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            movie.currentPosition = position
            movie.lastWatchedDate = Date()
            
            // 标记为已观看（90%完成）
            let progress = duration > 0 ? position / duration : 0
            if progress >= 0.9 {
                movie.isWatched = true
                movie.watchCount += 1
            }
            
            // 创建历史记录
            let entry = WatchHistoryEntry(context: context)
            entry.id = UUID()
            entry.timestamp = Date()
            entry.position = position
            entry.duration = duration
            entry.completed = progress >= 0.9
            entry.movie = movie
            
            try? context.save()
        }
    }
    
    /// 获取断点续播位置
    func getResumePosition(for movie: Movie) -> Double {
        return movie.currentPosition
    }
    
    /// 标记为已观看
    func markAsWatched(_ movie: Movie) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            movie.isWatched = true
            movie.currentPosition = movie.duration
            movie.lastWatchedDate = Date()
            movie.watchCount += 1
            try? context.save()
        }
    }
    
    /// 标记为未观看
    func markAsUnwatched(_ movie: Movie) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            movie.isWatched = false
            movie.currentPosition = 0
            try? context.save()
        }
    }
    
    /// 重置观看进度
    func resetProgress(_ movie: Movie) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            movie.currentPosition = 0
            movie.isWatched = false
            try? context.save()
        }
    }
    
    // MARK: - History Query
    
    /// 获取最近观看的电影
    func getRecentlyWatched(limit: Int = 20) -> [Movie] {
        let request = Movie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.lastWatchedDate, ascending: false)]
        request.predicate = NSPredicate(format: "lastWatchedDate != nil")
        request.fetchLimit = limit
        
        do {
            return try CoreDataManager.shared.viewContext.fetch(request)
        } catch {
            return []
        }
    }
    
    /// 获取观看历史记录
    func getHistoryEntries(for movie: Movie, limit: Int = 50) -> [WatchHistoryEntry] {
        let request = WatchHistoryEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WatchHistoryEntry.timestamp, ascending: false)]
        request.predicate = NSPredicate(format: "movie == %@", movie)
        request.fetchLimit = limit
        
        do {
            return try CoreDataManager.shared.viewContext.fetch(request)
        } catch {
            return []
        }
    }
    
    /// 获取所有历史记录
    func getAllHistory(limit: Int = 100) -> [WatchHistoryEntry] {
        let request = WatchHistoryEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WatchHistoryEntry.timestamp, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try CoreDataManager.shared.viewContext.fetch(request)
        } catch {
            return []
        }
    }
    
    /// 清空历史记录
    func clearHistory() {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            let request = WatchHistoryEntry.fetchRequest()
            if let entries = try? context.fetch(request) {
                entries.forEach { context.delete($0) }
            }
            try? context.save()
        }
    }
    
    /// 删除指定电影的历史记录
    func deleteHistory(for movie: Movie) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            let request = WatchHistoryEntry.fetchRequest()
            request.predicate = NSPredicate(format: "movie == %@", movie)
            if let entries = try? context.fetch(request) {
                entries.forEach { context.delete($0) }
            }
            try? context.save()
        }
    }
    
    // MARK: - Statistics
    
    /// 获取观看统计
    func getWatchStatistics() -> WatchStatistics {
        let context = CoreDataManager.shared.viewContext
        
        let totalMoviesRequest = Movie.fetchRequest()
        let totalMovies = (try? context.count(for: totalMoviesRequest)) ?? 0
        
        let watchedRequest = Movie.fetchRequest()
        watchedRequest.predicate = NSPredicate(format: "isWatched == YES")
        let watchedMovies = (try? context.count(for: watchedRequest)) ?? 0
        
        let inProgressRequest = Movie.fetchRequest()
        inProgressRequest.predicate = NSPredicate(format: "currentPosition > 0 AND isWatched == NO")
        let inProgress = (try? context.count(for: inProgressRequest)) ?? 0
        
        let totalWatchCountRequest = Movie.fetchRequest()
        let allMovies = (try? context.fetch(totalWatchCountRequest)) ?? []
        let totalWatchCount = allMovies.reduce(0) { $0 + Int($1.watchCount) }
        
        let totalMinutesWatched = allMovies.reduce(0.0) { $0 + $1.currentPosition } / 60
        
        let historyRequest = WatchHistoryEntry.fetchRequest()
        let historyEntries = (try? context.fetch(historyRequest)) ?? []
        let completedSessions = historyEntries.filter { $0.completed }.count
        
        let lastWeekDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentHistory = historyEntries.filter { $0.timestamp > lastWeekDate }
        let minutesThisWeek = recentHistory.reduce(0.0) { $0 + $1.position } / 60
        
        return WatchStatistics(
            totalMovies: totalMovies,
            watchedMovies: watchedMovies,
            inProgressMovies: inProgress,
            totalWatchCount: totalWatchCount,
            totalMinutesWatched: totalMinutesWatched,
            completedSessions: completedSessions,
            minutesThisWeek: minutesThisWeek
        )
    }
    
    /// 获取每日观看统计（过去30天）
    func getDailyWatchStats(days: Int = 30) -> [DailyWatchStat] {
        let context = CoreDataManager.shared.viewContext
        let calendar = Calendar.current
        
        var stats: [DailyWatchStat] = []
        let today = Date()
        
        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
            
            let request = WatchHistoryEntry.fetchRequest()
            request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
            
            let entries = (try? context.fetch(request)) ?? []
            let minutesWatched = entries.reduce(0.0) { $0 + $1.position } / 60
            let completed = entries.filter { $0.completed }.count
            
            stats.append(DailyWatchStat(
                date: date,
                minutesWatched: minutesWatched,
                moviesCompleted: completed
            ))
        }
        
        return stats.reversed()
    }
    
    /// 获取类型分布统计
    func getGenreDistribution() -> [GenreStat] {
        let context = CoreDataManager.shared.viewContext
        let movies = (try? context.fetch(Movie.fetchRequest())) ?? []
        
        var genreCounts: [String: Int] = [:]
        var genreMinutes: [String: Double] = [:]
        
        for movie in movies {
            guard let genres = movie.genres else { continue }
            for genre in genres {
                genreCounts[genre.name, default: 0] += 1
                genreMinutes[genre.name, default: 0] += movie.duration
            }
        }
        
        return genreCounts.keys.sorted().map { name in
            GenreStat(
                genre: name,
                movieCount: genreCounts[name] ?? 0,
                totalMinutes: genreMinutes[name] ?? 0
            )
        }
    }
    
    /// 获取每月观看趋势
    func getMonthlyTrend(months: Int = 12) -> [MonthlyTrend] {
        let history = getAllHistory(limit: 1000)
        let calendar = Calendar.current
        
        var trends: [Date: (month: Date, minutesWatched: Double, moviesCompleted: Int, sessions: Int)] = [:]
        let today = Date()
        
        for entry in history {
            guard let month = calendar.dateComponents([.year, .month], from: entry.timestamp).date else { continue }
            
            if trends[month] == nil {
                trends[month] = (month: month, minutesWatched: 0, moviesCompleted: 0, sessions: 0)
            }
            
            trends[month]?.minutesWatched += entry.position / 60
            if entry.completed {
                trends[month]?.moviesCompleted += 1
            }
            trends[month]?.sessions += 1
        }
        
        return trends.values.map { MonthlyTrend(month: $0.month, minutesWatched: $0.minutesWatched, moviesCompleted: $0.moviesCompleted, sessions: $0.sessions) }
            .sorted { $0.month < $1.month }
    }
}

// MARK: - Statistics Models

struct WatchStatistics {
    let totalMovies: Int
    let watchedMovies: Int
    let inProgressMovies: Int
    let totalWatchCount: Int
    let totalMinutesWatched: Double
    let completedSessions: Int
    let minutesThisWeek: Double
    
    var watchedPercentage: Double {
        guard totalMovies > 0 else { return 0 }
        return Double(watchedMovies) / Double(totalMovies) * 100
    }
    
    var formattedTotalTime: String {
        let hours = Int(totalMinutesWatched) / 60
        let minutes = Int(totalMinutesWatched) % 60
        return "\(hours)h \(minutes)m"
    }
    
    var formattedWeekTime: String {
        let hours = Int(minutesThisWeek) / 60
        let minutes = Int(minutesThisWeek) % 60
        return "\(hours)h \(minutes)m"
    }
}

struct DailyWatchStat {
    let date: Date
    let minutesWatched: Double
    let moviesCompleted: Int
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

struct GenreStat {
    let genre: String
    let movieCount: Int
    let totalMinutes: Double
    
    var formattedTime: String {
        let hours = Int(totalMinutes) / 60
        let minutes = Int(totalMinutes) % 60
        return "\(hours)h \(minutes)m"
    }
}

struct MonthlyTrend {
    let month: Date
    let minutesWatched: Double
    let moviesCompleted: Int
    let sessions: Int
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: month)
    }
}
