import Foundation
import CoreData
import CloudKit

/// iCloud 同步服务 - CloudKit 配置、冲突解决
@MainActor
final class CloudSyncService: ObservableObject {
    static let shared = CloudSyncService()
    
    private init() {}
    
    // MARK: - Published Properties
    
    @Published var isConfigured = false
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?
    @Published var accountStatus: CKAccountStatus = .couldNotDetermine
    
    // MARK: - Private Properties
    
    private let containerIdentifier = "iCloud.com.linfuse.app"
    private lazy var container = CKContainer(identifier: containerIdentifier)
    private lazy var privateDatabase = container.privateCloudDatabase
    
    private let syncQueue = DispatchQueue(label: "com.linfuse.sync", qos: .utility)
    
    // MARK: - Configuration
    
    /// 配置 CloudKit
    func configure() async {
        do {
            accountStatus = try await container.accountStatus()
            
            switch accountStatus {
            case .available:
                isConfigured = true
                await loadLastSyncDate()
            case .noAccount:
                isConfigured = false
                print("No iCloud account available")
            case .restricted:
                isConfigured = false
                print("iCloud access restricted")
            case .couldNotDetermine:
                isConfigured = false
                print("Could not determine iCloud account status")
            case .temporarilyUnavailable:
                isConfigured = false
                print("iCloud temporarily unavailable")
            @unknown default:
                isConfigured = false
            }
        } catch {
            syncError = error
            isConfigured = false
        }
    }
    
    /// 检查 iCloud 可用性
    func checkAvailability() async -> Bool {
        do {
            let status = try await container.accountStatus()
            return status == .available
        } catch {
            return false
        }
    }
    
    // MARK: - Sync Operations
    
    /// 执行完整同步
    func performFullSync() async throws {
        guard isConfigured else {
            throw SyncError.notConfigured
        }
        
        isSyncing = true
        syncError = nil
        
        defer { isSyncing = false }
        
        do {
            // 同步电影数据
            try await syncMovies()
            
            // 同步观看进度
            try await syncWatchProgress()
            
            // 同步收藏夹
            try await syncFavorites()
            
            // 同步自定义标签
            try await syncCustomTags()
            
            lastSyncDate = Date()
            await saveLastSyncDate()
        }
    }
    
    /// 同步电影数据
    private func syncMovies() async throws {
        let localMovies = await fetchLocalMovies()
        
        for movie in localMovies {
            try await uploadMovie(movie)
        }
        
        let remoteRecords = try await fetchRemoteMovies()
        for record in remoteRecords {
            try await downloadMovie(record)
        }
    }
    
    /// 同步观看进度
    private func syncWatchProgress() async throws {
        let localMovies = await fetchLocalMovies()
        
        for movie in localMovies {
            let recordID = CKRecord.ID(recordName: movie.id.uuidString)
            do {
                let record = try await privateDatabase.record(for: recordID)
                
                // 解决冲突：取最新的修改时间
                if let remotePosition = record["currentPosition"] as? Double,
                   let remoteDate = record["lastWatchedDate"] as? Date {
                    
                    if remoteDate > (movie.lastWatchedDate ?? Date.distantPast) {
                        // 远程更新更晚，采用远程数据
                        movie.currentPosition = remotePosition
                        movie.lastWatchedDate = remoteDate
                    }
                }
                
                // 上传本地进度
                record["currentPosition"] = movie.currentPosition
                record["lastWatchedDate"] = movie.lastWatchedDate
                record["isWatched"] = movie.isWatched
                record["watchCount"] = movie.watchCount
                
                _ = try await privateDatabase.save(record)
            } catch let error as CKError where error.code == .unknownItem {
                // 远程不存在，创建新记录
                try await uploadMovie(movie)
            }
        }
        
        try await saveContext()
    }
    
    /// 同步收藏夹
    private func syncFavorites() async throws {
        let lists = FavoritesService.shared.getAllFavoritesLists()
        
        for list in lists {
            // 同步收藏夹记录
            let recordID = CKRecord.ID(recordName: list.id.uuidString)
            let record = CKRecord(recordType: "FavoritesList", recordID: recordID)
            
            record["name"] = list.name
            record["icon"] = list.icon
            record["color"] = list.color
            record["isSmartList"] = list.isSmartList
            record["updatedAt"] = list.updatedAt
            
            // 序列化电影 ID 列表
            if let movieIds = (list.movies as? Set<Movie>)?.map({ $0.id.uuidString }) {
                record["movieIds"] = movieIds
            }
            
            _ = try await privateDatabase.save(record)
        }
    }
    
