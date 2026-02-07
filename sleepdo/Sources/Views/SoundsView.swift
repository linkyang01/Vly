//
//  SoundsView.swift
//  SleepDo
//
//  声音发现页面 - 完整版
//

import SwiftUI

struct SoundsView: View {
    @State private var selectedTab = 0
    @State private var showMixer = false
    @State private var showTimer = false
    
    enum SoundTab: String, CaseIterable {
        case recommended = "推荐"
        case sounds = "声音"
        case stories = "故事"
        case recording = "录制"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab 栏
            HStack(spacing: 0) {
                ForEach(Array(SoundTab.allCases.enumerated()), id: \.offset) { index, tab in
                    Button(action: { selectedTab = index }) {
                        VStack(spacing: 8) {
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: selectedTab == index ? .semibold : .regular))
                                .foregroundColor(selectedTab == index ? .white : Color.white.opacity(0.4))
                            
                            if selectedTab == index {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(red: 139/255, green: 92/255, blue: 246/255))
                                    .frame(width: 24, height: 3)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            
            // 内容
            TabView(selection: $selectedTab) {
                RecommendedContent().tag(0)
                SoundsContent().tag(1)
                StoriesContent().tag(2)
                RecordingContent().tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // 底部黑色条
            Color.black.frame(height: 60)
        }
        .background(Color.clear.ignoresSafeArea())
    }
}

// MARK: - 推荐内容
struct RecommendedContent: View {
    let collections = [
        ("雨天系列", "cloud.rain.fill", "8个声音", Color.blue),
        ("森林系列", "leaf.fill", "6个声音", Color.green),
        ("海浪系列", "water.waves.fill", "5个声音", Color.cyan),
        ("壁炉系列", "flame.fill", "4个声音", Color.orange),
        ("冥想系列", "sparkles", "7个声音", Color.purple),
        ("白噪声", "circle.hexagongrid.fill", "6个声音", Color.white)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 推荐合集
                VStack(alignment: .leading, spacing: 16) {
                    Text("推荐合集")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(collections, id: \.0) { collection in
                                CollectionCard(name: collection.0, icon: collection.1, count: collection.2, color: collection.3)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 成就进度
                AchievementProgressRow()
                    .padding(.horizontal)
                
                // 最近播放
                VStack(alignment: .leading, spacing: 16) {
                    Text("最近播放")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(0..<4) { i in
                            SoundHistoryRow(name: ["雨夜", "森林雨", "海浪", "壁炉"][i], 
                                          subtitle: ["轻柔的雨声", "森林中的雨声", "海浪轻拍声", "温暖的篝火声"][i],
                                          icon: ["cloud.rain.fill", "leaf.fill", "water.waves.fill", "flame.fill"][i],
                                          color: [Color.blue, Color.green, Color.cyan, Color.orange][i])
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer().frame(height: 20)
            }
            .padding(.vertical)
        }
    }
}

struct CollectionCard: View {
    let name: String
    let icon: String
    let count: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 100, height: 100)
                .background(color.opacity(0.15))
                .cornerRadius(20)
            
            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(count)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 120)
        .padding(16)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(20)
    }
}

struct AchievementProgressRow: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 28))
                .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                .frame(width: 48, height: 48)
                .background(Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.15))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("成就解锁进度")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("已解锁 12/35 个成就")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    .frame(width: 48, height: 48)
                Circle()
                    .trim(from: 0, to: 12/35)
                    .stroke(Color(red: 139/255, green: 92/255, blue: 246/255), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))
                Text("12")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(16)
    }
}

struct SoundHistoryRow: View {
    let name: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 56, height: 56)
                .background(color.opacity(0.15))
                .cornerRadius(14)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
            }
        }
        .padding(16)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(16)
    }
}

// MARK: - 声音内容
struct SoundsContent: View {
    @State private var selectedCategory = 0
    let categories = ["全部", "自然", "环境", "白噪声", "冥想", "音乐", "城市", "其他"]
    
