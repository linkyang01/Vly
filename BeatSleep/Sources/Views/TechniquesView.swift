import SwiftUI

// MARK: - 扩展方法获取保存的时长

extension String {
    func localized(args: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: args)
    }
}

extension BreathingTechnique {
    var userDuration: TimeInterval {
        let saved = UserDefaults.standard.integer(forKey: "duration_\(rawValue)")
        return saved > 0 ? TimeInterval(saved) : duration
    }
}

// MARK: - 方法选择页面

struct TechniquesView: View {
    @State private var selectedTechnique: BreathingTechnique?
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        
                        ForEach(BreathingTechnique.allCases) { technique in
                            NavigationLink(destination: TechniqueDetailView(technique: technique)) {
                                TechniqueCard(technique: technique)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("techniques_title".localized())
            .navigationBarTitleDisplayMode(.large)
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
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("techniques_choose".localized())
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("techniques_find_best".localized())
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
}

// MARK: - 方法卡片

struct TechniqueCard: View {
    let technique: BreathingTechnique
    @State private var showDurationPicker = false
    @State private var refreshTrigger = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(technique.gradient)
                    .frame(width: 56, height: 56)
                
                Image(systemName: technique.icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(technique.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(technique.recommendedFor)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\(Int(getTechniqueDuration(technique) / 60)) \(NSLocalizedString("techniques_min", comment: ""))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(technique.accentColor)
                            .id(refreshTrigger)
                        
                        Button(action: { showDurationPicker = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.caption)
                                .foregroundColor(technique.accentColor.opacity(0.8))
                        }
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .sheet(isPresented: $showDurationPicker) {
            DurationPickerView(technique: technique)
                .onDisappear {
                    refreshTrigger.toggle()
                }
        }
    }
    
    private func getTechniqueDuration(_ tech: BreathingTechnique) -> TimeInterval {
        let saved = UserDefaults.standard.integer(forKey: "duration_\(tech.rawValue)")
        return saved > 0 ? TimeInterval(saved) : tech.duration
    }
}

// MARK: - 方法详情

struct TechniqueDetailView: View {
    let technique: BreathingTechnique
    @State private var showDurationPicker = false
    @State private var refreshTrigger = false
    @State private var selectedSoundType: WhiteNoiseType = .rain
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#0D0D1A"),
                    Color(hex: "#1A1A3E"),
                    Color(hex: "#2D1B4E")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(technique.gradient)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: technique.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    
                    Text(technique.displayName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 16) {
                    Text(technique.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 32)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("recommended_for".localized() + ": \(technique.recommendedFor)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // 白噪音：声音选择器
                if technique == .whiteNoise {
                    whiteNoiseSoundSelector
                }
                
                // 详细信息
                VStack(spacing: 12) {
                    Button(action: { showDurationPicker = true }) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                            
                            Text("techniques_duration".localized())
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(Int(getTechniqueDuration(technique) / 60)) \(NSLocalizedString("techniques_min", comment: ""))")
                                .fontWeight(.medium)
                                .foregroundColor(technique.accentColor)
                                .id(refreshTrigger)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .font(.subheadline)
                    }
                    
                    InfoRow(icon: "chart.bar.fill", title: "techniques_difficulty".localized(), value: technique.difficulty.localized())
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 开始按钮
                if technique.steps.isEmpty {
                    if technique == .whiteNoise {
                        whiteNoisePlayButton
                    } else if technique == .progressiveMuscleRelaxation {
                        progressivePlayButton
                    } else if technique == .bodyScan {
                        bodyScanPlayButton
                    } else {
                        NavigationLink(destination: PlaceholderTherapyView(technique: technique, customDuration: getTechniqueDuration(technique))) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("breathing_start".localized())
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(technique.gradient)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    NavigationLink(destination: BreathingSessionView(technique: technique, customDuration: getTechniqueDuration(technique))) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("breathing_start".localized())
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showDurationPicker) {
            DurationPickerView(technique: technique)
                .onDisappear {
                    refreshTrigger.toggle()
                }
        }
        .onAppear {
            // 读取上次选择的声音
            if let saved = UserDefaults.standard.string(forKey: "selectedSoundType") {
                if let type = WhiteNoiseType(rawValue: saved) {
                    selectedSoundType = type
                }
            }
        }
    }
    
    // MARK: - 白噪音声音选择器
    
    private var whiteNoiseSoundSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("white_noise_select".localized())
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(WhiteNoiseType.allCases) { sound in
                        SoundTypeButton(
                            sound: sound,
                            isSelected: selectedSoundType == sound
                        ) {
                            selectedSoundType = sound
                            UserDefaults.standard.set(sound.rawValue, forKey: "selectedSoundType")
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - 白噪音播放按钮
    
    private var whiteNoisePlayButton: some View {
        let minutes = Int(getTechniqueDuration(technique) / 60)
        return NavigationLink(destination: WhiteNoisePlayerPage(soundType: selectedSoundType, duration: getTechniqueDuration(technique))) {
            HStack {
                Image(systemName: "play.fill")
                Text("breathing_start".localized())
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: selectedSoundType.accentColor), Color(hex: selectedSoundType.accentColor).opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 渐进式肌肉放松播放按钮
    
    private var progressivePlayButton: some View {
        return NavigationLink(destination: TherapyPlayerPage(therapyType: .progressive, duration: 600)) {
            HStack {
                Image(systemName: "play.fill")
                Text("breathing_start".localized())
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 身体扫描播放按钮
    
    private var bodyScanPlayButton: some View {
        return NavigationLink(destination: TherapyPlayerPage(therapyType: .bodyscan, duration: 600)) {
            HStack {
                Image(systemName: "play.fill")
                Text("breathing_start".localized())
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#10B981"), Color(hex: "#10B981").opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }
    
    private func getTechniqueDuration(_ tech: BreathingTechnique) -> TimeInterval {
        let saved = UserDefaults.standard.integer(forKey: "duration_\(tech.rawValue)")
        return saved > 0 ? TimeInterval(saved) : tech.duration
    }
}

// MARK: - 声音类型按钮

struct SoundTypeButton: View {
    let sound: WhiteNoiseType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(hex: sound.accentColor).opacity(isSelected ? 0.3 : 0.15))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: sound.icon)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: sound.accentColor))
                }
                
                Text(sound.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: sound.accentColor) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 信息行

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .font(.subheadline)
    }
}

// MARK: - 技术扩展

extension BreathingTechnique {
    var gradient: LinearGradient {
        LinearGradient(
            colors: [accentColor.opacity(0.8), accentColor.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var accentColor: Color {
        switch self {
        case .fourSevenEight: return Color(hex: "#8B5CF6")
        case .progressiveMuscleRelaxation: return Color(hex: "#3B82F6")
        case .bodyScan: return Color(hex: "#10B981")
        case .breathingTwoOneSix: return Color(hex: "#F59E0B")
        case .whiteNoise: return Color(hex: "#6366F1")
        }
    }
    
    var difficultyKey: String {
        switch self {
        case .fourSevenEight: return "difficulty_medium"
        case .progressiveMuscleRelaxation: return "difficulty_medium"
        case .bodyScan: return "difficulty_easy"
        case .breathingTwoOneSix: return "difficulty_easy"
        case .whiteNoise: return "difficulty_effortless"
        }
    }
    
    var difficulty: String {
        difficultyKey.localized()
    }
}

#Preview {
    NavigationStack {
        TechniquesView()
    }
}
