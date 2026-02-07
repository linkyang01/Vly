import SwiftUI

// MARK: - 睡眠回顾页面

struct SleepReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sleepManager: SleepManager
    
    @State private var sleepData: SleepData?
    @State private var isLoading = true
    @State private var quality: SleepQuality = .good
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1A3E"), Color(hex: "#2D1B4E")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(1.5)
                        Text("review_loading")
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            VStack(spacing: 8) {
                                Image(systemName: "moon.stars.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.yellow)
                                
                                Text("review_title")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("review_subtitle")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 20)
                            
                            if let data = sleepData {
                                VStack(spacing: 16) {
                                    Text("review_sleep_times")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack(spacing: 20) {
                                        VStack(spacing: 4) {
                                            Text("review_bedtime")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text(data.formattedBedtime)
                                                .font(.title)
                                                .foregroundColor(.white)
                                        }
                                        Spacer()
                                        VStack(spacing: 4) {
                                            Text("review_waketime")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text(data.formattedWakeTime)
                                                .font(.title)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    Divider()
                                        .background(Color.white.opacity(0.2))
                                    
                                    HStack(spacing: 16) {
                                        VStack {
                                            Text(data.formattedTotalSleep)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("review_total_sleep")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        VStack {
                                            Text("\(data.deepSleepMinutes) min")
                                                .font(.headline)
                                                .foregroundColor(.blue)
                                            Text("review_deep_sleep")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        VStack {
                                            Text("\(data.lightSleepMinutes) min")
                                                .font(.headline)
                                                .foregroundColor(.purple)
                                            Text("review_light_sleep")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
                                .padding(.horizontal)
                            }
                            
                            VStack(spacing: 12) {
                                Text("review_quality")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 12) {
                                    ForEach(SleepQuality.allCases, id: \.self) { q in
                                        Button(action: { quality = q }) {
                                            VStack(spacing: 4) {
                                                Text(q.emoji)
                                                    .font(.title)
                                                Text(q.rawValue)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(RoundedRectangle(cornerRadius: 12).fill(quality == q ? Color.purple.opacity(0.3) : Color.white.opacity(0.1)))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
                            .padding(.horizontal)
                            
                            Button(action: saveReview) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("review_save")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle("review_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("review_skip") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
            .preferredColorScheme(.dark)
        }
        .task {
            await loadData()
        }
    }
    
    @MainActor
    private func loadData() async {
        sleepData = await HealthKitManager.shared.fetchSleepData(for: Date())
        isLoading = false
    }
    
    @MainActor
    private func saveReview() {
        guard let data = sleepData else { return }
        
        let session = SleepSession(
            id: UUID(),
            date: Date(),
            bedTime: data.bedtime,
            wakeTime: data.wakeTime,
            techniqueUsed: "Apple Watch Sleep",
            timeToFallAsleep: nil,
            quality: quality,
            heartRateData: data.heartRateData,
            notes: nil
        )
        
        sleepManager.addSession(session)
        FeedbackManager.shared.success()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

#Preview {
    SleepReviewView()
        .environmentObject(SleepManager())
}
