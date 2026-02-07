import SwiftUI

// Forward declaration
struct WatchDataView: View {
    var body: some View {
        Text("Loading...")
    }
}

private func localizedName(for technique: BreathingTechnique) -> String {
    switch technique {
    case .fourSevenEight: return NSLocalizedString("technique_478", comment: "")
    case .progressiveMuscleRelaxation: return NSLocalizedString("technique_pmr", comment: "")
    case .bodyScan: return NSLocalizedString("technique_bodyscan", comment: "")
    case .breathingTwoOneSix: return NSLocalizedString("technique_216", comment: "")
    case .whiteNoise: return NSLocalizedString("technique_whitenoise", comment: "")
    }
}

struct WatchTechniquesView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // 心率数据入口
                    NavigationLink(destination: WatchDataView()) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .frame(width: 30)
                            
                            Text("watch_data")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.2))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 呼吸练习
                    ForEach(BreathingTechnique.allCases) { technique in
                        NavigationLink(destination: WatchBreathingView(technique: technique)) {
                            HStack {
                                Image(systemName: technique.icon)
                                    .foregroundColor(.purple)
                                    .frame(width: 30)
                                
                                Text(localizedName(for: technique))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("techniques_title")
        }
    }
}

struct WatchBreathingView: View {
    let technique: BreathingTechnique
    @State private var isRunning = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: technique.icon)
                .font(.system(size: 50))
                .foregroundColor(.purple)
            
            if !isRunning {
                Button(action: { isRunning = true }) {
                    Text(NSLocalizedString("breathing_start", comment: ""))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(20)
                }
                .padding(.horizontal)
            } else {
                // 简化动画
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isRunning ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isRunning)
                    .onAppear {
                        isRunning = true
                    }
                
                Text(NSLocalizedString("breathe_dot", comment: ""))
                    .font(.headline)
                
                Button(action: { isRunning = false }) {
                    Text(NSLocalizedString("breathing_stop", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .navigationTitle(localizedName(for: technique))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    WatchTechniquesView()
}
