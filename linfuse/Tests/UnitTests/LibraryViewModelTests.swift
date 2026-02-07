import XCTest
@testable import linfuse

final class LibraryViewModelTests: XCTestCase {
    var viewModel: LibraryViewModel!
    var mockContext: MockNSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        mockContext = MockNSManagedObjectContext()
        viewModel = LibraryViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        mockContext = nil
        super.tearDown()
    }
    
    // MARK: - Sort Option Tests
    
    func testSortOptionRawValues() {
        XCTAssertEqual(LibraryViewModel.SortOption.title.rawValue, "Title")
        XCTAssertEqual(LibraryViewModel.SortOption.dateAdded.rawValue, "Date Added")
        XCTAssertEqual(LibraryViewModel.SortOption.releaseDate.rawValue, "Release Date")
        XCTAssertEqual(LibraryViewModel.SortOption.rating.rawValue, "Rating")
        XCTAssertEqual(LibraryViewModel.SortOption.duration.rawValue, "Duration")
        XCTAssertEqual(LibraryViewModel.SortOption.watchProgress.rawValue, "In Progress")
    }
    
    func testSortOptionCaseIterable() {
        XCTAssertEqual(LibraryViewModel.SortOption.allCases.count, 6)
    }
    
    // MARK: - Filter Option Tests
    
    func testFilterOptionRawValues() {
        XCTAssertEqual(LibraryViewModel.FilterOption.all.rawValue, "All")
        XCTAssertEqual(LibraryViewModel.FilterOption.unwatched.rawValue, "Unwatched")
        XCTAssertEqual(LibraryViewModel.FilterOption.watched.rawValue, "Watched")
        XCTAssertEqual(LibraryViewModel.FilterOption.inProgress.rawValue, "In Progress")
    }
    
    func testFilterOptionCaseIterable() {
        XCTAssertEqual(LibraryViewModel.FilterOption.allCases.count, 4)
    }
    
    // MARK: - View Mode Tests
    
    func testViewModeRawValues() {
        XCTAssertEqual(LibraryViewModel.ViewMode.grid.rawValue, "Grid")
        XCTAssertEqual(LibraryViewModel.ViewMode.list.rawValue, "List")
        XCTAssertEqual(LibraryViewModel.ViewMode.hero.rawValue, "Hero")
    }
    
    func testViewModeCaseIterable() {
        XCTAssertEqual(LibraryViewModel.ViewMode.allCases.count, 3)
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateMoviesEmpty() {
        XCTAssertTrue(viewModel.movies.isEmpty)
    }
    
    func testInitialStateFilteredMoviesEmpty() {
        XCTAssertTrue(viewModel.filteredMovies.isEmpty)
    }
    
    func testInitialStateSelectedMovieNil() {
        XCTAssertNil(viewModel.selectedMovie)
    }
    
    func testInitialStateIsLoadingFalse() {
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testInitialStateSearchTextEmpty() {
        XCTAssertTrue(viewModel.searchText.isEmpty)
    }
    
    func testInitialStateDefaultSortOption() {
        XCTAssertEqual(viewModel.sortOption, .title)
    }
    
    func testInitialStateDefaultFilterOption() {
        XCTAssertEqual(viewModel.filterOption, .all)
    }
    
    func testInitialStateDefaultViewMode() {
        XCTAssertEqual(viewModel.viewMode, .grid)
    }
    
    // MARK: - State Changes Tests
    
    func testSearchTextUpdatesPublishedProperty() {
        viewModel.searchText = "Matrix"
        
        XCTAssertEqual(viewModel.searchText, "Matrix")
    }
    
    func testSortOptionUpdatesPublishedProperty() {
        viewModel.sortOption = .rating
        
        XCTAssertEqual(viewModel.sortOption, .rating)
    }
    
    func testFilterOptionUpdatesPublishedProperty() {
        viewModel.filterOption = .watched
        
        XCTAssertEqual(viewModel.filterOption, .watched)
    }
    
    func testViewModeUpdatesPublishedProperty() {
        viewModel.viewMode = .hero
        
        XCTAssertEqual(viewModel.viewMode, .hero)
    }
}

// MARK: - Mock NSManagedObjectContext

class MockNSManagedObjectContext: NSManagedObjectContext {
    override init(concurrencyType: NSManagedObjectContextConcurrencyType) {
        super.init(concurrencyType: concurrencyType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
        return []
    }
}
