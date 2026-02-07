import Foundation

// MARK: - Network Browser ViewModel

/// View model for browsing network shares
@MainActor
class NetworkBrowserViewModel: ObservableObject {
    @Published var currentItems: [NetworkItem] = []
    @Published var pathStack: [[NetworkItem]] = []
    @Published var currentPath: String = "/"
    @Published var isLoading = false
    @Published var error: NetworkStorageError?
    @Published var selectedItem: NetworkItem?
    
    let server: NetworkServer
    
    private var currentClient: Any?
    
    init(server: NetworkServer) {
        self.server = server
    }
    
    // MARK: - Browsing
    
    func browse(path: String = "/") async {
        isLoading = true
        error = nil
        
        do {
            let items: [NetworkItem]
            
            switch server.protocol {
            case .smb:
                if let mountedURL = MountManager.shared.getMountURL(for: server.id) {
                    let fullPath = path == "/" ? mountedURL : mountedURL.appendingPathComponent(path)
                    items = try await browseMountedURL(fullPath)
                } else {
                    items = []
                }
            case .nfs:
                if let mountedURL = MountManager.shared.getMountURL(for: server.id) {
                    let fullPath = path == "/" ? mountedURL : mountedURL.appendingPathComponent(path)
                    items = try await browseMountedURL(fullPath)
                } else {
                    items = []
                }
            case .webdav:
                items = try await browseWebDAV(path: path)
            case .dlna:
                items = try await browseDLNA(path: path)
            }
            
            // Save current path for back navigation
            if !currentPath.isEmpty {
                pathStack.append(currentItems)
            }
            
            currentItems = items.sorted { item1, item2 in
                // Folders first, then files
                if item1.isDirectory != item2.isDirectory {
                    return item1.isDirectory
                }
                return item1.name.localizedCaseInsensitiveCompare(item2.name) == .orderedAscending
            }
            currentPath = path
            
        } catch let networkError as NetworkStorageError {
            self.error = networkError
        } catch {
            self.error = .connectionFailed(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Navigation
    
    func navigateTo(_ item: NetworkItem) async {
        guard item.isDirectory else { return }
        await browse(path: item.path)
    }
    
    func goBack() async {
        guard let previousItems = pathStack.popLast() else { return }
        currentItems = previousItems
        currentPath = currentItems.isEmpty ? "/" : currentItems.first?.path ?? "/"
    }
    
    func goToRoot() async {
        pathStack.removeAll()
        await browse(path: "/")
    }
    
    // MARK: - Refresh
    
    func refresh() async {
        await browse(path: currentPath)
    }
    
    // MARK: - Private Browsers
    
    private func browseMountedURL(_ url: URL) async throws -> [NetworkItem] {
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [
                    .isDirectoryKey,
                    .fileSizeKey,
                    .contentModificationDateKey
                ],
                options: [.skipsHiddenFiles]
            )
            
            return contents.map { itemURL in
                let values = try? itemURL.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey])
                
                return NetworkItem(
                    id: UUID(),
                    name: itemURL.lastPathComponent,
                    path: itemURL.path.replacingOccurrences(of: MountManager.shared.mountBasePath + "/\(server.id.uuidString)", with: ""),
                    isDirectory: values?.isDirectory ?? false,
                    size: values?.fileSize.map { Int64($0) },
                    modifiedDate: values?.contentModificationDate,
                    protocol: server.protocol,
                    serverID: server.id
                )
            }
        } catch {
            throw NetworkStorageError.pathNotFound
        }
    }
    
    private func browseWebDAV(path: String) async throws -> [NetworkItem] {
        guard let url = server.url else {
            throw NetworkStorageError.serverNotFound
        }
        
        let webdavClient = WebDAVClient()
        return try await webdavClient.browse(url: url, path: path)
    }
    
    private func browseDLNA(path: String) async throws -> [NetworkItem] {
        guard let serverURL = URL(string: server.location) else {
            throw NetworkStorageError.serverNotFound
        }
        
        let dlnaDiscovery = DLNADiscovery()
        let items = try await dlnaDiscovery.browse(server: DLNAServer(
            id: server.id,
            name: server.name,
            location: server.location,
            ipAddress: server.address,
            port: server.port,
            usn: nil,
            server: nil
        ), path: path)
        
        return items.map { item in
            NetworkItem(
                id: item.id,
                name: item.title,
                path: item.path,
                isDirectory: item.isDirectory,
                size: item.size,
                modifiedDate: nil,
                protocol: server.protocol,
                serverID: server.id
            )
        }
    }
}

// MARK: - Computed Properties

extension NetworkBrowserViewModel {
    var canGoBack: Bool {
        !pathStack.isEmpty
    }
    
    var canGoToRoot: Bool {
        currentPath != "/" && !pathStack.isEmpty
    }
    
    var currentDirectoryName: String {
        if currentPath == "/" {
            return server.name
        }
        return (currentPath as NSString).lastPathComponent
    }
    
    var videoItems: [NetworkItem] {
        currentItems.filter { $0.isVideo }
    }
    
    var folderItems: [NetworkItem] {
        currentItems.filter { $0.isDirectory }
    }
}
