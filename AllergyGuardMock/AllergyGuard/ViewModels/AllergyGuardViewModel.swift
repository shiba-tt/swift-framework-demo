import Foundation

// MARK: - AllergyGuardViewModel

@MainActor
@Observable
final class AllergyGuardViewModel {

    // MARK: - State

    var selectedAllergens: Set<Allergen> = []
    var selectedCategory: MenuCategory?
    var showSafeOnly = false
    var searchText = ""
    var selectedRestaurant: Restaurant?
    var selectedMenuItem: MenuItem?

    // MARK: - Dependencies

    private let restaurantManager = RestaurantManager.shared

    // MARK: - Computed

    var restaurants: [Restaurant] {
        restaurantManager.restaurants
    }

    var filteredMenuItems: [MenuItem] {
        guard let restaurant = selectedRestaurant else { return [] }

        var items = restaurant.menuItems

        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }

        if showSafeOnly {
            items = items.filter { $0.isSafe(for: selectedAllergens) }
        }

        if !searchText.isEmpty {
            items = items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return items
    }

    var availableCategories: [MenuCategory] {
        selectedRestaurant?.availableCategories ?? []
    }

    var safeCount: Int {
        guard let restaurant = selectedRestaurant else { return 0 }
        return restaurant.safeMenuItems(for: selectedAllergens).count
    }

    var totalCount: Int {
        selectedRestaurant?.menuItems.count ?? 0
    }

    var safeRatio: Double {
        guard totalCount > 0 else { return 0 }
        return Double(safeCount) / Double(totalCount)
    }

    var hasSelectedAllergens: Bool {
        !selectedAllergens.isEmpty
    }

    // MARK: - Actions

    func loadRestaurant(id: String? = nil) {
        if let id, let restaurant = restaurantManager.restaurant(for: id) {
            selectedRestaurant = restaurant
        } else {
            selectedRestaurant = restaurantManager.restaurants.first
        }
    }

    func toggleAllergen(_ allergen: Allergen) {
        if selectedAllergens.contains(allergen) {
            selectedAllergens.remove(allergen)
        } else {
            selectedAllergens.insert(allergen)
        }
    }

    func selectCategory(_ category: MenuCategory?) {
        selectedCategory = category
    }

    func selectMenuItem(_ item: MenuItem) {
        selectedMenuItem = item
    }

    func clearAllergens() {
        selectedAllergens.removeAll()
    }

    func safetyStatus(for item: MenuItem) -> SafetyStatus {
        guard hasSelectedAllergens else { return .unknown }
        let dangers = item.dangerousAllergens(for: selectedAllergens)
        if dangers.isEmpty {
            return .safe
        } else if dangers.allSatisfy({ $0.1 == .mayContain }) {
            return .caution
        } else {
            return .danger
        }
    }
}

// MARK: - SafetyStatus

enum SafetyStatus: Sendable {
    case safe
    case caution
    case danger
    case unknown

    var displayName: String {
        switch self {
        case .safe: "安全"
        case .caution: "注意"
        case .danger: "危険"
        case .unknown: "未設定"
        }
    }

    var icon: String {
        switch self {
        case .safe: "checkmark.shield.fill"
        case .caution: "exclamationmark.triangle.fill"
        case .danger: "xmark.shield.fill"
        case .unknown: "questionmark.circle"
        }
    }

    var badgeColor: SwiftUI.Color {
        switch self {
        case .safe: .green
        case .caution: .orange
        case .danger: .red
        case .unknown: .gray
        }
    }
}
