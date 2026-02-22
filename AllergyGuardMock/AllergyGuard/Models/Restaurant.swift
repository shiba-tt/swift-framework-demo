import Foundation

// MARK: - Restaurant

struct Restaurant: Identifiable, Sendable {
    let id: UUID
    let name: String
    let description: String
    let cuisine: String
    let address: String
    let menuItems: [MenuItem]
    let supportedLanguages: [String]

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        cuisine: String,
        address: String,
        menuItems: [MenuItem],
        supportedLanguages: [String] = ["ja", "en"]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.cuisine = cuisine
        self.address = address
        self.menuItems = menuItems
        self.supportedLanguages = supportedLanguages
    }

    func safeMenuItems(for allergens: Set<Allergen>) -> [MenuItem] {
        menuItems.filter { $0.isSafe(for: allergens) }
    }

    func unsafeMenuItems(for allergens: Set<Allergen>) -> [MenuItem] {
        menuItems.filter { !$0.isSafe(for: allergens) }
    }

    func menuItems(for category: MenuCategory) -> [MenuItem] {
        menuItems.filter { $0.category == category }
    }

    var availableCategories: [MenuCategory] {
        let categories = Set(menuItems.map(\.category))
        return MenuCategory.allCases.filter { categories.contains($0) }
    }
}
