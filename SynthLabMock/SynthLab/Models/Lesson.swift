import Foundation

/// 学習レッスン
struct Lesson: Identifiable, Sendable {
    let id = UUID()
    let number: Int
    let title: String
    let description: String
    let focusModule: SynthModuleType
    let hint: String
    let steps: [LessonStep]
}

/// レッスンのステップ
struct LessonStep: Identifiable, Sendable {
    let id = UUID()
    let instruction: String
    let parameterName: String?
    let targetValue: Double?
    var isCompleted: Bool = false
}

/// プリセット
struct SynthPreset: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let category: PresetCategory
    let description: String
    let oscillatorWaveform: WaveformType
    let filterCutoff: Double
    let filterResonance: Double
    let filterType: FilterType
    let attackTime: Double
    let decayTime: Double
    let sustainLevel: Double
    let releaseTime: Double
    let lfoRate: Double
    let lfoDepth: Double
}

/// プリセットカテゴリ
enum PresetCategory: String, CaseIterable, Identifiable, Sendable {
    case bass = "ベース"
    case lead = "リード"
    case pad = "パッド"
    case fx = "エフェクト"
    case keys = "キーボード"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bass: "speaker.wave.1.fill"
        case .lead: "guitars.fill"
        case .pad: "cloud.fill"
        case .fx: "sparkles"
        case .keys: "pianokeys"
        }
    }
}
