import Foundation
import AudioToolbox

// MARK: - EffectPedal（エフェクトペダル）

struct EffectPedal: Identifiable, Sendable {
    let id: UUID
    var name: String
    var type: EffectType
    var isEnabled: Bool
    var parameters: [PedalParameter]
    var order: Int
    var presetName: String?

    init(
        name: String,
        type: EffectType,
        isEnabled: Bool = true,
        parameters: [PedalParameter] = [],
        order: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.isEnabled = isEnabled
        self.parameters = parameters
        self.order = order
        self.presetName = nil
    }

    var emoji: String { type.emoji }
    var colorName: String { type.colorName }
}

// MARK: - EffectType（エフェクトの種類）

enum EffectType: String, Sendable, CaseIterable, Identifiable {
    case overdrive = "Overdrive"
    case distortion = "Distortion"
    case delay = "Delay"
    case reverb = "Reverb"
    case chorus = "Chorus"
    case flanger = "Flanger"
    case phaser = "Phaser"
    case compressor = "Compressor"
    case eq = "EQ"
    case noiseGate = "Noise Gate"
    case tremolo = "Tremolo"
    case wah = "Wah"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .overdrive: "🔥"
        case .distortion: "⚡"
        case .delay: "🔄"
        case .reverb: "🌊"
        case .chorus: "🎵"
        case .flanger: "🌀"
        case .phaser: "🌙"
        case .compressor: "📊"
        case .eq: "🎛️"
        case .noiseGate: "🚪"
        case .tremolo: "〰️"
        case .wah: "🎸"
        }
    }

    var colorName: String {
        switch self {
        case .overdrive: "orange"
        case .distortion: "red"
        case .delay: "blue"
        case .reverb: "cyan"
        case .chorus: "purple"
        case .flanger: "indigo"
        case .phaser: "mint"
        case .compressor: "gray"
        case .eq: "green"
        case .noiseGate: "brown"
        case .tremolo: "yellow"
        case .wah: "pink"
        }
    }

    var displayName: String {
        rawValue
    }

    /// Audio Unit タイプコード（AUv3 識別用）
    var componentType: OSType {
        kAudioUnitType_Effect
    }

    /// デフォルトパラメータ定義
    var defaultParameters: [PedalParameter] {
        switch self {
        case .overdrive:
            [
                PedalParameter(name: "Drive", value: 0.5, range: 0...1, unit: ""),
                PedalParameter(name: "Tone", value: 0.6, range: 0...1, unit: ""),
                PedalParameter(name: "Level", value: 0.7, range: 0...1, unit: ""),
            ]
        case .distortion:
            [
                PedalParameter(name: "Gain", value: 0.6, range: 0...1, unit: ""),
                PedalParameter(name: "Tone", value: 0.5, range: 0...1, unit: ""),
                PedalParameter(name: "Level", value: 0.6, range: 0...1, unit: ""),
            ]
        case .delay:
            [
                PedalParameter(name: "Time", value: 0.4, range: 0.01...2.0, unit: "sec"),
                PedalParameter(name: "Feedback", value: 0.3, range: 0...0.95, unit: ""),
                PedalParameter(name: "Mix", value: 0.4, range: 0...1, unit: ""),
            ]
        case .reverb:
            [
                PedalParameter(name: "Decay", value: 0.5, range: 0.1...10.0, unit: "sec"),
                PedalParameter(name: "Damping", value: 0.5, range: 0...1, unit: ""),
                PedalParameter(name: "Mix", value: 0.3, range: 0...1, unit: ""),
            ]
        case .chorus:
            [
                PedalParameter(name: "Rate", value: 0.5, range: 0.1...10, unit: "Hz"),
                PedalParameter(name: "Depth", value: 0.5, range: 0...1, unit: ""),
                PedalParameter(name: "Mix", value: 0.5, range: 0...1, unit: ""),
            ]
        case .flanger:
            [
                PedalParameter(name: "Rate", value: 0.3, range: 0.05...5, unit: "Hz"),
                PedalParameter(name: "Depth", value: 0.7, range: 0...1, unit: ""),
                PedalParameter(name: "Feedback", value: 0.5, range: 0...0.95, unit: ""),
            ]
        case .phaser:
            [
                PedalParameter(name: "Rate", value: 0.4, range: 0.05...5, unit: "Hz"),
                PedalParameter(name: "Depth", value: 0.6, range: 0...1, unit: ""),
                PedalParameter(name: "Stages", value: 4, range: 2...12, unit: ""),
            ]
        case .compressor:
            [
                PedalParameter(name: "Threshold", value: -20, range: -60...0, unit: "dB"),
                PedalParameter(name: "Ratio", value: 4, range: 1...20, unit: ":1"),
                PedalParameter(name: "Attack", value: 10, range: 0.1...100, unit: "ms"),
                PedalParameter(name: "Release", value: 100, range: 10...1000, unit: "ms"),
            ]
        case .eq:
            [
                PedalParameter(name: "Low", value: 0, range: -12...12, unit: "dB"),
                PedalParameter(name: "Mid", value: 0, range: -12...12, unit: "dB"),
                PedalParameter(name: "High", value: 0, range: -12...12, unit: "dB"),
            ]
        case .noiseGate:
            [
                PedalParameter(name: "Threshold", value: -40, range: -80...0, unit: "dB"),
                PedalParameter(name: "Release", value: 50, range: 5...500, unit: "ms"),
            ]
        case .tremolo:
            [
                PedalParameter(name: "Rate", value: 5, range: 0.5...20, unit: "Hz"),
                PedalParameter(name: "Depth", value: 0.6, range: 0...1, unit: ""),
            ]
        case .wah:
            [
                PedalParameter(name: "Position", value: 0.5, range: 0...1, unit: ""),
                PedalParameter(name: "Q", value: 5, range: 1...15, unit: ""),
            ]
        }
    }
}

// MARK: - PedalParameter（ペダルパラメータ）

struct PedalParameter: Identifiable, Sendable {
    let id: UUID
    let name: String
    var value: Float
    let range: ClosedRange<Float>
    let unit: String
    var auParameterAddress: AUParameterAddress?

    init(
        name: String,
        value: Float,
        range: ClosedRange<Float>,
        unit: String,
        auParameterAddress: AUParameterAddress? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.value = value
        self.range = range
        self.unit = unit
        self.auParameterAddress = auParameterAddress
    }

    var normalizedValue: Float {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    var formattedValue: String {
        if unit.isEmpty {
            return String(format: "%.1f", value)
        }
        return String(format: "%.1f %@", value, unit)
    }
}
