import Foundation
import HealthKit
import Combine

// MARK: - HRV 反馈类型

enum HRVFeedbackType: String, CaseIterable, Identifiable {
    case relaxation = "放松"
    case stress = "压力"
    case balanced = "平衡"
    case recovery = "恢复"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .relaxation: return "leaf.fill"
        case .stress: return "bolt.fill"
        case .balanced: return "scale.3d"
        case .recovery: return "arrow.clockwise.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .relaxation: return "green"
        case .stress: return "red"
        case .balanced: return "blue"
        case .recovery: return "orange"
        }
    }
    
    var message: String {
        switch self {
        case .relaxation: return "你的心率变异性很好，身体处于放松状态"
        case .stress: return "检测到较高压力，建议进行呼吸练习"
        case .balanced: return "心率变异性正常，继续保持"
        case .recovery: return "正在恢复中，适合休息"
        }
    }
}

// MARK: - HRV 分析结果

struct HRVAnalysis: Identifiable {
    let id = UUID()
    let timestamp: Date
    let hrvValue: Double // 毫秒
    let feedbackType: HRVFeedbackType
    let trend: Trend
    
    enum Trend {
        case improving
        case declining
        case stable
    }
    
    /// 分类 HRV 值
    static func classify(hrv: Double) -> HRVFeedbackType {
        switch hrv {
        case 0..<20:
            return .stress
        case 20..<40:
            return .balanced
        case 40..<60:
            return .recovery
        default:
            return .relaxation
        }
    }
}

// MARK: - 增强 HRV 反馈服务

final class EnhancedHRVFeedbackService: ObservableObject {
    static let shared = EnhancedHRVFeedbackService()
    
    @Published private(set) var currentHRV: Double?
    @Published private(set) var hrvAnalysis: HRVAnalysis?
    @Published private(set) var hrvTrend: [HRVAnalysis] = []
    @Published private(set) var recommendations: [String] = []
    
    private let healthStore = HKHealthStore()
    private var hrvQuery: HKAnchoredObjectQuery?
    private var trendTimer: Timer?
    
    // MARK: - 分析配置
    
    struct AnalysisConfig {
        static let lowHRVThreshold: Double = 20.0      // 低 HRV 阈值 (ms)
        static let highHRVThreshold: Double = 60.0     // 高 HRV 阈值 (ms)
        static let trendWindowSize: Int = 10            // 趋势窗口大小
        static let analysisInterval: TimeInterval = 60 // 分析间隔 (秒)
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        requestAuthorization { [weak self] success in
            guard success else { return }
            self?.startHRVQuery()
            self?.startTrendAnalysis()
        }
    }
    
    func stopMonitoring() {
        if let query = hrvQuery {
            healthStore.stop(query)
        }
        trendTimer?.invalidate()
        trendTimer = nil
    }
    
    /// 实时分析 HRV 并提供反馈
    func analyzeCurrentHRV(_ hrv: Double) -> HRVAnalysis {
        let trend = calculateTrend()
        let feedbackType = HRVAnalysis.classify(hrv: hrv)
        
        let analysis = HRVAnalysis(
            timestamp: Date(),
            hrvValue: hrv,
            feedbackType: feedbackType,
            trend: trend
        )
        
        currentHRV = hrv
        hrvAnalysis = analysis
        
        // 更新趋势
        hrvTrend.append(analysis)
        if hrvTrend.count > AnalysisConfig.trendWindowSize {
            hrvTrend.removeFirst()
        }
        
        // 生成建议
        recommendations = generateRecommendations(for: feedbackType, trend: trend)
        
        return analysis
    }
    
    /// 获取呼吸建议
    func getBreathingRecommendation() -> String {
        guard let analysis = hrvAnalysis else {
            return "开始呼吸练习以改善睡眠"
        }
        
        switch analysis.feedbackType {
        case .stress:
            return "建议使用 4-7-8 呼吸法快速放松"
        case .relaxation:
            return "状态良好，可进行身体扫描放松"
        case .balanced:
            return "可尝试渐进式肌肉放松"
        case .recovery:
            return "适合进行冥想呼吸练习"
        }
    }
    
    /// 获取个性化建议
    func getPersonalizedSuggestion() -> String? {
        guard let analysis = hrvAnalysis else { return nil }
        
        switch analysis.feedbackType {
        case .stress:
            return "你的 HRV 较低，建议今晚提前 30 分钟开始放松仪式"
        case .relaxation:
            return "你的恢复状态很好！继续保持当前的睡眠习惯"
        case .balanced:
            return "你的状态稳定，可以尝试延长呼吸练习时长"
        case .recovery:
            return "你正在恢复中，建议避免睡前剧烈运动"
        }
    }
    
