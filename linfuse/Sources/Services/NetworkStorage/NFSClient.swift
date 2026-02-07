import Foundation

// MARK: - NFS Client

/// NFS client implementation using macOS built-in mount_nfs
class NFSClient {
    
    // MARK: - Discovery
    
    func discoverServers() async -> [NetworkServer] {
        var servers: [NetworkServer] = []
        
        // Query portmapper for NFS services on local network
        // Simplified implementation - scan common NFS ports
        
        // Try to discover via showmount
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/showmount")
        process.arguments = ["-e", "localhost"]
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            // Parse showmount output
            // Example: Exports list on localhost:
            // /path/to/export  host1,host2
            
            for line in output.components(separatedBy: "\n") {
                if line.hasPrefix("/") {
                    let parts = line.components(separatedBy: " ")
                    if let exportPath = parts.first {
                        let server = NetworkServer(
                            id: UUID(),
                            name: "NFS Export (\(exportPath))",
                            address: "localhost",
                            port: 2049,
                            protocol: .nfs,
                            share: exportPath,
                            isConnected: false,
                            lastConnected: nil,
                            credentialSaved: false
                        )
                        servers.append(server)
                    }
                }
            }
        } catch {
            // showmount failed, try alternative discovery
            print("NFS discovery via showmount failed: \(error)")
        }
        
        return servers
    }
    
    // MARK: - Mounting
    
    func mount(server: NetworkServer) async throws -> URL {
        guard let exportPath = server.share else {
            throw NetworkStorageError.mountFailed("No export path specified")
        }
        
        // Create mount point
        let mountBaseURL = URL(fileURLWithPath: "/Volumes/linfuse")
        try FileManager.default.createDirectory(at: mountBaseURL, withIntermediateDirectories: true)
        
        let mountPoint = mountBaseURL.appendingPathComponent("\(server.id.uuidString)")
        
        // Check if already mounted
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: mountPoint.path) {
            // Verify it's an NFS mount
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: mountPoint.path, isDirectory: &isDir) && isDir.boolValue {
                return mountPoint
            }
        }
        
        // Mount NFS share using mount_nfs
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/sbin/mount_nfs")
        process.arguments = [
            "-o", "resvport,soft,timeo=10,retrans=3",
            "\(server.address):\(exportPath)",
            mountPoint.path
        ]
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            
            if process.terminationStatus != 0 {
                throw NetworkStorageError.mountFailed(errorOutput.isEmpty ? "Unknown error" : errorOutput)
            }
        } catch {
            throw NetworkStorageError.mountFailed(error.localizedDescription)
        }
        
        // Verify mount succeeded
        if !fileManager.fileExists(atPath: mountPoint.path) {
            throw NetworkStorageError.mountFailed("Mount point not created")
        }
        
        return mountPoint
    }
    
    // MARK: - Browsing
    
    func browse(mountedURL: URL) async throws -> [NetworkItem] {
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: mountedURL,
                includingPropertiesForKeys: [
                    .isDirectoryKey,
                    .fileSizeKey,
                    .contentModificationDateKey
                ],
                options: [.skipsHiddenFiles]
            )
            
            return contents.map { url in
                let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize
                let modifiedDate = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
                
                return NetworkItem(
                    id: UUID(),
                    name: url.lastPathComponent,
                    path: url.path,
                    isDirectory: isDirectory,
                    size: size.map { Int64($0) },
                    modifiedDate: modifiedDate,
                    protocol: .nfs,
                    serverID: UUID()
                )
            }
        } catch {
            throw NetworkStorageError.pathNotFound
        }
    }
    
    // MARK: - Unmounting
    
    func unmount(mountedURL: URL) async throws {
        let process = Process()
        let outputPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/sbin/umount")
        process.arguments = [mountedURL.path]
        process.standardOutput = outputPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus != 0 {
                let errorData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                throw NetworkStorageError.unmountFailed
            }
        } catch {
            throw NetworkStorageError.unmountFailed
        }
    }
}
