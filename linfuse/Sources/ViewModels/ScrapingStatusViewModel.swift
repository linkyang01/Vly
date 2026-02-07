import Foundation
import CoreData
import Combine

/// 刮削状态视图模型
@MainActor
final class ScrapingStatusViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var unscrapedMovies: [Movie] = []
    @Published var scrapingMovies: [Movie] = []
    @Published var scrapedMovies: [Movie] = []
    @Published var failedMovies: [Movie] = []
    
    @Published var isScraping = false
    @Published var progress: Double = 0
    @Published var currentItemTitle: String = ""
    @Published var errorMessage: String?
    
    @Published var autoScrapeEnabled = false
    @Published var preferLocalMetadata = true
    @Published var scrapeMissingThumbnails = true
    
    // MARK: - Dependencies
    
    private let batchScraper = BatchScraper.shared
    private var cancellables = Set<AnyCancellable>()
    private var scrapeTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    
    var totalUnscraped: Int {
        unscrapedMovies.count
    }
    
    var totalScraped: Int {
        scrapedMovies.count
    }
    
    var successRate: Double {
        let total = scrapedMovies.count + failedMovies.count
        guard total > 0 else { return 0 }
        return Double(scrapedMovies.count) / Double(total) * 100
    }
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        BatchScraper.shared.progressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.handleProgress(progress)
            }
            .store(in: &cancellables)
    }
    
    private func handleProgress(_ progress: BatchScraper.ScrapingProgress) {
        self.progress = Double(progress.current) / Double(progress.total) * 100
        self.currentItemTitle = progress.currentTitle
        self.errorMessage = progress.error
        
        if progress.status == .scraping {
            isScraping = true
        } else if progress.status == .completed {
            isScraping = progress.current < progress.total
        }
    }
    
    // MARK: - Public Methods
    
    /// 加载未刮削的电影
    func loadUnscrapedMovies() {
        let context = CoreDataManager.shared.viewContext
        
        context.perform { [weak self] in
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.predicate = NSPredicate(format: "metadataFetched == NO")
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Movie.title, ascending: true)
            ]
            
            do {
                let movies = try context.fetch(request)
                Task { @MainActor in
                    self?.unscrapedMovies = movies
                }
            } catch {
                print("Failed to fetch unscraped movies: \(error)")
            }
        }
    }
    
    /// 开始刮削所有未刮削的电影
    func startScrapingAll() {
        guard !unscrapedMovies.isEmpty else { return }
        
        scrapeTask?.cancel()
        
        scrapeTask = Task {
            await batchScraper.startBatchScrape(movies: unscrapedMovies)
            loadUnscrapedMovies()
            loadScrapedMovies()
        }
    }
    
    /// 刮削选中的电影
    func scrapeSelected(_ movies: [Movie]) {
        scrapeTask?.cancel()
        
        scrapeTask = Task {
            await batchScraper.startBatchScrape(movies: movies)
            loadUnscrapedMovies()
            loadScrapedMovies()
        }
    }
    
    /// 重新刮削失败的电影
    func retryFailed() {
        scrapeSelected(failedMovies)
    }
    
    /// 取消刮削
    func cancelScraping() {
        scrapeTask?.cancel()
        Task {
            await batchScraper.cancelAllTasks()
            isScraping = false
        }
    }
    
    /// 跳过单个电影
    func skipMovie(_ movie: Movie) {
        Task {
            await MainActor.run {
                if let index = unscrapedMovies.firstIndex(where: { $0.objectID == movie.objectID }) {
                    unscrapedMovies.remove(at: index)
                    scrapedMovies.append(movie)
                }
            }
        }
    }
    
    /// 加载已刮削的电影
    func loadScrapedMovies() {
        let context = CoreDataManager.shared.viewContext
        
        context.perform { [weak self] in
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.predicate = NSPredicate(format: "metadataFetched == YES")
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Movie.title, ascending: true)
            ]
            
            do {
                let movies = try context.fetch(request)
                Task { @MainActor in
                    self?.scrapedMovies = movies
                }
            } catch {
                print("Failed to fetch scraped movies: \(error)")
            }
        }
    }
    
    /// 清除所有刮削数据
    func clearAllScrapedData() {
        let context = CoreDataManager.shared.viewContext
        
        context.perform { [weak self] in
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            
            do {
                let movies = try context.fetch(request)
                for movie in movies {
                    movie.metadataFetched = false
                    movie.title = nil
                    movie.overview = nil
                    movie.posterPath = nil
                    movie.backdropPath = nil
                    movie.rating = 0
                    movie.releaseDate = nil
                    movie.runtime = nil
                    movie.genres = nil
                }
                try context.save()
                
                Task { @MainActor in
                    self?.loadUnscrapedMovies()
                    self?.loadScrapedMovies()
                }
            } catch {
                print("Failed to clear scraped data: \(error)")
            }
        }
    }
}
