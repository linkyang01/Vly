import SwiftUI

// MARK: - 睡眠疗法选择视图

struct SleepTherapyView: View {
    @State private var selectedTab: TherapyTab = .sounds
    
    enum TherapyTab: String, CaseIterable {
        case sounds = "声音"
        case therapy = "CBT-I"
        case stories = "故事"
        case meditation = "冥想"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab 选择器
            Picker("疗法类型", selection: $selectedTab) {
                ForEach(TherapyTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // 内容
            TabView(selection: $selectedTab) {
                SoundscapeSelectionView()
                    .tag(TherapyTab.sounds)
                
                TherapyTechniqueView()
                    .tag(TherapyTab.therapy)
                
                SleepStoriesView()
                    .tag(TherapyTab.stories)
                
                GuidedMeditationView()
                    .tag(TherapyTab.meditation)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

// MARK: - 声音场景选择

struct SoundscapeSelectionView: View {
    @State private var selectedCategory: SoundCategory = .nature
    
    enum SoundCategory: String, CaseIterable {
        case nature = "自然"
        case pink = "粉红"
        case isochronic = "等时性"
        case asmr = "ASMR"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 分类选择
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(SoundCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 根据分类显示不同内容
                Group {
                    switch selectedCategory {
                    case .nature:
                        NatureSoundsGrid()
                    case .pink:
                        PinkNoiseGrid()
                    case .isochronic:
                        IsochronicGrid()
                    case .asmr:
                        ASMRGrid()
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - 分类按钮

struct CategoryButton: View {
    let category: SoundscapeSelectionView.SoundCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(category.rawValue)
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var icon: String {
        switch category {
        case .nature: return "leaf.fill"
        case .pink: return "waveform"
        case .isochronic: return "waveform.path.ecg"
        case .asmr: return "bubble.left.fill"
        }
    }
}

// MARK: - 自然声音网格

struct NatureSoundsGrid: View {
    @State private var selectedSound: SoundType?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(SoundType.allCases) { sound in
                SoundCard(sound: sound, isSelected: selectedSound == sound) {
                    selectedSound = sound
                }
            }
        }
    }
}

// MARK: - 粉红噪音网格

struct PinkNoiseGrid: View {
    @State private var selectedType: PinkNoiseType?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(PinkNoiseType.allCases) { type in
                PinkNoiseCard(type: type, isSelected: selectedType == type) {
                    selectedType = type
                }
            }
        }
    }
}

// MARK: - 粉红噪音卡片

struct PinkNoiseCard: View {
    let type: PinkNoiseType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "waveform")
                    .font(.largeTitle)
                    .foregroundStyle(isSelected ? .blue : .secondary)
                
                Text(type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(type.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 等时性 Tone 网格

struct IsochronicGrid: View {
    @State private var selectedType: IsochronicToneType?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(IsochronicToneType.allCases) { type in
                IsochronicCard(type: type, isSelected: selectedType == type) {
                    selectedType = type
                }
            }
        }
    }
}

// MARK: - 等时性卡片

struct IsochronicCard: View {
    let type: IsochronicToneType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.largeTitle)
                    .foregroundStyle(isSelected ? .purple : .secondary)
                
                Text(type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(type.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.purple.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ASMR 网格

struct ASMRGrid: View {
    @State private var selectedType: ASMRType?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(ASMRType.allCases) { type in
                ASMRCard(type: type, isSelected: selectedType == type) {
                    selectedType = type
                }
            }
        }
    }
}

// MARK: - ASMR 卡片

struct ASMRCard: View {
    let type: ASMRType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.largeTitle)
                    .foregroundStyle(isSelected ? .pink : .secondary)
                
                Text(type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(type.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.pink.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 声音卡片

struct SoundCard: View {
    let sound: SoundType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: sound.icon)
                    .font(.title)
                    .foregroundStyle(isSelected ? .blue : .secondary)
                
                Text(sound.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 疗法技术视图

struct TherapyTechniqueView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // CBT-I 技术
                ForEach(CBTSleepTechnique.allCases) { technique in
                    TherapyCard(technique: technique)
                }
                
                // 温度指导
                VStack(alignment: .leading, spacing: 12) {
                    Label("睡眠温度", systemImage: "thermometer")
                        .font(.headline)
                    
                    ForEach(TemperatureGuidance.allCases) { temp in
                        TemperatureCard(guidance: temp)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - 疗法卡片

struct TherapyCard: View {
    let technique: CBTSleepTechnique
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: technique.icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text(technique.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            
            Text(technique.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                // 跳转到详情
            } label: {
                Label("开始练习", systemImage: "play.fill")
                    .font(.subheadline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - 温度卡片

struct TemperatureCard: View {
    let guidance: TemperatureGuidance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(guidance.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(guidance.description)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(guidance.tip)
                .font(.caption)
                .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
        )
    }
}

// MARK: - 睡眠故事视图

struct SleepStoriesView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(SleepStory.allCases) { story in
                    SleepStoryCard(story: story)
                }
            }
            .padding()
        }
    }
}

// MARK: - 睡眠故事卡片

struct SleepStoryCard: View {
    let story: SleepStory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(story.scenery)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text(story.rawValue)
                        .font(.headline)
                    
                    Text(formatDuration(story.duration))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    // 播放
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                }
            }
            
            Text(story.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) 分钟"
    }
}

// MARK: - 引导冥想视图

struct GuidedMeditationView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(GuidedMeditation.allCases) { meditation in
                    MeditationCard(meditation: meditation)
                }
            }
            .padding()
        }
    }
}

// MARK: - 冥想卡片

struct MeditationCard: View {
    let meditation: GuidedMeditation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: meditation.icon)
                    .font(.title)
                    .foregroundStyle(.purple)
                
                VStack(alignment: .leading) {
                    Text(meditation.rawValue)
                        .font(.headline)
                    
                    Text(formatDuration(meditation.duration))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    // 播放
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.purple)
                }
            }
            
            Text(meditation.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) 分钟"
    }
}

// MARK: - 预览

#Preview {
    SleepTherapyView()
}
