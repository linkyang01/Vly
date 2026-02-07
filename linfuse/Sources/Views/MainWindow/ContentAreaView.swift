import SwiftUI
import CoreData

struct ContentAreaView: View {
    let selectedTab: String
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Movie.title, ascending: true)],
        animation: .default
    )
    private var allMovies: FetchedResults<Movie>
    
    @State private var selectedMovie: Movie?
    @State private var showingDetail = false
    
    private var favoriteCount: Int {
        allMovies.filter { $0.isFavorite }.count
    }
    
    private var recentlyWatchedCount: Int {
        allMovies.filter { $0.lastWatchedDate != nil }.count
    }
    
    private var recentlyAddedCount: Int {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return allMovies.filter { $0.addedDate > oneWeekAgo }.count
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch selectedTab {
                case "allMovies", "movies":
                    MovieGridView()
                    
                case "favorites":
                    if favoriteCount > 0 {
                        FavoritesView()
                    } else {
                        ContentUnavailableView(
                            "No Favorites",
                            systemImage: "star",
                            description: Text("Movies you mark as favorites will appear here")
                        )
                    }
                    
                case "recentlyAdded":
                    if allMovies.isEmpty {
                        ContentUnavailableView(
                            "No Movies",
                            systemImage: "film",
                            description: Text("Add a folder to start")
                        )
                    } else {
                        MovieGridView()
                    }
                    
                case "history":
                    WatchHistoryView()
                    
                case "topRated":
                    MovieGridView()
                    
                case "unwatched":
                    let unwatched = allMovies.filter { !$0.isWatched }
                    if unwatched.isEmpty {
                        ContentUnavailableView(
                            "All Watched!",
                            systemImage: "checkmark.circle.fill",
                            description: Text("You've watched all movies in your library")
                        )
                    } else {
                        MovieGridView()
                    }
                    
                case "statistics":
                    StatisticsView()
                    
                default:
                    MovieGridView()
                }
            }
            .navigationTitle(titleForTab(selectedTab))
        }
    }
    
    private func titleForTab(_ tab: String) -> String {
        switch tab {
        case "allMovies": return "All Movies"
        case "movies": return "Movies"
        case "favorites": return "Favorites"
        case "recentlyAdded": return "Recently Added"
        case "history": return "History"
        case "topRated": return "Top Rated"
        case "unwatched": return "Unwatched"
        case "statistics": return "Statistics"
        default: return tab.capitalized
        }
    }
}

struct StatisticsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Movie.title, ascending: true)],
        animation: .default
    )
    private var movies: FetchedResults<Movie>
    
    private var totalSize: Int64 {
        movies.reduce(0) { $0 + $1.fileSize }
    }
    
    private var watchedCount: Int {
        movies.filter { $0.isWatched }.count
    }
    
    private var favoriteCount: Int {
        movies.filter { $0.isFavorite }.count
    }
    
    private var totalRuntime: Int {
        movies.reduce(0) { $0 + Int($1.runtime) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Library Statistics")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(title: "Total Movies", value: "\(movies.count)", icon: "film.fill", color: .blue)
                    StatCard(title: "Watched", value: "\(watchedCount)", icon: "checkmark.circle.fill", color: .green)
                    StatCard(title: "Favorites", value: "\(favoriteCount)", icon: "star.fill", color: .yellow)
                    StatCard(title: "Total Size", value: formattedSize(totalSize), icon: "internaldrive.fill", color: .purple)
                }
                .padding(.horizontal)
                
                if totalRuntime > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Watch Time")
                            .font(.headline)
                        
                        Text(formattedRuntime(totalRuntime))
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func formattedSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formattedRuntime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ContentAreaView(selectedTab: "allMovies")
}
