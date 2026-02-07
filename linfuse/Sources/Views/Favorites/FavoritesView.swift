import SwiftUI
import CoreData

struct FavoritesView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Movie.title, ascending: true)],
        animation: .default
    )
    private var allMovies: FetchedResults<Movie>
    
    private var favoriteMovies: [Movie] {
        allMovies.filter { $0.isFavorite }
    }
    
    @State private var selectedMovie: Movie?
    @State private var showingDetail = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        Group {
            if favoriteMovies.isEmpty {
                ContentUnavailableView(
                    "No Favorites Yet",
                    systemImage: "star",
                    description: Text("Movies you mark as favorites will appear here")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(favoriteMovies) { movie in
                            MovieCardView(movie: movie)
                                .onTapGesture {
                                    selectedMovie = movie
                                    showingDetail = true
                                }
                                .contextMenu {
                                    Button {
                                        FavoritesService.shared.toggleFavorite(movie)
                                    } label: {
                                        Label("Remove from Favorites", systemImage: "star.slash")
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Favorites")
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
        FavoritesView()
    }
}
