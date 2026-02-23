import Foundation
import SwiftUI

// MARK: - SoundTranslatorViewModel

@MainActor
@Observable
final class SoundTranslatorViewModel {

    // MARK: - State

    var isListening = false
    var showingSettings = false
    var showingHistory = false
    var showingProfiles = false
    var selectedCategory: SoundCategory?

    // Profiles
    var profiles: [ListeningProfile] = ListeningProfile.samples
    var activeProfileIndex: Int = 0

    // Settings
    var hapticEnabled = true
    var speechRecognitionEnabled = true
    var liveActivityEnabled = true
    var watchNotificationEnabled = true
    var autoSummaryEnabled = true

    // MARK: - Dependencies

    let soundManager = SoundAnalysisManager.shared
    let hapticManager = HapticManager.shared

    // MARK: - Computed

    var detectedSounds: [SoundEvent] {
        soundManager.detectedSounds
    }

    var filteredSounds: [SoundEvent] {
        guard let category = selectedCategory else {
            return detectedSounds
        }
        return detectedSounds.filter { $0.category == category }
    }

    var currentSummary: SituationSummary? {
        soundManager.currentSummary
    }

    var audioLevel: Double {
        soundManager.audioLevel
    }

    var activeProfile: ListeningProfile? {
        guard profiles.indices.contains(activeProfileIndex) else { return nil }
        return profiles[activeProfileIndex]
    }

    var dangerCount: Int {
        detectedSounds.filter { $0.alertLevel == .danger }.count
    }

    var cautionCount: Int {
        detectedSounds.filter { $0.alertLevel == .caution }.count
    }

    var categoryStats: [(SoundCategory, Int)] {
        var stats: [SoundCategory: Int] = [:]
        for event in detectedSounds {
            stats[event.category, default: 0] += 1
        }
        return stats.sorted { $0.value > $1.value }
    }

    // MARK: - Actions

    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }

    func startListening() {
        isListening = true
        soundManager.startListening()
    }

    func stopListening() {
        isListening = false
        soundManager.stopListening()
    }

    func selectProfile(_ index: Int) {
        guard profiles.indices.contains(index) else { return }

        // 前のプロファイルを無効化
        if profiles.indices.contains(activeProfileIndex) {
            profiles[activeProfileIndex].isActive = false
        }

        activeProfileIndex = index
        profiles[index].isActive = true
    }

    func clearHistory() {
        soundManager.detectedSounds.removeAll()
    }

    func filterByCategory(_ category: SoundCategory?) {
        selectedCategory = category
    }
}
