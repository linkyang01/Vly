import Foundation
import CoreData

/// 收藏夹服务 - 添加/移除、自定义、智能收藏
final class FavoritesService {
    static let shared = FavoritesService()
    
    private init() {}
    
    // MARK: - Favorites List Management
    
    /// 获取所有收藏夹
    func getAllFavoritesLists() -> [FavoritesList] {
        let request = FavoritesList.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoritesList.createdAt, ascending: true)]
        
        do {
            return try CoreDataManager.shared.viewContext.fetch(request)
        } catch {
            return []
        }
    }
    
    /// 创建新收藏夹
    func createFavoritesList(name: String, icon: String = "star.fill", color: String = "yellow") -> FavoritesList {
        let context = CoreDataManager.shared.viewContext
        let list = FavoritesList(context: context)
        list.id = UUID()
        list.name = name
        list.icon = icon
        list.color = color
        list.createdAt = Date()
        list.updatedAt = Date()
        
        try? context.save()
        return list
    }
    
    /// 删除收藏夹
    func deleteFavoritesList(_ list: FavoritesList) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            context.delete(list)
            try? context.save()
        }
    }
    
    /// 更新收藏夹
    func updateFavoritesList(_ list: FavoritesList, name: String? = nil, icon: String? = nil, color: String? = nil) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            if let name = name { list.name = name }
            if let icon = icon { list.icon = icon }
            if let color = color { list.color = color }
            list.updatedAt = Date()
            try? context.save()
        }
    }
    
    // MARK: - Movie Favorites Management
    
    /// 添加到收藏夹
    func addToFavorites(_ movie: Movie, list: FavoritesList) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            if let movies = list.movies as? NSMutableSet {
                movies.add(movie)
            } else {
                list.movies = NSSet(object: movie)
            }
            list.updatedAt = Date()
            try? context.save()
        }
        
        // Sync to iCloud if enabled
        Task {
            await CloudSyncService.shared.syncFavoritesChange(movieId: movie.id, action: .add, listId: list.id)
        }
    }
    
    /// 从收藏夹移除
    func removeFromFavorites(_ movie: Movie, list: FavoritesList) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            if let movies = list.movies as? NSMutableSet {
                movies.remove(movie)
            } else if var moviesSet = list.movies as? Set<Movie> {
                moviesSet.remove(movie)
                list.movies = moviesSet as NSSet
            }
            list.updatedAt = Date()
            try? context.save()
        }
        
        // Sync to iCloud if enabled
        Task {
            await CloudSyncService.shared.syncFavoritesChange(movieId: movie.id, action: .remove, listId: list.id)
        }
    }
    
    /// 切换收藏状态
    func toggleFavorite(_ movie: Movie, list: FavoritesList) {
        let context = CoreDataManager.shared.viewContext
        context.perform {
            if list.movies?.contains(movie) == true {
                if let movies = list.movies as? NSMutableSet {
                    movies.remove(movie)
                }
            } else {
                if let movies = list.movies as? NSMutableSet {
                    movies.add(movie)
                } else {
                    list.movies = NSSet(object: movie)
                }
            }
            list.updatedAt = Date()
            try? context.save()
        }
    }
    
    /// 检查电影是否在收藏夹中
    func isFavorite(_ movie: Movie, list: FavoritesList) -> Bool {
        return list.movies?.contains(movie) ?? false
    }
    
    /// 获取电影所在的所有收藏夹
    func getListsContaining(_ movie: Movie) -> [FavoritesList] {
        let allLists = getAllFavoritesLists()
        return allLists.filter { list in
            list.movies?.contains(movie) ?? false
        }
    }
    
    // MARK: - Smart Collections
    
    /// 创建智能收藏夹
    func createSmartList(name: String, criteria: [SmartCriteria]) -> FavoritesList {
        let context = CoreDataManager.shared.viewContext
        let list = FavoritesList(context: context)
        list.id = UUID()
        list.name = name
        list.icon = "sparkles"
        list.color = "purple"
        list.isSmartList = true
        list.criteriaData = try? JSONEncoder().encode(criteria)
        list.createdAt = Date()
        list.updatedAt = Date()
        
        try? context.save()
        return list
    }
    
    /// 刷新智能收藏夹
    func refreshSmartList(_ list: FavoritesList) {
        guard list.isSmartList, let criteriaData = list.criteriaData else { return }
        
        let criteria = (try? JSONDecoder().decode([SmartCriteria].self, from: criteriaData)) ?? []
        let movies = evaluateCriteria(criteria)
        
        let context = CoreDataManager.shared.viewContext
        context.perform {
            // Clear existing movies and add new ones
            if let moviesSet = list.movies as? NSMutableSet {
                moviesSet.removeAllObjects()
            } else {
                list.movies = nil
            }
            
            for movie in movies {
                if let moviesSet = list.movies as? NSMutableSet {
                    moviesSet.add(movie)
                } else {
                    list.movies = NSSet(object: movie)
                }
            }
            
            list.updatedAt = Date()
            try? context.save()
        }
    }
    
    /// 评估智能收藏条件
    private func evaluateCriteria(_ criteria: [SmartCriteria]) -> [Movie] {
        let request = Movie.fetchRequest()
        var predicates: [NSPredicate] = []
        
        for criteriaItem in criteria {
            switch criteriaItem {
            case .genre(let name):
                predicates.append(NSPredicate(format: "ANY genres.name == %@", name))
            case .ratingAtLeast(let rating):
                predicates.append(NSPredicate(format: "rating >= %@", NSNumber(value: rating)))
            case .yearBetween(let start, let end):
                let calendar = Calendar.current
                let startDate = calendar.date(from: DateComponents(year: start))!
                let endDate = calendar.date(from: DateComponents(year: end + 1))!
                predicates.append(NSPredicate(format: "releaseDate >= %@ AND releaseDate < %@", startDate as NSDate, endDate as NSDate))
            case .unwatched:
                predicates.append(NSPredicate(format: "isWatched == NO"))
            case .watched:
                predicates.append(NSPredicate(format: "isWatched == YES"))
            case .inProgress:
                predicates.append(NSPredicate(format: "currentPosition > 0 AND isWatched == NO"))
            case .addedAfter(let date):
                predicates.append(NSPredicate(format: "addedDate >= %@", date as NSDate))
            case .durationLessThan(let minutes):
                predicates.append(NSPredicate(format: "runtime <= %d", minutes))
            case .durationGreaterThan(let minutes):
                predicates.append(NSPredicate(format: "runtime >= %d", minutes))
            case .titleContains(let text):
                predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", text))
            }
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            return try CoreDataManager.shared.viewContext.fetch(request)
        } catch {
            return []
        }
    }
    
    // MARK: - Quick Favorites
    
    /// 添加到默认收藏夹
    func addToDefaultFavorites(_ movie: Movie) {
        let context = CoreDataManager.shared.viewContext
        
        // Get or create default favorites list
        let request = FavoritesList.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "收藏的影片")
        if let list = (try? context.fetch(request))?.first {
            addToFavorites(movie, list: list)
        } else {
            let list = createFavoritesList(name: "收藏的影片", icon: "star.fill", color: "yellow")
            addToFavorites(movie, list: list)
        }
    }
    
    /// 从默认收藏夹移除
    func removeFromDefaultFavorites(_ movie: Movie) {
        let context = CoreDataManager.shared.viewContext
        let request = FavoritesList.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "收藏的影片")
        
        if let list = (try? context.fetch(request))?.first {
            removeFromFavorites(movie, list: list)
        }
    }
    
    /// 切换默认收藏状态
    func toggleDefaultFavorite(_ movie: Movie) {
        let context = CoreDataManager.shared.viewContext
        let request = FavoritesList.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "收藏的影片")
        
        if let list = (try? context.fetch(request))?.first {
            toggleFavorite(movie, list: list)
        } else {
            let list = createFavoritesList(name: "收藏的影片", icon: "star.fill", color: "yellow")
            addToFavorites(movie, list: list)
        }
    }
    
    /// 检查是否在默认收藏夹
    func isInDefaultFavorites(_ movie: Movie) -> Bool {
        let context = CoreDataManager.shared.viewContext
        let request = FavoritesList.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "收藏的影片")
        
        guard let list = (try? context.fetch(request))?.first else { return false }
        return list.movies?.contains(movie) ?? false
    }
    
    // MARK: - Import/Export
    
    /// 导出收藏夹
    func exportFavoritesList(_ list: FavoritesList) -> FavoritesExport? {
        guard let movies = list.movies as? Set<Movie> else { return nil }
        
        let movieIds = movies.map { $0.id.uuidString }
        
        return FavoritesExport(
            name: list.name,
            icon: list.icon,
            color: list.color,
            movieIds: movieIds,
            exportedAt: Date()
        )
    }
    
    /// 导入收藏夹
    func importFavoritesList(_ export: FavoritesExport) -> FavoritesList? {
        let context = CoreDataManager.shared.viewContext
        let list = createFavoritesList(name: export.name, icon: export.icon, color: export.color)
        
        var movies: [Movie] = []
        for idString in export.movieIds {
            guard let id = UUID(uuidString: idString) else { continue }
            let request = Movie.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
            let result = try? context.fetch(request)
            if let movie = result?.first {
                movies.append(movie)
            }
        }
        
        list.movies = NSSet(array: movies)
        
        return list
    }
}

// MARK: - Supporting Types

enum SmartCriteria: Codable {
    case genre(String)
    case ratingAtLeast(Double)
    case yearBetween(Int, Int)
    case unwatched
    case watched
    case inProgress
    case addedAfter(Date)
    case durationLessThan(Int)
    case durationGreaterThan(Int)
    case titleContains(String)
}

struct FavoritesExport: Codable {
    let name: String
    let icon: String
    let color: String
    let movieIds: [String]
    let exportedAt: Date
}

// MARK: - CloudKit Sync Protocol

extension FavoritesService {
    /// 同步本地收藏夹到云端
    func syncToCloud() async throws {
        #if os(iOS)
        guard CloudSyncService.shared.isConfigured else { return }
        try await CloudSyncService.shared.uploadFavorites(self.getAllFavoritesLists())
        #endif
    }
    
    /// 从云端同步收藏夹
    func syncFromCloud() async throws {
        #if os(iOS)
        guard CloudSyncService.shared.isConfigured else { return }
        try await CloudSyncService.shared.downloadFavorites()
        #endif
    }
}
