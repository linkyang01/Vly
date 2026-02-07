import SwiftUI
import Combine
import CoreData

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var filteredMovies: [Movie] = []
    @Published var selectedMovie: Movie?
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var sortOption: SortOption = .title
    @Published var filterOption: FilterOption = .all
    @Published var viewMode: ViewMode = .grid
    
    enum SortOption: String, CaseIterable {
        case title = "Title"
        case dateAdded = "Date Added"
        case releaseDate = "Release Date"
        case rating = "Rating"
    }
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case unwatched = "Unwatched"
        case watched = "Watched"
    }
    
    enum ViewMode: String, CaseIterable {
        case grid = "Grid"
        case list = "List"
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let context = CoreDataManager.shared.viewContext
    
    init() {
        loadMovies()
    }
    
    func loadMovies() {
        let request = Movie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.title, ascending: true)]
        
        if let result = try? context.fetch(request) {
            movies = result
            filteredMovies = result
        }
    }
    
    func addFolder(_ url: URL) {
        Task {
            await LibraryManager.shared.addLibraryFolder(url)
        }
    }
    
    func scanLibrary() async {
        for folder in LibraryManager.shared.libraryFolders {
            let files = await LibraryManager.shared.scanFolder(folder.path)
            // Import files...
        }
        loadMovies()
    }
}
