import Foundation

// MARK: - NodeGraphPreset（ノードグラフのプリセット）

struct NodeGraphPreset: Identifiable, Sendable {
    let id: UUID
    let name: String
    let category: PresetCategory
    let description: String
    let nodeConfigs: [NodeConfig]
    var isFavorite: Bool

    init(
        name: String,
        category: PresetCategory,
        description: String,
        nodeConfigs: [NodeConfig],
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.description = description
        self.nodeConfigs = nodeConfigs
        self.isFavorite = isFavorite
    }
}

// MARK: - NodeConfig（ノード設定）

struct NodeConfig: Sendable {
    let nodeType: AudioNodeType
    let isEnabled: Bool
    let parameterValues: [String: Float]
    let positionX: CGFloat
    let positionY: CGFloat
    let connectsTo: [Int]
}

// MARK: - PresetCategory

enum PresetCategory: String, Sendable, CaseIterable {
    case recording = "レコーディング"
    case podcast = "ポッドキャスト"
    case music = "音楽制作"
    case live = "ライブ"
    case mastering = "マスタリング"

    var emoji: String {
        switch self {
        case .recording:  "🎙️"
        case .podcast:    "🎧"
        case .music:      "🎵"
        case .live:       "🎤"
        case .mastering:  "💿"
        }
    }
}

// MARK: - FactoryPresets

enum FactoryPresets {
    static let all: [NodeGraphPreset] = [
        NodeGraphPreset(
            name: "ポッドキャスト基本",
            category: .podcast,
            description: "ボイス収録に最適な基本構成",
            nodeConfigs: [
                NodeConfig(nodeType: .input, isEnabled: true, parameterValues: ["Gain": 1.2], positionX: 50, positionY: 200, connectsTo: [1]),
                NodeConfig(nodeType: .eq, isEnabled: true, parameterValues: ["Low": -3, "Mid": 2, "High": 1], positionX: 200, positionY: 200, connectsTo: [2]),
                NodeConfig(nodeType: .compressor, isEnabled: true, parameterValues: ["Threshold": -18, "Ratio": 3], positionX: 350, positionY: 200, connectsTo: [3]),
                NodeConfig(nodeType: .output, isEnabled: true, parameterValues: ["Volume": 0.85], positionX: 500, positionY: 200, connectsTo: []),
            ]
        ),
        NodeGraphPreset(
            name: "アンビエント・シンセ",
            category: .music,
            description: "シンセとリバーブで空間的なサウンド",
            nodeConfigs: [
                NodeConfig(nodeType: .synth, isEnabled: true, parameterValues: ["Oscillator": 1, "Cutoff": 0.4, "Resonance": 0.5], positionX: 50, positionY: 150, connectsTo: [1]),
                NodeConfig(nodeType: .chorus, isEnabled: true, parameterValues: ["Rate": 0.3, "Depth": 0.7], positionX: 200, positionY: 150, connectsTo: [2]),
                NodeConfig(nodeType: .reverb, isEnabled: true, parameterValues: ["Decay": 5.0, "Mix": 0.6], positionX: 350, positionY: 150, connectsTo: [3]),
                NodeConfig(nodeType: .delay, isEnabled: true, parameterValues: ["Time": 0.5, "Feedback": 0.4, "Mix": 0.3], positionX: 350, positionY: 300, connectsTo: [3]),
                NodeConfig(nodeType: .output, isEnabled: true, parameterValues: ["Volume": 0.7], positionX: 500, positionY: 200, connectsTo: []),
            ]
        ),
        NodeGraphPreset(
            name: "ギター録音",
            category: .recording,
            description: "ギター録音用のエフェクトチェーン",
            nodeConfigs: [
                NodeConfig(nodeType: .input, isEnabled: true, parameterValues: ["Gain": 1.0], positionX: 50, positionY: 200, connectsTo: [1]),
                NodeConfig(nodeType: .distortion, isEnabled: true, parameterValues: ["Drive": 0.4, "Tone": 0.6], positionX: 200, positionY: 200, connectsTo: [2]),
                NodeConfig(nodeType: .delay, isEnabled: true, parameterValues: ["Time": 0.35, "Feedback": 0.25, "Mix": 0.3], positionX: 350, positionY: 200, connectsTo: [3]),
                NodeConfig(nodeType: .reverb, isEnabled: true, parameterValues: ["Decay": 1.2, "Mix": 0.2], positionX: 500, positionY: 200, connectsTo: [4]),
                NodeConfig(nodeType: .output, isEnabled: true, parameterValues: ["Volume": 0.8], positionX: 650, positionY: 200, connectsTo: []),
            ]
        ),
        NodeGraphPreset(
            name: "マスタリング",
            category: .mastering,
            description: "ステレオマスタリング用の基本チェーン",
            nodeConfigs: [
                NodeConfig(nodeType: .input, isEnabled: true, parameterValues: ["Gain": 1.0], positionX: 50, positionY: 200, connectsTo: [1]),
                NodeConfig(nodeType: .eq, isEnabled: true, parameterValues: ["Low": 1, "Mid": 0, "High": 0.5], positionX: 200, positionY: 200, connectsTo: [2]),
                NodeConfig(nodeType: .compressor, isEnabled: true, parameterValues: ["Threshold": -12, "Ratio": 2], positionX: 350, positionY: 200, connectsTo: [3]),
                NodeConfig(nodeType: .meter, isEnabled: true, parameterValues: [:], positionX: 350, positionY: 350, connectsTo: []),
                NodeConfig(nodeType: .output, isEnabled: true, parameterValues: ["Volume": 0.9], positionX: 500, positionY: 200, connectsTo: []),
            ]
        ),
        NodeGraphPreset(
            name: "ライブパフォーマンス",
            category: .live,
            description: "ライブステージ向けのリアルタイムエフェクト",
            nodeConfigs: [
                NodeConfig(nodeType: .input, isEnabled: true, parameterValues: ["Gain": 1.0], positionX: 50, positionY: 200, connectsTo: [1]),
                NodeConfig(nodeType: .eq, isEnabled: true, parameterValues: ["Low": -2, "Mid": 1, "High": 2], positionX: 200, positionY: 200, connectsTo: [2]),
                NodeConfig(nodeType: .compressor, isEnabled: true, parameterValues: ["Threshold": -15, "Ratio": 4], positionX: 350, positionY: 200, connectsTo: [3]),
                NodeConfig(nodeType: .reverb, isEnabled: true, parameterValues: ["Decay": 0.8, "Mix": 0.15], positionX: 500, positionY: 200, connectsTo: [4]),
                NodeConfig(nodeType: .output, isEnabled: true, parameterValues: ["Volume": 0.85], positionX: 650, positionY: 200, connectsTo: []),
            ]
        ),
    ]
}