    /// 同步自定义标签
    private func syncCustomTags() async throws {
        let tags = ClassificationService.shared.getAllCustomTags()
        
        for tag in tags {
            let recordID = CKRecord.ID(recordName: tag.id.uuidString)
            let record = CKRecord(recordType: "CustomTag", recordID: recordID)
            
            record["name"] = tag.name
            record["icon"] = tag.icon
            record["color"] = tag.color
            record["createdAt"] = tag.createdAt
            
            if let movieIds = (tag.movies as? Set<Movie>)?.map({ $0.id.uuidString }) {
                record["movieIds"] = movieIds
            }
            
            _ = try await privateDatabase.save(record)
        }
    }
    
    // MARK: - Upload Operations
    
    /// 上传电影
    private func uploadMovie(_ movie: Movie) async throws {
        let recordID = CKRecord.ID(recordName: movie.id.uuidString)
        let record = CKRecord(recordType: "Movie", recordID: recordID)
        
        record["title"] = movie.title
        record["originalTitle"] = movie.originalTitle
        record["overview"] = movie.overview
        record["releaseDate"] = movie.releaseDate
        record["runtime"] = movie.runtime
        record["rating"] = movie.rating
        record["posterPath"] = movie.posterPath
        record["backdropPath"] = movie.backdropPath
        record["filePath"] = movie.fileURL.absoluteString
        record["fileSize"] = movie.fileSize
        record["duration"] = movie.duration
        record["currentPosition"] = movie.currentPosition
        record["isWatched"] = movie.isWatched
        record["watchCount"] = movie.watchCount
        record["lastWatchedDate"] = movie.lastWatchedDate
        record["addedDate"] = movie.addedDate
        record["metadataFetched"] = movie.metadataFetched
        
        // 序列化类型
        if let genreNames = movie.genres?.map({ $0.name }) {
            record["genreNames"] = genreNames
        }
        
        _ = try await privateDatabase.save(record)
    }
    
    /// 上传收藏夹变更
    func syncFavoritesChange(movieId: UUID, action: FavoritesAction, listId: UUID) async {
        guard isConfigured else { return }
        
        let recordID = CKRecord.ID(recordName: "FavoritesChange-\(UUID().uuidString)")
        let record = CKRecord(recordType: "FavoritesChange", recordID: recordID)
        
        record["movieId"] = movieId.uuidString
        record["listId"] = listId.uuidString
        record["action"] = action.rawValue
        record["timestamp"] = Date()
        
        do {
            _ = try await privateDatabase.save(record)
        } catch {
            print("Failed to sync favorites change: \(error)")
        }
    }
    
    /// 上传收藏夹列表
    func uploadFavorites(_ lists: [FavoritesList]) async throws {
        guard isConfigured else { return }
        
        for list in lists {
            let recordID = CKRecord.ID(recordName: list.id.uuidString)
            let record = CKRecord(recordType: "FavoritesList", recordID: recordID)
            
            record["name"] = list.name
            record["icon"] = list.icon
            record["color"] = list.color
            record["isSmartList"] = list.isSmartList
            record["updatedAt"] = list.updatedAt
            
            if let movieIds = (list.movies as? Set<Movie>)?.map({ $0.id.uuidString }) {
                record["movieIds"] = movieIds
            }
            
            _ = try await privateDatabase.save(record)
        }
    }
    
    // MARK: - Download Operations
    
    /// 下载电影
    private func downloadMovie(_ record: CKRecord) async throws {
        let context = CoreDataManager.shared.viewContext
        
        guard let idString = record.recordID.recordName as String?,
              let id = UUID(uuidString: idString) else { return }
        
        // 检查是否已存在
        let request = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        
        let existingMovies = try context.fetch(request)
        let existingMovie = existingMovies.first
        
        // 冲突解决：比较修改时间
        let remoteDate = record.modificationDate ?? Date.distantPast
        let localDate = existingMovie?.addedDate ?? Date.distantPast
        
        if remoteDate > localDate {
            // 采用远程数据
            let movie = existingMovie ?? Movie(context: context)
            movie.id = id
            movie.title = record["title"] as? String ?? ""
            movie.originalTitle = record["originalTitle"] as? String
            movie.overview = record["overview"] as? String
            movie.releaseDate = record["releaseDate"] as? Date
            movie.runtime = record["runtime"] as? Int32 ?? 0
            movie.rating = record["rating"] as? Double ?? 0
            movie.posterPath = record["posterPath"] as? String
            movie.backdropPath = record["backdropPath"] as? String
            
            if let filePathString = record["filePath"] as? String {
                movie.fileURL = URL(string: filePathString) ?? URL(fileURLWithPath: "/")
            }
            
            movie.fileSize = record["fileSize"] as? Int64 ?? 0
            movie.duration = record["duration"] as? Double ?? 0
            movie.currentPosition = record["currentPosition"] as? Double ?? 0
            movie.isWatched = record["isWatched"] as? Bool ?? false
            movie.watchCount = record["watchCount"] as? Int32 ?? 0
            movie.lastWatchedDate = record["lastWatchedDate"] as? Date
            movie.addedDate = record["addedDate"] as? Date ?? Date()
            movie.metadataFetched = record["metadataFetched"] as? Bool ?? false
            
            try? context.save()
        }
    }
    
