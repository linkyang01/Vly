import Foundation
import CoreData

/// Core Data 管理器
final class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "linfuse")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data store failed to load: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        // 配置持久化存储
        configurePersistentStore()
    }
    
    // MARK: - Configuration
    
    private func configurePersistentStore() {
        // 可以在此配置 NSPersistentStoreDescription 的选项
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
    }
    
    // MARK: - CRUD Operations
    
    /// 保存上下文
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Movie Operations
    
    /// 创建电影
    func createMovie(title: String, fileURL: URL, fileName: String, fileSize: Int64, addedDate: Date = Date()) -> Movie {
        let context = viewContext
        let movie = Movie(context: context)
        
        movie.id = UUID()
        movie.title = title
        movie.fileURL = fileURL
        movie.fileName = fileName
        movie.fileSize = fileSize
        movie.addedDate = addedDate
        
        // 默认值
        movie.runtime = 0
        movie.rating = 0
        movie.voteCount = 0
        movie.currentPosition = 0
        movie.isWatched = false
        movie.watchCount = 0
        movie.isFavorite = false
        movie.metadataFetched = false
        
        saveContext()
        return movie
    }
    
    /// 获取所有电影
    func fetchAllMovies() -> [Movie] {
        let request = Movie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.title, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching movies: \(error)")
            return []
        }
    }
    
    /// 通过文件 URL 获取电影
    func fetchMovie(byFileURL url: URL) -> Movie? {
        let request = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "fileURL == %@", url as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error fetching movie by URL: \(error)")
            return nil
        }
    }
    
    /// 通过 ID 获取电影
    func fetchMovie(byID id: UUID) -> Movie? {
        let request = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error fetching movie by ID: \(error)")
            return nil
        }
    }
    
    /// 删除电影
    func deleteMovie(_ movie: Movie) {
        viewContext.delete(movie)
        saveContext()
    }
    
    /// 批量删除电影
    func deleteMovies(_ movies: [Movie]) {
        for movie in movies {
            viewContext.delete(movie)
        }
        saveContext()
    }
    
    /// 删除所有电影
    func deleteAllMovies() {
        let movies = fetchAllMovies()
        deleteMovies(movies)
    }
    
    // MARK: - Genre Operations
    
    /// 获取或创建类型
    func getOrCreateGenre(name: String, tmdbID: Int32 = 0) -> Genre {
        let request = Genre.fetchRequestForName(name)
        
        if let existing = try? viewContext.fetch(request).first {
            return existing
        }
        
        let genre = Genre(context: viewContext)
        genre.id = UUID()
        genre.name = name
        genre.tmdbID = tmdbID
        
        saveContext()
        return genre
    }
    
    // MARK: - Statistics
    
    /// 获取电影统计
    func getStatistics() -> LibraryStatistics {
        let movies = fetchAllMovies()
        
        let totalSize = movies.reduce(0) { $0 + $1.fileSize }
        let watchedCount = movies.filter { $0.isWatched }.count
        let favoriteCount = movies.filter { $0.isFavorite }.count
        let withMetadataCount = movies.filter { $0.metadataFetched }.count
        
        // 计算总时长
        let totalRuntime = movies.reduce(0) { $0 + Int($1.runtime) }
        let hours = totalRuntime / 60
        let minutes = totalRuntime % 60
        
        return LibraryStatistics(
            totalMovies: movies.count,
            totalSize: totalSize,
            watchedCount: watchedCount,
            favoriteCount: favoriteCount,
            withMetadataCount: withMetadataCount,
            totalRuntimeHours: hours,
            totalRuntimeMinutes: minutes
        )
    }
    
    // MARK: - Reset
    
    /// 重置整个库
    func resetLibrary() {
        // 删除所有电影
        deleteAllMovies()
        
        // 删除所有收藏夹
        let request = FavoritesList.fetchRequest()
        if let lists = try? viewContext.fetch(request) {
            for list in lists {
                viewContext.delete(list)
            }
        }
        
        // 删除所有类型
        let genreRequest = Genre.fetchRequest()
        if let genres = try? viewContext.fetch(genreRequest) {
            for genre in genres {
                viewContext.delete(genre)
            }
        }
        
        saveContext()
    }
}

// MARK: - Statistics Model

struct LibraryStatistics {
    let totalMovies: Int
    let totalSize: Int64
    let watchedCount: Int
    let favoriteCount: Int
    let withMetadataCount: Int
    let totalRuntimeHours: Int
    let totalRuntimeMinutes: Int
    
    var formattedTotalSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }
    
    var formattedTotalRuntime: String {
        if totalRuntimeHours > 0 {
            return "\(totalRuntimeHours)h \(totalRuntimeMinutes)m"
        }
        return "\(totalRuntimeMinutes)m"
    }
    
    var watchedPercentage: Double {
        guard totalMovies > 0 else { return 0 }
        return Double(watchedCount) / Double(totalMovies) * 100
    }
}
