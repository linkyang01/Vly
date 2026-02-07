import SwiftUI
import AVFoundation
import UIKit

// MARK: - 反馈管理器

class FeedbackManager {
    static let shared = FeedbackManager()
    
    private let generator = UIImpactFeedbackGenerator(style: .medium)
    
    private init() {
        generator.prepare()
    }
    
    /// 执行轻触反馈
    func tap() {
        guard UserDefaults.standard.bool(forKey: "hapticEnabled") else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// 执行成功反馈
    func success() {
        guard UserDefaults.standard.bool(forKey: "hapticEnabled") else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// 执行警告反馈
    func warning() {
        guard UserDefaults.standard.bool(forKey: "hapticEnabled") else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// 执行错误反馈
    func error() {
        guard UserDefaults.standard.bool(forKey: "hapticEnabled") else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// 播放按钮点击音效
    func playButtonSound() {
        guard UserDefaults.standard.bool(forKey: "soundEnabled") else { return }
        AudioServicesPlaySystemSound(1104) // 标准点击音效
    }
    
    /// 播放成功音效
    func playSuccessSound() {
        guard UserDefaults.standard.bool(forKey: "soundEnabled") else { return }
        AudioServicesPlaySystemSound(1057) // 成功音效
    }
}

// MARK: - View 扩展添加反馈

extension View {
    func withFeedback() -> some View {
        self.onTapGesture {
            FeedbackManager.shared.tap()
            FeedbackManager.shared.playButtonSound()
        }
    }
}
