import SwiftUI
import CoreData

struct WatchHistoryView: View {
    @StateObject private var historyService = WatchHistoryService.shared
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Movie.addedDate, ascending: false)],
        animation: .default
    )
    private var allMovies: FetchedResults<Movie>
    
    private var recentlyWatched: [Movie] {
        allMovies.filter { $0.lastWatchedDate != nil }
            .sorted { ($0.lastWatchedDate ?? Date.distantPast) > ($1.lastWatchedDate ?? Date.distantPast) }
    }
    
    @State private var selectedMovie: Movie?
    @State private var showingDetail = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        Group {
            if recentlyWatched.isEmpty {
                ContentUnavailableView(
                    "No Watch History",
                    systemImage: "clock",
                    description: Text("Movies you've watched will appear here")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(recentlyWatched) { movie in
                            MovieCardView(movie: movie)
                                .onTapGesture {
                                    selectedMovie = movie
                                    showingDetail = true
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("History")
        .sheet(isPresented: $showingDetail) {
            if let movie = selectedMovie {
                NavigationStack {
                    MovieDetailView(movie: movie)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WatchHistoryView()
    }
}
