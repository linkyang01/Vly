# Network Storage Architecture

## Overview

Network storage support for linfuse, inspired by Infuse. Supports SMB/CIFS, NFS, WebDAV, and optional DLNA/UPnP media server discovery.

```
┌─────────────────────────────────────────────────────────────────┐
│                   Network Storage Manager                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              NetworkStorageViewModel                     │   │
│  │  - Mount/Unmount servers                                 │   │
│  │  - Browse file hierarchy                                 │   │
│  │  - Credential management                                 │   │
│  │  - Connection state management                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│          ┌───────────────────┼───────────────────┐             │
│          ▼                   ▼                   ▼             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐        │
│  │ SMB/CIFS    │    │ NFS         │    │ WebDAV      │        │
│  │ Client      │    │ Client      │    │ Client      │        │
│  │ (Apple APIs)│    │ (Unix)      │    │ HTTP        │        │
│  └─────────────┘    └─────────────┘    └─────────────┘        │
│                              │                                  │
│                              ▼                                  │
│                    ┌─────────────────┐                          │
│                    │   DLNA/UPnP     │                          │
│                    │   Discovery     │                          │
│                    │   (Optional)    │                          │
│                    └─────────────────┘                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. Protocol Support

### SMB/CIFS (Primary)

**macOS Native APIs:**
- `NSNetServiceBrowser` for service discovery
- `NSNetService` for Bonjour/Zeroconf
- `smb://` URL scheme for mounting

**Implementation:**
```swift
class SMBClient {
    func discoverServers() async -> [SMBMountedServer] {
        // Bonjour service discovery for SMB
        // _smb._tcp.local
    }
    
    func mount(server: String, share: String, credentials: Credential?) async throws -> URL {
        // Mount SMB share using NSFileManager
        // Return mounted URL for browsing
    }
    
    func browse(mountedURL: URL) async throws -> [NetworkItem] {
        // Enumerate directory contents
        // Filter video files
    }
}
```

### NFS (Secondary)

**macOS Native Support:**
- `nfsd` daemon (built-in)
- `mount_nfs` command

**Implementation:**
```swift
class NFSClient {
    func discoverServers() async -> [NFSServer] {
        // Query portmapper for NFS services
        // Scan common ports (111, 2049)
    }
    
    func mount(server: String, exportPath: String) async throws -> URL {
        // Execute mount_nfs command
        // Return mounted path
    }
    
    func browse(mountedURL: URL) async throws -> [NetworkItem] {
        // Read directory contents
        // Filter video formats
    }
}
```

### WebDAV

**HTTP-based Protocol:**
- Standard HTTP methods (PROPFIND, GET, etc.)
- Digest/Basic authentication

**Implementation:**
```swift
class WebDAVClient {
    func discoverServers() async -> [WebDAVServer] {
        // Bonjour discovery for WebDAV
        // _webdav._tcp.local
    }
    
    func connect(url: URL, credentials: Credential?) async throws -> WebDAVConnection {
        // Validate connection
        // Store credentials securely in Keychain
    }
    
    func browse(path: String) async throws -> [NetworkItem] {
        // PROPFIND request
        // Parse XML response
    }
    
    func download(file: URL, to localURL: URL) async throws {
        // Stream download with progress
    }
}
```

### DLNA/UPnP (Optional)

**Media Server Discovery:**
- SSDP/UPnP protocol
- DDLNA media server profiles

**Implementation:**
```swift
class DLNADiscovery {
    func discoverServers(timeout: TimeInterval) async -> [DLNAServer] {
        // Send SSDP M-SEARCH broadcast
        // Parse LOCATION headers
        // Connect to device description XML
    }
    
    func browse(server: DLNAServer, path: String) async throws -> [DLNAItem] {
        // SOAP request to ContentDirectory
        // Parse DIDL-Lite XML
    }
    
    func getStreamingURL(item: DLNAItem) async throws -> URL {
        // Get resource URL for streaming
    }
}
```

---

## 2. Credential Management

### Secure Storage

**Keychain Integration:**
```swift
class CredentialManager {
    static let shared = CredentialManager()
    
    func save(credential: Credential, for server: ServerIdentity) throws {
        // Encode credential
        // Store in Keychain with server ID as key
    }
    
    func load(for server: ServerIdentity) throws -> Credential? {
        // Retrieve from Keychain
        // Decode and return
    }
    
    func delete(for server: ServerIdentity) throws {
        // Remove from Keychain
    }
    
    func listServers() -> [ServerIdentity] {
        // Return all stored server IDs
    }
}

struct Credential {
    let username: String
    let password: String  // Encrypted
    let domain: String?
    let protocol: NetworkProtocol
}

struct ServerIdentity: Codable, Hashable {
    let id: UUID
    let name: String
    let address: String
    let share: String?  // For SMB/NFS
    let protocol: NetworkProtocol
}
```

### UI for Credential Input

