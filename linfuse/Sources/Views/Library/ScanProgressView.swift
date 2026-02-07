import SwiftUI

struct ScanProgressView: View {
    @State private var scanProgress: Double = 0
    @State private var currentFile: String = ""
    @State private var scannedCount: Int = 0
    @State private var totalCount: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: scanProgress)
                .progressViewStyle(.linear)
                .padding(.horizontal)
            
            if !currentFile.isEmpty {
                Text(currentFile)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .padding(.horizontal)
            }
            
            HStack {
                Text("\(scannedCount)/\(totalCount) files")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(scanProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            startSimulation()
        }
    }
    
    private func startSimulation() {
        totalCount = 100
        for i in 0..<100 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                scannedCount = i + 1
                scanProgress = Double(scannedCount) / Double(totalCount)
                currentFile = "movie_\(i + 1).mkv"
            }
        }
    }
}

#Preview {
    ScanProgressView()
        .frame(width: 300)
}
