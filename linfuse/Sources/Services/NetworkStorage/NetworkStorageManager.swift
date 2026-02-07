import Foundation

// MARK: - Network Storage Manager

/// Main orchestrator for network storage operations
@MainActor
class NetworkStorageManager: ObservableObject {
    static let shared = NetworkStorageManager()
    
    @Published var connectedServers: [NetworkServer] = []
    @Published var discoveredServers: [NetworkServer] = []
    @Published var selectedServer: NetworkServer?
    @Published var isDiscovering = false
    @Published var lastError: NetworkStorageError?
    
    private let smbClient = SMBClient()
    private let nfsClient = NFSClient()
    private let webdavClient = WebDAVClient()
    private let dlnaDiscovery = DLNADiscovery()
    private let mountManager = MountManager.shared
    private let credentialManager = CredentialManager.shared
    
    private init() {}
    
    // MARK: - Discovery
    
    func discoverAll() async {
        isDiscovering = true
        lastError = nil
        
        // Discover all protocol types in parallel
        async let smbServers = smbClient.discoverServers()
        async let nfsServers = nfsClient.discoverServers()
        async let webdavServers = webdavClient.discoverServers()
        async let dlnaServers = dlnaDiscovery.discoverServers()
        
        do {
            let (smb, nfs, webdav, dlna) = try await (smbServers, nfsServers, webdavServers, dlnaServers)
            
            // Merge and filter already connected
            let allServers = smb + nfs + webdav + dlna
            discoveredServers = allServers.filter { server in
                !connectedServers.contains(where: { $0.address == server.address && $0.protocol == server.protocol })
            }
        } catch {
            lastError = .connectionFailed(error.localizedDescription)
        }
        
        isDiscovering = false
    }
    
    func discover(type: NetworkProtocol) async -> [NetworkServer] {
        switch type {
        case .smb:
            return await smbClient.discoverServers()
        case .nfs:
            return await nfsClient.discoverServers()
        case .webdav:
            return await webdavClient.discoverServers()
        case .dlna:
            return await dlnaDiscovery.discoverServers()
        }
    }
    
    // MARK: - Connection
    
    func connect(to server: NetworkServer, credential: Credential? = nil) async throws {
        lastError = nil
        
        do {
            let mountedURL: URL?
            
            switch server.protocol {
            case .smb:
                mountedURL = try await smbClient.mount(server: server, credential: credential)
            case .nfs:
                mountedURL = try await nfsClient.mount(server: server)
            case .webdav:
                mountedURL = try await webdavClient.connect(url: server.url, credential: credential)
            case .dlna:
                // DLNA servers don't mount, just connect
                mountedURL = nil
            }
            
            // Save connection info
            var connectedServer = server
            connectedServer.isConnected = true
            connectedServer.lastConnected = Date()
            connectedServer.credentialSaved = credential != nil
            
            if let url = mountedURL {
                try mountManager.addMount(server: connectedServer, url: url)
            }
            
            // Move from discovered to connected
            connectedServers.append(connectedServer)
            discoveredServers.removeAll { $0.id == server.id }
            selectedServer = connectedServer
            
        } catch let error as NetworkStorageError {
            throw error
        } catch {
            throw .connectionFailed(error.localizedDescription)
        }
    }
    
    func disconnect(from server: NetworkServer) async throws {
        lastError = nil
        
        // Unmount if needed
        if let mountInfo = mountManager.getMount(for: server.id) {
            try mountManager.unmount(url: mountInfo.mountURL)
        }
        
        // Update server state
        if let index = connectedServers.firstIndex(where: { $0.id == server.id }) {
            var disconnectedServer = connectedServers[index]
            disconnectedServer.isConnected = false
            connectedServers.remove(at: index)
            discoveredServers.append(disconnectedServer)
        }
        
        if selectedServer?.id == server.id {
            selectedServer = nil
        }
    }
    
    // MARK: - Credential Management
    
    func getCredential(for server: NetworkServer) -> Credential? {
        do {
            return try credentialManager.load(for: server.identity)
        } catch {
            return nil
        }
    }
    
    func saveCredential(_ credential: Credential, for server: NetworkServer) throws {
        try credentialManager.save(credential, for: server.identity)
        
        if let index = connectedServers.firstIndex(where: { $0.id == server.id }) {
            connectedServers[index].credentialSaved = true
        }
    }
    
    // MARK: - Server Management
    
    func addManualServer(_ server: NetworkServer) {
        if !discoveredServers.contains(where: { $0.id == server.id }) &&
           !connectedServers.contains(where: { $0.id == server.id }) {
            discoveredServers.append(server)
        }
    }
    
    func removeServer(_ server: NetworkServer) {
        // Remove from discovered
        discoveredServers.removeAll { $0.id == server.id }
        
        // Disconnect if connected
        if server.isConnected {
            Task {
                try? await disconnect(from: server)
            }
        }
        
        // Delete saved credentials
        try? credentialManager.delete(for: server.identity)
    }
}
