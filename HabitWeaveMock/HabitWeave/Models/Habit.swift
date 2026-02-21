import Foundation

/// 習慣を表すモデル
struct Habit: Identifiable, Sendable {
    let id: UUID
    var title: String
    var category: HabitCategory
    var frequency: HabitFrequency
    var durationMinutes: Int
    var preferredTimeSlot: PreferredTimeSlot
    var isActive: Bool
    var createdAt: Date
    var color: HabitColor

    /// 所要時間テキスト
    var durationText: String {
        if durationMinutes >= 60 {
            let hours = durationMinutes / 60
            let mins = durationMinutes % 60
            return mins > 0 ? "\(hours)時間\(mins)分" : "\(hours)時間"
        }
        return "\(durationMinutes)分"
    }

    /// 頻度テキスト
    var frequencyText: String {
        frequency.displayText
    }

    /// サンプルデータ
    static let samples: [Habit] = [
        Habit(id: UUID(), title: "読書", category: .learning, frequency: .daily, durationMinutes: 30, preferredTimeSlot: .evening, isActive: true, createdAt: Date().addingTimeInterval(-86400 * 14), color: .blue),
        Habit(id: UUID(), title: "ジョギング", category: .exercise, frequency: .weekdays(3), durationMinutes: 45, preferredTimeSlot: .morning, isActive: true, createdAt: Date().addingTimeInterval(-86400 * 10), color: .green),
        Habit(id: UUID(), title: "瞑想", category: .mindfulness, frequency: .daily, durationMinutes: 15, preferredTimeSlot: .morning, isActive: true, createdAt: Date().addingTimeInterval(-86400 * 7), color: .purple),
        Habit(id: UUID(), title: "英語学習", category: .learning, frequency: .weekdays(5), durationMinutes: 20, preferredTimeSlot: .afternoon, isActive: true, createdAt: Date().addingTimeInterval(-86400 * 5), color: .orange),
        Habit(id: UUID(), title: "ストレッチ", category: .exercise, frequency: .daily, durationMinutes: 10, preferredTimeSlot: .evening, isActive: false, createdAt: Date().addingTimeInterval(-86400 * 3), color: .pink),
    ]
}

// MARK: - HabitCategory

/// 習慣のカテゴリ
enum HabitCategory: String, CaseIterable, Sendable {
    case exercise = "運動"
    case learning = "学習"
    case mindfulness = "マインドフルネス"
    case health = "健康"
    case creativity = "クリエイティブ"
    case social = "社交"

    var emoji: String {
        switch self {
        case .exercise: "🏃"
        case .learning: "📚"
        case .mindfulness: "🧘"
        case .health: "💊"
        case .creativity: "🎨"
        case .social: "👥"
        }
    }

    var systemImageName: String {
        switch self {
        case .exercise: "figure.run"
        case .learning: "book.fill"
        case .mindfulness: "brain.head.profile"
        case .health: "heart.fill"
        case .creativity: "paintbrush.fill"
        case .social: "person.2.fill"
        }
    }
}

// MARK: - HabitFrequency

/// 習慣の頻度
enum HabitFrequency: Sendable {
    case daily
    case weekdays(Int)

    var displayText: String {
        switch self {
        case .daily:
            return "毎日"
        case .weekdays(let count):
            return "週\(count)回"
        }
    }

    var timesPerWeek: Int {
        switch self {
        case .daily: return 7
        case .weekdays(let count): return count
        }
    }
}

// MARK: - PreferredTimeSlot

/// 希望する実行時間帯
enum PreferredTimeSlot: String, CaseIterable, Sendable {
    case morning = "朝"
    case afternoon = "昼"
    case evening = "夜"
    case anytime = "いつでも"

    var emoji: String {
        switch self {
        case .morning: "🌅"
        case .afternoon: "☀️"
        case .evening: "🌙"
        case .anytime: "🕐"
        }
    }

    /// 該当する時間範囲
    var hourRange: ClosedRange<Int> {
        switch self {
        case .morning: return 6...11
        case .afternoon: return 12...17
        case .evening: return 18...23
        case .anytime: return 6...23
        }
    }
}

// MARK: - HabitColor

/// 習慣の表示カラー
enum HabitColor: String, CaseIterable, Sendable {
    case blue = "ブルー"
    case green = "グリーン"
    case orange = "オレンジ"
    case purple = "パープル"
    case pink = "ピンク"
    case red = "レッド"

    var colorName: String {
        switch self {
        case .blue: "blue"
        case .green: "green"
        case .orange: "orange"
        case .purple: "purple"
        case .pink: "pink"
        case .red: "red"
        }
    }
}
