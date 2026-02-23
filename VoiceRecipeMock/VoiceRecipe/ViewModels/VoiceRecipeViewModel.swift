import Foundation
import SwiftUI

@MainActor
@Observable
final class VoiceRecipeViewModel {
    // MARK: - Tab

    enum Tab: String, Sendable {
        case recipes
        case cooking
        case history
    }

    var selectedTab: Tab = .recipes

    // MARK: - UI State

    var searchText = ""
    var isListening = false

    // MARK: - Dependencies

    private let manager = CookingManager.shared

    // MARK: - Proxied State

    var recipes: [Recipe] { manager.recipes }
    var activeSession: CookingSession? { manager.activeSession }
    var recentCommands: [VoiceCommand] { manager.recentCommands }

    var recipesByCategory: [(category: RecipeCategory, recipes: [Recipe])] {
        manager.recipesByCategory
    }

    var filteredRecipes: [Recipe] {
        manager.searchRecipes(keyword: searchText)
    }

    // MARK: - Session Actions

    func startCooking(recipe: Recipe) {
        withAnimation(.spring(duration: 0.3)) {
            manager.startCooking(recipe: recipe)
            selectedTab = .cooking
        }
    }

    func endSession() {
        withAnimation {
            manager.endSession()
            selectedTab = .recipes
        }
    }

    func nextStep() {
        withAnimation(.spring(duration: 0.3)) {
            manager.nextStep()
        }
    }

    func previousStep() {
        withAnimation(.spring(duration: 0.3)) {
            manager.previousStep()
        }
    }

    func repeatCurrentStep() {
        manager.repeatCurrentStep()
    }

    func startStepTimer() {
        manager.startStepTimer()
    }

    func stopTimer() {
        manager.stopTimer()
    }

    func queryTimer() {
        manager.queryTimer()
    }

    func adjustServings(_ servings: Int) {
        manager.adjustServings(servings)
    }

    // MARK: - Favorites

    func toggleFavorite(_ recipe: Recipe) {
        withAnimation {
            manager.toggleFavorite(recipe)
        }
    }

    func isFavorite(_ recipe: Recipe) -> Bool {
        manager.isFavorite(recipe)
    }

    // MARK: - Voice Simulation

    func simulateVoiceCommand() {
        isListening = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            isListening = false
        }
    }
}
