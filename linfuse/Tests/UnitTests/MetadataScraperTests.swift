import XCTest
@testable import linfuse

final class MetadataScraperTests: XCTestCase {
    // MARK: - Filename Parsing Tests
    
    func testParseFilenameWithYear() {
        let (title, year) = parseFilename("The Matrix (1999).mp4")
        XCTAssertEqual(title, "The Matrix ")
        XCTAssertEqual(year, 1999)
    }
    
    func testParseFilenameWithYearAndQuality() {
        let (title, year) = parseFilename("Inception.2010.1080p.mkv")
        XCTAssertEqual(title, "Inception ")
        XCTAssertEqual(year, 2010)
    }
    
    func testParseFilenameWithoutYear() {
        let (title, year) = parseFilename("Pulp.Fiction.mkv")
        XCTAssertEqual(title, "Pulp Fiction")
        XCTAssertNil(year)
    }
    
    func testParseFilenameRemovesQualityIndicators() {
        let (title, _) = parseFilename("Movie.Name.2020.Bluray.1080p.x264.DTS.mkv")
        XCTAssertFalse(title.contains("Bluray"))
        XCTAssertFalse(title.contains("1080p"))
        XCTAssertFalse(title.contains("x264"))
        XCTAssertFalse(title.contains("DTS"))
    }
    
    func testParseFilenameRemovesExtensions() {
        let (title, _) = parseFilename("Some.Movie.mp4")
        XCTAssertFalse(title.contains("mp4"))
    }
    
    // MARK: - Sortable Title Tests
    
    func testSortableTitleWithThePrefix() {
        let result = sortableTitle("The Matrix")
        XCTAssertEqual(result, "Matrix, The")
    }
    
    func testSortableTitleWithAPrefix() {
        let result = sortableTitle("A Beautiful Day")
        XCTAssertEqual(result, "Beautiful Day, A")
    }
    
    func testSortableTitleWithAnPrefix() {
        let result = sortableTitle("An American Werewolf")
        XCTAssertEqual(result, "American Werewolf, An")
    }
    
    func testSortableTitleWithoutPrefix() {
        let result = sortableTitle("Pulp Fiction")
        XCTAssertEqual(result, "Pulp Fiction")
    }
}

// MARK: - Test Helpers

private func parseFilename(_ filename: String) -> (title: String, year: Int?) {
    var title = filename
    var year: Int?
    
    // Extract year from parentheses
    if let yearRange = filename.range(of: #"\(\d{4}\)"#, options: .regularExpression) {
        let yearString = filename[yearRange].dropFirst().dropLast()
        year = Int(yearString)
        title = filename.replacingCharacters(in: yearRange, with: "")
    }
    
    // Clean up
    title = title.replacingOccurrences(of: #"\.(mp4|mkv|avi|mov|wmv|flv|webm|mpg|mpeg|3gp|3g2|m4v)$"#, with: "", options: .regularExpression)
    title = title.replacingOccurrences(of: #"\d{3,4}p|1080p|720p|2160p|4k|uhd|bluray|dvdrip|brrip|x264|x265|h\.264|h\.265|aac|ac3|dts|webrip"#, with: "", options: .regularExpression)
    title = title.replacingOccurrences(of: #"[\.\-_]"#, with: " ", options: .regularExpression)
    title = title.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    title = title.trimmingCharacters(in: .whitespacesAndNewlines)
    
    return (title, year)
}

private func sortableTitle(_ title: String) -> String {
    let prefixes = ["The ", "A ", "An ", "El ", "La ", "Le ", "Die ", "Das "]
    for prefix in prefixes {
        if title.hasPrefix(prefix) {
            return String(title.dropFirst(prefix.count).trimmingCharacters(in: .whitespaces)) + ", " + prefix.trimmingCharacters(in: .whitespaces)
        }
    }
    return title
}
