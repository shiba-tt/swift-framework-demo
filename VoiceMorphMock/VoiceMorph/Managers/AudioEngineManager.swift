import AVFoundation
import Accelerate

/// AVAudioEngine を使ったリアルタイムオーディオ処理マネージャー
@MainActor
@Observable
final class AudioEngineManager {
    static let shared = AudioEngineManager()
    private init() {}

    // MARK: - State

    private(set) var isEngineRunning = false
    private(set) var isRecording = false
    private(set) var inputLevel: Float = 0
    private(set) var outputLevel: Float = 0
    private(set) var spectrumData: [Float] = Array(repeating: 0, count: 32)
    private(set) var recordingDuration: TimeInterval = 0
    private(set) var recordings: [Recording] = Recording.samples
    private(set) var errorMessage: String?

    var currentParameters: VoiceParameters = .default

    // MARK: - Audio Engine (Mock)

    /// オーディオエンジンの構成を表すモック状態
    /// 実デバイスでは AVAudioEngine + エフェクトノードを使用
    ///
    /// パイプライン:
    /// マイク → TimePitch → Reverb → EQ → Distortion → Delay → 出力
    private var mockTimer: Timer?
    private var recordingTimer: Timer?
    private var recordingStartDate: Date?

    // MARK: - Engine Control

    func startEngine() {
        guard !isEngineRunning else { return }
        isEngineRunning = true
        errorMessage = nil
        startMockAudioProcessing()
    }

    func stopEngine() {
        guard isEngineRunning else { return }
        if isRecording { stopRecording() }
        isEngineRunning = false
        stopMockAudioProcessing()
    }

    // MARK: - Recording

    func startRecording() {
        guard isEngineRunning, !isRecording else { return }
        isRecording = true
        recordingDuration = 0
        recordingStartDate = Date()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let start = self.recordingStartDate else { return }
                self.recordingDuration = Date().timeIntervalSince(start)
            }
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil

        let presetName = detectCurrentPresetName()
        let recording = Recording(
            id: UUID(),
            name: "\(presetName) 録音",
            date: Date(),
            duration: recordingDuration,
            presetName: presetName,
            fileURL: URL(fileURLWithPath: "/tmp/recording_\(UUID().uuidString).m4a")
        )
        recordings.insert(recording, at: 0)
        recordingDuration = 0
        recordingStartDate = nil
    }

    func deleteRecording(_ recording: Recording) {
        recordings.removeAll { $0.id == recording.id }
    }

    // MARK: - Parameters

    func applyPreset(_ preset: VoicePreset) {
        currentParameters = preset.parameters
    }

    func resetParameters() {
        currentParameters = .default
    }

    // MARK: - Private

    private func startMockAudioProcessing() {
        mockTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateMockLevels()
            }
        }
    }

    private func stopMockAudioProcessing() {
        mockTimer?.invalidate()
        mockTimer = nil
        inputLevel = 0
        outputLevel = 0
        spectrumData = Array(repeating: 0, count: 32)
    }

    private func updateMockLevels() {
        // 入力レベルのシミュレーション（-60dB 〜 0dB の間でランダム変動）
        let baseLevel: Float = -25
        let variation = Float.random(in: -15...15)
        inputLevel = max(-60, min(0, baseLevel + variation))

        // 出力レベル（エフェクトによるゲイン変化を反映）
        let gainOffset = (currentParameters.distortion / 100) * 6
        outputLevel = max(-60, min(0, inputLevel + gainOffset))

        // スペクトラムデータのシミュレーション
        for i in 0..<spectrumData.count {
            let freq = Float(i) / Float(spectrumData.count)
            let lowBoost = currentParameters.eqLow * (1 - freq)
            let midBoost = currentParameters.eqMid * (1 - abs(freq - 0.5) * 2)
            let highBoost = currentParameters.eqHigh * freq
            let base = Float.random(in: 0.1...0.7)
            let eqEffect = (lowBoost + midBoost + highBoost) / 40
            spectrumData[i] = min(1, max(0, base + eqEffect))
        }
    }

    private func detectCurrentPresetName() -> String {
        for preset in VoicePreset.allCases {
            if preset.parameters == currentParameters {
                return preset.rawValue
            }
        }
        return "カスタム"
    }
}
