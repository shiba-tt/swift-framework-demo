import SwiftUI

// MARK: - AUPlugin

struct AUPlugin: Identifiable, Sendable {
    let id: UUID
    let name: String
    let manufacturer: String
    let category: AUPluginCategory
    let version: String
    let rating: Double
    let reviewCount: Int
    let hasCustomUI: Bool
    let parameterCount: Int
    let presetCount: Int
    let latencyMs: Double
    let cpuLoad: Double
    let description: String
    let tags: [String]

    var ratingStars: String {
        let full = Int(rating)
        let half = rating - Double(full) >= 0.5
        var stars = String(repeating: "★", count: full)
        if half { stars += "☆" }
        return stars
    }

    var ratingText: String {
        String(format: "%.1f", rating)
    }

    var cpuLoadText: String {
        String(format: "%.1f%%", cpuLoad)
    }

    var latencyText: String {
        String(format: "%.1fms", latencyMs)
    }
}

// MARK: - AUPluginCategory

enum AUPluginCategory: String, Sendable, CaseIterable, Identifiable {
    case eq = "EQ"
    case compressor = "Comp"
    case reverb = "Reverb"
    case delay = "Delay"
    case distortion = "Dist"
    case synth = "Synth"
    case modulation = "Mod"
    case utility = "Utility"

    var id: String { rawValue }

    var fullName: String {
        switch self {
        case .eq: return "イコライザー"
        case .compressor: return "コンプレッサー"
        case .reverb: return "リバーブ"
        case .delay: return "ディレイ"
        case .distortion: return "ディストーション"
        case .synth: return "シンセサイザー"
        case .modulation: return "モジュレーション"
        case .utility: return "ユーティリティ"
        }
    }

    var emoji: String {
        switch self {
        case .eq: return "📊"
        case .compressor: return "🗜️"
        case .reverb: return "🌊"
        case .delay: return "🔄"
        case .distortion: return "🔥"
        case .synth: return "🎹"
        case .modulation: return "🌀"
        case .utility: return "🔧"
        }
    }

    var color: Color {
        switch self {
        case .eq: return .blue
        case .compressor: return .orange
        case .reverb: return .cyan
        case .delay: return .green
        case .distortion: return .red
        case .synth: return .purple
        case .modulation: return .pink
        case .utility: return .gray
        }
    }

    var auType: String {
        switch self {
        case .synth: return "aumu"
        default: return "aufx"
        }
    }

    var auTypeDescription: String {
        switch self {
        case .synth: return "Music Instrument"
        default: return "Effect"
        }
    }
}

// MARK: - AUPluginParameter

struct AUPluginParameter: Identifiable, Sendable {
    let id: UUID
    let name: String
    let unit: String
    let minValue: Float
    let maxValue: Float
    var currentValue: Float
    let defaultValue: Float

    var normalizedValue: Float {
        guard maxValue > minValue else { return 0 }
        return (currentValue - minValue) / (maxValue - minValue)
    }

    var displayValue: String {
        if unit == "Hz" && currentValue >= 1000 {
            return String(format: "%.1f kHz", currentValue / 1000)
        }
        return String(format: "%.1f %@", currentValue, unit)
    }
}

// MARK: - AudioSource

enum AudioSource: String, Sendable, CaseIterable, Identifiable {
    case vocal = "ボーカル"
    case guitar = "ギター"
    case drums = "ドラム"
    case piano = "ピアノ"
    case fullMix = "フルミックス"
    case microphone = "マイク入力"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .vocal: return "🎤"
        case .guitar: return "🎸"
        case .drums: return "🥁"
        case .piano: return "🎹"
        case .fullMix: return "🎵"
        case .microphone: return "🎙️"
        }
    }
}

// MARK: - ABCompareSlot

enum ABCompareSlot: String, Sendable {
    case slotA = "A"
    case slotB = "B"

    var color: Color {
        switch self {
        case .slotA: return .blue
        case .slotB: return .orange
        }
    }
}

// MARK: - Sample Data

