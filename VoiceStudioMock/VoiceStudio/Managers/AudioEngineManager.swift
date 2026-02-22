import Foundation
import AVFoundation
import AudioToolbox

/// AVAudioEngine + AUv3 によるエフェクトチェーン管理
@MainActor
@Observable
final class AudioEngineManager {
    static let shared = AudioEngineManager()

    // MARK: - Public State

    private(set) var isRunning = false
    private(set) var isRecording = false
    private(set) var audioMeter = VoiceAudioMeter.zero
    private(set) var recordingDuration: TimeInterval = 0
    private(set) var sampleRate: Double = 48000

    // MARK: - Private

    private var audioEngine: AVAudioEngine?
    private var attachedUnits: [UUID: AVAudioUnit] = [:]
    private var audioFile: AVAudioFile?
    private var meterTimer: Timer?
    private var recordingTimer: Timer?

    private init() {}

    // MARK: - Audio Session

    func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .allowBluetoothA2DP]
        )
        try session.setPreferredSampleRate(48000)
        try session.setPreferredIOBufferDuration(0.005) // 5ms バッファ
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        sampleRate = session.sampleRate
    }

    // MARK: - Engine Lifecycle

    /// エフェクトチェーンを構築して AudioEngine を起動
    func startEngine(with effects: [AudioEffect]) async throws {
        try configureAudioSession()

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let mainMixer = engine.mainMixerNode
        let format = inputNode.outputFormat(forBus: 0)

        // エフェクトチェーンを順番に接続
        // Mic → Gate → DeEsser → Comp → EQ → Limiter → Output
        var previousNode: AVAudioNode = inputNode

        for effect in effects.sorted(by: { $0.order < $1.order }) where effect.isEnabled {
            let audioUnit = try await instantiateAudioUnit(for: effect)
            engine.attach(audioUnit)
            engine.connect(previousNode, to: audioUnit, format: format)
            attachedUnits[effect.id] = audioUnit
            previousNode = audioUnit

            applyParameters(effect.parameters, to: audioUnit)
        }

        engine.connect(previousNode, to: mainMixer, format: format)

        // メータリングタップ（入力）
        installInputMeterTap(on: inputNode, format: format)
        // メータリングタップ（出力）
        installOutputMeterTap(on: mainMixer, format: format)

        engine.prepare()
        try engine.start()

        self.audioEngine = engine
        isRunning = true
        startMeterTimer()
    }

    /// AudioEngine を停止
    func stopEngine() {
        if isRecording { stopRecording() }
        audioEngine?.stop()
        audioEngine?.reset()
        audioEngine = nil
        attachedUnits.removeAll()
        isRunning = false
        audioMeter = .zero
        stopMeterTimer()
    }

    // MARK: - Effect Chain

    /// チェーンを再構築
    func rebuildChain(with effects: [AudioEffect]) async throws {
        stopEngine()
        try await startEngine(with: effects)
    }

    /// エフェクトのバイパス切替
    func toggleEffect(effectID: UUID, enabled: Bool) {
        guard let audioUnit = attachedUnits[effectID] else { return }
        audioUnit.auAudioUnit.shouldBypassEffect = !enabled
    }

    /// パラメータ更新
    func updateParameter(effectID: UUID, parameterName: String, value: Float) {
        guard let audioUnit = attachedUnits[effectID],
              let paramTree = audioUnit.auAudioUnit.parameterTree
        else { return }

        for param in allParameters(in: paramTree) {
            if param.identifier == parameterName || param.displayName == parameterName {
                param.value = AUValue(value)
                return
            }
        }
    }

    // MARK: - Recording

    /// 録音を開始
    func startRecording(fileName: String) throws {
        guard let engine = audioEngine else { return }

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)

        let mainMixer = engine.mainMixerNode
        let format = mainMixer.outputFormat(forBus: 0)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: format.sampleRate,
            AVNumberOfChannelsKey: format.channelCount,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 256000,
        ]

        audioFile = try AVAudioFile(forWriting: fileURL, settings: settings)
        recordingDuration = 0

        mainMixer.installTap(onBus: 1, bufferSize: 4096, format: format) { [weak self] buffer, _ in
            try? self?.audioFile?.write(from: buffer)
        }

        isRecording = true

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordingDuration += 0.1
            }
        }
    }

    /// 録音を停止
    func stopRecording() {
        guard let engine = audioEngine else { return }
        engine.mainMixerNode.removeTap(onBus: 1)
        audioFile = nil
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    var formattedRecordingDuration: String {
        let hours = Int(recordingDuration) / 3600
        let minutes = (Int(recordingDuration) % 3600) / 60
        let seconds = Int(recordingDuration) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Private: Instantiation

    private func instantiateAudioUnit(for effect: AudioEffect) async throws -> AVAudioUnit {
        try await AVAudioUnit.instantiate(with: effect.type.audioComponentDescription)
    }

    private func applyParameters(_ parameters: [EffectParameter], to audioUnit: AVAudioUnit) {
        guard let paramTree = audioUnit.auAudioUnit.parameterTree else { return }
        for (index, param) in parameters.enumerated() {
            if index < paramTree.allParameters.count {
                paramTree.allParameters[index].value = AUValue(param.value)
            }
        }
    }

    private func allParameters(in tree: AUParameterTree) -> [AUParameter] {
        var result: [AUParameter] = []
        func collect(_ node: AUParameterNode) {
            if let param = node as? AUParameter {
                result.append(param)
            } else if let group = node as? AUParameterGroup {
                group.children.forEach { collect($0) }
            }
        }
        tree.children.forEach { collect($0) }
        return result
    }

    // MARK: - Private: Metering

    private var lastInputLevel: Float = 0
    private var lastOutputLevel: Float = 0

    private func installInputMeterTap(on node: AVAudioNode, format: AVAudioFormat) {
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            let level = self?.calculateRMS(buffer: buffer) ?? 0
            Task { @MainActor in
                self?.lastInputLevel = level
            }
        }
    }

    private func installOutputMeterTap(on node: AVAudioNode, format: AVAudioFormat) {
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            let level = self?.calculateRMS(buffer: buffer) ?? 0
            Task { @MainActor in
                self?.lastOutputLevel = level
            }
        }
    }

    private nonisolated func calculateRMS(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        let frames = Int(buffer.frameLength)
        guard frames > 0 else { return 0 }
        var sum: Float = 0
        for i in 0..<frames {
            let sample = channelData[0][i]
            sum += sample * sample
        }
        return sqrt(sum / Float(frames))
    }

    private func startMeterTimer() {
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let inputDB = 20 * log10(max(self.lastInputLevel, 0.00001))
                let outputDB = 20 * log10(max(self.lastOutputLevel, 0.00001))
                let gainReduction = max(0, inputDB - outputDB)
                // 簡易 LUFS 推定（短期 LUFS）
                let lufs = Double(outputDB) - 0.691

                self.audioMeter = VoiceAudioMeter(
                    inputLevel: self.lastInputLevel,
                    outputLevel: self.lastOutputLevel,
                    gainReduction: gainReduction,
                    lufs: lufs,
                    inputPeak: max(self.audioMeter.inputPeak * 0.95, self.lastInputLevel),
                    outputPeak: max(self.audioMeter.outputPeak * 0.95, self.lastOutputLevel),
                    isClipping: self.lastOutputLevel > 0.99
                )
            }
        }
    }

    private func stopMeterTimer() {
        meterTimer?.invalidate()
        meterTimer = nil
    }
}
