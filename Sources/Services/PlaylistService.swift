import Foundation

/// 播放列表服务 - 管理播放列表的 CRUD 和持久化
class PlaylistService: ObservableObject {
    // MARK: - Singleton
    
    static let shared = PlaylistService()
    
    // MARK: - Published Properties
    
    @Published var playlists: [Playlist] = []
    @Published var currentPlaylistId: UUID?
    
    // MARK: - Private Properties
    
    private let userDefaultsKey = "vly_playlists"
    private let currentPlaylistKey = "vly_current_playlist"
    
    // MARK: - Initialization
    
    private init() {
        loadPlaylists()
    }
    
    // MARK: - Playlist CRUD
    
    func createPlaylist(name: String = "新建播放列表") -> Playlist {
        let playlist = Playlist(name: name)
        playlists.append(playlist)
        savePlaylists()
        return playlist
    }
    
    func deletePlaylist(id: UUID) {
        playlists.removeAll { $0.id == id }
        if currentPlaylistId == id {
            currentPlaylistId = playlists.first?.id
        }
        savePlaylists()
    }
    
    func updatePlaylist(_ playlist: Playlist) {
        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            var updatedPlaylist = playlist
            updatedPlaylist.updatedAt = Date()
            playlists[index] = updatedPlaylist
            savePlaylists()
        }
    }
    
    func duplicatePlaylist(id: UUID, newName: String? = nil) {
        guard let original = playlists.first(where: { $0.id == id }) else { return }
        
        let duplicate = Playlist(
            id: UUID(),
            name: newName ?? "\(original.name) 副本",
            videos: original.videos,
            createdAt: Date(),
            updatedAt: Date(),
            sortOrder: original.sortOrder,
            shuffleEnabled: original.shuffleEnabled,
            repeatMode: original.repeatMode
        )
        
        playlists.append(duplicate)
        savePlaylists()
    }
    
    // MARK: - Video CRUD
    
    func addVideo(_ video: Video, to playlistId: UUID) {
        guard let index = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        playlists[index].addVideo(video)
        savePlaylists()
    }
    
    func addVideos(_ videos: [Video], to playlistId: UUID) {
        guard let index = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        playlists[index].addVideos(videos)
        savePlaylists()
    }
    
    func removeVideo(id: UUID, from playlistId: UUID) {
        guard let index = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        playlists[index].removeVideo(id: id)
        savePlaylists()
    }
    
    func removeVideo(at index: Int, from playlistId: UUID) {
        guard let playlistIndex = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        playlists[playlistIndex].removeVideo(at: index)
        savePlaylists()
    }
    
    func moveVideo(from source: IndexSet, to destination: Int, in playlistId: UUID) {
        guard let index = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        playlists[index].moveVideo(from: source, to: destination)
        savePlaylists()
    }
    
    func updateVideo(_ video: Video, in playlistId: UUID) {
        guard let index = playlists.firstIndex(where: { $0.id == playlistId }) else { return }
        playlists[index].updateVideo(video)
        savePlaylists()
    }
    
    // MARK: - Playlist Management
    
    func setCurrentPlaylist(_ playlistId: UUID?) {
        currentPlaylistId = playlistId
        UserDefaults.standard.set(playlistId?.uuidString, forKey: currentPlaylistKey)
    }
    
    func getCurrentPlaylist() -> Playlist? {
        guard let id = currentPlaylistId else {
            return playlists.first
        }
        return playlists.first { $0.id == id }
    }
    
    func clearPlaylist(id: UUID) {
        guard let index = playlists.firstIndex(where: { $0.id == id }) else { return }
        playlists[index].clear()
        savePlaylists()
    }
    
    // MARK: - Playback Control
    
    func nextVideo(currentVideoId: UUID?, in playlistId: UUID) -> Video? {
        guard let index = playlists.firstIndex(where: { $0.id == playlistId }) else { return nil }
        return playlists[index].nextVideo(currentVideoId: currentVideoId)
    }
    
    func previousVideo(currentVideoId: UUID?, in playlistId: UUID) -> Video? {
        guard let index = playlists.firstIndex(where: { $0.id == playlistId }) else { return nil }
        return playlists[index].previousVideo(currentVideoId: currentVideoId)
    }
    
    // MARK: - Sorting
    
    func sortPlaylist(id: UUID, by order: SortOrder) {
        guard let index = playlists.firstIndex(where: { $0.id == id }) else { return }
        
        var playlist = playlists[index]
        switch order {
        case .manual:
            break
        case .nameAsc:
            playlist.videos.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .nameDesc:
            playlist.videos.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .dateAdded:
            playlist.videos.sort { $0.dateAdded > $1.dateAdded }
        case .duration:
            playlist.videos.sort { $0.duration > $1.duration }
        }
        
        playlist.sortOrder = order
        playlist.updatedAt = Date()
        playlists[index] = playlist
        savePlaylists()
    }
    
    // MARK: - Persistence
    
    private func savePlaylists() {
        do {
            let data = try JSONEncoder().encode(playlists)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save playlists: \(error)")
        }
    }
    
    private func loadPlaylists() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        
        do {
            playlists = try JSONDecoder().decode([Playlist].self, from: data)
        } catch {
            print("Failed to load playlists: \(error)")
            playlists = []
        }
        
        if let idString = UserDefaults.standard.string(forKey: currentPlaylistKey),
           let id = UUID(uuidString: idString) {
            currentPlaylistId = id
        }
    }
    
    func reset() {
        playlists.removeAll()
        currentPlaylistId = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: currentPlaylistKey)
    }
}
