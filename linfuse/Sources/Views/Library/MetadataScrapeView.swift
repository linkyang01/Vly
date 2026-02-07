import SwiftUI

struct MetadataScrapeView: View {
    @State private var isScraping = false
    @State private var progress: Double = 0
    @State private var currentMovie: String = ""
    @State private var scrapedCount: Int = 0
    @State private var totalCount: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .padding(.horizontal)
            
            HStack {
                if !currentMovie.isEmpty {
                    Text(currentMovie)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Text("\(scrapedCount)/\(totalCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Stats
            HStack(spacing: 40) {
                VStack {
                    Text("\(scrapedCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("0")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Failed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(totalCount - scrapedCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            Spacer()
            
            // Actions
            HStack {
                Button("Stop") {
                    stopScraping()
                }
                .disabled(!isScraping)
                
                Spacer()
                
                Button("Start Scraping") {
                    startScraping()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isScraping)
            }
        }
        .padding()
        .navigationTitle("Fetch Metadata")
    }
    
    private func startScraping() {
        isScraping = true
        totalCount = 50
        scrapedCount = 0
        
        for i in 0..<50 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                currentMovie = "Movie_\(i + 1)"
                scrapedCount = i + 1
                progress = Double(scrapedCount) / Double(totalCount)
                
                if scrapedCount >= totalCount {
                    isScraping = false
                }
            }
        }
    }
    
    private func stopScraping() {
        isScraping = false
    }
}

#Preview {
    NavigationStack {
        MetadataScrapeView()
    }
}
