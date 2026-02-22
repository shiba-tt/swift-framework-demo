import Foundation

/// VoiceMorph のメイン ViewModel
@MainActor
@Observable
final class VoiceMorphViewModel {
    private let audioManager = AudioEngineManager.shared

    // MARK: - UI State

    var selectedPreset: VoicePreset? = nil
    var showingCustomParameters = false
    var showingRecordings = false
    var selectedTab: AppTab = .morph

    enum AppTab: String, CaseIterable, Sendable {
        case morph = "モーフ"
        case recordings = "録音"

        var systemImageName: String {
            switch self {
            case .morph:      return "waveform.circle.fill"
            case .recordings: return "list.bullet"
            }
        }
    }

    // MARK: - Computed Properties

    var isEngineRunning: Bool { audioManager.isEngineRunning }
    var isRecording: Bool { audioManager.isRecording }
    var inputLevel: Float { audioManager.inputLevel }
    var outputLevel: Float { audioManager.outputLevel }
    var spectrumData: [Float] { audioManager.spectrumData }
    var recordingDuration: TimeInterval { audioManager.recordingDuration }
    var recordings: [Recording] { audioManager.recordings }
    var errorMessage: String? { audioManager.errorMessage }
    var parameters: VoiceParameters {
        get { audioManager.currentParameters }
        set { audioManager.currentParameters = newValue }
    }

    var recordingDurationText: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        let centiseconds = Int((recordingDuration.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%d:%02d.%02d", minutes, seconds, centiseconds)
    }

    var inputLevelNormalized: Float {
        // -60dB 〜 0dB → 0 〜 1
        max(0, min(1, (inputLevel + 60) / 60))
    }

    var outputLevelNormalized: Float {
        max(0, min(1, (outputLevel + 60) / 60))
    }

    var inputLevelText: String {
        String(format: "%.0f dB", inputLevel)
    }

    // MARK: - Actions

    func toggleEngine() {
        if isEngineRunning {
            audioManager.stopEngine()
            selectedPreset = nil
        } else {
            audioManager.startEngine()
        }
    }

    func selectPreset(_ preset: VoicePreset) {
        if selectedPreset == preset {
            selectedPreset = nil
            audioManager.resetParameters()
        } else {
            selectedPreset = preset
            audioManager.applyPreset(preset)
        }
    }

    func toggleRecording() {
        if isRecording {
            audioManager.stopRecording()
        } else {
            audioManager.startRecording()
        }
    }

    func deleteRecording(_ recording: Recording) {
        audioManager.deleteRecording(recording)
    }

    func resetToDefault() {
        selectedPreset = nil
        audioManager.resetParameters()
    }
}
