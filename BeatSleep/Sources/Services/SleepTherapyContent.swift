import Foundation

// MARK: - CBT-I 睡眠技术

enum CBTSleepTechnique: String, CaseIterable, Identifiable {
    case sleepRestriction = "睡眠限制"
    case stimulusControl = "刺激控制"
    case relaxation = "放松训练"
    case cognitive = "认知重构"
    case sleepHygiene = "睡眠卫生"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .sleepRestriction: return "限制床上时间，提高睡眠效率"
        case .stimulusControl: return "建立床与睡眠的条件反射"
        case .relaxation: return "渐进式肌肉放松和呼吸练习"
        case .cognitive: return "识别和改变睡眠相关负面思维"
        case .sleepHygiene: return "优化睡眠环境和睡前习惯"
        }
    }
    
    var icon: String {
        switch self {
        case .sleepRestriction: return "clock.fill"
        case .stimulusControl: return "bed.double.fill"
        case .relaxation: return "leaf.fill"
        case .cognitive: return "brain.head.profile"
        case .sleepHygiene: return "sparkles"
        }
    }
}

// MARK: - 睡眠故事

enum SleepStory: String, CaseIterable, Identifiable {
    case forestWalk = "森林漫步"
    case oceanWave = "海浪轻摇"
    case mountainStream = "山间溪流"
    case rainOnRoof = "雨夜屋檐"
    case starryNight = "星空之旅"
    
    var id: String { rawValue }
    
    var duration: TimeInterval {
        switch self {
        case .forestWalk: return 1200  // 20分钟
        case .oceanWave: return 1500   // 25分钟
        case .mountainStream: return 1800  // 30分钟
        case .rainOnRoof: return 1200  // 20分钟
        case .starryNight: return 2100  // 35分钟
        }
    }
    
    var description: String {
        switch self {
        case .forestWalk: return "想象漫步在宁静的森林中"
        case .oceanWave: return "随着海浪节奏慢慢放松"
        case .mountainStream: return "聆听山间溪流的潺潺声"
        case .rainOnRoof: return "雨夜窗边的温馨氛围"
        case .starryNight: return "仰望星空，放空思绪"
        }
    }
    
    var scenery: String {
        switch self {
        case .forestWalk: return "🌲 森林"
        case .oceanWave: return "🌊 大海"
        case .mountainStream: return "⛰️ 山溪"
        case .rainOnRoof: return "🌧️ 雨夜"
        case .starryNight: return "⭐ 星空"
        }
    }
}

// MARK: - 引导冥想类型

enum GuidedMeditation: String, CaseIterable, Identifiable {
    case bodyScan = "身体扫描"
    case breathingAwareness = "呼吸觉察"
    case gratitude = "感恩练习"
    case visualization = "可视化冥想"
    case lovingKindness = "慈心冥想"
    
    var id: String { rawValue }
    
    var duration: TimeInterval {
        switch self {
        case .bodyScan: return 900      // 15分钟
        case .breathingAwareness: return 600  // 10分钟
        case .gratitude: return 480     // 8分钟
        case .visualization: return 900 // 15分钟
        case .lovingKindness: return 600  // 10分钟
        }
    }
    
    var description: String {
        switch self {
        case .bodyScan: return "从脚到头扫描全身，释放紧张"
        case .breathingAwareness: return "专注于呼吸节奏，不加评判"
        case .gratitude: return "回顾今天的美好时刻"
        case .visualization: return "想象宁静祥和的场景"
        case .lovingKindness: return "培养对自己和他人的善意"
        }
    }
    
    var icon: String {
        switch self {
        case .bodyScan: return "figure.scan"
        case .breathingAwareness: return "wind"
        case .gratitude: return "heart.fill"
        case .visualization: return "eye.fill"
        case .lovingKindness: return "heart.circle.fill"
        }
    }
}

// MARK: - 声音场景

enum SleepSoundscape: String, CaseIterable, Identifiable {
    case thunderstorm = "雷暴"
    case campfire = "篝火"
    case cafe = "咖啡馆"
    case library = "图书馆"
    case train = "火车"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .thunderstorm: return "远处的雷声和雨声"
        case .campfire: return "篝火噼啪声"
        case .cafe: return "咖啡馆背景白噪音"
        case .library: return "图书馆翻书声"
        case .train: return "火车行进声"
        }
    }
    
    var icon: String {
        switch self {
        case .thunderstorm: return "cloud.bolt.rain.fill"
        case .campfire: return "flame.fill"
        case .cafe: return "cup.and.saucer.fill"
        case .library: return "books.vertical.fill"
        case .train: return "tram.fill"
        }
    }
}

// MARK: - 温度调节建议

enum TemperatureGuidance: String, CaseIterable, Identifiable {
    case cool = "偏凉 (18-20°C)"
    case warm = "偏暖 (22-24°C)"
    case neutral = "中性 (20-22°C)"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .cool: return "促进深度睡眠，降低核心体温"
        case .warm: return "舒适放松，适合怕冷人群"
        case .neutral: return "平衡温度，适合大多数人"
        }
    }
    
    var tip: String {
        switch self {
        case .cool: return "🧊 建议：睡前洗热水澡，让体温自然下降"
        case .warm: return "🛋️ 建议：使用保暖睡衣和厚被子"
        case .neutral: return "📏 建议：保持室温稳定"
        }
    }
}

// MARK: - 睡前仪式配置

struct BedtimeRoutineConfig {
    var routineSteps: [RoutineStep]
    var totalDuration: TimeInterval
    var startTime: Date?
    
    struct RoutineStep: Identifiable {
        let id = UUID()
        let type: RoutineStepType
        let duration: TimeInterval
        var isCompleted: Bool
        
        enum RoutineStepType {
            case breathing
            case meditation
            case story
            case stretching
            case journaling
            case gratitude
            case visualization
        }
    }
    
    static let `default` = BedtimeRoutineConfig(
        routineSteps: [
            RoutineStep(type: .breathing, duration: 300, isCompleted: true),  // 5分钟呼吸
            RoutineStep(type: .gratitude, duration: 120, isCompleted: false),  // 2分钟感恩
            RoutineStep(type: .visualization, duration: 180, isCompleted: false)  // 3分钟想象
        ],
        totalDuration: 600,  // 10分钟
        startTime: nil
    )
}

// MARK: - 智能推荐配置

struct SmartSleepRecommendation {
    let type: RecommendationType
    let title: String
    let description: String
    let priority: Int
    let action: () -> Void
    
    enum RecommendationType {
        case hrvBased
        case timeBased
        case streakBased
        case weatherBased
    }
}

// MARK: - 睡眠数据统计

struct SleepAnalytics {
    let averageSleepDuration: TimeInterval
    let averageBedtime: Date
    let averageWakeTime: Date
    let sleepEfficiency: Double
    let weeklyTrend: Trend
    let streakDays: Int
    
    enum Trend {
        case improving
        case declining
        case stable
    }
}
