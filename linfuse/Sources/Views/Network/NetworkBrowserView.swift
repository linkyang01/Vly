import SwiftUI

// MARK: - Network Browser View

/// View for browsing network share contents
struct NetworkBrowserView: View {
    @StateObject var viewModel: NetworkBrowserViewModel
    @State private var viewMode: BrowserViewMode = .grid
    
    init(server: NetworkServer) {
        _viewModel = StateObject(wrappedValue: NetworkBrowserViewModel(server: server))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            browserToolbar
            
            Divider()
            
            // Content
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(error)
            } else if viewModel.currentItems.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .navigationTitle(viewModel.currentDirectoryName)
        .task {
            await viewModel.browse()
        }
    }
    
    // MARK: - Toolbar
    
    private var browserToolbar: some View {
        HStack(spacing: 16) {
            // Back button
            Button {
                Task {
                    await viewModel.goBack()
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(!viewModel.canGoBack)
            
            // Forward button (for future implementation)
            Button {
                // Forward navigation
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(true)
            
            // Root button
            Button {
                Task {
                    await viewModel.goToRoot()
                }
            } label: {
                Image(systemName: "house")
            }
            .disabled(!viewModel.canGoToRoot)
            
            Divider()
                .frame(height: 20)
            
            // Path breadcrumb
            Text(viewModel.currentPath)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer()
            
            // Refresh
            Button {
                Task {
                    await viewModel.refresh()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            
            // View mode toggle
            Picker("View", selection: $viewMode) {
                Image(systemName: "square.grid.2x2").tag(BrowserViewMode.grid)
                Image(systemName: "list.bullet").tag(BrowserViewMode.list)
            }
            .pickerStyle(.segmented)
            .frame(width: 80)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Content Views
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ error: NetworkStorageError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task {
                    await viewModel.refresh()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Empty Folder")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("No files in this folder")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var contentView: some View {
        Group {
            switch viewMode {
            case .grid:
                gridView
            case .list:
                listView
            }
        }
    }
    
    // MARK: - Grid View
    
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.currentItems) { item in
                    NetworkItemGridCell(item: item)
                        .onTapGesture {
                            Task {
                                await viewModel.navigateTo(item)
                            }
                        }
                }
            }
            .padding()
        }
    }
    
    // MARK: - List View
    
    private var listView: some View {
        List(viewModel.currentItems) { item in
            NetworkItemListCell(item: item)
                .onTapGesture {
                    if item.isDirectory {
                        Task {
                            await viewModel.navigateTo(item)
                        }
                    }
                }
        }
        .listStyle(.plain)
    }
}

// MARK: - View Mode

enum BrowserViewMode {
    case grid
    case list
}

// MARK: - Grid Cell

struct NetworkItemGridCell: View {
    let item: NetworkItem
    
    var body: some View {
        VStack(spacing: 8) {
            // Thumbnail or icon
            ZStack {
                if item.isDirectory {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                } else if item.isVideo {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 100)
                        .overlay(
                            Image(systemName: "film")
                                .font(.title)
                                .foregroundColor(.secondary)
                        )
                } else {
                    Image(systemName: "doc")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                }
            }
            
            // Name
            Text(item.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            // Size
            if let size = item.size, !item.isDirectory {
                Text(item.formattedSize)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 150)
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - List Cell

struct NetworkItemListCell: View {
    let item: NetworkItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: iconForItem)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 32)
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    if item.isDirectory {
                        Text("Folder")
                            .font(.caption)
                            .foregroundColor(.blue)
                    } else if item.isVideo {
                        Text("Video")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    if let size = item.size {
                        Text(item.formattedSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Modified date
            if let date = item.modifiedDate {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var iconForItem: String {
        if item.isDirectory {
            return "folder.fill"
        } else if item.isVideo {
            return "film"
        } else {
            return "doc"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NetworkBrowserView(server: NetworkServer(
            id: UUID(),
            name: "Test Server",
            address: "192.168.1.100",
            port: 445,
            protocol: .smb,
            share: "Videos",
            isConnected: true,
            lastConnected: Date(),
            credentialSaved: false
        ))
    }
}
