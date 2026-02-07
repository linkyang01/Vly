import XCTest
@testable import linfuse

final class NetworkItemTests: XCTestCase {
    
    // MARK: - NetworkItem Video Detection Tests
    
    func testNetworkItemDetectsMP4Video() {
        let item = createNetworkItem(name: "movie.mp4")
        
        XCTAssertTrue(item.isVideo)
    }
    
    func testNetworkItemDetectsMKVVideo() {
        let item = createNetworkItem(name: "movie.mkv")
        
        XCTAssertTrue(item.isVideo)
    }
    
    func testNetworkItemDetectsMOVVideo() {
        let item = createNetworkItem(name: "movie.mov")
        
        XCTAssertTrue(item.isVideo)
    }
    
    func testNetworkItemDetectsAVIVideo() {
        let item = createNetworkItem(name: "movie.avi")
        
        XCTAssertTrue(item.isVideo)
    }
    
    func testNetworkItemDetectsM4VVideo() {
        let item = createNetworkItem(name: "movie.m4v")
        
        XCTAssertTrue(item.isVideo)
    }
    
    func testNetworkItemIgnoresNonVideoFiles() {
        let item = createNetworkItem(name: "document.pdf")
        
        XCTAssertFalse(item.isVideo)
    }
    
    func testNetworkItemIgnoresImages() {
        let item = createNetworkItem(name: "poster.jpg")
        
        XCTAssertFalse(item.isVideo)
    }
    
    func testNetworkItemIgnoresCaseInsensitive() {
        let itemUpper = createNetworkItem(name: "MOVIE.MP4")
        let itemLower = createNetworkItem(name: "movie.mp4")
        
        XCTAssertTrue(itemUpper.isVideo)
        XCTAssertTrue(itemLower.isVideo)
    }
    
    func testNetworkItemDetectsM2TSFormat() {
        let item = createNetworkItem(name: "movie.m2ts")
        
        XCTAssertTrue(item.isVideo)
    }
    
    func testNetworkItemDetectsTSFormat() {
        let item = createNetworkItem(name: "movie.ts")
        
        XCTAssertTrue(item.isVideo)
    }
    
    // MARK: - NetworkItem Formatted Size Tests
    
    func testNetworkItemFormattedSizeBytes() {
        let item = createNetworkItem(size: 500)
        
        XCTAssertEqual(item.formattedSize, "500 bytes")
    }
    
    func testNetworkItemFormattedSizeKilobytes() {
        let item = createNetworkItem(size: 5_000)
        
        XCTAssertTrue(item.formattedSize.contains("KB"))
    }
    
    func testNetworkItemFormattedSizeMegabytes() {
        let item = createNetworkItem(size: 5_000_000)
        
        XCTAssertTrue(item.formattedSize.contains("MB"))
    }
    
    func testNetworkItemFormattedSizeGigabytes() {
        let item = createNetworkItem(size: 5_000_000_000)
        
        XCTAssertTrue(item.formattedSize.contains("GB"))
    }
    
    func testNetworkItemFormattedSizeUnknownForNil() {
        let item = createNetworkItem(size: nil)
        
        XCTAssertEqual(item.formattedSize, "Unknown")
    }
    
    // MARK: - NetworkItem Hashable Tests
    
    func testNetworkItemHashable() {
        let id = UUID()
        let item1 = createNetworkItem(id: id, name: "movie.mp4")
        let item2 = createNetworkItem(id: id, name: "movie.mp4")
        
        XCTAssertEqual(item1.hashValue, item2.hashValue)
    }
    
    // MARK: - VideoMetadata Tests
    
    func testVideoMetadataCreation() {
        let metadata = VideoMetadata(
            title: "Test Movie",
            path: "/share/movies/test.mp4",
            size: 2_000_000_000,
            protocol: .smb
        )
        
        XCTAssertEqual(metadata.title, "Test Movie")
        XCTAssertEqual(metadata.size, 2_000_000_000)
    }
    
    // MARK: - Helpers
    
