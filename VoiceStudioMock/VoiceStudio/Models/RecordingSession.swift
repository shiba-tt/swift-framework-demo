import Foundation

/// 録音セッション（エピソード）
struct RecordingSession: Identifiable, Sendable {
    let id = UUID()
    var title: String
    let createdDate: Date
    var duration: TimeInterval
    var fileURL: URL?
    var status: RecordingStatus
    /// 使用プリセット名
    var presetName: String?

    var durationText: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: createdDate)
    }

    var shortDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: createdDate)
    }
}

/// 録音ステータス
enum RecordingStatus: String, Sendable {
    case recording = "録音中"
    case paused = "一時停止"
    case completed = "完了"
    case editing = "編集中"

    var systemImageName: String {
        switch self {
        case .recording: "record.circle"
        case .paused: "pause.circle.fill"
        case .completed: "checkmark.circle.fill"
        case .editing: "waveform"
        }
    }
}

/// エフェクトチェーンプリセット
struct EffectPreset: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let category: PresetCategory
    let effects: [AudioEffect]
    var isFavorite: Bool = false

    /// LUFS ターゲット値
    let targetLUFS: Double
}

/// プリセットカテゴリ
enum PresetCategory: String, Sendable, CaseIterable {
    case podcast = "ポッドキャスト"
    case narration = "ナレーション"
    case interview = "インタビュー"
    case custom = "カスタム"

    var systemImageName: String {
        switch self {
        case .podcast: "mic.fill"
        case .narration: "text.book.closed.fill"
        case .interview: "person.2.fill"
        case .custom: "slider.horizontal.3"
        }
    }
}

/// オーディオメーター
struct VoiceAudioMeter: Sendable {
    let inputLevel: Float
    let outputLevel: Float
    let gainReduction: Float
    let lufs: Double
    let inputPeak: Float
    let outputPeak: Float
    let isClipping: Bool

    static let zero = VoiceAudioMeter(
        inputLevel: 0,
        outputLevel: 0,
        gainReduction: 0,
        lufs: -60,
        inputPeak: 0,
        outputPeak: 0,
        isClipping: false
    )
}
