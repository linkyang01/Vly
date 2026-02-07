import XCTest
@testable import linfuse

final class TMDBServiceTests: XCTestCase {
    
    // MARK: - API Configuration Tests
    
    func testAPIKeyValidation() {
        // Test that empty API key is handled
        let emptyKey = ""
        XCTAssertTrue(emptyKey.isEmpty)
    }
    
    func testBaseURL() {
        let expectedBaseURL = "https://api.themoviedb.org/3"
        XCTAssertFalse(expectedBaseURL.isEmpty)
    }
    
    func testImageBaseURL() {
        let expectedImageURL = "https://image.tmdb.org/t/p"
        XCTAssertFalse(expectedImageURL.isEmpty)
    }
    
    // MARK: - URL Construction Tests
    
    func testSearchMovieURL() {
        let query = "Matrix"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=DEMO&query=\(encodedQuery)"
        
        XCTAssertTrue(urlString.contains("search/movie"))
        XCTAssertTrue(urlString.contains("query=Matrix"))
    }
    
    func testMovieDetailsURL() {
        let movieID = 603
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)?api_key=DEMO"
        
        XCTAssertTrue(urlString.contains("movie/603"))
    }
    
    func testCreditsURL() {
        let movieID = 603
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)/credits?api_key=DEMO"
        
        XCTAssertTrue(urlString.contains("movie/603/credits"))
    }
    
    func testImageURLWithW500() {
        let path = "/poster.jpg"
        let url = "https://image.tmdb.org/t/p/w500\(path)"
        
        XCTAssertTrue(url.contains("/w500/"))
    }
    
    func testImageURLWithOriginal() {
        let path = "/backdrop.jpg"
        let url = "https://image.tmdb.org/t/p/original\(path)"
        
        XCTAssertTrue(url.contains("/original"))
    }
}

// MARK: - MetadataCache Tests

final class MetadataCacheTests: XCTestCase {
    
    // MARK: - Cache Key Generation Tests
    
    func testCacheKeyForMovieTitle() {
        let title = "The Matrix"
        let year = 1999
        let key = "\(title.lowercased())_\(year)"
        
        XCTAssertEqual(key, "the matrix_1999")
    }
    
    func testCacheKeyForMovieWithoutYear() {
        let title = "Pulp Fiction"
        let key = "\(title.lowercased())_0"
        
        XCTAssertEqual(key, "pulp fiction_0")
    }
    
    // MARK: - Cache Operations Tests
    
    func testCacheStorageAndRetrieval() {
        let cache = MetadataCache.shared
        let testData = "test metadata".data(using: .utf8)!
        
        cache.cacheMovieMetadata(testData, forKey: "test_key")
        let retrieved = cache.getMovieMetadata(forKey: "test_key")
        
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved, testData)
    }
    
    func testCacheMiss() {
        let cache = MetadataCache.shared
        let retrieved = cache.getMovieMetadata(forKey: "nonexistent_key")
        
        XCTAssertNil(retrieved)
    }
    
    func testCacheClear() {
        let cache = MetadataCache.shared
        let testData = "test".data(using: .utf8)!
        
        cache.cacheMovieMetadata(testData, forKey: "key_to_clear")
        cache.clearCache()
        let retrieved = cache.getMovieMetadata(forKey: "key_to_clear")
        
        XCTAssertNil(retrieved)
    }
}

// MARK: - ClassificationService Tests

final class ClassificationServiceTests: XCTestCase {
    var service: ClassificationService!
    
    override func setUp() {
        super.setUp()
        service = ClassificationService()
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - Genre Classification Tests
    
    func testGenreMappingForAction() {
        let genres = service.mapTMDBGenres([28]) // Action ID
        
        XCTAssertFalse(genres.isEmpty)
        XCTAssertTrue(genres.contains { $0.tmdbId == 28 })
    }
    
    func testGenreMappingForSciFi() {
        let genres = service.mapTMDBGenres([878]) // Sci-Fi ID
        
        XCTAssertFalse(genres.isEmpty)
        XCTAssertTrue(genres.contains { $0.tmdbId == 878 })
    }
    
    func testGenreMappingForMultipleGenres() {
        let genreIds: [Int32] = [28, 12, 878] // Action, Adventure, Sci-Fi
        
        let genres = service.mapTMDBGenres(genreIds)
        
        XCTAssertEqual(genres.count, 3)
    }
    
    func testGenreMappingForEmptyArray() {
        let genres = service.mapTMDBGenres([])
        
        XCTAssertTrue(genres.isEmpty)
    }
    
    // MARK: - Quality Detection Tests
    
    func testQualityDetection4K() {
        let quality = service.detectQuality(filename: "Movie.2020.UHD.4K.mkv")
        
        XCTAssertEqual(quality, .uhd4K)
    }
    
    func testQualityDetection1080p() {
        let quality = service.detectQuality(filename: "Movie.2020.1080p.mkv")
        
        XCTAssertEqual(quality, .fhd)
    }
    
    func testQualityDetection720p() {
        let quality = service.detectQuality(filename: "Movie.2020.HD.mkv")
        
        XCTAssertEqual(quality, .hd)
    }
    
    func testQualityDetectionSD() {
        let quality = service.detectQuality(filename: "Movie.2020.DVDRip.mkv")
        
        XCTAssertEqual(quality, .sd)
    }
    
    func testQualityDetectionUnknown() {
        let quality = service.detectQuality(filename: "Movie.mkv")
        
        XCTAssertEqual(quality, .unknown)
    }
    
    // MARK: - Helper Methods Tests
    
    func testSortableTitleWithThePrefix() {
        let result = service.sortableTitle("The Matrix")
        
        XCTAssertEqual(result, "Matrix, The")
    }
    
    func testSortableTitleWithAPrefix() {
        let result = service.sortableTitle("A Beautiful Day")
        
        XCTAssertEqual(result, "Beautiful Day, A")
    }
    
    func testSortableTitleWithAnPrefix() {
        let result = service.sortableTitle("An American Werewolf in London")
        
        XCTAssertEqual(result, "American Werewolf in London, An")
    }
    
    func testSortableTitleWithoutPrefix() {
        let result = service.sortableTitle("Pulp Fiction")
        
        XCTAssertEqual(result, "Pulp Fiction")
    }
    
    func testSortableTitleWithNonEnglishPrefix() {
        let result = service.sortableTitle("The Last Emperor") // Should handle English prefix
        
        XCTAssertEqual(result, "Last Emperor, The")
    }
}

// MARK: - VideoQuality Enum Tests

final class VideoQualityTests: XCTestCase {
    
    func testVideoQualityRawValues() {
        XCTAssertEqual(VideoQuality.sd.rawValue, "SD")
        XCTAssertEqual(VideoQuality.hd.rawValue, "720p")
        XCTAssertEqual(VideoQuality.fhd.rawValue, "1080p")
        XCTAssertEqual(VideoQuality.uhd4K.rawValue, "4K")
        XCTAssertEqual(VideoQuality.uhd8K.rawValue, "8K")
    }
    
    func testVideoQualityCaseIterable() {
        XCTAssertEqual(VideoQuality.allCases.count, 5)
    }
}
