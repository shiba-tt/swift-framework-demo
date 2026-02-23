import SwiftUI

/// レシピのカテゴリ
enum RecipeCategory: String, CaseIterable, Sendable {
    case japanese = "和食"
    case western = "洋食"
    case chinese = "中華"

    var emoji: String {
        switch self {
        case .japanese: "🍱"
        case .western: "🍝"
        case .chinese: "🥟"
        }
    }

    var color: Color {
        switch self {
        case .japanese: .red
        case .western: .blue
        case .chinese: .orange
        }
    }
}
