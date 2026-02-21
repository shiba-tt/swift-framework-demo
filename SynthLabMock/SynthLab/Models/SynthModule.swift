import Foundation
import SwiftUI

/// シンセモジュールの種類
enum SynthModuleType: String, Identifiable, CaseIterable, Sendable {
    case oscillator = "オシレーター"
    case filter = "フィルター"
    case amplifier = "アンプ"
    case lfo = "LFO"
    case envelope = "エンベロープ"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .oscillator: "waveform"
        case .filter: "slider.horizontal.3"
        case .amplifier: "speaker.wave.3.fill"
        case .lfo: "waveform.path.ecg"
        case .envelope: "chart.line.uptrend.xyaxis"
        }
    }

    var color: Color {
        switch self {
        case .oscillator: .blue
        case .filter: .orange
        case .amplifier: .green
        case .lfo: .purple
        case .envelope: .pink
        }
    }

    var description: String {
        switch self {
        case .oscillator: "音の波形を生成する基本モジュール"
        case .filter: "特定の周波数を通過・カットして音色を変える"
        case .amplifier: "音量を制御し、最終出力を調整する"
        case .lfo: "低い周波数で他のパラメータを周期的に変調する"
        case .envelope: "時間経過に応じた音量やパラメータの変化を定義する"
        }
    }
}

/// オシレーターの波形タイプ
enum WaveformType: String, CaseIterable, Identifiable, Sendable {
    case sine = "サイン波"
    case square = "矩形波"
    case sawtooth = "ノコギリ波"
    case triangle = "三角波"
    case noise = "ノイズ"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .sine: "waveform"
        case .square: "square.fill"
        case .sawtooth: "triangle.fill"
        case .triangle: "triangle"
        case .noise: "waveform.path.badge.minus"
        }
    }
}

/// フィルタータイプ
enum FilterType: String, CaseIterable, Identifiable, Sendable {
    case lowPass = "LPF"
    case highPass = "HPF"
    case bandPass = "BPF"
    case notch = "Notch"

    var id: String { rawValue }
}

/// シンセモジュールのパラメータ
struct SynthParameter: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let unit: String
    var value: Double
    let minValue: Double
    let maxValue: Double
    let step: Double

    /// 正規化された値 (0.0〜1.0)
    var normalizedValue: Double {
        (value - minValue) / (maxValue - minValue)
    }

    /// 表示用テキスト
    var displayText: String {
        if maxValue >= 1000 {
            return String(format: "%.0f %@", value, unit)
        }
        return String(format: "%.2f %@", value, unit)
    }
}

/// シンセモジュール
struct SynthModule: Identifiable, Sendable {
    let id = UUID()
    let type: SynthModuleType
    var isEnabled: Bool = true
    var parameters: [SynthParameter]

    /// モジュールのプリセット名
    var presetName: String?
}

/// シグナルフローの接続
struct SignalConnection: Identifiable, Sendable {
    let id = UUID()
    let sourceModuleID: UUID
    let destinationModuleID: UUID
}
