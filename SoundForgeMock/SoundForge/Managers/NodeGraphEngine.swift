import Foundation
import AVFoundation
import AudioToolbox
import CoreAudioKit

// MARK: - NodeGraphEngine（ノードグラフのオーディオエンジン管理）

@MainActor
@Observable
final class NodeGraphEngine {
    static let shared = NodeGraphEngine()

    // MARK: - Public State

    private(set) var isRunning = false
    private(set) var inputLevel: Float = 0
    private(set) var outputLevel: Float = 0
    private(set) var latencyMs: Double = 5.8
    private(set) var sampleRate: Double = 44100

    // MARK: - Private

    private var audioEngine: AVAudioEngine?
    private var attachedUnits: [UUID: AVAudioUnit] = [:]
    private var meterTimer: Timer?

    private init() {}

    // MARK: - Engine Lifecycle

    /// ノードグラフに基づいてオーディオエンジンを構築・起動
    func startEngine(with nodes: [AudioNode]) async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .measurement,
            options: [.defaultToSpeaker, .allowBluetoothA2DP]
        )
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        sampleRate = session.sampleRate

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let mainMixer = engine.mainMixerNode
        let format = inputNode.outputFormat(forBus: 0)

        // エフェクトノードのみを信号順に接続
        let effectNodes = nodes.filter { $0.type.category == .effect && $0.isEnabled }
        var previousNode: AVAudioNode = inputNode

        for node in effectNodes {
            let audioUnit = try await instantiateAudioUnit(for: node)
            engine.attach(audioUnit)
            engine.connect(previousNode, to: audioUnit, format: format)
            attachedUnits[node.id] = audioUnit
            applyParameters(node.parameters, to: audioUnit)
            previousNode = audioUnit
        }

        engine.connect(previousNode, to: mainMixer, format: format)
        installMeterTap(on: mainMixer, format: format)

        engine.prepare()
        try engine.start()

        self.audioEngine = engine
        isRunning = true
        startMeterTimer()
    }

    /// エンジンを停止
    func stopEngine() {
        audioEngine?.stop()
        audioEngine?.reset()
        audioEngine = nil
        attachedUnits.removeAll()
        isRunning = false
        inputLevel = 0
        outputLevel = 0
        stopMeterTimer()
    }

    /// ノードグラフの変更を反映して再構築
    func rebuildGraph(with nodes: [AudioNode]) async throws {
        stopEngine()
        try await startEngine(with: nodes)
    }

    // MARK: - Parameter Update

    func updateParameter(nodeID: UUID, parameterName: String, value: Float) {
        guard let audioUnit = attachedUnits[nodeID],
              let paramTree = audioUnit.auAudioUnit.parameterTree
        else { return }

        for param in collectParameters(from: paramTree) {
            if param.identifier == parameterName || param.displayName == parameterName {
                param.value = AUValue(value)
                return
            }
        }
    }

    func toggleNode(nodeID: UUID, enabled: Bool) {
        guard let audioUnit = attachedUnits[nodeID] else { return }
        audioUnit.auAudioUnit.shouldBypassEffect = !enabled
    }

    // MARK: - AUv3 Plugin UI

    /// AUv3 プラグインの UI を取得（CoreAudioKit）
    func requestPluginViewController(
        for nodeID: UUID
    ) async -> UIViewController? {
        guard let audioUnit = attachedUnits[nodeID] else { return nil }

        // カスタム UI を試行
        let customVC = await withCheckedContinuation { continuation in
            audioUnit.auAudioUnit.requestViewController { vc in
                continuation.resume(returning: vc)
            }
        }

        if let vc = customVC { return vc }

        // フォールバック: CoreAudioKit の汎用 UI
        let genericVC = AUGenericViewController()
        genericVC.auAudioUnit = audioUnit.auAudioUnit
        return genericVC
    }

    // MARK: - Plugin Discovery

    /// インストール済み AUv3 プラグインを検索
    func scanAvailablePlugins() -> [AVAudioUnitComponent] {
        let manager = AVAudioUnitComponentManager.shared()
        let effectDesc = AudioComponentDescription(
            componentType: kAudioUnitType_Effect,
            componentSubType: 0,
            componentManufacturer: 0,
            componentFlags: 0,
            componentFlagsMask: 0
        )
        return manager.components(matching: effectDesc)
    }

    // MARK: - Private

    private func instantiateAudioUnit(for node: AudioNode) async throws -> AVAudioUnit {
        let description = audioComponentDescription(for: node.type)
        return try await AVAudioUnit.instantiate(with: description)
    }

    private func audioComponentDescription(for type: AudioNodeType) -> AudioComponentDescription {
        switch type {
        case .reverb:
            AudioComponentDescription(componentType: kAudioUnitType_Effect, componentSubType: kAudioUnitSubType_Reverb2, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        case .delay:
            AudioComponentDescription(componentType: kAudioUnitType_Effect, componentSubType: kAudioUnitSubType_Delay, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        case .distortion:
            AudioComponentDescription(componentType: kAudioUnitType_Effect, componentSubType: kAudioUnitSubType_Distortion, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        case .eq:
            AudioComponentDescription(componentType: kAudioUnitType_Effect, componentSubType: kAudioUnitSubType_NBandEQ, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        default:
            AudioComponentDescription(componentType: kAudioUnitType_Effect, componentSubType: kAudioUnitSubType_Delay, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        }
    }

    private func applyParameters(_ parameters: [NodeParameter], to audioUnit: AVAudioUnit) {
        guard let paramTree = audioUnit.auAudioUnit.parameterTree else { return }
        let auParams = collectParameters(from: paramTree)
        for (index, param) in parameters.enumerated() where index < auParams.count {
            auParams[index].value = AUValue(param.value)
        }
    }

    private func collectParameters(from tree: AUParameterTree) -> [AUParameter] {
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

    private func installMeterTap(on node: AVAudioNode, format: AVAudioFormat) {
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            let level = self?.calculateRMS(buffer: buffer) ?? 0
            Task { @MainActor in
                self?.inputLevel = level
                self?.outputLevel = level * 0.95
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
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                // ピークの減衰
                self.inputLevel *= 0.95
                self.outputLevel *= 0.95
            }
        }
    }

    private func stopMeterTimer() {
        meterTimer?.invalidate()
        meterTimer = nil
    }
}
