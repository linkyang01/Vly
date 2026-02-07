import SwiftUI

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

#Preview {
    WatchTechniquesView()
}
