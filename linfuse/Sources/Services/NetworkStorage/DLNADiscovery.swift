import Foundation
import Darwin

// MARK: - DLNA/UPnP Discovery

/// DLNA/UPnP media server discovery using SSDP
class DLNADiscovery {
    
    private var searchResults: [DLNAServer] = []
    
    // MARK: - Discovery
    
    func discoverServers(timeout: TimeInterval = 5.0) async -> [DLNAServer] {
        var servers: [DLNAServer] = []
        
        // SSDP M-SEARCH request
        let message = """
        M-SEARCH * HTTP/1.1
        HOST: 239.255.255.250:1900
        MAN: "ssdp:discover"
        MX: \(Int(timeout))
        ST: ssdp:all
        \r\n
        """
        
        guard let messageData = message.data(using: .utf8) else {
            return servers
        }
        
        // Create UDP socket
        let socket = createUDPSocket()
        guard socket >= 0 else {
            return servers
        }
        
        // Set socket options for broadcasting
        var reuse: Int32 = 1
        setsockopt(socket, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))
        
        var broadcast: Int32 = 1
        setsockopt(socket, SOL_SOCKET, SO_BROADCAST, &broadcast, socklen_t(MemoryLayout<Int32>.size))
        
        // Prepare address for broadcast
        var address = sockaddr_in(
            sin_len: UInt8(MemoryLayout<sockaddr_in>.size),
            sin_family: UInt8(AF_INET),
            sin_port: UInt16(1900).bigEndian,
            sin_addr: in_addr(s_addr: inet_addr("239.255.255.250")),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
        )
        
        let addressData = withUnsafePointer(to: &address) { pointer in
            Data(bytes: pointer, count: MemoryLayout<sockaddr_in>.size)
        }
        
        // Send SSDP discovery request
        addressData.withUnsafeBytes { ptr in
            let addrPtr = ptr.baseAddress?.assumingMemoryBound(to: sockaddr.self)
            _ = sendto(socket, messageData.withUnsafeBytes { $0.baseAddress }, messageData.count, 0, addrPtr, socklen_t(addressData.count))
        }
        
        // Wait for responses with polling instead of select()
        let endTime = Date().addingTimeInterval(timeout)
        var responseData = Data(repeating: 0, count: 4096)
        
        while Date() < endTime {
            var tv = timeval(tv_sec: 0, tv_usec: 200000) // 0.2 second
            var timeoutStruct = tv
            
            var readfds = fd_set()
            withUnsafeMutablePointer(to: &readfds) { ptr in
                let fd_ptr = UnsafeMutableRawPointer(ptr).assumingMemoryBound(to: Int32.self)
                fd_ptr.pointee = 0
            }
            
            // Set the socket in the fd_set
            withUnsafeMutablePointer(to: &readfds) { ptr in
                let fd_ptr = UnsafeMutableRawPointer(ptr).assumingMemoryBound(to: Int32.self)
                fd_ptr.pointee = socket
            }
            
            let selectResult = withUnsafeMutablePointer(to: &timeoutStruct) { tvPtr in
                withUnsafeMutablePointer(to: &readfds) { fdsPtr in
                    select(socket + 1, fdsPtr, nil, nil, tvPtr)
                }
            }
            
            if selectResult > 0 {
                var responseAddress = sockaddr_in()
                var responseAddressLength = socklen_t(MemoryLayout<sockaddr_in>.size)
                
                let bytesRead = responseData.withUnsafeMutableBytes { mutablePtr in
                    withUnsafeMutablePointer(to: &responseAddress) { addrPtr in
                        addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
                            recvfrom(socket, mutablePtr.baseAddress, responseData.count, 0, sockaddrPtr, &responseAddressLength)
                        }
                    }
                }
                
                if bytesRead > 0 {
                    responseData.count = bytesRead
                    if let server = parseSSDOResponse(responseData, from: responseAddress) {
                        if !servers.contains(where: { $0.location == server.location }) {
                            servers.append(server)
                        }
                    }
                    responseData = Data(repeating: 0, count: 4096)
                }
            }
            
            // Small delay to prevent CPU spinning
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        }
        
        close(socket)
        
        return servers
    }
    
    private func parseSSDOResponse(_ data: Data, from address: sockaddr_in) -> DLNAServer? {
        guard let responseString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        // Parse SSDP response headers
        var location: String?
        var server: String?
        var usn: String?
        
        let lines = responseString.components(separatedBy: "\r\n")
        for line in lines {
            let components = line.components(separatedBy: ": ")
            guard components.count >= 2 else { continue }
            
            let key = components[0].lowercased()
            let value = components.dropFirst().joined(separator: ": ")
            
            switch key {
            case "location":
                location = value
            case "server":
                server = value
            case "usn":
                usn = value
            default:
                break
            }
        }
        
        guard let locationURL = location, let url = URL(string: locationURL) else {
            return nil
        }
        
        var ipAddress = ""
        var addrCopy = address
        withUnsafePointer(to: &addrCopy) { ptr in
            let addr = ptr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
            ipAddress = String(cString: inet_ntoa(addr.sin_addr))
        }
        
        return DLNAServer(
            id: UUID(),
            name: server ?? "DLNA Server",
            location: locationURL,
            ipAddress: ipAddress,
            port: Int(address.sin_port.bigEndian),
            usn: usn,
            server: server
        )
    }
    
    private func createUDPSocket() -> Int32 {
        let socket = Darwin.socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        return socket
    }
    
    // MARK: - Browsing
    
    func browse(server: DLNAServer, path: String = "0") async throws -> [DLNAItem] {
        // SOAP request to ContentDirectory service
        guard let serverURL = URL(string: server.location) else {
            throw NetworkStorageError.serverNotFound
        }
        
        // First, get device description to find ContentDirectory service
        let (descriptionData, _) = try await URLSession.shared.data(from: serverURL)
        
        // Parse device description to find ContentDirectory service URL
        // Simplified - in production use proper XML parsing
        
        // Example SOAP request
        let soapBody = """
        <?xml version="1.0" encoding="utf-8"?>
        <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
            <s:Body>
                <u:Browse xmlns:u="urn:schemas-upnp-org:service:ContentDirectory:1">
                    <ObjectID>\(path)</ObjectID>
                    <BrowseFlag>BrowseDirectChildren</BrowseFlag>
                    <Filter>*</Filter>
                    <StartingIndex>0</StartingIndex>
                    <RequestedCount>100</RequestedCount>
                    <SortCriteria></SortCriteria>
                </u:Browse>
            </s:Body>
        </s:Envelope>
        """
        
        // This is a simplified implementation
        // In production, need to:
        // 1. Parse device XML to find ContentDirectory service
        // 2. Get service description for SOAP action URLs
        // 3. Send proper SOAP request
        
        return []
    }
}

// MARK: - Supporting Types

struct DLNAServer: Identifiable, Codable {
    let id: UUID
    let name: String
    let location: String
    let ipAddress: String
    let port: Int
    let usn: String?
    let server: String?
}

struct DLNAItem: Identifiable, Codable {
    let id: UUID
    let objectID: String
    let title: String
    let path: String
    let isDirectory: Bool
    let size: Int64?
    let duration: TimeInterval?
    let resolution: String?
    let mimeType: String?
    
    var streamingURL: URL? {
        // Return URL for DLNA streaming
        URL(string: path)
    }
}
