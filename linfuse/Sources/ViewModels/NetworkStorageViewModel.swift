import Foundation

// MARK: - Network Storage ViewModel

/// Main view model for network storage management
@MainActor
class NetworkStorageViewModel: ObservableObject {
    @Published var connectedServers: [NetworkServer] = []
    @Published var discoveredServers: [NetworkServer] = []
    @Published var isDiscovering = false
    @Published var error: NetworkStorageError?
    @Published var selectedServer: NetworkServer?

    private var discoveryTask: Task<Void, Never>?

    // MARK: - Discovery

    func discoverAll() async {
        isDiscovering = true
        error = nil

        // For now, just use discoveredServers from NetworkBrowserViewModel
        // Full implementation would scan for SMB/WebDAV/DLNA servers
        isDiscovering = false
    }

    // MARK: - Server Management

    func addManualServer(_ server: NetworkServer) {
        if !connectedServers.contains(where: { $0.id == server.id }) {
            connectedServers.append(server)
        }
    }

    func connect(to server: NetworkServer) async throws {
        // Connection logic is handled by individual clients
        if !connectedServers.contains(where: { $0.id == server.id }) {
            connectedServers.append(server)
        }
        selectedServer = server
    }

    func disconnect(from server: NetworkServer) async throws {
        connectedServers.removeAll { $0.id == server.id }
        if selectedServer?.id == server.id {
            selectedServer = nil
        }
    }

    // MARK: - Credentials

    func getCredential(for server: NetworkServer) -> Credential? {
        // Placeholder - actual implementation uses CredentialManager
        return nil
    }
}
