import Foundation

/// 元数据缓存服务
final class MetadataCache {
    static let shared = MetadataCache()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private var memoryCache: [String: CachedMetadata] = [:]
    private let queue = DispatchQueue(label: "com.linfuse.metadataCache", attributes: .concurrent)
    
    private init() {
        let cachePath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cachePath.appendingPathComponent("MetadataCache", isDirectory: true)
        
        createCacheDirectoryIfNeeded()
    }
    
    // MARK: - Cache Operations
    
    /// 缓存元数据
    func cacheMetadata(_ metadata: CachedMetadata, for filename: String) {
        let key = normalizedKey(for: filename)
        
        // 内存缓存
        queue.async(flags: .barrier) {
            self.memoryCache[key] = metadata
        }
        
        // 磁盘缓存
        let fileURL = cacheFileURL(for: key)
        if let data = try? JSONEncoder().encode(metadata) {
            try? data.write(to: fileURL)
        }
    }
    
    /// 获取缓存的元数据
    func getCachedMetadata(for filename: String) -> CachedMetadata? {
        let key = normalizedKey(for: filename)
        
        // 先检查内存缓存
        var cached: CachedMetadata?
        queue.sync {
            cached = memoryCache[key]
        }
        
        if cached != nil {
            return cached
        }
        
        // 检查磁盘缓存
        let fileURL = cacheFileURL(for: key)
        if let data = try? Data(contentsOf: fileURL),
           let metadata = try? JSONDecoder().decode(CachedMetadata.self, from: data) {
            // 添加到内存缓存
            queue.async(flags: .barrier) {
                self.memoryCache[key] = metadata
            }
            return metadata
        }
        
        return nil
    }
    
    /// 检查是否有缓存
    func hasCachedMetadata(for filename: String) -> Bool {
        let key = normalizedKey(for: filename)
        return getCachedMetadata(for: filename) != nil
    }
    
    /// 清除缓存
    func clearCache() {
        queue.async(flags: .barrier) {
            self.memoryCache.removeAll()
        }
        
        if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) {
            for file in files {
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    /// 清除过期缓存（超过30天）
    func clearExpiredCache() {
        let expirationDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey]) {
            for file in files {
                if let attributes = try? fileManager.attributesOfItem(atPath: file.path),
                   let modificationDate = attributes[.modificationDate] as? Date,
                   modificationDate < expirationDate {
                    try? fileManager.removeItem(at: file)
                }
            }
        }
    }
    
    // MARK: - Statistics
    
    /// 获取缓存统计
    func getStatistics() -> CacheStatistics {
        var memoryCount = 0
        queue.sync {
            memoryCount = memoryCache.count
        }
        
        let files: [URL]
        do {
            files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
        } catch {
            return CacheStatistics(memoryEntries: memoryCount, diskEntries: 0, totalDiskSize: 0)
        }
        
        var totalSize: Int64 = 0
        for file in files {
            if let resourceValues = try? file.resourceValues(forKeys: [.fileSizeKey]),
               let size = resourceValues.fileSize {
                totalSize += Int64(size)
            }
        }
        
        return CacheStatistics(
            memoryEntries: memoryCount,
            diskEntries: files.count,
            totalDiskSize: totalSize
        )
    }
    
    // MARK: - Private
    
    private func normalizedKey(for filename: String) -> String {
        // 移除扩展名和常见的后缀
        var key = filename.lowercased()
        key = key.replacingOccurrences(of: "-", with: " ")
        key = key.replacingOccurrences(of: ".", with: " ")
        key = key.replacingOccurrences(of: "_", with: " ")
        
        // 移除分辨率和质量标记
        key = key.replacingOccurrences(of: "1080p", with: "")
        key = key.replacingOccurrences(of: "720p", with: "")
        key = key.replacingOccurrences(of: "4k", with: "")
        key = key.replacingOccurrences(of: "bluray", with: "")
        key = key.replacingOccurrences(of: "web-dl", with: "")
        
        return key.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func cacheFileURL(for key: String) -> URL {
        // 使用哈希作为文件名
        let hash = key.hashValue
        return cacheDirectory.appendingPathComponent("\(hash).json")
    }
    
    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
}

// MARK: - Cached Metadata

struct CachedMetadata: Codable {
    let filename: String
    let title: String?
    let originalTitle: String?
    let overview: String?
    let releaseDate: String?
    let posterPath: String?
    let backdropPath: String?
    let rating: Double?
    let runtime: Int?
    let genres: [String]?
    let cast: [String]?
    let director: String?
    let cachedAt: Date
    let source: String
    
    init(from movie: Movie, source: String = "tmdb") {
        self.filename = movie.fileURL.deletingPathExtension().lastPathComponent
        self.title = movie.title
        self.originalTitle = movie.originalTitle
        self.overview = movie.overview
        self.releaseDate = movie.releaseDate?.description
        self.posterPath = movie.posterPath
        self.backdropPath = movie.backdropPath
        self.rating = movie.rating > 0 ? movie.rating : nil
        self.runtime = movie.runtime > 0 ? Int(movie.runtime) : nil
        self.genres = movie.genreNames
        self.cast = movie.sortedCast.prefix(5).map { $0.name }
        self.director = movie.sortedCrew.first { $0.job == "Director" }?.name
        self.cachedAt = Date()
        self.source = source
    }
    
    init(filename: String, title: String?, originalTitle: String?, overview: String?, releaseDate: String?, posterPath: String?, backdropPath: String?, rating: Double?, runtime: Int?, genres: [String]?, cast: [String]?, director: String?, source: String) {
        self.filename = filename
        self.title = title
        self.originalTitle = originalTitle
        self.overview = overview
        self.releaseDate = releaseDate
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.rating = rating
        self.runtime = runtime
        self.genres = genres
        self.cast = cast
        self.director = director
        self.cachedAt = Date()
        self.source = source
    }
}

// MARK: - Statistics

struct CacheStatistics {
    let memoryEntries: Int
    let diskEntries: Int
    let totalDiskSize: Int64
    
    var formattedDiskSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalDiskSize)
    }
}
