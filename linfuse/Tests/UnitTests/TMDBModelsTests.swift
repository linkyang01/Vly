import XCTest
@testable import linfuse

final class TMDBModelsTests: XCTestCase {
    // MARK: - TMDBMovieDTO Tests
    
    func testMovieDTODecoding() throws {
        let json = """
        {
            "id": 550,
            "title": "Fight Club",
            "original_title": "Fight Club",
            "overview": "A depressed man suffering from insomnia meets a strange soap salesman.",
            "release_date": "1999-10-15",
            "runtime": 139,
            "vote_average": 8.4,
            "poster_path": "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
            "backdrop_path": "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let movie = try decoder.decode(TMDBMovieDTO.self, from: json)
        
        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.title, "Fight Club")
        XCTAssertEqual(movie.overview, "A depressed man suffering from insomnia meets a strange soap salesman.")
        XCTAssertEqual(movie.releaseDate, "1999-10-15")
        XCTAssertEqual(movie.runtime, 139)
        XCTAssertEqual(movie.voteAverage, 8.4)
        XCTAssertEqual(movie.posterPath, "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg")
    }
    
    // MARK: - TMDBMovieResponse Tests
    
    func testMovieResponseDecoding() throws {
        let json = """
        {
            "page": 1,
            "results": [
                {
                    "id": 550,
                    "title": "Fight Club",
                    "original_title": "Fight Club",
                    "overview": "A depressed man suffering from insomnia meets a strange soap salesman.",
                    "release_date": "1999-10-15",
                    "vote_average": 8.4
                }
            ],
            "total_pages": 10,
            "total_results": 200
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let response = try decoder.decode(TMDBMovieResponse.self, from: json)
        
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.totalPages, 10)
        XCTAssertEqual(response.totalResults, 200)
    }
    
    // MARK: - TMDBCreditsDTO Tests
    
    func testCreditsDTODecoding() throws {
        let json = """
        {
            "cast": [
                {
                    "id": 819,
                    "name": "Edward Norton",
                    "character": "The Narrator",
                    "order": 0
                },
                {
                    "id": 287,
                    "name": "Brad Pitt",
                    "character": "Tyler Durden",
                    "order": 1
                }
            ],
            "crew": [
                {
                    "id": 525,
                    "name": "David Fincher",
                    "job": "Director",
                    "department": "Directing"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let credits = try decoder.decode(TMDBCreditsDTO.self, from: json)
        
        XCTAssertEqual(credits.cast?.count, 2)
        XCTAssertEqual(credits.crew?.count, 1)
        
        XCTAssertEqual(credits.cast?[0].name, "Edward Norton")
        XCTAssertEqual(credits.cast?[0].character, "The Narrator")
        XCTAssertEqual(credits.cast?[0].order, 0)
        
        XCTAssertEqual(credits.crew?[0].name, "David Fincher")
        XCTAssertEqual(credits.crew?[0].job, "Director")
    }
}