```swift
struct CredentialInputView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var domain = ""
    @State private var rememberCredentials = true
    
    var body: some View {
        Form {
            Section("Authentication") {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                TextField("Domain (optional)", text: $domain)
            }
            Section {
                Toggle("Remember credentials", isOn: $rememberCredentials)
            }
        }
    }
}
```

---

## 3. Server Discovery

### Bonjour/ZeroConf

```swift
enum NetworkProtocol: String, Codable, CaseIterable {
    case smb = "SMB"
    case nfs = "NFS"
    case webdav = "WebDAV"
    case dlna = "DLNA/UPnP"
}

struct NetworkServer: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let port: Int
    let protocol: NetworkProtocol
    let share: String?  // SMB/NFS share name
    var isConnected: Bool
    var lastConnected: Date?
    var credentialSaved: Bool
}

class ServerDiscovery {
    func discover(type: NetworkProtocol) async -> [NetworkServer] {
        switch type {
        case .smb:
            return await discoverSMB()
        case .nfs:
            return await discoverNFS()
        case .webdav:
            return await discoverWebDAV()
        case .dlna:
            return await discoverDLNA()
        }
    }
    
    private func discoverSMB() async -> [NetworkServer] {
        let browser = NetServiceBrowser()
        var servers: [NetworkServer] = []
        
        // Discover SMB services
        browser.searchForServices(ofType: "_smb._tcp", inDomain: "local.")
        
        return servers
    }
}
```

---

## 4. Mount Management

### macOS Mount Points

```swift
class MountManager {
    static let shared = MountManager()
    
    private var mountedShares: [URL: MountInfo] = [:]
    private let mountBaseURL = URL(fileURLWithPath: "/Volumes/linfuse")
    
    struct MountInfo {
        let server: NetworkServer
        let mountURL: URL
        let mountedAt: Date
        let credentials: Bool
    }
    
    func mount(server: NetworkServer, credential: Credential?) async throws -> URL {
        let mountPoint = mountBaseURL.appendingPathComponent(server.id.uuidString)
        
        try FileManager.default.createDirectory(at: mountPoint, withIntermediateDirectories: true)
        
        switch server.protocol {
        case .smb:
            return try await mountSMB(server: server, to: mountPoint, credential: credential)
        case .nfs:
            return try await mountNFS(server: server, to: mountPoint)
        case .webdav:
            return try await mountWebDAV(server: server, credential: credential)
        case .dlna:
            throw MountError.unsupportedProtocol
        }
    }
    
    func unmount(url: URL) throws {
        guard let mountInfo = mountedShares[url] else {
            throw MountError.notMounted
        }
        
        switch mountInfo.server.protocol {
        case .smb, .nfs:
            try FileManager.default.unmountAndPurgeContents(at: url)
        case .webdav:
            // No unmount needed for WebDAV
            break
        case .dlna:
            break
        }
        
        mountedShares.removeValue(forKey: url)
    }
    
    func listMounted() -> [MountInfo] {
        return Array(mountedShares.values)
    }
}
```

---

## 5. File Browsing

### Unified File Item

```swift
struct NetworkItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64?
    let modifiedDate: Date?
    let protocol: NetworkProtocol
    let serverID: UUID
    
    // Video metadata (if video file)
    var duration: TimeInterval?
    var resolution: String?
    var codec: String?
}

enum NetworkItemType {
    case folder
    case video(VideoMetadata)
    case audio
    case image
    case document
    case unknown
}
```

### Browser Implementation

```swift
class NetworkBrowser: ObservableObject {
    @Published var currentPath: [NetworkItem] = []
    @Published var pathHistory: [[NetworkItem]] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var currentServer: NetworkServer?
    private var connection: Any?
    
    func browse(server: NetworkServer, path: String = "/") async {
        isLoading = true
        error = nil
        
        do {
            let items = try await fetchItems(server: server, path: path)
            await MainActor.run {
                currentPath = items
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }
    
    func navigateTo(_ item: NetworkItem) async {
        guard item.isDirectory else { return }
        
        pathHistory.append(currentPath)
        await browse(server: currentServer!, path: item.path)
    }
    
    func goBack() async {
        guard let previousPath = pathHistory.popLast() else { return }
        currentPath = previousPath
    }
    
    private func fetchItems(server: NetworkServer, path: String) async throws -> [NetworkItem] {
        switch server.protocol {
        case .smb:
            return try await fetchSMBItems(server: server, path: path)
        case .nfs:
            return try await fetchNFSItems(server: server, path: path)
        case .webdav:
            return try await fetchWebDAVItems(server: server, path: path)
        case .dlna:
            return try await fetchDLNAItems(server: server, path: path)
        }
    }
}
```

---

## 6. UI Integration

### Network Storage View

