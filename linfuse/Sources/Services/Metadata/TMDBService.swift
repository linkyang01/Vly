import Foundation

enum TMDBError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noResults
    case invalidAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .noResults:
            return "No results found"
        case .invalidAPIKey:
            return "Invalid API key"
        }
    }
}

struct TMDBService {
    static let shared = TMDBService()
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let imageBaseURL = "https://image.tmdb.org/t/p"
    private let apiKey = "" // Should be loaded from settings
    
    private init() {}
    
    func searchMovies(query: String, page: Int = 1) async throws -> TMDBMovieResponse {
        guard !apiKey.isEmpty else {
            // Return mock data for demo
            return TMDBMovieResponse(
                page: 1,
                results: [
                    TMDBMovie(
                        id: 1,
                        title: "Sample Movie",
                        originalTitle: "Sample Movie",
                        overview: "This is a sample movie overview.",
                        posterPath: nil,
                        backdropPath: nil,
                        releaseDate: "2024-01-01",
                        voteAverage: 7.5,
                        voteCount: 100,
                        genreIds: [28, 12]
                    )
                ],
                totalPages: 1,
                totalResults: 1
            )
        }
        
        let urlString = "\(baseURL)/search/movie?api_key=\(apiKey)&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)&page=\(page)"
        
        guard let url = URL(string: urlString) else {
            throw TMDBError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(TMDBMovieResponse.self, from: data)
            return response
        } catch let error as TMDBError {
            throw error
        } catch let error as DecodingError {
            throw TMDBError.decodingError(error)
        } catch {
            throw TMDBError.networkError(error)
        }
    }
    
    func getMovieDetails(id: Int) async throws -> TMDBMovieDetails {
        guard !apiKey.isEmpty else {
            return TMDBMovieDetails(
                id: id,
                title: "Sample Movie",
                originalTitle: "Sample Movie",
                overview: "Sample overview",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2024-01-01",
                runtime: 120,
                voteAverage: 7.5,
                voteCount: 100,
                genres: [TMDBGenre(id: 28, name: "Action")],
                credits: TMDBCredits(cast: [], crew: [])
            )
        }
        
        let urlString = "\(baseURL)/movie/\(id)?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw TMDBError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let details = try JSONDecoder().decode(TMDBMovieDetails.self, from: data)
        return details
    }
    
    func getImageURL(path: String?, size: String = "w500") -> URL? {
        guard let path = path else { return nil }
        return URL(string: "\(imageBaseURL)/\(size)\(path)")
    }
}