extension AUPlugin {
    static let samples: [AUPlugin] = [
        AUPlugin(
            id: UUID(), name: "Pro-Q 3", manufacturer: "FabFilter",
            category: .eq, version: "3.2.1", rating: 4.9, reviewCount: 1250,
            hasCustomUI: true, parameterCount: 24, presetCount: 40,
            latencyMs: 0.0, cpuLoad: 2.3,
            description: "業界標準のパラメトリック EQ。最大 24 バンドの精密な周波数制御。ダイナミック EQ モード搭載。",
            tags: ["パラメトリック", "ダイナミック", "リニアフェーズ"]
        ),
        AUPlugin(
            id: UUID(), name: "Pro-C 2", manufacturer: "FabFilter",
            category: .compressor, version: "2.1.5", rating: 4.8, reviewCount: 890,
            hasCustomUI: true, parameterCount: 16, presetCount: 35,
            latencyMs: 0.0, cpuLoad: 1.8,
            description: "透明感のあるコンプレッション。8 つのコンプレッションスタイルを搭載。サイドチェーン対応。",
            tags: ["マルチバンド", "サイドチェーン", "リミッター"]
        ),
        AUPlugin(
            id: UUID(), name: "Valhalla Shimmer", manufacturer: "Valhalla DSP",
            category: .reverb, version: "1.1.2", rating: 4.9, reviewCount: 2100,
            hasCustomUI: true, parameterCount: 12, presetCount: 100,
            latencyMs: 0.0, cpuLoad: 3.5,
            description: "ピッチシフトリバーブ。無限に広がるアンビエントサウンドを生成。シンプルな操作で深い音空間を実現。",
            tags: ["ピッチシフト", "アンビエント", "パッド"]
        ),
        AUPlugin(
            id: UUID(), name: "EchoBoy", manufacturer: "Soundtoys",
            category: .delay, version: "5.4.0", rating: 4.7, reviewCount: 780,
            hasCustomUI: true, parameterCount: 18, presetCount: 60,
            latencyMs: 0.0, cpuLoad: 2.1,
            description: "アナログディレイのエミュレーション。テープ / BBD / デジタルの豊富なディレイスタイル。",
            tags: ["アナログ", "テープ", "リズムシンク"]
        ),
        AUPlugin(
            id: UUID(), name: "Decapitator", manufacturer: "Soundtoys",
            category: .distortion, version: "5.4.0", rating: 4.6, reviewCount: 650,
            hasCustomUI: true, parameterCount: 10, presetCount: 45,
            latencyMs: 0.0, cpuLoad: 1.5,
            description: "アナログサチュレーション / ディストーション。5 つのサチュレーションスタイルで倍音を付加。",
            tags: ["サチュレーション", "アナログ", "ウォーム"]
        ),
        AUPlugin(
            id: UUID(), name: "Model 15", manufacturer: "Moog",
            category: .synth, version: "2.3.0", rating: 4.9, reviewCount: 3200,
            hasCustomUI: true, parameterCount: 56, presetCount: 400,
            latencyMs: 5.0, cpuLoad: 4.2,
            description: "Moog Model 15 モジュラーシンセの完全再現。パッチケーブルによるモジュール接続。",
            tags: ["モジュラー", "アナログ", "クラシック"]
        ),
        AUPlugin(
            id: UUID(), name: "TDR Nova", manufacturer: "Tokyo Dawn Records",
            category: .eq, version: "2.1.7", rating: 4.5, reviewCount: 520,
            hasCustomUI: true, parameterCount: 20, presetCount: 25,
            latencyMs: 0.0, cpuLoad: 1.9,
            description: "ダイナミック EQ とワイドバンドコンプレッサーのハイブリッド。無料版から始められる高品質 EQ。",
            tags: ["ダイナミック", "ワイドバンド", "フリーミアム"]
        ),
        AUPlugin(
            id: UUID(), name: "BlackHole", manufacturer: "Eventide",
            category: .reverb, version: "2.8.1", rating: 4.4, reviewCount: 430,
            hasCustomUI: true, parameterCount: 14, presetCount: 50,
            latencyMs: 0.0, cpuLoad: 3.8,
            description: "インフィニット・リバーブ。ブラックホールに吸い込まれるような深い残響空間。",
            tags: ["インフィニット", "スペース", "エクスペリメンタル"]
        ),
        AUPlugin(
            id: UUID(), name: "Dimension-D", manufacturer: "Roland Cloud",
            category: .modulation, version: "1.2.0", rating: 4.3, reviewCount: 310,
            hasCustomUI: true, parameterCount: 6, presetCount: 4,
            latencyMs: 1.0, cpuLoad: 1.2,
            description: "伝説のコーラス / アンサンブルエフェクト Roland SDD-320 の再現。4 つのボタンでシンプル操作。",
            tags: ["コーラス", "アンサンブル", "ヴィンテージ"]
        ),
        AUPlugin(
            id: UUID(), name: "Gain Utility", manufacturer: "Apple",
            category: .utility, version: "1.0.0", rating: 4.0, reviewCount: 150,
            hasCustomUI: false, parameterCount: 3, presetCount: 0,
            latencyMs: 0.0, cpuLoad: 0.1,
            description: "シンプルなゲイン・パン・フェーズ調整ユーティリティ。Apple 純正。",
            tags: ["ゲイン", "パン", "フェーズ"]
        ),
    ]

