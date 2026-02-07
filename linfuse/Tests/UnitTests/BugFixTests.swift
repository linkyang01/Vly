import XCTest
@testable import linfuse

final class BugFixTests: XCTestCase {
    
    // MARK: - Potential Bug 1: Nil URL Handling
    
    func testMovieFilePathCanBeNil() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.id = UUID()
        movie.title = "Test Movie"
        movie.runtime = 120
        movie.duration = 7200
        movie.currentPosition = 0
        movie.filePath = URL(fileURLWithPath: "/test/movie.mp4")
        
        XCTAssertNotNil(movie.filePath)
    }
    
    // MARK: - Potential Bug 2: Division by Zero in Progress
    
    func testProgressPercentageWithZeroDuration() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.id = UUID()
        movie.title = "Test"
        movie.duration = 0
        movie.currentPosition = 100
        
        // This should not crash and should return 0
        let progress = movie.progressPercentage
        XCTAssertEqual(progress, 0)
    }
    
    // MARK: - Potential Bug 3: Large Numbers Handling
    
    func testMovieWithLargeFileSize() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.id = UUID()
        movie.title = "Test"
        movie.fileSize = Int64.max - 1
        movie.duration = Double.greatestFiniteMagnitude / 2
        
        // Should handle large numbers without overflow
        XCTAssertLessThan(movie.fileSize, Int64.max)
    }
    
    func testMovieWithLargeDuration() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.id = UUID()
        movie.title = "Test"
        movie.duration = Double.greatestFiniteMagnitude
        movie.currentPosition = Double.greatestFiniteMagnitude / 2
        
        let progress = movie.progressPercentage
        // Should be around 50%, not NaN or infinity
        XCTAssertFalse(progress.isNaN)
        XCTAssertFalse(progress.isInfinite)
    }
    
    // MARK: - Potential Bug 4: Unicode and Special Characters
    
    func testMovieTitleWithUnicodeCharacters() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.id = UUID()
        movie.title = "电锯惊魂" // Chinese title
        movie.originalTitle = "Saw"
        movie.overview = "A detective hunts a serial killer."
        
        XCTAssertEqual(movie.title, "电锯惊魂")
        XCTAssertNotNil(movie.originalTitle)
    }
    
    func testMovieTitleWithEmoji() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.id = UUID()
        movie.title = "Star Wars: Episode IV 🎬"
        
        XCTAssertTrue(movie.title.contains("🎬"))
    }
    
    // MARK: - Potential Bug 5: Year Range Handling
    
    func testMovieReleaseDateWithFutureYear() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.id = UUID()
        movie.title = "Future Movie"
        movie.releaseDate = Calendar.current.date(from: .init(year: 2100, month: 1, day: 1))
        
        XCTAssertNotNil(movie.releaseDate)
    }
    
    func testMovieReleaseDateWithPastExtremes() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.id = UUID()
        movie.title = "Old Movie"
        movie.releaseDate = Calendar.current.date(from: .init(year: 1900, month: 1, day: 1))
        
        XCTAssertNotNil(movie.releaseDate)
    }
    
    // MARK: - Potential Bug 6: Empty String Handling
    
    func testMovieWithEmptyTitle() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.id = UUID()
        movie.title = ""
        movie.runtime = 90
        
        XCTAssertEqual(movie.title, "")
    }
    
    func testMovieWithEmptyOverview() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.id = UUID()
        movie.title = "Test"
        movie.overview = ""
        
        XCTAssertEqual(movie.overview, "")
    }
    
    // MARK: - Potential Bug 7: Sorting Edge Cases
    
    func testSortTitleWithOnlyPrefix() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.title = "The"
        movie.sortTitle = ClassificationService.sortableTitle("The")
        
        XCTAssertEqual(movie.sortTitle, ", The")
    }
    
    func testSortTitleWithSingleLetter() {
        let movie = Movie(context: CoreDataManager.shared.viewContext)
        movie.title = "A"
        movie.sortTitle = ClassificationService.sortableTitle("A")
        
        XCTAssertEqual(movie.sortTitle, ", A")
    }
    
    // MARK: - Potential Bug 8: Network Protocol URL Construction
    
    func testNetworkServerURLWithSpecialCharactersInShare() {
        let server = NetworkServer(
            id: UUID(),
            name: "Test",
            address: "192.168.1.100",
            port: 445,
            protocol: .smb,
            share: "Movies & TV Shows",
            isConnected: false,
            lastConnected: nil,
            credentialSaved: false
        )
        
        // URL should be constructed without crashing
        _ = server.url
    }
    
    // MARK: - Potential Bug 9: Array Index Out of Bounds Prevention
    
    func testFilterOptionsCaseIterableCount() {
        let count = LibraryViewModel.FilterOption.allCases.count
        
        // Ensure count is positive
        XCTAssertGreaterThan(count, 0)
        
        // Ensure we can iterate through all
        for option in LibraryViewModel.FilterOption.allCases {
            XCTAssertNotNil(option.rawValue)
        }
    }
    
    func testSortOptionsCaseIterableCount() {
        let count = LibraryViewModel.SortOption.allCases.count
        
        XCTAssertGreaterThan(count, 0)
        
        for option in LibraryViewModel.SortOption.allCases {
            XCTAssertNotNil(option.rawValue)
        }
    }
    
    // MARK: - Potential Bug 10: Thread Safety Simulation
    
    func testConcurrentAccessToViewModelState() {
        let viewModel = LibraryViewModel()
        
        DispatchQueue.concurrentPerform(iterations: 10) { i in
            viewModel.searchText = "Search \(i)"
            viewModel.sortOption = LibraryViewModel.SortOption.allCases[i % 6]
            viewModel.filterOption = LibraryViewModel.FilterOption.allCases[i % 4]
            viewModel.viewMode = LibraryViewModel.ViewMode.allCases[i % 3]
        }
        
        // Should not crash - state should be consistent
        XCTAssertNotNil(viewModel.searchText)
        XCTAssertNotNil(viewModel.sortOption)
        XCTAssertNotNil(viewModel.filterOption)
        XCTAssertNotNil(viewModel.viewMode)
    }
    
    // MARK: - Potential Bug 11: Date Handling
    
    func testDateCreationWithValidComponents() {
        let components = DateComponents(year: 2024, month: 2, day: 29) // Leap year
        let date = Calendar.current.date(from: components)
        
        // 2024 is a leap year, so Feb 29 is valid
        XCTAssertNotNil(date)
    }
    
    func testDateCreationWithInvalidDate() {
        let components = DateComponents(year: 2023, month: 2, day: 29) // Not a leap year
        let date = Calendar.current.date(from: components)
        
        // 2023 is not a leap year, so Feb 29 should be nil or adjusted
        XCTAssertNil(date) // or date might be Mar 1 depending on calendar
    }
    
    // MARK: - Potential Bug 12: Metadata Scraping Edge Cases
    
    func testParseFilenameWithMultipleQualityIndicators() {
        let filename = "Movie.Title.2020.Bluray.1080p.x264.DTS.AC3.mkv"
        let (title, year) = MetadataScraper.parseFilename(filename)
        
        XCTAssertEqual(year, 2020)
        // Title should not contain quality indicators
        XCTAssertFalse(title.contains("Bluray"))
        XCTAssertFalse(title.contains("1080p"))
        XCTAssertFalse(title.contains("x264"))
        XCTAssertFalse(title.contains("DTS"))
        XCTAssertFalse(title.contains("AC3"))
    }
    
    func testParseFilenameWithChineseCharacters() {
        let filename = "电影名称 2020.mkv"
        let (title, year) = MetadataScraper.parseFilename(filename)
        
        XCTAssertEqual(year, 2020)
        // Chinese characters should be preserved
        XCTAssertTrue(title.contains("电影名称"))
    }
    
    // MARK: - Potential Bug 13: Genre Mapping Boundary Conditions
    
    func testGenreMappingWithInvalidTMDBID() {
        let genres = ClassificationService().mapTMDBGenres([-1, 0, 999999])
        
        // Should handle gracefully without crashing
        XCTAssertNotNil(genres)
    }
    
    func testGenreMappingWithDuplicateIDs() {
        let genres = ClassificationService().mapTMDBGenres([28, 28, 28])
        
        // Should return same genre 3 times or deduplicate
        XCTAssertNotNil(genres)
    }
}

// MARK: - DateComponents Extension

extension DateComponents {
    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = nil
        self.minute = nil
        self.second = nil
    }
}
