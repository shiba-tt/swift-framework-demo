import Foundation

/// SoundForge のメイン ViewModel
@MainActor
@Observable
final class SoundForgeViewModel {
    private let engine = NodeGraphEngine.shared

    // MARK: - UI State

    var selectedTab: AppTab = .graph

    enum AppTab: String, CaseIterable, Sendable {
        case graph = "ノードグラフ"
        case presets = "プリセット"
        case plugins = "プラグイン"

        var systemImageName: String {
            switch self {
            case .graph:   return "point.3.connected.trianglepath.dotted"
            case .presets: return "slider.horizontal.3"
            case .plugins: return "puzzlepiece.extension"
            }
        }
    }

    // MARK: - State

    var nodes: [AudioNode] = []
    var presets: [NodeGraphPreset] = []
    var selectedNode: AudioNode?
    var showingAddNode = false
    var showingNodeDetail = false
    var errorMessage: String?

    var isEngineRunning: Bool { engine.isRunning }
    var inputLevel: Float { engine.inputLevel }
    var outputLevel: Float { engine.outputLevel }
    var latencyMs: Double { engine.latencyMs }
    var sampleRate: Double { engine.sampleRate }

    var effectNodes: [AudioNode] {
        nodes.filter { $0.type.category == .effect }
    }

    var ioNodes: [AudioNode] {
        nodes.filter { $0.type.category == .io }
    }

    var nodesByCategory: [(category: NodeCategory, nodes: [AudioNode])] {
        let grouped = Dictionary(grouping: nodes) { $0.type.category }
        return grouped
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { (category: $0.key, nodes: $0.value) }
    }

    var formattedLatency: String {
        String(format: "%.1f ms", latencyMs)
    }

    var formattedSampleRate: String {
        String(format: "%.0f Hz", sampleRate)
    }

    // MARK: - Setup

    func setup() {
        presets = FactoryPresets.all
    }

    // MARK: - Engine Control

