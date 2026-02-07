import Foundation
import Combine
import AVFoundation

/// 库管理器 - 管理视频库文件夹和扫描
final class LibraryManager: ObservableObject {
    static let shared = LibraryManager()
    
    // MARK: - Published Properties
    
    @Published var libraryFolders: [LibraryFolder] = []
    @Published var isScanning = false
    @Published var scanProgress: Double = 0
    @Published var scanStatus: String = ""
    
    // MARK: - Private Properties
    
    private let fileScanner = FileScanner()
    private var cancellables = Set<AnyCancellable>()
    private let scanLock = NSLock()
    
    // MARK: - Initialization
    
    private init() {
        loadLibraryFolders()
    }
    
    // MARK: - Library Folder Management
    
    /// 添加库文件夹
    func addLibraryFolder(_ url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        let folder = LibraryFolder(
            id: UUID(),
            name: url.lastPathComponent,
            path: url,
            isMonitoringEnabled: true
        )
        
        libraryFolders.append(folder)
        saveLibraryFolders()
    }
    
    /// 移除库文件夹
    func removeLibraryFolder(at offsets: IndexSet) {
        libraryFolders.remove(atOffsets: offsets)
        saveLibraryFolders()
    }
    
    // MARK: - Scanning
    
    /// 扫描文件夹
    func scanFolder(_ url: URL) async -> [ScannedVideoFile] {
        isScanning = true
        scanProgress = 0
        scanStatus = "Scanning..."
        
        let files = await fileScanner.scanFolder(url)
        
        scanProgress = 1.0
        scanStatus = "Found \(files.count) videos"
        isScanning = false
        
        return files
    }
    
    // MARK: - Persistence
    
    private func loadLibraryFolders() {
        // 从 UserDefaults 加载
        if let data = UserDefaults.standard.data(forKey: "libraryFolders"),
           let folders = try? JSONDecoder().decode([LibraryFolder].self, from: data) {
            libraryFolders = folders
        }
    }
    
    private func saveLibraryFolders() {
        if let data = try? JSONEncoder().encode(libraryFolders) {
            UserDefaults.standard.set(data, forKey: "libraryFolders")
        }
    }
}

// MARK: - Supporting Types

struct LibraryFolder: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var path: URL
    var isMonitoringEnabled: Bool
    
    init(id: UUID = UUID(), name: String, path: URL, isMonitoringEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.path = path
        self.isMonitoringEnabled = isMonitoringEnabled
    }
}

enum LibraryError: Error, LocalizedError {
    case folderNotFound
    case invalidURL
    case scanFailed
    
    var errorDescription: String? {
        switch self {
        case .folderNotFound: return "Folder not found"
        case .invalidURL: return "Invalid URL"
        case .scanFailed: return "Scan failed"
        }
    }
}