    private func createNetworkItem(
        id: UUID = UUID(),
        name: String,
        path: String = "/test/path",
        isDirectory: Bool = false,
        size: Int64? = 1_000_000,
        modifiedDate: Date? = nil,
        protocol: NetworkProtocol = .smb,
        serverID: UUID = UUID()
    ) -> NetworkItem {
        NetworkItem(
            id: id,
            name: name,
            path: path,
            isDirectory: isDirectory,
            size: size,
            modifiedDate: modifiedDate,
            protocol: `protocol`,
            serverID: serverID
        )
    }
}

// MARK: - NetworkProtocol Tests

final class NetworkProtocolTests: XCTestCase {
    
    // MARK: - Protocol Display Names
    
    func testSMBDisplayName() {
        XCTAssertEqual(NetworkProtocol.smb.rawValue, "SMB")
    }
    
    func testNFSDisplayName() {
        XCTAssertEqual(NetworkProtocol.nfs.rawValue, "NFS")
    }
    
    func testWebDAVDisplayName() {
        XCTAssertEqual(NetworkProtocol.webdav.rawValue, "WebDAV")
    }
    
    func testDLNADisplayName() {
        XCTAssertEqual(NetworkProtocol.dlna.rawValue, "DLNA/UPnP")
    }
    
    // MARK: - Protocol Icons
    
    func testSMBIcon() {
        XCTAssertEqual(NetworkProtocol.smb.icon, "server.rack")
    }
    
    func testNFSIcon() {
        XCTAssertEqual(NetworkProtocol.nfs.icon, "network")
    }
    
    func testWebDAVIcon() {
        XCTAssertEqual(NetworkProtocol.webdav.icon, "globe")
    }
    
    func testDLNAIcon() {
        XCTAssertEqual(NetworkProtocol.dlna.icon, "antenna.radiowaves.left.and.right")
    }
    
    // MARK: - Protocol Descriptions
    
    func testSMBDescription() {
        XCTAssertEqual(NetworkProtocol.smb.description, "Windows/macOS file sharing")
    }
    
    func testNFSDescription() {
        XCTAssertEqual(NetworkProtocol.nfs.description, "Linux/Unix network filesystem")
    }
    
    func testWebDAVDescription() {
        XCTAssertEqual(NetworkProtocol.webdav.description, "HTTP-based web folders")
    }
    
    func testDLNADescription() {
        XCTAssertEqual(NetworkProtocol.dlna.description, "Media server discovery")
    }
    
    // MARK: - Protocol CaseIterable
    
    func testProtocolCaseIterableCount() {
        XCTAssertEqual(NetworkProtocol.allCases.count, 4)
    }
}

// MARK: - NetworkStorageError Tests

final class NetworkStorageErrorTests: XCTestCase {
    
    func testConnectionFailedErrorDescription() {
        let error = NetworkStorageError.connectionFailed("Timeout")
        
        XCTAssertTrue(error.localizedDescription.contains("Connection failed"))
        XCTAssertTrue(error.localizedDescription.contains("Timeout"))
    }
    
    func testAuthenticationFailedErrorDescription() {
        let error = NetworkStorageError.authenticationFailed
        
        XCTAssertTrue(error.localizedDescription.contains("Authentication failed"))
    }
    
    func testServerNotFoundErrorDescription() {
        let error = NetworkStorageError.serverNotFound
        
        XCTAssertTrue(error.localizedDescription.contains("Server not found"))
    }
    
    func testPathNotFoundErrorDescription() {
        let error = NetworkStorageError.pathNotFound
        
        XCTAssertTrue(error.localizedDescription.contains("Path not found"))
    }
    
    func testMountFailedErrorDescription() {
        let error = NetworkStorageError.mountFailed("Permission denied")
        
        XCTAssertTrue(error.localizedDescription.contains("Failed to mount"))
        XCTAssertTrue(error.localizedDescription.contains("Permission denied"))
    }
    
