import XCTest
@testable import linfuse

final class NetworkModelsTests: XCTestCase {
    // MARK: - Server Tests
    
    func testServerCreation() {
        let server = Server(
            id: UUID(),
            name: "My NAS",
            type: .smb,
            address: "192.168.1.100",
            port: 445,
            username: "user",
            password: nil,
            shareName: "Videos"
        )
        
        XCTAssertEqual(server.name, "My NAS")
        XCTAssertEqual(server.type, .smb)
        XCTAssertEqual(server.address, "192.168.1.100")
        XCTAssertEqual(server.port, 445)
    }
    
    func testServerURL() {
        let smbServer = Server(
            id: UUID(),
            name: "Test SMB",
            type: .smb,
            address: "192.168.1.100",
            port: 445
        )
        
        XCTAssertEqual(smbServer.url?.absoluteString, "smb://192.168.1.100:445")
        
        let nfsServer = Server(
            id: UUID(),
            name: "Test NFS",
            type: .nfs,
            address: "192.168.1.100",
            port: 2049
        )
        
        XCTAssertEqual(nfsServer.url?.absoluteString, "nfs://192.168.1.100:2049")
    }
    
    // MARK: - NetworkFile Tests
    
    func testNetworkFileCreation() {
        let file = NetworkFile(
            id: UUID(),
            name: "Movie.mkv",
            path: "/share/movies/Movie.mkv",
            isDirectory: false,
            size: 2_000_000_000,
            modifiedDate: Date()
        )
        
        XCTAssertEqual(file.name, "Movie.mkv")
        XCTAssertFalse(file.isDirectory)
        XCTAssertEqual(file.size, 2_000_000_000)
    }
    
    func testNetworkFileFormattedSize() {
        let smallFile = NetworkFile(
            id: UUID(),
            name: "small.txt",
            path: "/small.txt",
            isDirectory: false,
            size: 500,
            modifiedDate: nil
        )
        
        XCTAssertEqual(smallFile.formattedSize, "500 bytes")
        
        let largeFile = NetworkFile(
            id: UUID(),
            name: "movie.mkv",
            path: "/movie.mkv",
            isDirectory: false,
            size: 5_000_000_000,
            modifiedDate: nil
        )
        
        XCTAssertEqual(largeFile.formattedSize, "5 GB")
    }
    
    // MARK: - ConnectionStatus Tests
    
    func testConnectionStatus() {
        let connecting = ConnectionStatus.connecting
        XCTAssertTrue(connecting.isConnecting)
        XCTAssertFalse(connecting.isConnected)
        XCTAssertFalse(connecting.isDisconnected)
        
        let connected = ConnectionStatus.connected
        XCTAssertFalse(connected.isConnecting)
        XCTAssertTrue(connected.isConnected)
        XCTAssertFalse(connected.isDisconnected)
        
        let disconnected = ConnectionStatus.disconnected
        XCTAssertFalse(disconnected.isConnecting)
        XCTAssertFalse(disconnected.isConnected)
        XCTAssertTrue(disconnected.isDisconnected)
    }
    
    // MARK: - ServerType Tests
    
    func testServerTypeDisplayName() {
        XCTAssertEqual(ServerType.smb.displayName, "SMB/CIFS")
        XCTAssertEqual(ServerType.nfs.displayName, "NFS")
        XCTAssertEqual(ServerType.webdav.displayName, "WebDAV")
        XCTAssertEqual(ServerType.upnp.displayName, "UPnP/DLNA")
    }
}
