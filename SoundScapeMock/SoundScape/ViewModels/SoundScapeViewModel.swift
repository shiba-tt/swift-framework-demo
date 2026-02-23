import Foundation
import SwiftUI

@MainActor
@Observable
final class SoundScapeViewModel {
    // MARK: - Tab

    enum Tab: String, Sendable {
        case analyze
        case log
        case stats
    }

    var selectedTab: Tab = .analyze

    // MARK: - Dependencies

    private let manager = SoundAnalysisManager.shared

    // MARK: - Proxied State

    var isListening: Bool { manager.isListening }
    var currentDecibel: Double { manager.currentDecibel }
    var peakDecibel: Double { manager.peakDecibel }
    var currentClassifications: [SoundClassification] { manager.currentClassifications }
    var spectrumHistory: [SpectrumData] { manager.spectrumHistory }
    var soundLog: [SoundLogEntry] { manager.soundLog }
    var isRecording: Bool { manager.isRecording }
    var noiseLevel: NoiseLevel { manager.noiseLevel }
    var sessionDuration: TimeInterval { manager.sessionDuration }

    // MARK: - Statistics

    var todayTotalListeningTime: TimeInterval { manager.todayTotalListeningTime }
    var todayAverageDecibel: Double { manager.todayAverageDecibel }
    var todayPeakDecibel: Double { manager.todayPeakDecibel }
    var categoryBreakdown: [(category: SoundCategory, totalDuration: TimeInterval)] {
        manager.categoryBreakdown
    }

    // MARK: - Computed

    var sessionDurationText: String {
        let minutes = Int(sessionDuration) / 60
        let seconds = Int(sessionDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var totalListeningTimeText: String {
        let hours = Int(todayTotalListeningTime) / 3600
        let minutes = (Int(todayTotalListeningTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        }
        return "\(minutes)分"
    }

    // MARK: - Actions

    func toggleListening() {
        if isListening {
            manager.stopListening()
        } else {
            manager.startListening()
        }
    }

    func toggleRecording() {
        manager.toggleRecording()
    }
}
