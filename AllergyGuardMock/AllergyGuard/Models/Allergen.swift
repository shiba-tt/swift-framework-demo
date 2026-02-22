import SwiftUI

// MARK: - Allergen

enum Allergen: String, CaseIterable, Identifiable, Sendable {
    case egg = "卵"
    case milk = "乳"
    case wheat = "小麦"
    case buckwheat = "そば"
    case peanut = "落花生"
    case shrimp = "えび"
    case crab = "かに"
    case walnut = "くるみ"
    case almond = "アーモンド"
    case soy = "大豆"
    case sesame = "ごま"
    case cashew = "カシューナッツ"
    case macadamia = "マカダミアナッツ"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .egg: "bird"
        case .milk: "cup.and.saucer"
        case .wheat: "leaf"
        case .buckwheat: "leaf.circle"
        case .peanut: "oval"
        case .shrimp: "fish"
        case .crab: "fish.circle"
        case .walnut: "tree"
        case .almond: "tree.circle"
        case .soy: "drop"
        case .sesame: "circle.grid.3x3"
        case .cashew: "oval.portrait"
        case .macadamia: "circle"
        }
    }

    var color: Color {
        switch self {
        case .egg: .yellow
        case .milk: .white
        case .wheat: .orange
        case .buckwheat: .brown
        case .peanut: .orange
        case .shrimp: .red
        case .crab: .red
        case .walnut: .brown
        case .almond: .brown
        case .soy: .green
        case .sesame: .gray
        case .cashew: .yellow
        case .macadamia: .mint
        }
    }

    /// 特定原材料7品目 + くるみ
    var isMandatory: Bool {
        switch self {
        case .egg, .milk, .wheat, .buckwheat, .peanut, .shrimp, .crab, .walnut:
            true
        default:
            false
        }
    }
}

// MARK: - AllergenSeverity

enum AllergenSeverity: String, Sendable {
    case contains = "含む"
    case mayContain = "含む可能性あり"
    case notContained = "含まない"

    var icon: String {
        switch self {
        case .contains: "xmark.circle.fill"
        case .mayContain: "exclamationmark.triangle.fill"
        case .notContained: "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .contains: .red
        case .mayContain: .orange
        case .notContained: .green
        }
    }
}
