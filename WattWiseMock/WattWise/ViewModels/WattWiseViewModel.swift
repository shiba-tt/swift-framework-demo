import Foundation
import SwiftUI

/// WattWise のメインビューモデル
@MainActor
@Observable
final class WattWiseViewModel {
    var familyName = "田中家"
    var familyMembers: [FamilyMember] = []
    var currentChallenge: EnergyChallenge?
    var dailyInsight: DailyInsight?
    var gridTimeSlots: [GridTimeSlot] = []
    var weeklyReport: WeeklyReport?
    var currentQuiz: EnergyQuiz?
    var selectedQuizAnswer: Int?
    var showQuizResult = false
    var isLoading = false

    private let manager = WattWiseEnergyManager.shared

    // MARK: - 初期化

    func initialize() async {
        isLoading = true
        loadDemoData()
        isLoading = false
    }

    // MARK: - クイズ操作

    func answerQuiz(_ index: Int) {
        selectedQuizAnswer = index
        showQuizResult = true

        if let quiz = currentQuiz, index == quiz.correctIndex {
            // 正解 — 子供のスコアを更新
            for i in familyMembers.indices where familyMembers[i].role == .child {
                familyMembers[i].quizScore += quiz.points
            }
        }
    }

    func nextQuiz() {
        selectedQuizAnswer = nil
        showQuizResult = false
        currentQuiz = manager.generateQuiz(gridSlots: gridTimeSlots)
    }

    // MARK: - デモデータ

    private func loadDemoData() {
        familyMembers = [
            FamilyMember(
                id: UUID(), name: "パパ", icon: "👨",
                role: .parent, deviceType: .ev,
                cleanEnergyRate: 0.85, quizScore: 0
            ),
            FamilyMember(
                id: UUID(), name: "ママ", icon: "👩",
                role: .parent, deviceType: .aircon,
                cleanEnergyRate: 0.62, quizScore: 0
            ),
            FamilyMember(
                id: UUID(), name: "太郎", icon: "👦",
                role: .child, deviceType: .learning,
                cleanEnergyRate: 0, quizScore: 80
            ),
            FamilyMember(
                id: UUID(), name: "花子", icon: "👧",
                role: .child, deviceType: .learning,
                cleanEnergyRate: 0, quizScore: 120
            ),
        ]

        currentChallenge = EnergyChallenge(
            id: UUID(),
            title: "ピーク時間に電力 20% カット",
            description: "18:00〜20:00 のピーク時間帯の電力使用量を先週比 20% 削減しよう",
            targetReduction: 0.20,
            durationDays: 7,
            startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            currentProgress: 0.72,
            icon: "bolt.slash.fill"
        )

        dailyInsight = manager.generateDailyInsight()
        gridTimeSlots = manager.generateGridTimeSlots()
        currentQuiz = manager.generateQuiz(gridSlots: gridTimeSlots)

        weeklyReport = WeeklyReport(
            id: UUID(),
            weekNumber: Calendar.current.component(.weekOfYear, from: Date()),
            totalCO2Reduction: 14.7,
            totalCostSaving: 12.60,
            averageCleanRate: 0.74,
            dailyCleanRates: [0.68, 0.72, 0.78, 0.65, 0.82, 0.75, 0.78],
            challengeAchieved: false
        )

        updateWidgetData()
    }

    private func updateWidgetData() {
        let widgetData = WattWiseWidgetData(
            familyName: familyName,
            challengeTitle: currentChallenge?.title ?? "",
            challengeProgress: currentChallenge?.currentProgress ?? 0,
            co2Reduction: dailyInsight?.co2Reduction ?? 0,
            costSaving: dailyInsight?.costSaving ?? 0,
            cleanRate: dailyInsight?.cleanRate ?? 0
        )
        manager.persistWidgetData(widgetData)
    }
}
