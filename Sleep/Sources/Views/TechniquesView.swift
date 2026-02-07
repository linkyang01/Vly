import SwiftUI

// MARK: - 方法选择视图

struct TechniquesView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 呼吸练习
                        Text("breathing_title")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        
                        // 4-7-8 呼吸
                        NavigationLink(destination: BreathingSessionView(technique: .fourSevenEight)) {
                            TechniqueCard(
                                icon: "lungs.fill",
                                iconColor: .purple,
                                name: "four7_8_name",
                                description: "four7_8_desc",
                                duration: "3 min",
                                durationColor: .purple,
                                bgColor: Color.purple.opacity(0.2)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // 2-1-6 呼吸
                        NavigationLink(destination: BreathingSessionView(technique: .twoOneSix)) {
                            TechniqueCard(
                                icon: "wind",
                                iconColor: .blue,
                                name: "two1_6_name",
                                description: "two1_6_desc",
                                duration: "3 min",
                                durationColor: .blue,
                                bgColor: Color.blue.opacity(0.2)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // 白噪音
                        Text("whitenoise_title")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                            .padding(.top, 8)
                        
                        NavigationLink(destination: SleepTherapyView()) {
                            TechniqueCard(
                                icon: "waveform",
                                iconColor: .cyan,
                                name: "whitenoise_name",
                                description: "whitenoise_desc",
                                duration: "5-60 min",
                                durationColor: .cyan,
                                bgColor: Color.cyan.opacity(0.2)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // 放松练习
                        Text("relaxation_title")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                            .padding(.top, 8)
                        
                        // 渐进式肌肉放松
                        NavigationLink(destination: TherapyPlayerPage(technique: .progressive)) {
                            TechniqueCard(
                                icon: "figure.cooldown",
                                iconColor: .green,
                                name: "relaxation_name",
                                description: "relaxation_desc",
                                duration: "10 min",
                                durationColor: .green,
                                bgColor: Color.green.opacity(0.2)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // 身体扫描
                        NavigationLink(destination: TherapyPlayerPage(technique: .bodyScan)) {
                            TechniqueCard(
                                icon: "figure.scan",
                                iconColor: .orange,
                                name: "bodyscan_name",
                                description: "bodyscan_desc",
                                duration: "10 min",
                                durationColor: .orange,
                                bgColor: Color.orange.opacity(0.2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("select_method_title")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "#0D0D1A"),
                Color(hex: "#1A1A3E"),
                Color(hex: "#2D1B4E")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - 统一方法卡片

struct TechniqueCard: View {
    let icon: String
    let iconColor: Color
    let name: String
    let description: String
    let duration: String
    let durationColor: Color
    let bgColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    // 图标和名称
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.system(size: 28))
                            .foregroundColor(iconColor)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(bgColor)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                    }
                    
                    // 持续时间
                    HStack(spacing: 8) {
                        Label(duration, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(durationColor)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // 开始按钮
            HStack {
                Spacer()
                Text("start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(iconColor)
                    )
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
        )
    }
}

// MARK: - 预览

#Preview {
    TechniquesView()
}
