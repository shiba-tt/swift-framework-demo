import SwiftUI

/// 習慣のカテゴリ
enum HabitCategory: String, CaseIterable, Identifiable, Sendable {
    case health = "健康"
    case exercise = "運動"
    case mindfulness = "マインドフルネス"
    case learning = "学習"
    case productivity = "生産性"
    case social = "社交"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .health: "💧"
        case .exercise: "🏃"
        case .mindfulness: "🧘"
        case .learning: "📖"
        case .productivity: "⚡"
        case .social: "👋"
        }
    }

    var color: Color {
        switch self {
        case .health: .blue
        case .exercise: .orange
        case .mindfulness: .purple
        case .learning: .green
        case .productivity: .yellow
        case .social: .pink
        }
    }

    var systemImageName: String {
        switch self {
        case .health: "heart.fill"
        case .exercise: "figure.run"
        case .mindfulness: "brain.head.profile"
        case .learning: "book.fill"
        case .productivity: "bolt.fill"
        case .social: "person.2.fill"
        }
    }
}
