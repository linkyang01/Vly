import XCTest
@testable import linfuse

final class ViewModelUITests: XCTestCase {
    
    // MARK: - SettingsViewModel Tests
    
    func testSettingsViewModelDefaultValues() {
        // Test default settings values
        let viewModel = SettingsViewModel()
        
        // Default theme should be system
        XCTAssertEqual(viewModel.selectedTheme, .system)
        
        // Default scraping language should be Chinese
        XCTAssertEqual(viewModel.scrapingLanguage, "zh-CN")
    }
    
    // MARK: - SubscriptionViewModel Tests
    
    func testSubscriptionViewModelDefaultState() {
        let viewModel = SubscriptionViewModel()
        
        // Initial state checks
        XCTAssertFalse(viewModel.isSubscribed)
        XCTAssertNil(viewModel.expirationDate)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSubscriptionViewModelTrialCalculation() {
        let viewModel = SubscriptionViewModel()
        
        // Test trial days remaining calculation
        let trialStart = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        viewModel.trialStartDate = trialStart
        
        // Should have 4 days remaining
        XCTAssertEqual(viewModel.trialDaysRemaining, 4)
    }
    
    // MARK: - ScrapingStatusViewModel Tests
    
    func testScrapingStatusViewModelDefaultState() {
        let viewModel = ScrapingStatusViewModel()
        
        XCTAssertFalse(viewModel.isScraping)
        XCTAssertEqual(viewModel.progress, 0)
        XCTAssertTrue(viewModel.pendingMovies.isEmpty)
    }
    
    // MARK: - NetworkBrowserViewModel Tests
    
    func testNetworkBrowserViewModelDefaultState() {
        let viewModel = NetworkBrowserViewModel()
        
        XCTAssertTrue(viewModel.servers.isEmpty)
        XCTAssertTrue(viewModel.browsingHistory.isEmpty)
        XCTAssertNil(viewModel.currentPath)
        XCTAssertNil(viewModel.selectedServer)
    }
    
    // MARK: - StatisticsViewModel Tests
    
    func testStatisticsViewModelDefaultState() {
        let viewModel = StatisticsViewModel()
        
        XCTAssertEqual(viewModel.totalMovies, 0)
        XCTAssertEqual(viewModel.totalWatchTime, 0)
        XCTAssertEqual(viewModel.watchedMovies, 0)
    }
}

// MARK: - FavoritesViewModel Tests

final class FavoritesViewModelTests: XCTestCase {
    var viewModel: FavoritesViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = FavoritesViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateFavoritesListsEmpty() {
        XCTAssertTrue(viewModel.favoritesLists.isEmpty)
    }
    
    func testInitialStateSelectedListNil() {
        XCTAssertNil(viewModel.selectedList)
    }
    
    func testInitialStateIsLoadingFalse() {
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testInitialStateSearchTextEmpty() {
        XCTAssertTrue(viewModel.searchText.isEmpty)
    }
    
    // MARK: - List Creation Tests
    
    func testCreateFavoritesList() {
        let initialCount = viewModel.favoritesLists.count
        
        viewModel.createList(name: "My Favorites", icon: "star.fill", color: "yellow")
        
        XCTAssertEqual(viewModel.favoritesLists.count, initialCount + 1)
    }
    
    func testCreateFavoritesListWithDefaultValues() {
        let initialCount = viewModel.favoritesLists.count
        
        viewModel.createList(name: "Test List")
        
        XCTAssertEqual(viewModel.favoritesLists.count, initialCount + 1)
        XCTAssertEqual(viewModel.favoritesLists.last?.name, "Test List")
    }
    
    // MARK: - List Deletion Tests
    
    func testDeleteFavoritesList() {
        viewModel.createList(name: "To Delete", icon: "trash", color: "red")
        guard let listToDelete = viewModel.favoritesLists.last else {
            return
        }
        let countBeforeDelete = viewModel.favoritesLists.count
        
        viewModel.deleteList(listToDelete)
        
        XCTAssertEqual(viewModel.favoritesLists.count, countBeforeDelete - 1)
    }
    
    // MARK: - List Selection Tests
    
    func testSelectFavoritesList() {
        viewModel.createList(name: "Selectable List")
        guard let list = viewModel.favoritesLists.last else {
            return
        }
        
        viewModel.selectList(list)
        
        XCTAssertEqual(viewModel.selectedList, list)
    }
    
    func testClearSelection() {
        viewModel.selectList(nil)
        
        XCTAssertNil(viewModel.selectedList)
    }
    
    // MARK: - Search Tests
    
    func testSearchTextUpdates() {
        viewModel.searchText = "Matrix"
        
        XCTAssertEqual(viewModel.searchText, "Matrix")
    }
}

// MARK: - WatchHistoryViewModel Tests

final class WatchHistoryViewModelTests: XCTestCase {
    var viewModel: WatchHistoryViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = WatchHistoryViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateHistoryEmpty() {
        XCTAssertTrue(viewModel.historyEntries.isEmpty)
    }
    
    func testInitialStateSelectedEntryNil() {
        XCTAssertNil(viewModel.selectedEntry)
    }
    
    func testInitialStateIsLoadingFalse() {
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testInitialStateFilterOptionAll() {
        XCTAssertEqual(viewModel.filterOption, .all)
    }
    
    func testInitialStateSortOptionDateDesc() {
        XCTAssertEqual(viewModel.sortOption, .dateDescending)
    }
    
    // MARK: - Filter Options Tests
    
    func testFilterOptionCaseIterable() {
        XCTAssertEqual(WatchHistoryViewModel.FilterOption.allCases.count, 4)
    }
    
    func testFilterOptionRawValues() {
        XCTAssertEqual(WatchHistoryViewModel.FilterOption.all.rawValue, "All")
        XCTAssertEqual(WatchHistoryViewModel.FilterOption.today.rawValue, "Today")
        XCTAssertEqual(WatchHistoryViewModel.FilterOption.thisWeek.rawValue, "This Week")
        XCTAssertEqual(WatchHistoryViewModel.FilterOption.thisMonth.rawValue, "This Month")
    }
    
    // MARK: - Sort Options Tests
    
    func testSortOptionCaseIterable() {
        XCTAssertEqual(WatchHistoryViewModel.SortOption.allCases.count, 3)
    }
    
    func testSortOptionRawValues() {
        XCTAssertEqual(WatchHistoryViewModel.SortOption.dateDescending.rawValue, "Newest First")
        XCTAssertEqual(WatchHistoryViewModel.SortOption.dateAscending.rawValue, "Oldest First")
        XCTAssertEqual(WatchHistoryViewModel.SortOption.progress.rawValue, "Watch Progress")
    }
}
