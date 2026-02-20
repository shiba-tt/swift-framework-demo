import Foundation

/// ポモドーロの各フェーズを表す列挙型
enum PomodoroPhase: String, Codable, Sendable {
    /// 作業フェーズ（デフォルト25分）
    case work
    /// 短い休憩フェーズ（デフォルト5分）
    case shortBreak
    /// 長い休憩フェーズ（デフォルト15分、4ポモドーロごと）
    case longBreak

    var label: String {
        switch self {
        case .work: "集中"
        case .shortBreak: "休憩"
        case .longBreak: "長い休憩"
        }
    }

    var systemImageName: String {
        switch self {
        case .work: "brain.head.profile"
        case .shortBreak: "cup.and.saucer.fill"
        case .longBreak: "figure.walk"
        }
    }

    var emoji: String {
        switch self {
        case .work: "🧠"
        case .shortBreak: "☕"
        case .longBreak: "🚶"
        }
    }

    /// アラーム発火時のタイトル
    var alertTitle: String {
        switch self {
        case .work: "🔥 作業再開！"
        case .shortBreak: "🧘 休憩時間です！"
        case .longBreak: "🎉 長い休憩です！"
        }
    }

    /// アラーム発火時のサブタイトル
    func alertSubtitle(completedCount: Int) -> String {
        switch self {
        case .work:
            "今日 \(completedCount + 1) ポモドーロ目です"
        case .shortBreak:
            "\(completedCount) ポモドーロ完了！お疲れさまでした"
        case .longBreak:
            "\(completedCount) ポモドーロ達成！ゆっくり休みましょう"
        }
    }
}
