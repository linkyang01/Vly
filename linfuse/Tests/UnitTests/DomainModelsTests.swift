import XCTest
@testable import linfuse

final class DomainModelsTests: XCTestCase {
    
    // MARK: - MovieDomain Tests
    
    func testMovieDomainFormattedRuntime() {
        let movie = createTestDomainMovie(runtime: 145) // 2h 25m
        
        XCTAssertEqual(movie.formattedRuntime, "2h 25m")
    }
    
    func testMovieDomainFormattedRuntimeMinutesOnly() {
        let movie = createTestDomainMovie(runtime: 45)
        
        XCTAssertEqual(movie.formattedRuntime, "45m")
    }
    
    func testMovieDomainProgressPercentage() {
        let movie = createTestDomainMovie(duration: 5400, currentPosition: 2700)
        
        XCTAssertEqual(movie.progressPercentage, 50.0, accuracy: 0.01)
    }
    
    func testMovieDomainProgressPercentageZeroDuration() {
        let movie = createTestDomainMovie(duration: 0)
        
        XCTAssertEqual(movie.progressPercentage, 0)
    }
    
    // MARK: - GenreDomain Tests
    
    func testGenreDomainCreation() {
        let genre = GenreDomain(
            id: UUID(),
            name: "Sci-Fi",
            tmdbId: 878
        )
        
        XCTAssertEqual(genre.name, "Sci-Fi")
        XCTAssertEqual(genre.tmdbId, 878)
    }
    
    func testGenreDomainHashable() {
        let id = UUID()
        let genre1 = GenreDomain(id: id, name: "Action", tmdbId: 28)
        let genre2 = GenreDomain(id: id, name: "Action", tmdbId: 28)
        
        XCTAssertEqual(genre1.hashValue, genre2.hashValue)
    }
    
    // MARK: - PersonDomain Tests
    
    func testPersonDomainCreation() {
        let person = PersonDomain(
            id: UUID(),
            name: "Christopher Nolan",
            tmdbId: 525,
            biography: "British-American film director",
            profilePath: "/profile.jpg",
            birthDate: Calendar.current.date(from: .init(year: 1970, month: 7, day: 30)),
            deathDate: nil
        )
        
        XCTAssertEqual(person.name, "Christopher Nolan")
        XCTAssertNil(person.deathDate)
    }
    
    // MARK: - CastMemberDomain Tests
    
    func testCastMemberDomainCreation() {
        let person = PersonDomain(
            id: UUID(),
            name: "Tom Hardy",
            tmdbId: 10859,
            biography: nil,
            profilePath: nil,
            birthDate: nil,
            deathDate: nil
        )
        
        let cast = CastMemberDomain(
            id: UUID(),
            character: "Max Rockatansky",
            order: 0,
            person: person
        )
        
        XCTAssertEqual(cast.character, "Max Rockatansky")
        XCTAssertEqual(cast.order, 0)
    }
    
    // MARK: - CrewMemberDomain Tests
    
    func testCrewMemberDomainCreation() {
        let person = PersonDomain(
            id: UUID(),
            name: "Steven Spielberg",
            tmdbId: 488,
            biography: nil,
            profilePath: nil,
            birthDate: nil,
            deathDate: nil
        )
        
        let crew = CrewMemberDomain(
            id: UUID(),
            job: "Director",
            department: "Directing",
            order: 0,
            person: person
        )
        
        XCTAssertEqual(crew.job, "Director")
        XCTAssertEqual(crew.department, "Directing")
    }
    
    // MARK: - LibraryFolder Tests
    
    func testLibraryFolderCreation() {
        let folder = LibraryFolder(
            id: UUID(),
            path: URL(fileURLWithPath: "/Users/test/Movies"),
            name: "My Movies",
            addedDate: Date(),
            isMonitoringEnabled: true,
            lastScanDate: nil,
            videoCount: 150
        )
        
        XCTAssertEqual(folder.name, "My Movies")
        XCTAssertEqual(folder.videoCount, 150)
        XCTAssertTrue(folder.isMonitoringEnabled)
    }
    
    func testLibraryFolderHashable() {
        let id = UUID()
        let path = URL(fileURLWithPath: "/test")
        
        let folder1 = LibraryFolder(
            id: id,
            path: path,
            name: "Test",
            addedDate: Date(),
            isMonitoringEnabled: true,
            lastScanDate: nil,
            videoCount: 10
        )
        
        let folder2 = LibraryFolder(
            id: id,
            path: path,
            name: "Test",
            addedDate: Date(),
            isMonitoringEnabled: true,
            lastScanDate: nil,
            videoCount: 10
        )
        
        XCTAssertEqual(folder1.hashValue, folder2.hashValue)
    }
    
    // MARK: - Helpers
    
    private func createTestDomainMovie(
        title: String = "Test Movie",
        runtime: Int = 120,
        duration: Double = 7200,
        currentPosition: Double = 0
    ) -> MovieDomain {
        MovieDomain(
            id: UUID(),
            title: title,
            originalTitle: nil,
            overview: nil,
            releaseDate: nil,
            runtime: runtime,
            rating: 0,
            posterPath: nil,
            backdropPath: nil,
            filePath: URL(fileURLWithPath: "/test/movie.mp4"),
            fileSize: 0,
            duration: duration,
            currentPosition: currentPosition,
            isWatched: false,
            watchCount: 0,
            addedDate: Date(),
            metadataFetched: false,
            genres: [],
            cast: [],
            crew: []
        )
    }
}
