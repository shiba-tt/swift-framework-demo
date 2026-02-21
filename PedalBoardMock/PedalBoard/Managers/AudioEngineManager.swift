import Foundation
import AVFoundation
import AudioToolbox

// MARK: - AudioEngineManager（AVAudioEngine によるエフェクトチェーン管理）

@MainActor
@Observable
final class AudioEngineManager {
    static let shared = AudioEngineManager()

    // MARK: - Public State

    private(set) var isRunning = false
    private(set) var isRecording = false
    private(set) var audioMeter = AudioMeter.zero
    private(set) var tunerData = TunerData.empty
    private(set) var recordingDuration: TimeInterval = 0
    private(set) var bufferSize: AVAudioFrameCount = 256
    private(set) var sampleRate: Double = 44100

    var isTunerEnabled = false

    // MARK: - Private

    private var audioEngine: AVAudioEngine?
    private var attachedUnits: [UUID: AVAudioUnit] = [:]
    private var audioFile: AVAudioFile?
    private var meterTimer: Timer?
    private var recordingTimer: Timer?

    private init() {}

    // MARK: - Audio Session Setup

    func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .measurement,
            options: [.defaultToSpeaker, .allowBluetoothA2DP]
        )
        // 最小バッファサイズで低レイテンシー
        try session.setPreferredIOBufferDuration(Double(bufferSize) / sampleRate)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        sampleRate = session.sampleRate
    }

    // MARK: - Engine Lifecycle

    /// エフェクトチェーンを構築して AudioEngine を起動
    func startEngine(with pedals: [EffectPedal]) async throws {
        try configureAudioSession()

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let mainMixer = engine.mainMixerNode
        let format = inputNode.outputFormat(forBus: 0)

        // エフェクトチェーンを構築
        var previousNode: AVAudioNode = inputNode

        for pedal in pedals.sorted(by: { $0.order < $1.order }) where pedal.isEnabled {
            let audioUnit = try await instantiateAudioUnit(for: pedal)
            engine.attach(audioUnit)
            engine.connect(previousNode, to: audioUnit, format: format)
            attachedUnits[pedal.id] = audioUnit
            previousNode = audioUnit

            // パラメータ値を設定
            applyParameters(pedal.parameters, to: audioUnit)
        }

        // 最後のノードをメインミキサーに接続
        engine.connect(previousNode, to: mainMixer, format: format)

        // メータリング用のタップ
        installMeterTap(on: mainMixer, format: format)

        engine.prepare()
        try engine.start()

        self.audioEngine = engine
        isRunning = true

        startMeterTimer()
    }

    /// AudioEngine を停止
    func stopEngine() {
        audioEngine?.stop()
        audioEngine?.reset()
        audioEngine = nil
        attachedUnits.removeAll()
        isRunning = false
        audioMeter = .zero
        stopMeterTimer()
    }

    // MARK: - Effect Chain Management

    /// エフェクトチェーンを再構築
    func rebuildChain(with pedals: [EffectPedal]) async throws {
        stopEngine()
        try await startEngine(with: pedals)
    }

    /// 特定のペダルのパラメータを更新
    func updateParameter(pedalID: UUID, parameterName: String, value: Float) {
        guard let audioUnit = attachedUnits[pedalID],
              let paramTree = audioUnit.auAudioUnit.parameterTree
        else { return }

        // パラメータ名で検索
        for param in allParameters(in: paramTree) {
            if param.identifier == parameterName || param.displayName == parameterName {
                param.value = AUValue(value)
                return
            }
        }
    }

    /// ペダルの有効/無効を切り替え
    func togglePedal(pedalID: UUID, enabled: Bool) {
        guard let audioUnit = attachedUnits[pedalID] else { return }
        audioUnit.auAudioUnit.shouldBypassEffect = !enabled
    }

    // MARK: - Recording

    /// 録音を開始
    func startRecording() throws {
        guard let engine = audioEngine else { return }

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "PedalBoard_\(formatter.string(from: .now)).m4a"
        let fileURL = documentsURL.appendingPathComponent(fileName)

        let mainMixer = engine.mainMixerNode
        let format = mainMixer.outputFormat(forBus: 0)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: format.sampleRate,
            AVNumberOfChannelsKey: format.channelCount,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
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
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Tuner

    func startTuner() {
        isTunerEnabled = true
        // ピッチ検出の実装（YIN アルゴリズムなど）
        // 実際の実装では Accelerate フレームワークの vDSP を使用
    }

    func stopTuner() {
        isTunerEnabled = false
        tunerData = .empty
    }

    // MARK: - Private: Audio Unit Instantiation

    /// エフェクトタイプに応じた AUv3 Audio Unit をインスタンス化
    private func instantiateAudioUnit(for pedal: EffectPedal) async throws -> AVAudioUnit {
        let description = audioComponentDescription(for: pedal.type)
        return try await AVAudioUnit.instantiate(with: description)
    }

    /// エフェクトタイプから AudioComponentDescription を生成
    private func audioComponentDescription(for type: EffectType) -> AudioComponentDescription {
        // Apple 内蔵 Audio Unit を使用
        switch type {
        case .reverb:
            return AudioComponentDescription(
                componentType: kAudioUnitType_Effect,
                componentSubType: kAudioUnitSubType_Reverb2,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        case .delay:
            return AudioComponentDescription(
                componentType: kAudioUnitType_Effect,
                componentSubType: kAudioUnitSubType_Delay,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        case .distortion, .overdrive:
            return AudioComponentDescription(
                componentType: kAudioUnitType_Effect,
                componentSubType: kAudioUnitSubType_Distortion,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        case .eq:
            return AudioComponentDescription(
                componentType: kAudioUnitType_Effect,
                componentSubType: kAudioUnitSubType_NBandEQ,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        default:
            // その他はディレイでフォールバック
            return AudioComponentDescription(
                componentType: kAudioUnitType_Effect,
                componentSubType: kAudioUnitSubType_Delay,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        }
    }

    // MARK: - Private: Parameter Helpers

    private func applyParameters(_ parameters: [PedalParameter], to audioUnit: AVAudioUnit) {
        guard let paramTree = audioUnit.auAudioUnit.parameterTree else { return }
        for param in parameters {
            if let address = param.auParameterAddress {
                paramTree.parameter(withAddress: address)?.value = AUValue(param.value)
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

    private func installMeterTap(on node: AVAudioNode, format: AVAudioFormat) {
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            let level = self?.calculateRMS(buffer: buffer) ?? 0
            Task { @MainActor in
                self?.audioMeter = AudioMeter(
                    inputLevel: level,
                    outputLevel: level,
                    inputPeak: max(self?.audioMeter.inputPeak ?? 0, level),
                    outputPeak: max(self?.audioMeter.outputPeak ?? 0, level),
                    latencyMs: Double(self?.bufferSize ?? 256) / (self?.sampleRate ?? 44100) * 1000,
                    isClipping: level > 0.99
                )
            }
        }
    }

    private nonisolated func calculateRMS(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        let frames = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<frames {
            let sample = channelData[0][i]
            sum += sample * sample
        }
        return sqrt(sum / Float(frames))
    }

    private func startMeterTimer() {
        // ピークメーターの減衰タイマー
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.audioMeter = AudioMeter(
                    inputLevel: self.audioMeter.inputLevel,
                    outputLevel: self.audioMeter.outputLevel,
                    inputPeak: self.audioMeter.inputPeak * 0.95,
                    outputPeak: self.audioMeter.outputPeak * 0.95,
                    latencyMs: self.audioMeter.latencyMs,
                    isClipping: self.audioMeter.isClipping
                )
            }
        }
    }

    private func stopMeterTimer() {
        meterTimer?.invalidate()
        meterTimer = nil
    }
}
