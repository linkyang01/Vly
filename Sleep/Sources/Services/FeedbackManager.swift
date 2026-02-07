import Foundation
import UIKit
import AVFoundation

// MARK: - 反馈管理器

class FeedbackManager {
    static let shared = FeedbackManager()
    
    private let generator = UIImpactFeedbackGenerator(style: .medium)
    private let successGenerator = UINotificationFeedbackGenerator()
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        generator.prepare()
        successGenerator.prepare()
    }
    
    // MARK: - 触觉反馈
    
    func impact() {
        generator.impactOccurred()
    }
    
    func lightImpact() {
        let lightGenerator = UIImpactFeedbackGenerator(style: .light)
        lightGenerator.impactOccurred()
    }
    
    func heavyImpact() {
        let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
        heavyGenerator.impactOccurred()
    }
    
    func success() {
        successGenerator.notificationOccurred(.success)
    }
    
    func warning() {
        successGenerator.notificationOccurred(.warning)
    }
    
    func error() {
        successGenerator.notificationOccurred(.error)
    }
    
    func selection() {
        let selectionGenerator = UISelectionFeedbackGenerator()
        selectionGenerator.selectionChanged()
    }
    
    // MARK: - 声音反馈
    
    func playClick() {
        playSound(named: "click", ofType: "wav")
    }
    
    func playSuccess() {
        playSound(named: "success", ofType: "wav")
    }
    
    func playCompletion() {
        playSound(named: "completion", ofType: "wav")
    }
    
    func playStart() {
        playSound(named: "start", ofType: "wav")
    }
    
    private func playSound(named name: String, ofType ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.3
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    // MARK: - 组合反馈
    
    func playAndVibrate() {
        playClick()
        impact()
    }
    
    func startSession() {
        playStart()
        lightImpact()
    }
    
    func pauseSession() {
        playClick()
        selection()
    }
    
    func completeSession() {
        playCompletion()
        success()
    }
}