    func testUnmountFailedErrorDescription() {
        let error = NetworkStorageError.unmountFailed
        
        XCTAssertTrue(error.localizedDescription.contains("Failed to unmount"))
    }
    
    func testCredentialNotFoundErrorDescription() {
        let error = NetworkStorageError.credentialNotFound
        
        XCTAssertTrue(error.localizedDescription.contains("credentials not found"))
    }
    
    func testTimeoutErrorDescription() {
        let error = NetworkStorageError.timeout
        
        XCTAssertTrue(error.localizedDescription.contains("timed out"))
    }
    
    func testUnsupportedProtocolErrorDescription() {
        let error = NetworkStorageError.unsupportedProtocol
        
        XCTAssertTrue(error.localizedDescription.contains("not supported"))
    }
}

// MARK: - NetworkServer Tests

final class NetworkServerTests: XCTestCase {
    
    func testServerCreation() {
        let server = NetworkServer(
            id: UUID(),
            name: "Test NAS",
            address: "192.168.1.100",
            port: 445,
            protocol: .smb,
            share: "Videos",
            isConnected: false,
            lastConnected: nil,
            credentialSaved: true
        )
        
        XCTAssertEqual(server.name, "Test NAS")
        XCTAssertEqual(server.address, "192.168.1.100")
        XCTAssertEqual(server.port, 445)
        XCTAssertEqual(server.protocol, .smb)
    }
    
    func testServerSMBURL() {
        let server = NetworkServer(
            id: UUID(),
            name: "Test",
            address: "192.168.1.100",
            port: 445,
            protocol: .smb,
            share: "Movies",
            isConnected: false,
            lastConnected: nil,
            credentialSaved: false
        )
        
        XCTAssertEqual(server.url?.absoluteString, "smb://192.168.1.100/Movies")
    }
    
    func testServerNFSURL() {
        let server = NetworkServer(
            id: UUID(),
            name: "Test",
            address: "192.168.1.100",
            port: 2049,
            protocol: .nfs,
            share: "/volume1/movies",
            isConnected: false,
            lastConnected: nil,
            credentialSaved: false
        )
        
        XCTAssertEqual(server.url?.absoluteString, "nfs://192.168.1.100//volume1/movies")
    }
    
    func testServerWebDAVHTTPSURL() {
        let server = NetworkServer(
            id: UUID(),
            name: "Test",
            address: "192.168.1.100",
            port: 443,
            protocol: .webdav,
            share: nil,
            isConnected: false,
            lastConnected: nil,
            credentialSaved: false
        )
        
        XCTAssertEqual(server.url?.absoluteString, "https://192.168.1.100:443")
    }
    
    func testServerWebDAVHTTPURL() {
        let server = NetworkServer(
            id: UUID(),
            name: "Test",
            address: "192.168.1.100",
            port: 8080,
            protocol: .webdav,
            share: nil,
            isConnected: false,
            lastConnected: nil,
            credentialSaved: false
        )
        
        XCTAssertEqual(server.url?.absoluteString, "http://192.168.1.100:8080")
    }
    
    func testServerLocation() {
        let server = NetworkServer(
            id: UUID(),
            name: "Test",
            address: "192.168.1.100",
            port: 445,
            protocol: .smb,
            share: nil,
            isConnected: false,
            lastConnected: nil,
            credentialSaved: false
        )
        
        XCTAssertEqual(server.location, "192.168.1.100:445")
    }
    
    func testServerHashable() {
        let id = UUID()
        let server1 = NetworkServer(
            id: id,
            name: "Test",
            address: "192.168.1.100",
            port: 445,
            protocol: .smb,
            share: nil,
            isConnected: false,
            lastConnected: nil,
            credentialSaved: false
        )
        
        let server2 = NetworkServer(
            id: id,
            name: "Test",
            address: "192.168.1.100",
            port: 445,
            protocol: .smb,
            share: nil,
            isConnected: false,
            lastConnected: nil,
            credentialSaved: false
        )
        
        XCTAssertEqual(server1.hashValue, server2.hashValue)
    }
}
