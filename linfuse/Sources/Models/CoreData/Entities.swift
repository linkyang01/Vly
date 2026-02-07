import Foundation
import CoreData

// MARK: - Movie Entity

@objc(Movie)
public class Movie: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var originalTitle: String?
    @NSManaged public var overview: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var runtime: Int32
    @NSManaged public var rating: Double
    @NSManaged public var voteCount: Int32
    @NSManaged public var posterPath: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var tmdbID: Int32
    
    // File information
    @NSManaged public var fileURL: URL
    @NSManaged public var fileSize: Int64
    @NSManaged public var duration: Double
    @NSManaged public var resolution: String?
    @NSManaged public var codec: String?
    @NSManaged public var fileName: String
    
    // Watch status
    @NSManaged public var currentPosition: Double
    @NSManaged public var isWatched: Bool
    @NSManaged public var watchCount: Int32
    @NSManaged public var lastWatchedDate: Date?
    
    // Favorites
    @NSManaged public var isFavorite: Bool
    @NSManaged public var tags: String?
    
    // Metadata
    @NSManaged public var metadataFetched: Bool
    @NSManaged public var addedDate: Date
    @NSManaged public var sortTitle: String?
    
    // Relationships
    @NSManaged public var genres: Set<Genre>?
    @NSManaged public var cast: Set<CastMember>?
    @NSManaged public var crew: Set<CrewMember>?
    @NSManaged public var watchHistory: Set<WatchHistoryEntry>?
}

// MARK: - Computed Properties

extension Movie {
    public var unwrappedTitle: String { title }
    public var unwrappedOriginalTitle: String? { originalTitle }
    public var unwrappedOverview: String? { overview }
    public var unwrappedPosterPath: String? { posterPath }
    public var unwrappedBackdropPath: String? { backdropPath }
    public var unwrappedResolution: String? { resolution }
    public var unwrappedCodec: String? { codec }
    
    public var formattedRuntime: String {
        let hours = runtime / 60
        let minutes = runtime % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
    
    public var progressPercentage: Double {
        guard duration > 0 else { return 0 }
        return (currentPosition / duration) * 100
    }
    
    public var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    
    public var genreNames: [String] {
        guard let genres = genres else { return [] }
        return genres.map { $0.name }.sorted()
    }
    
    public var sortedCast: [CastMember] {
        guard let cast = cast else { return [] }
        return cast.sorted { $0.order < $1.order }
    }
    
    public var sortedCrew: [CrewMember] {
        guard let crew = crew else { return [] }
        return crew.sorted { $0.order < $1.order }
    }
}

// MARK: - Fetch Requests

extension Movie {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }
    
    static func sortedByTitleFetchRequest() -> NSFetchRequest<Movie> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.title, ascending: true)]
        return request
    }
    
    static func recentlyAddedFetchRequest() -> NSFetchRequest<Movie> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.addedDate, ascending: false)]
        return request
    }
    
    static func continueWatchingFetchRequest() -> NSFetchRequest<Movie> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "currentPosition > 0 AND isWatched == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.lastWatchedDate, ascending: false)]
        return request
    }
}

// MARK: - Genre Entity

@objc(Genre)
public class Genre: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var tmdbID: Int32
    @NSManaged public var movies: Set<Movie>?
}

extension Genre {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Genre> {
        return NSFetchRequest<Genre>(entityName: "Genre")
    }
    
    static func fetchRequestForName(_ name: String) -> NSFetchRequest<Genre> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        return request
    }
}

// MARK: - CastMember Entity

@objc(CastMember)
public class CastMember: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var personID: Int32
    @NSManaged public var name: String
    @NSManaged public var character: String?
    @NSManaged public var profilePath: String?
    @NSManaged public var order: Int32
    @NSManaged public var movie: Movie?
}

extension CastMember {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CastMember> {
        return NSFetchRequest<CastMember>(entityName: "CastMember")
    }
}

// MARK: - CrewMember Entity

@objc(CrewMember)
public class CrewMember: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var personID: Int32
    @NSManaged public var name: String
    @NSManaged public var job: String?
    @NSManaged public var department: String?
    @NSManaged public var profilePath: String?
    @NSManaged public var order: Int32
    @NSManaged public var movie: Movie?
}

extension CrewMember {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CrewMember> {
        return NSFetchRequest<CrewMember>(entityName: "CrewMember")
    }
}

// MARK: - WatchHistoryEntry Entity

@objc(WatchHistoryEntry)
public class WatchHistoryEntry: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var position: Double
    @NSManaged public var timestamp: Date
    @NSManaged public var duration: Double
    @NSManaged public var completed: Bool
    @NSManaged public var movie: Movie?
}

extension WatchHistoryEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchHistoryEntry> {
        return NSFetchRequest<WatchHistoryEntry>(entityName: "WatchHistoryEntry")
    }
    
    static func recentEntriesFetchRequest(limit: Int = 50) -> NSFetchRequest<WatchHistoryEntry> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WatchHistoryEntry.timestamp, ascending: false)]
        request.fetchLimit = limit
        return request
    }
}

// MARK: - FavoritesList Entity

@objc(FavoritesList)
public class FavoritesList: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var icon: String
    @NSManaged public var color: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isSmartList: Bool
    @NSManaged public var criteriaData: Data?
    @NSManaged public var movies: Set<Movie>?
}

extension FavoritesList {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritesList> {
        return NSFetchRequest<FavoritesList>(entityName: "FavoritesList")
    }
}