    static func sampleParameters(for plugin: AUPlugin) -> [AUPluginParameter] {
        switch plugin.category {
        case .eq:
            return [
                AUPluginParameter(id: UUID(), name: "Band 1 Freq", unit: "Hz", minValue: 20, maxValue: 20000, currentValue: 100, defaultValue: 100),
                AUPluginParameter(id: UUID(), name: "Band 1 Gain", unit: "dB", minValue: -24, maxValue: 24, currentValue: 3.5, defaultValue: 0),
                AUPluginParameter(id: UUID(), name: "Band 1 Q", unit: "", minValue: 0.1, maxValue: 10, currentValue: 1.4, defaultValue: 1.0),
                AUPluginParameter(id: UUID(), name: "Band 2 Freq", unit: "Hz", minValue: 20, maxValue: 20000, currentValue: 1000, defaultValue: 1000),
                AUPluginParameter(id: UUID(), name: "Band 2 Gain", unit: "dB", minValue: -24, maxValue: 24, currentValue: -2.0, defaultValue: 0),
                AUPluginParameter(id: UUID(), name: "Output Gain", unit: "dB", minValue: -12, maxValue: 12, currentValue: 0, defaultValue: 0),
            ]
        case .compressor:
            return [
                AUPluginParameter(id: UUID(), name: "Threshold", unit: "dB", minValue: -60, maxValue: 0, currentValue: -18, defaultValue: -20),
                AUPluginParameter(id: UUID(), name: "Ratio", unit: ":1", minValue: 1, maxValue: 20, currentValue: 4, defaultValue: 4),
                AUPluginParameter(id: UUID(), name: "Attack", unit: "ms", minValue: 0.01, maxValue: 100, currentValue: 10, defaultValue: 10),
                AUPluginParameter(id: UUID(), name: "Release", unit: "ms", minValue: 10, maxValue: 2000, currentValue: 100, defaultValue: 100),
                AUPluginParameter(id: UUID(), name: "Makeup Gain", unit: "dB", minValue: 0, maxValue: 24, currentValue: 6, defaultValue: 0),
            ]
        case .reverb:
            return [
                AUPluginParameter(id: UUID(), name: "Decay", unit: "sec", minValue: 0.1, maxValue: 30, currentValue: 5.0, defaultValue: 2.0),
                AUPluginParameter(id: UUID(), name: "Pre-Delay", unit: "ms", minValue: 0, maxValue: 200, currentValue: 20, defaultValue: 10),
                AUPluginParameter(id: UUID(), name: "Damping", unit: "%", minValue: 0, maxValue: 100, currentValue: 50, defaultValue: 50),
                AUPluginParameter(id: UUID(), name: "Mix", unit: "%", minValue: 0, maxValue: 100, currentValue: 35, defaultValue: 30),
            ]
        case .delay:
            return [
                AUPluginParameter(id: UUID(), name: "Delay Time", unit: "ms", minValue: 1, maxValue: 2000, currentValue: 375, defaultValue: 500),
                AUPluginParameter(id: UUID(), name: "Feedback", unit: "%", minValue: 0, maxValue: 95, currentValue: 40, defaultValue: 30),
                AUPluginParameter(id: UUID(), name: "Mix", unit: "%", minValue: 0, maxValue: 100, currentValue: 30, defaultValue: 25),
            ]
        default:
            return [
                AUPluginParameter(id: UUID(), name: "Mix", unit: "%", minValue: 0, maxValue: 100, currentValue: 50, defaultValue: 50),
                AUPluginParameter(id: UUID(), name: "Output", unit: "dB", minValue: -12, maxValue: 12, currentValue: 0, defaultValue: 0),
            ]
        }
    }
}