```swift
struct NetworkStorageView: View {
    @StateObject var viewModel = NetworkStorageViewModel()
    @State private var selectedServer: NetworkServer?
    
    var body: some View {
        NavigationSplitView {
            serverListView
        } detail: {
            if let server = selectedServer {
                NetworkBrowserView(server: server)
            } else {
                Text("Select a server")
            }
        }
    }
    
    private var serverListView: some View {
        List {
            Section("Connected") {
                ForEach(viewModel.connectedServers) { server in
                    ServerRowView(server: server)
                        .onTapGesture {
                            selectedServer = server
                        }
                }
            }
            
            Section("Discovered") {
                ForEach(viewModel.discoveredServers) { server in
                    ServerRowView(server: server)
                        .onTapGesture {
                            viewModel.connect(to: server)
                        }
                }
            }
        }
    }
}

struct ServerRowView: View {
    let server: NetworkServer
    
    var body: some View {
        HStack {
            Image(systemName: iconForProtocol(server.protocol))
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading) {
                Text(server.name)
                Text("\(server.address):\(server.port)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if server.isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
    
    private func iconForProtocol(_ protocol: NetworkProtocol) -> String {
        switch `protocol` {
        case .smb: return "server.rack"
        case .nfs: return "network"
        case .webdav: return "globe"
        case .dlna: return "antenna.radiowaves.left.and.right"
        }
    }
}
```

---

## 7. Error Handling

```swift
enum NetworkStorageError: LocalizedError {
    case connectionFailed(String)
    case authenticationFailed
    case serverNotFound
    case pathNotFound
    case mountFailed(String)
    case unmountFailed
    case credentialNotFound
    case timeout
    case unsupportedProtocol
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason):
            return "Connection failed: \(reason)"
        case .authenticationFailed:
            return "Authentication failed. Check your credentials."
        case .serverNotFound:
            return "Server not found on network."
        case .pathNotFound:
            return "Path not found on server."
        case .mountFailed(let reason):
            return "Failed to mount: \(reason)"
        case .unmountFailed:
            return "Failed to unmount share."
        case .credentialNotFound:
            return "Saved credentials not found."
        case .timeout:
            return "Connection timed out."
        case .unsupportedProtocol:
            return "Protocol not supported for this operation."
        }
    }
}
```

---

## 8. Directory Structure

```
Sources/
├── Services/
│   ├── NetworkStorage/
│   │   ├── NetworkStorageManager.swift    # Main orchestrator
│   │   ├── SMBClient.swift                # SMB/CIFS implementation
│   │   ├── NFSClient.swift                # NFS implementation
│   │   ├── WebDAVClient.swift             # WebDAV implementation
│   │   ├── DLNADiscovery.swift            # DLNA/UPnP discovery
│   │   ├── CredentialManager.swift        # Keychain integration
│   │   ├── MountManager.swift             # Mount point management
│   │   └── NetworkBrowser.swift           # File browsing logic
│   └── TMDBService.swift
│
├── ViewModels/
│   ├── NetworkStorageViewModel.swift      # UI-facing view model
│   └── NetworkBrowserViewModel.swift      # Browser state
│
├── Models/
│   └── NetworkModels.swift                # Data structures
│
└── Views/
    ├── Network/
    │   ├── NetworkStorageView.swift       # Main storage UI
    │   ├── ServerListView.swift           # Server listing
    │   ├── ServerRowView.swift            # Server row component
    │   ├── NetworkBrowserView.swift       # File browser
    │   ├── CredentialInputView.swift      # Auth dialog
    │   ├── AddServerView.swift            # Manual add server
    │   └── ServerDetailView.swift         # Server info
    └── Settings/
        └── NetworkSettingsView.swift      # Network preferences
```

---

## 9. Progress Tracking

### Phase 1: Foundation (Completed in main architecture)

### Phase 2: Network Storage (In Progress)
- [x] Architecture design (this document)
- [ ] SMB/CIFS client implementation
- [ ] NFS client implementation
- [ ] WebDAV client implementation
- [ ] DLNA/UPnP discovery
- [ ] Credential management
- [ ] Mount management
- [ ] File browser UI

### Phase 3: UI Integration
- [ ] Network storage view
- [ ] Server discovery UI
- [ ] Credential input dialog
- [ ] Browser navigation
- [ ] Progress indicators

### Phase 4: Polish
- [ ] Error handling
- [ ] Reconnection logic
- [ ] Performance optimization
- [ ] Testing

---

## Dependencies

| Component | Dependency | Notes |
|-----------|------------|-------|
| SMB | Apple's NetService | Built-in, no external dependency |
| NFS | mount_nfs | Built-in on macOS |
| WebDAV | URLSession | Built-in networking |
| DLNA | SSDP/UPnP | Custom implementation |
| Keychain | Security.framework | Built-in |

---

## References

- [Apple's NetService Documentation](https://developer.apple.com/documentation/foundation/netservice)
- [SMB Protocol Reference](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-smb)
- [WebDAV Protocol](https://tools.ietf.org/html/rfc4918)
- [UPnP Device Architecture](http://www.upnp.org/specs/arch/UPnP-arch-DeviceArchitecture-v2.0.pdf)
