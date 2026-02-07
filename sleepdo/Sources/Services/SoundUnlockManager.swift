//
//  SoundUnlockManager.swift
//  SleepDo
//
//  声音解锁管理
//

import Foundation
import Combine

class SoundUnlockManager: ObservableObject {
    static let shared = SoundUnlockManager()
    
    @Published var unlockedSoundIds: Set<String> = []
    @Published var ownedSoundIds: Set<String> = []
    
    private let userDefaults = UserDefaults.standard
    private let unlockedKey = "unlocked_sound_ids"
    private let ownedKey = "owned_sound_ids"
    
    init() {
        loadUnlockedSounds()
        loadOwnedSounds()
    }
    
    // MARK: - Public Methods
    
    func isUnlocked(_ soundId: String) -> Bool {
        unlockedSoundIds.contains(soundId) || !Sound.all.first(where: { $0.id == soundId })!.isPremium
    }
    
    func isOwned(_ soundId: String) -> Bool {
        ownedSoundIds.contains(soundId)
    }
    
    func unlockSound(_ soundId: String) {
        unlockedSoundIds.insert(soundId)
        saveUnlockedSounds()
    }
    
    func purchaseSound(_ soundId: String) {
        ownedSoundIds.insert(soundId)
        saveOwnedSounds()
    }
    
    func unlockSounds(for achievementId: String) {
        let soundsToUnlock = Sound.all.filter { $0.unlockAchievementId == achievementId }
        for sound in soundsToUnlock {
            unlockSound(sound.id)
        }
    }
    
    func resetAll() {
        unlockedSoundIds.removeAll()
        ownedSoundIds.removeAll()
        saveUnlockedSounds()
        saveOwnedSounds()
    }
    
    // MARK: - Statistics
    
    var totalUnlocked: Int {
        unlockedSoundIds.count
    }
    
    var totalSounds: Int {
        Sound.all.count
    }
    
    var unlockedPercentage: Double {
        guard totalSounds > 0 else { return 0 }
        return Double(totalUnlocked) / Double(totalSounds)
    }
    
    func unlockedCount(for category: SoundCategory) -> Int {
        Sound.category(category).filter { isUnlocked($0.id) }.count
    }
    
    func totalCount(for category: SoundCategory) -> Int {
        Sound.category(category).count
    }
    
    // MARK: - Persistence
    
    private func loadUnlockedSounds() {
        if let data = userDefaults.array(forKey: unlockedKey) as? [String] {
            unlockedSoundIds = Set(data)
        }
    }
    
    private func loadOwnedSounds() {
        if let data = userDefaults.array(forKey: ownedKey) as? [String] {
            ownedSoundIds = Set(data)
        }
    }
    
    private func saveUnlockedSounds() {
        userDefaults.set(Array(unlockedSoundIds), forKey: unlockedKey)
    }
    
    private func saveOwnedSounds() {
        userDefaults.set(Array(ownedSoundIds), forKey: ownedKey)
    }
    
    // MARK: - Initial Unlock
    
    func unlockDefaultSounds() {
        // 解锁所有非 premium 声音
        for sound in Sound.unlocked {
            unlockedSoundIds.insert(sound.id)
        }
        saveUnlockedSounds()
    }
}
