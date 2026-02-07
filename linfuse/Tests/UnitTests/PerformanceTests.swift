import XCTest
@testable import linfuse

final class PerformanceTests: XCTestCase {
    
    // MARK: - Memory Usage Tests
    
    func testMemoryFootprintOfMovieObject() {
        measure(metrics: [XCTMemoryMetric()]) {
            var movies: [Movie] = []
            
            for i in 0..<100 {
                let movie = Movie(context: CoreDataManager.shared.viewContext)
                movie.id = UUID()
                movie.title = "Test Movie \(i)"
                movie.runtime = 120
                movie.duration = 7200
                movies.append(movie)
            }
            
            XCTAssertEqual(movies.count, 100)
        }
    }
    
    // MARK: - Array Operations Performance Tests
    
    func testFilteringLargeMovieArray() {
        var movies: [Movie] = []
        
        for i in 0..<1000 {
            let movie = Movie(context: CoreDataManager.shared.viewContext)
            movie.id = UUID()
            movie.title = "Movie \(i)"
            movie.rating = Double.random(in: 0...10)
            movie.isWatched = i % 2 == 0
            movie.runtime = Int32.random(in: 60...240)
            movies.append(movie)
        }
        
        measure {
            let watched = movies.filter { $0.isWatched }
            let highRated = movies.filter { $0.rating >= 8.0 }
            let longMovies = movies.filter { $0.runtime > 180 }
            
            _ = watched.count + highRated.count + longMovies.count
        }
    }
    
    func testSortingLargeMovieArray() {
        var movies: [Movie] = []
        
        for i in 0..<1000 {
            let movie = Movie(context: CoreDataManager.shared.viewContext)
            movie.id = UUID()
            movie.title = "Movie \(i)"
            movie.rating = Double.random(in: 0...10)
            movie.addedDate = Date().addingTimeInterval(TimeInterval(-i * 3600))
            movie.releaseDate = Date().addingTimeInterval(TimeInterval(-i * 86400 * 365))
            movies.append(movie)
        }
        
        measure {
            let sortedByRating = movies.sorted { $0.rating > $1.rating }
            let sortedByDate = movies.sorted { $0.addedDate > $1.addedDate }
            let sortedByTitle = movies.sorted { $0.title < $1.title }
            
            _ = sortedByRating.first?.rating
            _ = sortedByDate.first?.addedDate
            _ = sortedByTitle.first?.title
        }
    }
    
    // MARK: - Search Performance Tests
    
    func testSearchPerformanceOnLargeArray() {
        var movies: [Movie] = []
        
        for i in 0..<500 {
            let titles = ["The Matrix", "Pulp Fiction", "Inception", "Interstellar", "The Dark Knight"]
            let movie = Movie(context: CoreDataManager.shared.viewContext)
            movie.id = UUID()
            movie.title = "\(titles[i % titles.count]) \(i)"
            movie.overview = "This is a test movie overview for \(titles[i % titles.count])"
            movies.append(movie)
        }
        
        measure {
            let searchTerm = "Matrix"
            let results = movies.filter {
                $0.title.localizedCaseInsensitiveContains(searchTerm) ||
                ($0.overview?.localizedCaseInsensitiveContains(searchTerm) ?? false)
            }
            
            XCTAssertFalse(results.isEmpty)
        }
    }
    
    // MARK: - Computed Properties Performance Tests
    
    func testFormattedRuntimePerformance() {
        var movies: [Movie] = []
        
        for i in 0..<100 {
            let movie = Movie(context: CoreDataManager.shared.viewContext)
            movie.id = UUID()
            movie.title = "Test"
            movie.runtime = Int32(i * 30 + 60)
            movies.append(movie)
        }
        
        measure {
            for movie in movies {
                _ = movie.formattedRuntime
            }
        }
    }
    
    func testProgressPercentagePerformance() {
        var movies: [Movie] = []
        
        for i in 0..<100 {
            let movie = Movie(context: CoreDataManager.shared.viewContext)
            movie.id = UUID()
            movie.title = "Test"
            movie.duration = 7200
            movie.currentPosition = Double(i * 72)
            movies.append(movie)
        }
        
        measure {
            for movie in movies {
                _ = movie.progressPercentage
            }
        }
    }
    
    // MARK: - String Operations Performance Tests
    
    func testSortableTitlePerformance() {
        let titles = [
            "The Matrix",
            "A Beautiful Mind",
            "An American Werewolf in London",
            "The Dark Knight",
            "Pulp Fiction",
            "Inception",
            "Interstellar",
            "The Shawshank Redemption",
            "Forrest Gump",
            "Fight Club"
        ]
        
        measure {
            for _ in 0..<100 {
                for title in titles {
                    _ = ClassificationService.sortableTitle(title)
                }
            }
        }
    }
    
    func testFilenameParsingPerformance() {
        let filenames = [
            "The Matrix (1999).Bluray.1080p.x264.mkv",
            "Pulp.Fiction.1994.720p.mkv",
            "Inception.2010.1080p.mkv",
            "The.Dark.Knight.2008.2160p.mkv",
            "Interstellar.2014.4K.mkv"
        ]
        
        measure {
            for _ in 0..<50 {
                for filename in filenames {
                    _ = MetadataScraper.parseFilename(filename)
                }
            }
        }
    }
    
    // MARK: - Network Model Performance Tests
    
    func testNetworkItemVideoDetectionPerformance() {
        let items = (0..<500).map { i in
            NetworkItem(
                id: UUID(),
                name: "movie\(i).mp4",
                path: "/share/movies/movie\(i).mp4",
                isDirectory: false,
                size: 2_000_000_000,
                modifiedDate: Date(),
                protocol: .smb,
                serverID: UUID()
            )
        }
        
        measure {
            for item in items {
                _ = item.isVideo
            }
        }
    }
    
    func testFormattedSizePerformance() {
        let items = (0..<100).map { i in
            NetworkItem(
                id: UUID(),
                name: "movie\(i).mkv",
                path: "/share/movies/movie\(i).mkv",
                isDirectory: false,
                size: Int64(pow(1024.0, Double(i % 5))) * 1000,
                modifiedDate: Date(),
                protocol: .smb,
                serverID: UUID()
            )
        }
        
        measure {
            for item in items {
                _ = item.formattedSize
            }
        }
    }
}
