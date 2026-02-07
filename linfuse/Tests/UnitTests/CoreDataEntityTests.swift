import XCTest
@testable import linfuse

final class MovieEntityTests: XCTestCase {
    
    // MARK: - Movie Computed Properties Tests
    
    func testFormattedRuntimeHoursAndMinutes() {
        let movie = createTestMovie(runtime: 135) // 2h 15m
        
        XCTAssertEqual(movie.formattedRuntime, "2h 15m")
    }
    
    func testFormattedRuntimeMinutesOnly() {
        let movie = createTestMovie(runtime: 45)
        
        XCTAssertEqual(movie.formattedRuntime, "45m")
    }
    
    func testFormattedRuntimeZero() {
        let movie = createTestMovie(runtime: 0)
        
        XCTAssertEqual(movie.formattedRuntime, "0m")
    }
    
    func testProgressPercentageCalculatesCorrectly() {
        let movie = createTestMovie(duration: 7200, currentPosition: 3600) // 50%
        
        XCTAssertEqual(movie.progressPercentage, 50.0, accuracy: 0.01)
    }
    
    func testProgressPercentageZeroDuration() {
        let movie = createTestMovie(duration: 0, currentPosition: 100)
        
        XCTAssertEqual(movie.progressPercentage, 0)
    }
    
    func testProgressPercentageFullWatched() {
        let movie = createTestMovie(duration: 7200, currentPosition: 7200)
        
        XCTAssertEqual(movie.progressPercentage, 100.0, accuracy: 0.01)
    }
    
    func testDisplayTitleUsesSortTitleWhenAvailable() {
        let movie = createTestMovie(title: "The Matrix", sortTitle: "Matrix, The")
        
        XCTAssertEqual(movie.displayTitle, "Matrix, The")
    }
    
    func testDisplayTitleFallsBackToTitle() {
        let movie = createTestMovie(title: "Pulp Fiction", sortTitle: nil)
        
        XCTAssertEqual(movie.displayTitle, "Pulp Fiction")
    }
    
    // MARK: - Movie Creation Tests
    
    func testMovieCreationWithAllFields() {
        let movie = Movie(
            context: CoreDataManager.shared.viewContext
        )
        movie.id = UUID()
        movie.title = "Test Movie"
        movie.originalTitle = "Test Movie Original"
        movie.overview = "A test movie overview"
        movie.releaseDate = Date()
        movie.runtime = 120
        movie.rating = 8.5
        movie.posterPath = "/poster.jpg"
        movie.backdropPath = "/backdrop.jpg"
        movie.filePath = URL(fileURLWithPath: "/test/movie.mp4")
        movie.fileSize = 2_000_000_000
        movie.duration = 7200
        movie.currentPosition = 0
        movie.isWatched = false
        movie.watchCount = 0
        movie.addedDate = Date()
        movie.metadataFetched = false
        
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertEqual(movie.runtime, 120)
        XCTAssertEqual(movie.rating, 8.5)
    }
    
    // MARK: - Helper
    
    private func createTestMovie(
        title: String = "Test Movie",
        sortTitle: String? = nil,
        runtime: Int32 = 120,
        duration: Double = 7200,
        currentPosition: Double = 0
    ) -> Movie {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.id = UUID()
        movie.title = title
        movie.sortTitle = sortTitle
        movie.runtime = runtime
        movie.duration = duration
        movie.currentPosition = currentPosition
        return movie
    }
}

// MARK: - Genre Tests

final class GenreEntityTests: XCTestCase {
    
    func testGenreCreation() {
        let genre = Genre(context: CoreDataManager.shared.viewContext)
        genre.id = UUID()
        genre.name = "Action"
        genre.tmdbId = 28
        
        XCTAssertEqual(genre.name, "Action")
        XCTAssertEqual(genre.tmdbId, 28)
    }
}

// MARK: - WatchHistoryEntry Tests

final class WatchHistoryEntryTests: XCTestCase {
    
    func testWatchHistoryEntryCreation() {
        let entry = WatchHistoryEntry(context: CoreDataManager.shared.viewContext)
        entry.id = UUID()
        entry.watchDate = Date()
        entry.position = 3600
        entry.duration = 7200
        entry.completed = false
        
        XCTAssertEqual(entry.position, 3600)
        XCTAssertEqual(entry.duration, 7200)
        XCTAssertFalse(entry.completed)
    }
    
    func testWatchHistoryEntryCompletion() {
        let entry = WatchHistoryEntry(context: CoreDataManager.shared.viewContext)
        entry.position = 7200
        entry.duration = 7200
        entry.completed = true
        
        XCTAssertTrue(entry.completed)
    }
}
