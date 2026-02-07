import SwiftUI
import AVKit
import Kingfisher

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    @State private var showingPlayer = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with poster and info
                HStack(alignment: .top, spacing: 20) {
                    // Poster
                    Group {
                        if let posterPath = movie.posterPath,
                           let url = TMDBService.shared.getImageURL(path: posterPath) {
                            KFImage(url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 225)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 150, height: 225)
                                .overlay {
                                    Image(systemName: "film.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                }
                        }
                    }
                    
                    // Movie info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.unwrappedTitle)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let originalTitle = movie.unwrappedOriginalTitle, !originalTitle.isEmpty {
                            Text(originalTitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            if let date = movie.releaseDate {
                                Text(date, format: .dateTime.year())
                                    .font(.caption)
                            }
                            if movie.runtime > 0 {
                                Text("• \(movie.formattedRuntime)")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", movie.rating))
                                .fontWeight(.semibold)
                            Text("(\(movie.voteCount) votes)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Play button
                        Button {
                            showingPlayer = true
                        } label: {
                            Label("Play", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Overview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.headline)
                    
                    Text(movie.unwrappedOverview ?? "No overview available.")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Action buttons
                HStack(spacing: 20) {
                    ActionButton(icon: "star", title: "Favorite", action: {
                        FavoritesService.shared.toggleFavorite(movie)
                    })
                    
                    ActionButton(icon: "bookmark", title: "Watchlist", action: {})
                    
                    ActionButton(icon: "square.and.arrow.up", title: "Share", action: {})
                }
                
                // Genres
                if !movie.genreNames.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Genres")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(movie.genreNames, id: \.self) { genre in
                                Text(genre)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.secondary.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                // Cast
                if !movie.sortedCast.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cast")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(movie.sortedCast.prefix(10))) { cast in
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 60, height: 60)
                                            .overlay {
                                                Text(String(cast.name.prefix(1)))
                                                    .font(.title2)
                                                    .foregroundColor(.gray)
                                            }
                                        
                                        Text(cast.name)
                                            .font(.caption)
                                            .lineLimit(1)
                                        
                                        Text(cast.character ?? "")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 80)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingPlayer) {
            VideoPlayerView(videoURL: movie.fileURL)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// Simple flow layout for genres
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: Movie())
    }
}
