import Foundation
import SwiftUI

@MainActor
@Observable
final class AIFormCoachViewModel {
    // MARK: - Tab

    enum Tab: String, Sendable {
        case workout
        case analysis
        case history
    }

    var selectedTab: Tab = .workout

    // MARK: - UI State

    var selectedExercise: Exercise = .squat

    // MARK: - Dependencies

    private let manager = PoseAnalysisManager.shared

    // MARK: - Proxied State

    var activeSession: WorkoutSession? { manager.activeSession }
    var isAnalyzing: Bool { manager.isAnalyzing }
    var history: [DailyWorkoutSummary] { manager.history }

    var totalWorkouts: Int { manager.totalWorkouts }
    var overallAverageScore: Int { manager.overallAverageScore }
    var totalRepsAllTime: Int { manager.totalRepsAllTime }

    // MARK: - Session Actions

    func startSession() {
        withAnimation(.spring(duration: 0.3)) {
            manager.startSession(exercise: selectedExercise)
            selectedTab = .analysis
        }
    }

    func endSession() {
        withAnimation {
            manager.endSession()
            selectedTab = .workout
        }
    }

    func analyzeForm() {
        withAnimation(.spring(duration: 0.3)) {
            manager.analyzeCurrentForm()
        }
    }

    // MARK: - Query

    func bestScore(for exercise: Exercise) -> Int {
        manager.bestScoreForExercise(exercise)
    }
}
