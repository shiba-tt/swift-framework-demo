import Foundation
import SwiftUI

// MARK: - MemoCategory

enum MemoCategory: String, Sendable, CaseIterable, Identifiable {
    case meeting = "meeting"
    case shopping = "shopping"
    case todo = "todo"
    case idea = "idea"
    case diary = "diary"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .meeting: return "会議メモ"
        case .shopping: return "買い物リスト"
        case .todo: return "TODOリスト"
        case .idea: return "アイデア"
        case .diary: return "日記・雑記"
        case .other: return "その他"
        }
    }

    var emoji: String {
        switch self {
        case .meeting: return "🏢"
        case .shopping: return "🛒"
        case .todo: return "✅"
        case .idea: return "💡"
        case .diary: return "📝"
        case .other: return "📋"
        }
    }

    var systemImageName: String {
        switch self {
        case .meeting: return "person.3.fill"
        case .shopping: return "cart.fill"
        case .todo: return "checklist"
        case .idea: return "lightbulb.fill"
        case .diary: return "book.fill"
        case .other: return "doc.text.fill"
        }
    }

    var color: Color {
        switch self {
        case .meeting: return .blue
        case .shopping: return .orange
        case .todo: return .green
        case .idea: return .yellow
        case .diary: return .purple
        case .other: return .gray
        }
    }
}
