import Foundation

// MARK: - Mount Manager

/// Manages mount points for network shares
class MountManager {
    static let shared = MountManager()
    
    private var mounts: [UUID: MountInfo] = [:]
    private let mountBaseURL = URL(fileURLWithPath: "/Volumes/linfuse")
    private let fileManager = FileManager.default
    
    // Public access to mount base URL for network browsing
    var mountBasePath: String { mountBaseURL.path }
    
    private init() {
        setupMountDirectory()
    }
    
    // MARK: - Setup
    
    private func setupMountDirectory() {
        if !fileManager.fileExists(atPath: mountBaseURL.path) {
            try? fileManager.createDirectory(at: mountBaseURL, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Add Mount
    
    func addMount(server: NetworkServer, url: URL) throws {
        let info = MountInfo(
            server: server,
            mountURL: url,
            mountedAt: Date()
        )
        mounts[server.id] = info
    }
    
    // MARK: - Remove Mount
    
    func removeMount(for serverID: UUID) throws {
        guard let info = mounts[serverID] else {
            throw MountError.notMounted
        }
        
        switch info.server.protocol {
        case .smb:
            try unmountSMB(url: info.mountURL)
        case .nfs:
            try unmountNFS(url: info.mountURL)
        case .webdav, .dlna:
            // No unmount needed
            break
        }
        
        mounts.removeValue(forKey: serverID)
    }
    
    // MARK: - Unmount
    
    func unmount(url: URL) throws {
        // Find the server ID for this mount
        guard let serverID = mounts.first(where: { $0.value.mountURL == url })?.key else {
            throw MountError.notMounted
        }
        
        try removeMount(for: serverID)
    }
    
    // MARK: - Get Mount
    
    func getMount(for serverID: UUID) -> MountInfo? {
        return mounts[serverID]
    }
    
    func getMountURL(for serverID: UUID) -> URL? {
        return mounts[serverID]?.mountURL
    }
    
    // MARK: - List Mounts
    
    func listMounts() -> [MountInfo] {
        return Array(mounts.values)
    }
    
    // MARK: - Protocol-Specific Unmount
    
    private func unmountSMB(url: URL) throws {
        // Unmount SMB share
        let process = Process()
        let outputPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/sbin/umount")
        process.arguments = [url.path]
        process.standardOutput = outputPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus != 0 {
                throw MountError.unmountFailed("SMB unmount failed")
            }
        } catch {
            throw MountError.unmountFailed(error.localizedDescription)
        }
    }
    
    private func unmountNFS(url: URL) throws {
        // Unmount NFS share
        let process = Process()
        let outputPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/sbin/umount")
        process.arguments = [url.path]
        process.standardOutput = outputPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus != 0 {
                throw MountError.unmountFailed("NFS unmount failed")
            }
        } catch {
            throw MountError.unmountFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        // Unmount all shares on app exit
        for serverID in mounts.keys {
            try? removeMount(for: serverID)
        }
    }
}

// MARK: - Mount Info

struct MountInfo {
    let server: NetworkServer
    let mountURL: URL
    let mountedAt: Date
}

// MARK: - Mount Error

enum MountError: LocalizedError {
    case alreadyMounted
    case notMounted
    case mountFailed(String)
    case unmountFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .alreadyMounted:
            return "Share is already mounted"
        case .notMounted:
            return "Share is not mounted"
        case .mountFailed(let reason):
            return "Failed to mount: \(reason)"
        case .unmountFailed(let reason):
            return "Failed to unmount: \(reason)"
        }
    }
}