    func toggleEngine() async {
        if isEngineRunning {
            engine.stopEngine()
        } else {
            do {
                try await engine.startEngine(with: nodes)
            } catch {
                errorMessage = "オーディオエンジンの起動に失敗: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Node Management

    func addNode(type: AudioNodeType) {
        let xOffset = CGFloat(nodes.count) * 160 + 50
        let node = AudioNode(
            name: type.displayName,
            type: type,
            position: NodePosition(x: xOffset, y: 200)
        )
        nodes.append(node)

        if isEngineRunning {
            Task { try? await engine.rebuildGraph(with: nodes) }
        }
    }

    func removeNode(_ node: AudioNode) {
        nodes.removeAll { $0.id == node.id }
        if selectedNode?.id == node.id {
            selectedNode = nil
        }

        if isEngineRunning {
            Task { try? await engine.rebuildGraph(with: nodes) }
        }
    }

    func toggleNode(_ node: AudioNode) {
        guard let index = nodes.firstIndex(where: { $0.id == node.id }) else { return }
        nodes[index].isEnabled.toggle()
        engine.toggleNode(nodeID: node.id, enabled: nodes[index].isEnabled)
    }

    func selectNode(_ node: AudioNode) {
        selectedNode = node
        showingNodeDetail = true
    }

    func updateParameter(nodeID: UUID, parameterIndex: Int, value: Float) {
        guard let nodeIndex = nodes.firstIndex(where: { $0.id == nodeID }),
              parameterIndex < nodes[nodeIndex].parameters.count
        else { return }

        nodes[nodeIndex].parameters[parameterIndex].value = value
        engine.updateParameter(
            nodeID: nodeID,
            parameterName: nodes[nodeIndex].parameters[parameterIndex].name,
            value: value
        )
    }

    func connectNodes(from sourceID: UUID, to destinationID: UUID) {
        guard let sourceIndex = nodes.firstIndex(where: { $0.id == sourceID }) else { return }
        if !nodes[sourceIndex].connections.contains(destinationID) {
            nodes[sourceIndex].connections.append(destinationID)
        }
    }

    func disconnectNodes(from sourceID: UUID, to destinationID: UUID) {
        guard let sourceIndex = nodes.firstIndex(where: { $0.id == sourceID }) else { return }
        nodes[sourceIndex].connections.removeAll { $0 == destinationID }
    }

    // MARK: - Preset Management

    func loadPreset(_ preset: NodeGraphPreset) {
        nodes = preset.nodeConfigs.enumerated().map { index, config in
            var node = AudioNode(
                name: config.nodeType.displayName,
                type: config.nodeType,
                position: NodePosition(x: config.positionX, y: config.positionY),
                isEnabled: config.isEnabled
            )
            // プリセットのパラメータ値を適用
            for (paramName, paramValue) in config.parameterValues {
                if let paramIndex = node.parameters.firstIndex(where: { $0.name == paramName }) {
                    node.parameters[paramIndex].value = paramValue
                }
            }
            // 接続情報を設定
            let connections = config.connectsTo.compactMap { targetIndex -> UUID? in
                guard targetIndex < preset.nodeConfigs.count else { return nil }
                return nil // ロード後に再構築
            }
            return node
        }

        // 接続情報の再構築
        for (index, config) in preset.nodeConfigs.enumerated() where index < nodes.count {
            nodes[index].connections = config.connectsTo.compactMap { targetIndex in
                guard targetIndex < nodes.count else { return nil }
                return nodes[targetIndex].id
            }
        }

        selectedTab = .graph

        if isEngineRunning {
            Task { try? await engine.rebuildGraph(with: nodes) }
        }
    }

    func saveCurrentAsPreset(name: String, category: PresetCategory) {
        let configs = nodes.enumerated().map { index, node in
            var paramValues: [String: Float] = [:]
            for param in node.parameters {
                paramValues[param.name] = param.value
            }
            let connectsTo = node.connections.compactMap { connID in
                nodes.firstIndex(where: { $0.id == connID })
            }
            return NodeConfig(
                nodeType: node.type,
                isEnabled: node.isEnabled,
                parameterValues: paramValues,
                positionX: node.position.x,
                positionY: node.position.y,
                connectsTo: connectsTo
            )
        }

        let preset = NodeGraphPreset(
            name: name,
            category: category,
            description: "カスタムプリセット",
            nodeConfigs: configs
        )
        presets.append(preset)
    }

    func togglePresetFavorite(_ preset: NodeGraphPreset) {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
        presets[index].isFavorite.toggle()
    }

    func deletePreset(_ preset: NodeGraphPreset) {
        presets.removeAll { $0.id == preset.id }
    }

    // MARK: - Quick Templates

    func loadQuickTemplate(_ template: QuickTemplate) {
        nodes.removeAll()
        for type in template.nodeTypes {
            addNode(type: type)
        }
        // 直列接続
        for i in 0..<(nodes.count - 1) {
            nodes[i].connections = [nodes[i + 1].id]
        }
    }
}

// MARK: - QuickTemplate（クイックテンプレート）

enum QuickTemplate: String, CaseIterable {
    case voiceRecording = "ボイス収録"
    case guitarChain = "ギターチェーン"
    case synthPad = "シンセパッド"
    case djSetup = "DJセットアップ"

    var emoji: String {
        switch self {
        case .voiceRecording: "🎙️"
        case .guitarChain:    "🎸"
        case .synthPad:       "🎹"
        case .djSetup:        "🎧"
        }
    }

    var nodeTypes: [AudioNodeType] {
        switch self {
        case .voiceRecording:
            [.input, .eq, .compressor, .output]
        case .guitarChain:
            [.input, .distortion, .delay, .reverb, .output]
        case .synthPad:
            [.synth, .chorus, .reverb, .output]
        case .djSetup:
            [.input, .eq, .mixer, .output]
        }
    }
}
