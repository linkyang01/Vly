import XCTest
@testable import linfuse

final class FileScannerTests: XCTestCase {
    var fileScanner: FileScanner!
    
    override func setUp() {
        super.setUp()
        fileScanner = FileScanner()
    }
    
    override func tearDown() {
        fileScanner = nil
        super.tearDown()
    }
    
    // MARK: - Supported Extensions Tests
    
    func testSupportedExtensionsContainsCommonFormats() {
        let commonExtensions = ["mp4", "m4v", "mkv", "mov", "avi"]
        for ext in commonExtensions {
            XCTAssertTrue(
                fileScanner.supportedExtensions.contains(ext),
                "Extension \(ext) should be supported"
            )
        }
    }
    
    // MARK: - VideoFile Tests
    
    func testVideoFileFormattedSize() {
        let smallFile = VideoFile(
            url: URL(string: "file:///test/small.mkv")!,
            name: "small",
            size: 1_000_000, // 1 MB
            modifiedDate: nil,
            createdDate: nil,
            extension: "mkv"
        )
        
        XCTAssertEqual(smallFile.formattedSize, "1 MB")
        
        let largeFile = VideoFile(
            url: URL(string: "file:///test/large.mkv")!,
            name: "large",
            size: 1_500_000_000, // 1.5 GB
            modifiedDate: nil,
            createdDate: nil,
            extension: "mkv"
        )
        
        XCTAssertEqual(largeFile.formattedSize, "1.5 GB")
    }
    
    func testVideoFileEquality() {
        let url = URL(string: "file:///test/movie.mkv")!
        
        let file1 = VideoFile(
            url: url,
            name: "movie",
            size: 1_000_000,
            modifiedDate: Date(),
            createdDate: Date(),
            extension: "mkv"
        )
        
        let file2 = VideoFile(
            url: url,
            name: "movie",
            size: 1_000_000,
            modifiedDate: Date(),
            createdDate: Date(),
            extension: "mkv"
        )
        
        XCTAssertEqual(file1, file2)
    }
}
