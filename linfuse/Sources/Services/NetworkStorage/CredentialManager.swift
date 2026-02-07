import Foundation
import Security

// MARK: - Credential Manager

/// Manages secure storage of network credentials using Keychain
class CredentialManager {
    static let shared = CredentialManager()
    
    private let service = "com.linfuse.credentials"
    private let keychain = KeychainHelper()
    
    private init() {}
    
    // MARK: - Save
    
    func save(_ credential: Credential, for identity: ServerIdentity) throws {
        let data = try JSONEncoder().encode(credential)
        
        let key = credentialKey(for: identity)
        try keychain.save(data, for: key, service: service)
    }
    
    // MARK: - Load
    
    func load(for identity: ServerIdentity) throws -> Credential? {
        let key = credentialKey(for: identity)
        guard let data = try keychain.load(for: key, service: service) else {
            return nil
        }
        
        return try JSONDecoder().decode(Credential.self, from: data)
    }
    
    // MARK: - Delete
    
    func delete(for identity: ServerIdentity) throws {
        let key = credentialKey(for: identity)
        try keychain.delete(for: key, service: service)
    }
    
    // MARK: - List
    
    func listIdentities() -> [ServerIdentity] {
        // Query Keychain for all credentials
        // This is a simplified implementation
        return []
    }
    
    // MARK: - Helper
    
    private func credentialKey(for identity: ServerIdentity) -> String {
        "\(identity.protocol.rawValue)-\(identity.address)-\(identity.share ?? "default")"
    }
}

// MARK: - Keychain Helper

private struct KeychainHelper {
    func save(_ data: Data, for key: String, service: String) throws {
        // Delete existing item first
        delete(for: key, service: service)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    func load(for key: String, service: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.loadFailed(status)
        }
        
        return result as? Data
    }
    
    func delete(for key: String, service: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Keychain Error

enum KeychainError: LocalizedError {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Keychain save failed: \(status)"
        case .loadFailed(let status):
            return "Keychain load failed: \(status)"
        case .deleteFailed(let status):
            return "Keychain delete failed: \(status)"
        }
    }
}

// MARK: - Credential Models

struct Credential: Codable {
    let username: String
    let password: String  // Will be encrypted by Keychain
    let domain: String?
    let `protocol`: NetworkProtocol
}

struct ServerIdentity: Codable, Hashable {
    let id: UUID
    let name: String
    let address: String
    let share: String?
    let `protocol`: NetworkProtocol
    
    static func from(_ server: NetworkServer) -> ServerIdentity {
        ServerIdentity(
            id: server.id,
            name: server.name,
            address: server.address,
            share: server.share,
            `protocol`: server.`protocol`
        )
    }
}
