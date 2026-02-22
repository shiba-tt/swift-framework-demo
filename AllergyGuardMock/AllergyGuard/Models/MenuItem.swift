import Foundation

// MARK: - MenuCategory

enum MenuCategory: String, CaseIterable, Identifiable, Sendable {
    case appetizer = "前菜"
    case main = "メイン"
    case pasta = "パスタ"
    case dessert = "デザート"
    case drink = "ドリンク"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .appetizer: "leaf.arrow.circlepath"
        case .main: "fork.knife"
        case .pasta: "takeoutbag.and.cup.and.straw"
        case .dessert: "birthday.cake"
        case .drink: "cup.and.saucer"
        }
    }
}

// MARK: - MenuItem

struct MenuItem: Identifiable, Sendable {
    let id: UUID
    let name: String
    let description: String
    let category: MenuCategory
    let price: Int
    let imageURL: String?
    let allergens: [Allergen: AllergenSeverity]

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        category: MenuCategory,
        price: Int,
        imageURL: String? = nil,
        allergens: [Allergen: AllergenSeverity]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.price = price
        self.imageURL = imageURL
        self.allergens = allergens
    }

    func isSafe(for userAllergens: Set<Allergen>) -> Bool {
        for allergen in userAllergens {
            if let severity = allergens[allergen],
               severity == .contains || severity == .mayContain {
                return false
            }
        }
        return true
    }

    func dangerousAllergens(for userAllergens: Set<Allergen>) -> [(Allergen, AllergenSeverity)] {
        userAllergens.compactMap { allergen in
            guard let severity = allergens[allergen],
                  severity != .notContained else {
                return nil
            }
            return (allergen, severity)
        }
        .sorted { $0.1 == .contains && $1.1 != .contains }
    }

    var priceText: String {
        "¥\(price)"
    }
}
