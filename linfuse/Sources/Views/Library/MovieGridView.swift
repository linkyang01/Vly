import SwiftUI
import CoreData
import Kingfisher

struct MovieGridView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Movie.title, ascending: true)],
        animation: .default
    )
    private var movies: FetchedResults<Movie>
    
    @State private var selectedMovie: Movie?
    @State private var showingDetail = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        Group {
            if movies.isEmpty {
                ContentUnavailableView(
                    "No Movies",
                    systemImage: "film",
                    description: Text("Add a folder to start building your library")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(movies) { movie in
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
        .sheet(isPresented: $showingDetail) {
            if let movie = selectedMovie {
                NavigationStack {
                    MovieDetailView(movie: movie)
                }
            }
        }
    }
}

struct MovieCardView: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster
            Group {
                if let posterPath = movie.posterPath,
                   let url = TMDBService.shared.getImageURL(path: posterPath) {
                    KFImage(url)
                        .placeholder {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay {
                            Image(systemName: "film.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                }
            }
            
            // Title
            Text(movie.unwrappedTitle)
                .font(.headline)
                .lineLimit(1)
            
            // Year and Rating
            HStack {
                if let year = movie.releaseDate {
                    Text(year, format: .dateTime.year())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", movie.rating))
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    MovieGridView()
        .frame(width: 600, height: 400)
}