    /// 获取远程电影
    private func fetchRemoteMovies() async throws -> [CKRecord] {
        let query = CKQuery(recordType: "Movie", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "addedDate", ascending: false)]
        
        let (results, _) = try await privateDatabase.records(matching: query)
        return results.compactMap { _, result -> CKRecord? in
            guard case .success(let record) = result else { return nil }
            return record
        }
    }
    
    /// 下载收藏夹
    func downloadFavorites() async throws {
        let query = CKQuery(recordType: "FavoritesList", predicate: NSPredicate(value: true))
        
        let (results, _) = try await privateDatabase.records(matching: query)
        
        for (_, result) in results {
            guard case .success(let record) = result else { continue }
            
            guard let idString = record.recordID.recordName as String?,
                  let id = UUID(uuidString: idString) else { continue }
            
            let context = CoreDataManager.shared.viewContext
            let request = FavoritesList.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
            
            if (try? context.fetch(request))?.first == nil {
                let list = FavoritesList(context: context)
                list.id = id
                list.name = record["name"] as? String ?? "Unknown"
                list.icon = record["icon"] as? String ?? "star.fill"
                list.color = record["color"] as? String ?? "yellow"
                list.isSmartList = record["isSmartList"] as? Bool ?? false
                list.createdAt = Date()
                list.updatedAt = record["updatedAt"] as? Date ?? Date()
            }
            
            try? context.save()
        }
    }
    
    /// 获取本地电影
    private func fetchLocalMovies() async -> [Movie] {
        let context = CoreDataManager.shared.viewContext
        return (try? context.fetch(Movie.fetchRequest())) ?? []
    }
    
    // MARK: - Delete Operations
    
    /// 删除远程电影记录
    func deleteRemoteMovie(_ movie: Movie) async throws {
        guard isConfigured else { return }
        
        let recordID = CKRecord.ID(recordName: movie.id.uuidString)
        do {
            try await privateDatabase.deleteRecord(withID: recordID)
        } catch let error as CKError where error.code != .unknownItem {
            throw error
        }
    }
    
    /// 删除远程收藏夹记录
    func deleteRemoteFavoritesList(_ list: FavoritesList) async throws {
        guard isConfigured else { return }
        
        let recordID = CKRecord.ID(recordName: list.id.uuidString)
        do {
            try await privateDatabase.deleteRecord(withID: recordID)
        } catch let error as CKError where error.code != .unknownItem {
            throw error
        }
    }
    
    // MARK: - Conflict Resolution
    
    /// 解决数据冲突
    func resolveConflict(local: Movie, remote: CKRecord) -> Movie {
        let localDate = local.lastWatchedDate ?? Date.distantPast
        let remoteDate = remote.modificationDate ?? Date.distantPast
        
        // 取更新更晚的数据
        if remoteDate > localDate {
            // 更新本地数据
            local.currentPosition = remote["currentPosition"] as? Double ?? 0
            local.lastWatchedDate = remote["lastWatchedDate"] as? Date
            local.isWatched = remote["isWatched"] as? Bool ?? false
            local.watchCount = remote["watchCount"] as? Int32 ?? 0
            
            // 标记需要重新上传
            Task {
                try? await uploadMovie(local)
            }
        }
        
        return local
    }
    
    // MARK: - Persistence
    
    private func loadLastSyncDate() async {
        let defaults = UserDefaults.standard
        lastSyncDate = defaults.object(forKey: "lastSyncDate") as? Date
    }
    
    private func saveLastSyncDate() async {
        let defaults = UserDefaults.standard
        defaults.set(lastSyncDate, forKey: "lastSyncDate")
    }
    
    private func saveContext() async {
        let context = CoreDataManager.shared.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}

// MARK: - Supporting Types

enum SyncError: LocalizedError {
    case notConfigured
    case networkUnavailable
    case conflictDetected
    case uploadFailed(Error)
    case downloadFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "iCloud is not configured. Please sign in to iCloud in System Settings."
        case .networkUnavailable:
            return "Network is unavailable. Please check your connection."
        case .conflictDetected:
            return "A sync conflict was detected. Please resolve manually."
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        case .downloadFailed(let error):
            return "Download failed: \(error.localizedDescription)"
        }
    }
}

enum FavoritesAction: String {
    case add
    case remove
}
