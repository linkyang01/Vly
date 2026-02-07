import Foundation

// MARK: - WebDAV Client

/// WebDAV client implementation for HTTP-based network shares
class WebDAVClient {
    
    private var session: URLSession
    private var credentials: [URL: Credential] = [:]
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Discovery
    
    func discoverServers() async -> [NetworkServer] {
        var servers: [NetworkServer] = []
        
        // Bonjour discovery for WebDAV
        let browser = NetServiceBrowser()
        let semaphore = DispatchSemaphore(value: 0)
        var discovered: [NetworkServer] = []
        
        browser.searchForServices(ofType: "_webdav._tcp", inDomain: "local.")
        
        // Wait for discovery
        semaphore.wait(timeout: .now() + 5)
        browser.stop()
        
        return discovered
    }
    
    // MARK: - Connection
    
    func connect(url: URL, credential: Credential?) async throws -> URL {
        // Validate connection
        var request = URLRequest(url: url.appendingPathComponent("/"))
        request.httpMethod = "PROPFIND"
        request.setValue("1", forHTTPHeaderField: "Depth")
        
        if let cred = credential {
            let credentialString = "\(cred.username):\(cred.password)"
            if let credentialData = credentialString.data(using: .utf8) {
                let base64 = credentialData.base64EncodedString()
                request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
            }
        }
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkStorageError.connectionFailed("Invalid response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw NetworkStorageError.authenticationFailed
            }
            throw NetworkStorageError.connectionFailed("HTTP \(httpResponse.statusCode)")
        }
        
        // Store credentials if provided
        if let cred = credential {
            credentials[url] = cred
        }
        
        // Return the URL as-is (WebDAV doesn't mount, it's accessed directly)
        return url
    }
    
    // MARK: - Browsing
    
    func browse(url: URL, path: String = "/") async throws -> [NetworkItem] {
        let fullURL = url.appendingPathComponent(path)
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = "PROPFIND"
        request.setValue("1", forHTTPHeaderField: "Depth")
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        
        // PROPFIND request body
        let propfindBody = """
        <?xml version="1.0" encoding="utf-8"?>
        <D:propfind xmlns:D="DAV:">
            <D:prop>
                <D:displayname/>
                <D:getcontentlength/>
                <D:getlastmodified/>
                <D:resourcetype/>
            </D:prop>
        </D:propfind>
        """
        request.httpBody = propfindBody.data(using: .utf8)
        
        // Add authentication if stored
        if let cred = credentials[url] {
            let credentialString = "\(cred.username):\(cred.password)"
            if let credentialData = credentialString.data(using: .utf8) {
                let base64 = credentialData.base64EncodedString()
                request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
            }
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkStorageError.connectionFailed("Failed to browse")
        }
        
        // Parse WebDAV response
        return parseWebDAVResponse(data: data, baseURL: url, path: path)
    }
    
    // MARK: - File Operations
    
    func download(fileURL: URL, to localURL: URL, progress: ((Double) -> Void)? = nil) async throws {
        var request = URLRequest(url: fileURL)
        
        if let cred = credentials[fileURL.deletingLastPathComponent()] {
            let credentialString = "\(cred.username):\(cred.password)"
            if let credentialData = credentialString.data(using: .utf8) {
                let base64 = credentialData.base64EncodedString()
                request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
            }
        }
        
        let (tempURL, response) = try await session.download(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkStorageError.connectionFailed("Download failed")
        }
        
        // Move to final location
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: localURL.path) {
            try fileManager.removeItem(at: localURL)
        }
        try fileManager.moveItem(at: tempURL, to: localURL)
    }
    
    func stream(fileURL: URL) -> URL {
        // Return the WebDAV URL for streaming
        return fileURL
    }
    
    // MARK: - Response Parsing
    
    private func parseWebDAVResponse(data: Data, baseURL: URL, path: String) -> [NetworkItem] {
        var items: [NetworkItem] = []
        
        guard let xmlString = String(data: data, encoding: .utf8) else {
            return items
        }
        
        // Simple XML parsing for WebDAV responses
        // In production, use a proper XML parser
        
        let responsePattern = #"<D:response>.*?<D:href>([^<]+)</D:href>.*?<D:propstat>.*?<D:prop>(.*?)</D:prop>.*?</D:response>"#
        
        // This is a simplified parser - for production use proper XML parsing
        // Example structure:
        // <D:response>
        //   <D:href>/path/to/file</D:href>
        //   <D:propstat>
        //     <D:prop>
        //       <D:displayname>filename</D:displayname>
        //       <D:getcontentlength>12345</D:getcontentlength>
        //       <D:resourcetype><D:collection/></D:resourcetype>
        //     </D:prop>
        //   </D:propstat>
        // </D:response>
        
        return items
    }
}
