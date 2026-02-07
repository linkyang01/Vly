import Foundation

// MARK: - Movie Response

struct TMDBMovieResponse: Codable {
    let page: Int
    let results: [TMDBMovie]
    let totalPages: Int
    let totalResults: Int
}

// MARK: - Movie

struct TMDBMovie: Codable, Identifiable {
    let id: Int
    let title: String
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let genreIds: [Int]?
    
    var releaseYear: String? {
        guard let date = releaseDate, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }
}

// MARK: - Movie Details

struct TMDBMovieDetails: Codable {
    let id: Int
    let title: String
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let runtime: Int?
    let voteAverage: Double
    let voteCount: Int
    let genres: [TMDBGenre]?
    let credits: TMDBCredits?
    
    var formattedRuntime: String? {
        guard let runtime = runtime else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Genre

struct TMDBGenre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

// MARK: - Credits

struct TMDBCredits: Codable {
    let cast: [TMDBCastMember]
    let crew: [TMDBCrewMember]
}

struct TMDBCastMember: Codable, Identifiable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
}

struct TMDBCrewMember: Codable, Identifiable {
    let id: Int
    let name: String
    let job: String?
    let department: String?
    let profilePath: String?
}

// MARK: - Genre Mapping

extension TMDBMovieDetails {
    static let allGenres: [Int: String] = [
        28: "Action",
        12: "Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        14: "Fantasy",
        36: "History",
        27: "Horror",
        10402: "Music",
        9648: "Mystery",
        10749: "Romance",
        878: "Science Fiction",
        10770: "TV Movie",
        53: "Thriller",
        10752: "War",
        37: "Western"
    ]
    
    var genreNames: [String] {
        guard let genres = genres else { return [] }
        return genres.map { $0.name }
    }
}
