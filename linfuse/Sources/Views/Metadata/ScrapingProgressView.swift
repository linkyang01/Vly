import SwiftUI

struct ScrapingProgressView: View {
    @State private var progress: Double = 0
    @State private var currentItem: String = ""
    @State private var currentStatusText: String = "Waiting..."
    @State private var completed: Int = 0
    @State private var total: Int = 0
    @State private var successCount: Int = 0
    @State private var failedCount: Int = 0
    @State private var pendingCount: Int = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress bar
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .padding(.horizontal)
            
            // Current item
            if !currentItem.isEmpty {
                Text(currentItem)
                    .font(.headline)
                    .lineLimit(1)
            }
            
            Text(currentStatusText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Stats
            HStack(spacing: 20) {
                StatView(value: completed, label: "Completed", color: .green)
                StatView(value: failedCount, label: "Failed", color: .red)
                StatView(value: pendingCount, label: "Pending", color: .orange)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct StatView: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ScrapingProgressView()
}