    let sounds = [
        ("雨夜", "cloud.rain.fill", true, Color.blue),
        ("森林雨", "leaf.fill", true, Color.green),
        ("海浪", "water.waves.fill", true, Color.cyan),
        ("壁炉", "flame.fill", true, Color.orange),
        ("雷雨", "cloud.bolt.fill", false, Color.purple),
        ("瀑布", "waterfall.fill", false, Color.blue),
        ("河流", "river.fill", false, Color.cyan),
        ("风", "wind", false, Color.gray),
        ("咖啡厅", "cup.and.saucer.fill", false, Color.brown),
        ("图书馆", "book.fill", false, Color.brown),
        ("布朗噪声", "waveform", true, Color.pink),
        ("白噪声", "circle.hexagongrid.fill", true, Color.white),
        ("粉红噪声", "circle.fill", false, Color.pink),
        ("空调", "air.conditioner.horizontal.fill", false, Color.cyan),
        ("电风扇", "fan.fill", false, Color.blue),
        ("篝火", "fireplace.fill", false, Color.orange),
        ("鸟鸣", "bird.fill", false, Color.green),
        ("虫鸣", "antenna.radiowaves.left.and.right", false, Color.green),
        ("鲸鱼", "figure.wave", false, Color.blue),
        ("海豚", "figure.wave", false, Color.blue),
        ("雨林", "tree.fill", false, Color.green),
        ("田野", "sun.max.fill", false, Color.yellow),
        ("火车", "tram.fill", false, Color.gray),
        ("心率", "heart.fill", false, Color.red)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 分类标签
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                            Button(action: { selectedCategory = index }) {
                                Text(category)
                                    .font(.subheadline)
                                    .foregroundColor(selectedCategory == index ? .white : .gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedCategory == index 
                                            ? Color(red: 139/255, green: 92/255, blue: 246/255)
                                            : Color.gray.opacity(0.2)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 声音统计
                HStack {
                    Text("\(sounds.count) 个声音")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(sounds.filter { $2 }.count) 个已解锁")
                        .font(.caption)
                        .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                }
                .padding(.horizontal)
                
                // 声音网格
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(sounds, id: \.0) { sound in
                        SoundGridItem(name: sound.0, icon: sound.1, isUnlocked: sound.2, color: sound.3)
                    }
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 20)
            }
        }
    }
}

struct SoundGridItem: View {
    let name: String
    let icon: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(color)
                
                if !isUnlocked {
                    Circle()
                        .fill(Color.black.opacity(0.65))
                        .frame(width: 64, height: 64)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
            
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.6))
        .cornerRadius(16)
    }
}

// MARK: - 故事内容
struct StoriesContent: View {
    let stories = [
        ("森林冥想", "leaf.fill", "10分钟", "在森林中放松身心", Color.green),
        ("雨夜叙事", "cloud.rain.fill", "15分钟", "听着雨声入眠", Color.blue),
        ("海浪引导", "water.waves.fill", "12分钟", "海浪声引导冥想", Color.cyan),
        ("星空之旅", "star.fill", "20分钟", "想象在星空下", Color.purple),
        ("清晨唤醒", "sun.max.fill", "8分钟", "温和的早晨引导", Color.orange),
        ("深海放松", "water.waves.fill", "18分钟", "深海的宁静", Color.blue)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(stories, id: \.0) { story in
                    StoryRow(title: story.0, icon: story.1, duration: story.2, desc: story.3, color: story.4)
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 20)
            }
            .padding(.vertical)
        }
    }
}

struct StoryRow: View {
    let title: String
    let icon: String
    let duration: String
    let desc: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 64, height: 64)
                .background(color.opacity(0.15))
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(duration)
                    .font(.caption2)
                    .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
            }
        }
        .padding(20)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(20)
    }
}

// MARK: - 录制内容
struct RecordingContent: View {
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    
    let myRecordings = [
        ("我的录音 1", 45),
        ("睡前记录", 120),
        ("冥想录音", 180),
        ("白噪声", 60)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // 录制按钮区域
                VStack(spacing: 16) {
                    Button(action: {
                        isRecording.toggle()
                        if isRecording {
                            startRecording()
                        } else {
                            stopRecording()
                        }
                    }) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(isRecording 
                                        ? Color.red.opacity(0.2) 
                                        : Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.2))
                                    .frame(width: 140, height: 140)
                                
                                Circle()
                                    .fill(isRecording ? Color.red : Color(red: 139/255, green: 92/255, blue: 246/255))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                            }
                            
                            Text(isRecording ? "点击停止录制" : "点击开始录制")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            if isRecording {
                                Text(formatTime(recordingTime))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.red)
                                    .monospacedDigit()
                            }
                        }
                    }
                    
                    // 录制提示
                    Text("长按可录制自定义声音")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 24)
                
                // 我的录音列表
                VStack(alignment: .leading, spacing: 16) {
                    Text("我的录音")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(myRecordings, id: \.0) { recording in
                            RecordingRow(name: recording.0, duration: recording.1)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer().frame(height: 20)
            }
            .padding(.vertical)
        }
    }
    
    func startRecording() {
        recordingTime = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if !isRecording {
                timer.invalidate()
            } else {
                recordingTime += 0.1
            }
        }
    }
    
    func stopRecording() {
        isRecording = false
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct RecordingRow: View {
    let name: String
    let duration: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // 播放按钮
            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(Color(red: 139/255, green: 92/255, blue: 246/255).opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "play.fill")
                        .foregroundColor(Color(red: 139/255, green: 92/255, blue: 246/255))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Text(formatDuration(duration))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                // 编辑按钮
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                }
                
                // 删除按钮
                Button(action: {}) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8))
        .cornerRadius(16)
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return "\(mins)分\(secs)秒"
    }
}

#Preview {
    SoundsView()
}
