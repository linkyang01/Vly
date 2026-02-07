import Foundation
import CoreData

/// 收藏夹服务
final class FavoritesService {
    static let shared = FavoritesService()
    
    private let context: NSManagedObjectContext
    
    private init() {
        self.context = CoreDataManager.shared.viewContext
    }
    
    // MARK: - Favorites Lists
    
    /// 获取所有收藏夹
    func fetchAllLists() -> [FavoritesList] {
        let request = FavoritesList.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoritesList.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching favorite lists: \(error)")
            return []
        }
    }
    
    /// 创建收藏夹
    func createList(name: String, icon: String = "star.fill", color: String = "yellow") -> FavoritesList {
        let list = FavoritesList(context: context)
        list.id = UUID()
        list.name = name
        list.icon = icon
        list.color = color
        list.createdAt = Date()
        list.updatedAt = Date()
        list.isSmartList = false
        
        saveContext()
        return list
    }
    
    /// 删除收藏夹
    func deleteList(_ list: FavoritesList) {
        context.delete(list)
        saveContext()
    }
    
    /// 更新收藏夹
    func updateList(_ list: FavoritesList, name: String? = nil, icon: String? = nil, color: String? = nil) {
        if let name = name {
            list.name = name
        }
        if let icon = icon {
            list.icon = icon
        }
        if let color = color {
            list.color = color
        }
        list.updatedAt = Date()
        saveContext()
    }
    
    // MARK: - Manage Favorites
    
    /// 添加到收藏夹
    func addToFavorites(_ movie: Movie, list: FavoritesList? = nil) {
        // 如果没有指定收藏夹，使用默认的 "Favorites"
        let targetList = list ?? getOrCreateDefaultList()
        
        if targetList.movies == nil {
            targetList.movies = Set<Movie>()
        }
        
        targetList.movies?.insert(movie)
        targetList.updatedAt = Date()
        movie.isFavorite = true
        
        saveContext()
    }
    
    /// 从收藏夹移除
    func removeFromFavorites(_ movie: Movie, list: FavoritesList? = nil) {
        let targetList = list ?? getOrCreateDefaultList()
        targetList.movies?.remove(movie)
        targetList.updatedAt = Date()
        
        // 检查是否还在其他收藏夹
        if !isInAnyList(movie) {
            movie.isFavorite = false
        }
        
        saveContext()
    }
    
    /// 切换收藏状态
    func toggleFavorite(_ movie: Movie, list: FavoritesList? = nil) {
        if isFavorite(movie, in: list) {
            removeFromFavorites(movie, list: list)
        } else {
            addToFavorites(movie, list: list)
        }
    }
    
    // MARK: - Query
    
    /// 检查是否在收藏夹
    func isFavorite(_ movie: Movie, in list: FavoritesList? = nil) -> Bool {
        if let list = list {
            return list.movies?.contains(movie) ?? false
        }
        return isInAnyList(movie)
    }
    
    /// 检查是否在任何收藏夹中
    func isInAnyList(_ movie: Movie) -> Bool {
        let lists = fetchAllLists()
        return lists.contains { $0.movies?.contains(movie) ?? false }
    }
    
    /// 获取电影所在的所有收藏夹
    func listsContaining(_ movie: Movie) -> [FavoritesList] {
        return fetchAllLists().filter { $0.movies?.contains(movie) ?? false }
    }
    
    /// 获取收藏的电影
    func fetchFavoriteMovies() -> [Movie] {
        let lists = fetchAllLists()
        var movies: [Movie] = []
        var seenIds = Set<UUID>()
        
        for list in lists {
            for movie in list.movies ?? [] {
                if !seenIds.contains(movie.id) {
                    movies.append(movie)
                    seenIds.insert(movie.id)
                }
            }
        }
        
        return movies.sorted { $0.title < $1.title }
    }
    
    // MARK: - Smart Lists
    
    /// 创建智能收藏夹
    func createSmartList(name: String, criteria: SmartFilterCriteria) -> FavoritesList {
        let list = FavoritesList(context: context)
        list.id = UUID()
        list.name = name
        list.icon = "sparkles"
        list.color = "purple"
        list.createdAt = Date()
        list.updatedAt = Date()
        list.isSmartList = true
        list.criteriaData = try? JSONEncoder().encode(criteria)
        
        saveContext()
        return list
    }
    
    /// 获取智能列表的电影
    func fetchSmartListMovies(_ list: FavoritesList) -> [Movie] {
        guard list.isSmartList, let criteriaData = list.criteriaData,
              let criteria = try? JSONDecoder().decode(SmartFilterCriteria.self, from: criteriaData) else {
            return []
        }
        
        let request = Movie.fetchRequest()
        var predicates: [NSPredicate] = []
        
        // 应用筛选条件
        if let minRating = criteria.minRating {
            predicates.append(NSPredicate(format: "rating >= %@", NSNumber(value: minRating)))
        }
        
        if let yearFrom = criteria.yearFrom {
            predicates.append(NSPredicate(format: "releaseDate >= %@", yearFrom as NSDate))
        }
        
        if let yearTo = criteria.yearTo {
            predicates.append(NSPredicate(format: "releaseDate <= %@", yearTo as NSDate))
        }
        
        switch criteria.watchStatus {
        case .watched:
            predicates.append(NSPredicate(format: "isWatched == YES"))
        case .unwatched:
            predicates.append(NSPredicate(format: "isWatched == NO"))
        case .inProgress:
            predicates.append(NSPredicate(format: "currentPosition > 0 AND isWatched == NO"))
        default:
            break
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching smart list movies: \(error)")
            return []
        }
    }
    
    // MARK: - Private
    
    private func getOrCreateDefaultList() -> FavoritesList {
        let request = FavoritesList.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "Favorites")
        
        if let existing = try? context.fetch(request).first {
            return existing
        }
        
        return createList(name: "Favorites", icon: "star.fill", color: "yellow")
    }
    
    private func saveContext() {
        CoreDataManager.shared.saveContext()
    }
}

// MARK: - Smart Filter Criteria

struct SmartFilterCriteria: Codable {
    var minRating: Double?
    var yearFrom: Date?
    var yearTo: Date?
    var genres: [String]?
    var watchStatus: WatchStatus
    var sortBy: SortOption
    
    enum WatchStatus: String, Codable {
        case all, watched, unwatched, inProgress
    }
    
    enum SortOption: String, Codable {
        case dateAdded, rating, releaseDate, title
    }
}
