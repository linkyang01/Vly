import SwiftUI

// MARK: - Network Storage View

/// Main view for network storage management
struct NetworkStorageView: View {
    @StateObject var viewModel = NetworkStorageViewModel()
    @State private var selectedServer: NetworkServer?
    @State private var showingAddServer = false
    @State private var showingCredentialPrompt = false
    @State private var pendingServerForAuth: NetworkServer?
    
    var body: some View {
        NavigationSplitView {
            serverListView
        } detail: {
            if let server = selectedServer {
                NetworkBrowserView(server: server)
            } else {
                emptyStateView
            }
        }
        .task {
            await viewModel.discoverAll()
        }
        .sheet(isPresented: $showingAddServer) {
            AddServerView { server in
                viewModel.addManualServer(server)
                selectedServer = server
            }
        }
        .sheet(isPresented: $showingCredentialPrompt) {
            if let server = pendingServerForAuth {
                CredentialInputView { credential in
                    Task {
                        try? await viewModel.connect(to: server, credential: credential)
                    }
                }
            }
        }
    }
    
    // MARK: - Server List
    
    private var serverListView: some View {
        List(selection: $selectedServer) {
            Section("Connected") {
                if viewModel.connectedServers.isEmpty {
                    Text("No connected servers")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(viewModel.connectedServers) { server in
                        ServerRowView(server: server)
                            .tag(server)
                    }
                    .onDelete { indexSet in
                        deleteServers(at: indexSet, from: viewModel.connectedServers)
                    }
                }
            }
            
            Section("Discovered") {
                if viewModel.isDiscovering {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                        Text("Searching...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if viewModel.discoveredServers.isEmpty && !viewModel.isDiscovering {
                    Text("No servers found")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(viewModel.discoveredServers) { server in
                        ServerRowView(server: server)
                            .tag(server)
                            .onTapGesture {
                                connectToServer(server)
                            }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Network")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddServer = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            #if os(iOS)
            ToolbarItem(placement: .bottomElevation) {
                Button {
                    Task {
                        await viewModel.discoverAll()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isDiscovering)
            }
            #endif
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "network")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Select a Server")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Browse network shares to access your video library from network storage.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                showingAddServer = true
            } label: {
                Label("Add Server", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Actions
    
    private func connectToServer(_ server: NetworkServer) {
        // Check if credentials are needed
        if server.`protocol` == .smb || server.`protocol` == .webdav {
            if let _ = viewModel.getCredential(for: server) {
                // Try to connect with saved credentials
                Task {
                    try? await viewModel.connect(to: server)
                    if viewModel.selectedServer == nil {
                        // Connection failed, prompt for credentials
                        pendingServerForAuth = server
                        showingCredentialPrompt = true
                    }
                }
            } else {
                // Prompt for credentials
                pendingServerForAuth = server
                showingCredentialPrompt = true
            }
        } else {
            // No credentials needed
            Task {
                try? await viewModel.connect(to: server)
            }
        }
    }
    
    private func deleteServers(at indexSet: IndexSet, from servers: [NetworkServer]) {
        for index in indexSet {
            let server = servers[index]
            Task {
                try? await viewModel.disconnect(from: server)
            }
        }
    }
}

// MARK: - Server Row View

struct ServerRowView: View {
    let server: NetworkServer
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: server.`protocol`.icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(server.name)
                    .font(.body)
                
                HStack(spacing: 4) {
                    Text(server.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let share = server.share {
                        Text("/\(share)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if server.isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            if server.credentialSaved {
                Image(systemName: "key.fill")
                    .foregroundColor(.orange)
                    .font(.caption2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    NetworkStorageView()
}
