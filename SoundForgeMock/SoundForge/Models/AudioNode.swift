import Foundation
import AudioToolbox

// MARK: - AudioNode（ノードグラフ上のオーディオノード）

struct AudioNode: Identifiable, Sendable {
    let id: UUID
    var name: String
    var type: AudioNodeType
    var position: NodePosition
    var isEnabled: Bool
    var parameters: [NodeParameter]
    var connections: [UUID]

    init(
        name: String,
        type: AudioNodeType,
        position: NodePosition = .zero,
        isEnabled: Bool = true,
        parameters: [NodeParameter] = [],
        connections: [UUID] = []
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.position = position
        self.isEnabled = isEnabled
        self.parameters = parameters.isEmpty ? type.defaultParameters : parameters
        self.connections = connections
    }

    var emoji: String { type.emoji }
    var colorName: String { type.colorName }
}

// MARK: - NodePosition（ノードの位置）

struct NodePosition: Sendable {
    var x: CGFloat
    var y: CGFloat

    static let zero = NodePosition(x: 0, y: 0)
}

// MARK: - AudioNodeType（ノードの種類）

enum AudioNodeType: String, Sendable, CaseIterable, Identifiable {
    case input = "Input"
    case output = "Output"
    case eq = "EQ"
    case reverb = "Reverb"
    case delay = "Delay"
    case compressor = "Compressor"
    case distortion = "Distortion"
    case chorus = "Chorus"
    case synth = "Synth"
    case sampler = "Sampler"
    case mixer = "Mixer"
    case meter = "Meter"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .input:      "🎤"
        case .output:     "🔊"
        case .eq:         "🎛️"
        case .reverb:     "🌊"
        case .delay:      "🔄"
        case .compressor: "📊"
        case .distortion: "⚡"
        case .chorus:     "🎵"
        case .synth:      "🎹"
        case .sampler:    "🥁"
        case .mixer:      "🎚️"
        case .meter:      "📈"
        }
    }

    var colorName: String {
        switch self {
        case .input:      "green"
        case .output:     "red"
        case .eq:         "blue"
        case .reverb:     "cyan"
        case .delay:      "purple"
        case .compressor: "gray"
        case .distortion: "orange"
        case .chorus:     "indigo"
        case .synth:      "pink"
        case .sampler:    "brown"
        case .mixer:      "yellow"
        case .meter:      "mint"
        }
    }

    var displayName: String { rawValue }

    var category: NodeCategory {
        switch self {
        case .input, .output:
            return .io
        case .eq, .reverb, .delay, .compressor, .distortion, .chorus:
            return .effect
        case .synth, .sampler:
            return .instrument
        case .mixer, .meter:
            return .utility
        }
    }

    var componentType: OSType {
        switch self {
        case .input, .output, .mixer, .meter:
            kAudioUnitType_Effect
        case .eq, .reverb, .delay, .compressor, .distortion, .chorus:
            kAudioUnitType_Effect
        case .synth, .sampler:
            kAudioUnitType_MusicDevice
        }
    }

    var defaultParameters: [NodeParameter] {
        switch self {
        case .input:
            [
                NodeParameter(name: "Gain", value: 1.0, range: 0...2, unit: ""),
            ]
        case .output:
            [
                NodeParameter(name: "Volume", value: 0.8, range: 0...1, unit: ""),
            ]
        case .eq:
            [
                NodeParameter(name: "Low", value: 0, range: -12...12, unit: "dB"),
                NodeParameter(name: "Mid", value: 0, range: -12...12, unit: "dB"),
                NodeParameter(name: "High", value: 0, range: -12...12, unit: "dB"),
            ]
        case .reverb:
            [
                NodeParameter(name: "Decay", value: 1.5, range: 0.1...10, unit: "sec"),
                NodeParameter(name: "Mix", value: 0.3, range: 0...1, unit: ""),
            ]
        case .delay:
            [
                NodeParameter(name: "Time", value: 0.4, range: 0.01...2, unit: "sec"),
                NodeParameter(name: "Feedback", value: 0.3, range: 0...0.95, unit: ""),
                NodeParameter(name: "Mix", value: 0.4, range: 0...1, unit: ""),
            ]
        case .compressor:
            [
                NodeParameter(name: "Threshold", value: -20, range: -60...0, unit: "dB"),
                NodeParameter(name: "Ratio", value: 4, range: 1...20, unit: ":1"),
            ]
        case .distortion:
            [
                NodeParameter(name: "Drive", value: 0.5, range: 0...1, unit: ""),
                NodeParameter(name: "Tone", value: 0.6, range: 0...1, unit: ""),
            ]
        case .chorus:
            [
                NodeParameter(name: "Rate", value: 0.5, range: 0.1...10, unit: "Hz"),
                NodeParameter(name: "Depth", value: 0.5, range: 0...1, unit: ""),
            ]
        case .synth:
            [
                NodeParameter(name: "Oscillator", value: 0, range: 0...3, unit: ""),
                NodeParameter(name: "Cutoff", value: 0.7, range: 0...1, unit: ""),
                NodeParameter(name: "Resonance", value: 0.3, range: 0...1, unit: ""),
            ]
        case .sampler:
            [
                NodeParameter(name: "Volume", value: 0.8, range: 0...1, unit: ""),
                NodeParameter(name: "Pan", value: 0, range: -1...1, unit: ""),
            ]
        case .mixer:
            [
                NodeParameter(name: "Channel 1", value: 0.8, range: 0...1, unit: ""),
                NodeParameter(name: "Channel 2", value: 0.8, range: 0...1, unit: ""),
            ]
        case .meter:
            []
        }
    }
}

// MARK: - NodeCategory（ノードカテゴリ）

enum NodeCategory: String, Sendable, CaseIterable {
    case io = "入出力"
    case effect = "エフェクト"
    case instrument = "インストゥルメント"
    case utility = "ユーティリティ"

    var systemImage: String {
        switch self {
        case .io:         "arrow.left.arrow.right"
        case .effect:     "waveform.badge.plus"
        case .instrument: "pianokeys"
        case .utility:    "wrench.and.screwdriver"
        }
    }
}

// MARK: - NodeParameter（ノードパラメータ）

struct NodeParameter: Identifiable, Sendable {
    let id: UUID
    let name: String
    var value: Float
    let range: ClosedRange<Float>
    let unit: String

    init(
        name: String,
        value: Float,
        range: ClosedRange<Float>,
        unit: String
    ) {
        self.id = UUID()
        self.name = name
        self.value = value
        self.range = range
        self.unit = unit
    }

    var normalizedValue: Float {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    var formattedValue: String {
        if unit.isEmpty {
            return String(format: "%.2f", value)
        }
        return String(format: "%.1f %@", value, unit)
    }
}