    // MARK: - Private Methods
    
    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        
        healthStore.requestAuthorization(toShare: [], read: [hrvType]) { success, error in
            completion(success)
        }
    }
    
    private func startHRVQuery() {
        let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        
        let query = HKAnchoredObjectQuery(
            type: hrvType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, error in
            guard let samples = samples as? [HKQuantitySample],
                  let lastSample = samples.last else { return }
            
            let hrvUnit = HKUnit.secondUnit(with: .milli)
            let hrv = lastSample.quantity.doubleValue(for: hrvUnit)
            DispatchQueue.main.async {
                _ = self?.analyzeCurrentHRV(hrv)
            }
        }
        
        query.updateHandler = { [weak self] _, samples, _, _, error in
            guard let samples = samples as? [HKQuantitySample],
                  let lastSample = samples.last else { return }
            
            let hrvUnit = HKUnit.secondUnit(with: .milli)
            let hrv = lastSample.quantity.doubleValue(for: hrvUnit)
            DispatchQueue.main.async {
                _ = self?.analyzeCurrentHRV(hrv)
            }
        }
        
        hrvQuery = query
        healthStore.execute(query)
    }
    
    private func startTrendAnalysis() {
        trendTimer = Timer.scheduledTimer(withTimeInterval: AnalysisConfig.analysisInterval, repeats: true) { [weak self] _ in
            guard let hrv = self?.currentHRV else { return }
            _ = self?.analyzeCurrentHRV(hrv)
        }
    }
    
    private func calculateTrend() -> HRVAnalysis.Trend {
        guard hrvTrend.count >= 3 else { return .stable }
        
        let recent = hrvTrend.suffix(3)
        let recentAvg = recent.map(\.hrvValue).reduce(0, +) / Double(recent.count)
        
        let older = hrvTrend.prefix(max(0, hrvTrend.count - 3))
        guard !older.isEmpty else { return .stable }
        let olderAvg = older.map(\.hrvValue).reduce(0, +) / Double(older.count)
        
        let diff = recentAvg - olderAvg
        let threshold = olderAvg * 0.1 // 10% 变化阈值
        
        if diff > threshold {
            return .improving
        } else if diff < -threshold {
            return .declining
        } else {
            return .stable
        }
    }
    
    private func generateRecommendations(for type: HRVFeedbackType, trend: HRVAnalysis.Trend) -> [String] {
        var recommendations: [String] = []
        
        switch type {
        case .stress:
            recommendations.append("🫁 建议进行 4-7-8 呼吸练习")
            recommendations.append("🌡️ 今晚可以洗个热水澡")
            recommendations.append("📱 避免睡前使用电子设备")
        case .relaxation:
            recommendations.append("✨ 状态很好，继续保持")
            recommendations.append("📖 可以尝试阅读帮助入睡")
            recommendations.append("🎵 继续使用助眠声音")
        case .balanced:
            recommendations.append("💤 保持当前作息")
            recommendations.append("🧘 可延长冥想时间")
            recommendations.append("☕ 避免午后咖啡因")
        case .recovery:
            recommendations.append("🌙 今晚早点休息")
            recommendations.append("🏃 避免睡前剧烈运动")
            recommendations.append("🥗 保持健康饮食")
        }
        
        switch trend {
        case .improving:
            recommendations.append("📈 HRV 正在改善！")
        case .declining:
            recommendations.append("📉 注意压力管理")
        case .stable:
            recommendations.append("➡️ 状态稳定")
        }
        
        return recommendations
    }
}

// MARK: - HRV 统计

struct HRVStatistics {
    let average: Double
    let minimum: Double
    let maximum: Double
    let standardDeviation: Double
    
    static func calculate(from analyses: [HRVAnalysis]) -> HRVStatistics? {
        guard !analyses.isEmpty else { return nil }
        
        let values = analyses.map(\.hrvValue)
        let avg = values.reduce(0, +) / Double(values.count)
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        
        let squaredDiffs = values.map { pow($0 - avg, 2) }
        let stdDev = sqrt(squaredDiffs.reduce(0, +) / Double(values.count))
        
        return HRVStatistics(
            average: avg,
            minimum: min,
            maximum: max,
            standardDeviation: stdDev
        )
    }
}
