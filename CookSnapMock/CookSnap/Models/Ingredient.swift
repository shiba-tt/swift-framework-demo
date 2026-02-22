import Foundation

/// 食材
struct Ingredient: Identifiable, Sendable, Hashable {
    let id = UUID()
    let name: String
    let emoji: String
    let category: IngredientCategory

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
}

/// 食材カテゴリ
enum IngredientCategory: String, Sendable, CaseIterable {
    case vegetable = "野菜"
    case protein = "たんぱく質"
    case dairy = "乳製品"
    case grain = "穀物"
    case seasoning = "調味料"
    case other = "その他"

    var systemImageName: String {
        switch self {
        case .vegetable: return "leaf.fill"
        case .protein:   return "fish.fill"
        case .dairy:     return "cup.and.saucer.fill"
        case .grain:     return "basket.fill"
        case .seasoning: return "takeoutbag.and.cup.and.straw.fill"
        case .other:     return "fork.knife"
        }
    }
}

/// サンプル食材カタログ（Vision による認識結果のモック）
extension Ingredient {
    static let sampleCatalog: [Ingredient] = [
        // 野菜
        Ingredient(name: "にんじん", emoji: "🥕", category: .vegetable),
        Ingredient(name: "たまねぎ", emoji: "🧅", category: .vegetable),
        Ingredient(name: "じゃがいも", emoji: "🥔", category: .vegetable),
        Ingredient(name: "トマト", emoji: "🍅", category: .vegetable),
        Ingredient(name: "キャベツ", emoji: "🥬", category: .vegetable),
        Ingredient(name: "ほうれん草", emoji: "🥬", category: .vegetable),
        Ingredient(name: "ピーマン", emoji: "🫑", category: .vegetable),
        Ingredient(name: "きのこ", emoji: "🍄", category: .vegetable),
        Ingredient(name: "もやし", emoji: "🌱", category: .vegetable),
        Ingredient(name: "大根", emoji: "🥕", category: .vegetable),

        // たんぱく質
        Ingredient(name: "鶏むね肉", emoji: "🍗", category: .protein),
        Ingredient(name: "豚バラ肉", emoji: "🥩", category: .protein),
        Ingredient(name: "牛こま切れ", emoji: "🥩", category: .protein),
        Ingredient(name: "サーモン", emoji: "🐟", category: .protein),
        Ingredient(name: "卵", emoji: "🥚", category: .protein),
        Ingredient(name: "豆腐", emoji: "🧈", category: .protein),

        // 乳製品
        Ingredient(name: "牛乳", emoji: "🥛", category: .dairy),
        Ingredient(name: "チーズ", emoji: "🧀", category: .dairy),
        Ingredient(name: "バター", emoji: "🧈", category: .dairy),

        // 穀物
        Ingredient(name: "ごはん", emoji: "🍚", category: .grain),
        Ingredient(name: "パスタ", emoji: "🍝", category: .grain),
        Ingredient(name: "食パン", emoji: "🍞", category: .grain),
        Ingredient(name: "うどん", emoji: "🍜", category: .grain),
    ]

    /// ランダムに食材を選択して「冷蔵庫の中身」をシミュレーション
    static func randomFridgeContents() -> [Ingredient] {
        let count = Int.random(in: 4...8)
        return Array(sampleCatalog.shuffled().prefix(count))
    }
}
