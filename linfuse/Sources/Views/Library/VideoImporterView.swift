import SwiftUI

struct VideoImporterView: View {
    @State private var selectedFolders: [URL] = []
    @State private var isScanning = false
    @State private var showScanProgress = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Drop zone
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundColor(.accentColor)
                .frame(height: 150)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "folder.badge.plus")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                        
                        Text("Drop folders here or")
                            .foregroundColor(.secondary)
                        
                        Button("Choose Folders...") {
                            selectFolders()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
            
            // Selected folders
            if !selectedFolders.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected Folders (\(selectedFolders.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(selectedFolders, id: \.self) { url in
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.accentColor)
                            Text(url.lastPathComponent)
                                .lineLimit(1)
                            Spacer()
                            Button {
                                removeFolder(url)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack {
                Button("Clear") {
                    selectedFolders.removeAll()
                }
                .disabled(selectedFolders.isEmpty)
                
                Spacer()
                
                Button {
                    startScanning()
                } label: {
                    if isScanning {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Scan for Videos")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedFolders.isEmpty || isScanning)
            }
            .padding()
        }
        .padding()
        .navigationTitle("Add Videos")
        .sheet(isPresented: $showScanProgress) {
            ScanProgressView()
        }
    }
    
    private func selectFolders() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        if panel.runModal() == .OK {
            selectedFolders.append(contentsOf: panel.urls)
        }
    }
    
    private func removeFolder(_ url: URL) {
        selectedFolders.removeAll { $0 == url }
    }
    
    private func startScanning() {
        isScanning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showScanProgress = true
            isScanning = false
        }
    }
}

#Preview {
    NavigationStack {
        VideoImporterView()
    }
}
