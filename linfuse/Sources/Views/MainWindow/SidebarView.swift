import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: String
    @State private var showingAddFolder = false
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Movie.addedDate, ascending: false)],
        animation: .default
    )
    private var movies: FetchedResults<Movie>
    
    private var favoriteCount: Int {
        movies.filter { $0.isFavorite }.count
    }
    
    private var recentlyAddedCount: Int {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return movies.filter { $0.addedDate > oneWeekAgo }.count
    }
    
    var body: some View {
        List(selection: $selectedTab) {
            Section("Library") {
                Button {
                    selectedTab = "allMovies"
                } label: {
                    Label("All Movies", systemImage: "film")
                }
                .buttonStyle(.plain)
                .foregroundColor(selectedTab == "allMovies" ? .accentColor : .primary)
                
                Button {
                    selectedTab = "recentlyAdded"
                } label: {
                    HStack {
                        Label("Recently Added", systemImage: "clock")
                        Spacer()
                        if recentlyAddedCount > 0 {
                            Text("\(recentlyAddedCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(selectedTab == "recentlyAdded" ? .accentColor : .primary)
                
                Button {
                    selectedTab = "favorites"
                } label: {
                    HStack {
                        Label("Favorites", systemImage: "star")
                        Spacer()
                        if favoriteCount > 0 {
                            Text("\(favoriteCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(selectedTab == "favorites" ? .accentColor : .primary)
                
                Button {
                    selectedTab = "history"
                } label: {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .buttonStyle(.plain)
                .foregroundColor(selectedTab == "history" ? .accentColor : .primary)
            }
            
            Section("Smart Collections") {
                Button {
                    selectedTab = "topRated"
                } label: {
                    Label("Top Rated", systemImage: "star.fill")
                }
                .buttonStyle(.plain)
                
                Button {
                    selectedTab = "unwatched"
                } label: {
                    Label("Unwatched", systemImage: "eye")
                }
                .buttonStyle(.plain)
            }
            
            Section("Library Folders") {
                Button {
                    showingAddFolder = true
                } label: {
                    Label("Add Folder...", systemImage: "plus")
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Library")
        .sheet(isPresented: $showingAddFolder) {
            AddFolderView()
        }
    }
}

#Preview {
    SidebarView(selectedTab: .constant("allMovies"))
        .frame(width: 250)
}
