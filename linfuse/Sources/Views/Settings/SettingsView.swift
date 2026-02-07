import SwiftUI
import StoreKit

struct SettingsView: View {
    @AppStorage("autoFetchMetadata") private var autoFetchMetadata = true
    @AppStorage("preferredImageQuality") private var preferredImageQuality = "high"
    @AppStorage("enableMonitoring") private var enableMonitoring = true
    @AppStorage("tmdbApiKey") private var tmdbApiKey = ""
    @State private var showingSubscriptionView = false
    
    var body: some View {
        Form {
            Section("Subscription") {
                Button {
                    showingSubscriptionView = true
                } label: {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Manage Subscription")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
            
            Section("General") {
                Toggle("Auto-fetch Metadata", isOn: $autoFetchMetadata)
                Toggle("Enable Folder Monitoring", isOn: $enableMonitoring)
            }
            
            Section("Image Quality") {
                Picker("Preferred Quality:", selection: $preferredImageQuality) {
                    Text("Low").tag("low")
                    Text("Medium").tag("medium")
                    Text("High").tag("high")
                }
                .pickerStyle(.segmented)
            }
            
            Section("TMDB API") {
                HStack {
                    SecureField("API Key", text: $tmdbApiKey)
                    
                    if !tmdbApiKey.isEmpty {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Button {
                    // Show API key info
                } label: {
                    Text("Where to get API key?")
                        .font(.caption)
                }
            }
            
            Section("Data") {
                HStack {
                    Text("Database Location:")
                    Spacer()
                    Text("/Users/user/Library/Application Support/linfuse")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                Button("Clear Cache") {
                    clearCache()
                }
                
                Button("Reset Library", role: .destructive) {
                    resetLibrary()
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("1")
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 500, height: 450)
        .sheet(isPresented: $showingSubscriptionView) {
            SubscriptionManagementView()
        }
    }
    
    private func clearCache() {
        // Clear Kingfisher cache would go here
    }
    
    private func resetLibrary() {
        // Reset library logic would go here
    }
}

#Preview {
    SettingsView()
}
