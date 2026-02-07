import SwiftUI

/// 刮削设置视图
struct ScrapingSettingsView: View {
    @AppStorage("scrapeEnabled") private var scrapeEnabled = true
    @AppStorage("scrapeOnImport") private var scrapeOnImport = true
    @AppStorage("preferLocalMetadata") private var preferLocalMetadata = true
    @AppStorage("scrapeMissingThumbnails") private var scrapeMissingThumbnails = true
    @AppStorage("autoScrapeNewFiles") private var autoScrapeNewFiles = false
    @AppStorage("scrapeLanguage") private var scrapeLanguage = "zh-CN"
    @AppStorage("preferTitleLanguage") private var preferTitleLanguage = "original"
    
    @State private var showAPIKeyInput = false
    @State private var apiKey: String = ""
    
    var body: some View {
        Form {
            // General Settings
            Section {
                Toggle("Enable Metadata Scraping", isOn: $scrapeEnabled)
                Toggle("Auto-scrape on Import", isOn: $scrapeOnImport)
                Toggle("Prefer Local Metadata", isOn: $preferLocalMetadata)
                Toggle("Scrape Missing Thumbnails", isOn: $scrapeMissingThumbnails)
                Toggle("Auto-scrape New Files", isOn: $autoScrapeNewFiles)
            } header: {
                Text("General")
            } footer: {
                Text("Auto-scrape new files when they're added to your library")
            }
            
            // Language Settings
            Section {
                Picker("Scrape Language", selection: $scrapeLanguage) {
                    Text("Chinese").tag("zh-CN")
                    Text("English").tag("en-US")
                    Text("Japanese").tag("ja-JP")
                    Text("Korean").tag("ko-KR")
                }
                
                Picker("Title Language", selection: $preferTitleLanguage) {
                    Text("Original Title").tag("original")
                    Text("Localized Title").tag("localized")
                    Text("Chinese Title").tag("zh-CN")
                }
            } header: {
                Text("Language")
            } footer: {
                Text("Choose which language to prefer for metadata and titles")
            }
            
            // API Key Section
            Section {
                HStack {
                    Label("TMDB API Key", systemImage: "key.fill")
                    
                    Spacer()
                    
                    Button(action: { showAPIKeyInput = true }) {
                        Text(apiKey.isEmpty ? "Configure" : "Edit")
                    }
                }
                
                if !apiKey.isEmpty {
                    HStack {
                        Text("API Key Status")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label("Configured", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            } header: {
                Text("TMDB API")
            } footer: {
                Text("A TMDB API key is required for metadata scraping. Get one from https://www.themoviedb.org/settings/api")
            }
            
            // Cache Section
            Section {
                HStack {
                    Label("Metadata Cache", systemImage: "internaldrive.fill")
                    
                    Spacer()
                    
                    Button("Clear Cache") {
                        clearMetadataCache()
                    }
                    .buttonStyle(.bordered)
                }
                
                HStack {
                    Text("Cache Size")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(cacheSize)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Cache")
            }
            
            // Reset Section
            Section {
                Button(role: .destructive, action: resetToDefaults) {
                    Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $showAPIKeyInput) {
            APIKeyInputSheet(apiKey: $apiKey)
        }
        .onAppear {
            loadAPIKey()
        }
    }
    
    // MARK: - Private Methods
    
    private var cacheSize: String {
        let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MetadataCache")
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: cachePath,
                includingPropertiesForKeys: [.fileSizeKey],
                options: .skipsHiddenFiles
            )
            
            var totalSize: Int64 = 0
            for url in contents {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                if let size = attributes[.size] as? Int64 {
                    totalSize += size
                }
            }
            
            return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
        } catch {
            return "Unknown"
        }
    }
    
    private func loadAPIKey() {
        apiKey = UserDefaults.standard.string(forKey: "TMDB_API_KEY") ?? ""
    }
    
    private func clearMetadataCache() {
        let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MetadataCache")
        
        try? FileManager.default.removeItem(at: cachePath)
    }
    
    private func resetToDefaults() {
        scrapeEnabled = true
        scrapeOnImport = true
        preferLocalMetadata = true
        scrapeMissingThumbnails = true
        autoScrapeNewFiles = false
        scrapeLanguage = "zh-CN"
        preferTitleLanguage = "original"
    }
}

/// API Key 输入表单
struct APIKeyInputSheet: View {
    @Binding var apiKey: String
    @Environment(\.dismiss) private var dismiss
    @State private var inputKey: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "key.fill")
                    .font(.title)
                    .foregroundColor(.accentColor)
                
                Text("Configure TMDB API Key")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Input
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                SecureField("Enter your TMDB API key", text: $inputKey)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                if showError {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Info
            Text("Get your API key from https://www.themoviedb.org/settings/api")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Actions
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Button("Save") {
                    saveAPIKey()
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(inputKey.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 450, height: 300)
        .onAppear {
            inputKey = apiKey
        }
    }
    
    private func saveAPIKey() {
        guard !inputKey.isEmpty else {
            showError = true
            errorMessage = "API key cannot be empty"
            return
        }
        
        // 验证 API key 格式（基本检查）
        guard inputKey.count >= 32 else {
            showError = true
            errorMessage = "API key seems too short. Please check."
            return
        }
        
        UserDefaults.standard.set(inputKey, forKey: "TMDB_API_KEY")
        apiKey = inputKey
        dismiss()
    }
}

#Preview {
    ScrapingSettingsView()
        .frame(width: 500)
}
