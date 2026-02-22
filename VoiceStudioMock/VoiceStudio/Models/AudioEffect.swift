import Foundation
import AudioToolbox

/// エフェクトチェーン内の個別エフェクト
struct AudioEffect: Identifiable, Sendable {
    let id = UUID()
    var name: String
    var type: AudioEffectType
    var isEnabled: Bool
    var parameters: [EffectParameter]
    var order: Int
}

/// エフェクトタイプ（ポッドキャスト向けの定番エフェクト）
enum AudioEffectType: String, Sendable, CaseIterable, Identifiable {
    case noiseGate = "Noise Gate"
    case deEsser = "De-Esser"
    case compressor = "Compressor"
    case eq = "EQ"
    case limiter = "Limiter"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var systemImageName: String {
        switch self {
        case .noiseGate: "waveform.badge.minus"
        case .deEsser: "s.circle.fill"
        case .compressor: "arrow.down.right.and.arrow.up.left"
        case .eq: "slider.horizontal.3"
        case .limiter: "line.horizontal.3.decrease"
        }
    }

    var description: String {
        switch self {
        case .noiseGate: "背景ノイズを除去"
        case .deEsser: "歯擦音（サ行）を低減"
        case .compressor: "音量を均一化"
        case .eq: "周波数バランスを調整"
        case .limiter: "ピークを制限して歪みを防止"
        }
    }

    var defaultParameters: [EffectParameter] {
        switch self {
        case .noiseGate:
            [
                EffectParameter(name: "Threshold", value: -40, minValue: -80, maxValue: 0, unit: "dB"),
                EffectParameter(name: "Attack", value: 1.0, minValue: 0.1, maxValue: 50, unit: "ms"),
                EffectParameter(name: "Release", value: 50, minValue: 5, maxValue: 500, unit: "ms"),
            ]
        case .deEsser:
            [
                EffectParameter(name: "Frequency", value: 6000, minValue: 2000, maxValue: 12000, unit: "Hz"),
                EffectParameter(name: "Threshold", value: -20, minValue: -60, maxValue: 0, unit: "dB"),
                EffectParameter(name: "Reduction", value: 6, minValue: 0, maxValue: 20, unit: "dB"),
            ]
        case .compressor:
            [
                EffectParameter(name: "Threshold", value: -18, minValue: -60, maxValue: 0, unit: "dB"),
                EffectParameter(name: "Ratio", value: 3.0, minValue: 1.0, maxValue: 20.0, unit: ":1"),
                EffectParameter(name: "Attack", value: 10, minValue: 0.1, maxValue: 100, unit: "ms"),
                EffectParameter(name: "Release", value: 100, minValue: 10, maxValue: 1000, unit: "ms"),
                EffectParameter(name: "Makeup", value: 6, minValue: 0, maxValue: 24, unit: "dB"),
            ]
        case .eq:
            [
                EffectParameter(name: "Low Cut", value: 80, minValue: 20, maxValue: 300, unit: "Hz"),
                EffectParameter(name: "Low Gain", value: 0, minValue: -12, maxValue: 12, unit: "dB"),
                EffectParameter(name: "Mid Gain", value: 2, minValue: -12, maxValue: 12, unit: "dB"),
                EffectParameter(name: "High Gain", value: 1, minValue: -12, maxValue: 12, unit: "dB"),
            ]
        case .limiter:
            [
                EffectParameter(name: "Ceiling", value: -1.0, minValue: -12, maxValue: 0, unit: "dB"),
                EffectParameter(name: "Release", value: 50, minValue: 1, maxValue: 500, unit: "ms"),
            ]
        }
    }

    /// Apple 内蔵 Audio Unit の AudioComponentDescription
    var audioComponentDescription: AudioComponentDescription {
        switch self {
        case .noiseGate:
            AudioComponentDescription(
                componentType: kAudioUnitType_Effect,
                componentSubType: kAudioUnitSubType_Delay,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        case .deEsser:
            AudioComponentDescription(
                componentType: kAudioUnitType_Effect,
                componentSubType: kAudioUnitSubType_DynamicsProcessor,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        case .compressor:
            AudioComponentDescription(
                componentType: kAudioUnitType_Effect,
                componentSubType: kAudioUnitSubType_DynamicsProcessor,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        case .eq:
            AudioComponentDescription(
                componentType: kAudioUnitType_Effect,
                componentSubType: kAudioUnitSubType_NBandEQ,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        case .limiter:
            AudioComponentDescription(
                componentType: kAudioUnitType_Effect,
                componentSubType: kAudioUnitSubType_PeakLimiter,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        }
    }
}

/// エフェクトパラメータ
struct EffectParameter: Identifiable, Sendable {
    let id = UUID()
    let name: String
    var value: Float
    let minValue: Float
    let maxValue: Float
    let unit: String

    var displayValue: String {
        if abs(value) >= 100 {
            return String(format: "%.0f %@", value, unit)
        }
        return String(format: "%.1f %@", value, unit)
    }
}
