import SwiftUI

// MARK: - Add Server View

/// View for manually adding a network server
struct AddServerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProtocol: NetworkProtocol = .smb
    @State private var serverName = ""
    @State private var address = ""
    @State private var port = ""
    @State private var share = ""
    @State private var testingConnection = false
    @State private var connectionStatus: ConnectionStatus = .idle
    @State private var errorMessage: String?
    
    let onAdd: (NetworkServer) -> Void
    
    enum ConnectionStatus {
        case idle
        case testing
        case success
        case failure
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Server")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Form
            Form {
                Section("Protocol") {
                    Picker("Protocol", selection: $selectedProtocol) {
                        ForEach(NetworkProtocol.allCases) { protocolItem in
                            Label(protocolItem.rawValue, systemImage: protocolItem.icon)
                                .tag(protocolItem)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text(selectedProtocol.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Server Details") {
                    TextField("Display Name", text: $serverName)
                        #if os(macOS)
                        .textContentType(.name)
                        #endif
                    
                    HStack {
                        TextField("Address", text: $address)
                            #if os(macOS)
                            .textContentType(.URL)
                            #endif
                            .disableAutocorrection(true)
                        
                        Text(":")
                            .foregroundColor(.secondary)
                        
                        TextField("Port", text: $port)
                            .frame(width: 60)
                            .disableAutocorrection(true)
                    }
                    
                    if selectedProtocol == .smb || selectedProtocol == .nfs {
                        TextField("Share/Export Path", text: $share)
                            .disableAutocorrection(true)
                    }
                }
                
                Section {
                    Button {
                        testingConnection
                    } label: {
                        HStack {
                            if connectionStatus == .testing {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "network")
                            }
                            Text("Test Connection")
                        }
                    }
                    .disabled(address.isEmpty || connectionStatus == .testing)
                    
                    if connectionStatus == .success {
                        Label("Connection successful", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if connectionStatus == .failure {
                        Label(errorMessage ?? "Connection failed", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .formStyle(.grouped)
            .padding()
            
            Divider()
            
            // Footer
            HStack {
                Spacer()
                Button("Add Server") {
                    addServer()
                }
                .buttonStyle(.borderedProminent)
                .disabled(address.isEmpty || connectionStatus != .success)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 450, height: 500)
    }
    
    // MARK: - Actions
    
    private func testConnection() {
        connectionStatus = .testing
        errorMessage = nil
        
        Task {
            // Simulate connection test
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // In production, actually test the connection
            if !address.isEmpty {
                await MainActor.run {
                    connectionStatus = .success
                }
            } else {
                await MainActor.run {
                    connectionStatus = .failure
                    errorMessage = "Invalid address"
                }
            }
        }
    }
    
    private func addServer() {
        let server = NetworkServer(
            id: UUID(),
            name: serverName.isEmpty ? address : serverName,
            address: address,
            port: Int(port) ?? defaultPort(for: selectedProtocol),
            protocol: selectedProtocol,
            share: share.isEmpty ? nil : share,
            isConnected: false,
            lastConnected: nil,
            credentialSaved: false
        )
        
        onAdd(server)
        dismiss()
    }
    
    private func defaultPort(for protocol: NetworkProtocol) -> Int {
        switch `protocol` {
        case .smb: return 445
        case .nfs: return 2049
        case .webdav: return 80
        case .dlna: return 0
        }
    }
}

// MARK: - Preview

#Preview {
    AddServerView { server in
        print("Added: \(server.name)")
    }
}
