import Foundation
import SwiftUI

/// PixelPet アプリのメイン ViewModel
@MainActor
@Observable
final class PixelPetViewModel {

    // MARK: - State

    private(set) var pet: Pet = .default
    private(set) var actionHistory: [PetAction] = []
    private(set) var achievements: [PetAchievement] = PetAchievement.defaults
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var showingNameEditor = false
    var showingSpeciesSelector = false

    // MARK: - Dependencies

    private let stateManager = PetStateManager.shared

    // MARK: - Computed Properties

    /// ペットが作成済みかどうか
    var hasPet: Bool {
        stateManager.loadPet() != nil
    }

    /// 各アクションのクールダウン状態
    func isCooldownActive(for actionType: PetActionType) -> Bool {
        let lastAction = actionHistory
            .filter { $0.type == actionType }
            .sorted { $0.timestamp > $1.timestamp }
            .first

        guard let last = lastAction else { return false }
        return Date().timeIntervalSince(last.timestamp) < actionType.cooldownSeconds
    }

    /// クールダウン残り時間テキスト
    func cooldownText(for actionType: PetActionType) -> String? {
        let lastAction = actionHistory
            .filter { $0.type == actionType }
            .sorted { $0.timestamp > $1.timestamp }
            .first

        guard let last = lastAction else { return nil }
        let elapsed = Date().timeIntervalSince(last.timestamp)
        let remaining = actionType.cooldownSeconds - elapsed

        guard remaining > 0 else { return nil }

        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// ステータス履歴データ
    var statusHistory: [PetStatusRecord] {
        stateManager.statusHistory
    }

    /// 今日のお世話回数
    var todayActionCount: Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return actionHistory.filter { $0.timestamp >= startOfDay }.count
    }

    /// ペットの総合評価テキスト
    var conditionSummary: String {
        let condition = pet.overallCondition
        if condition >= 80 {
            return "とても元気です！"
        } else if condition >= 60 {
            return "まあまあ元気です"
        } else if condition >= 40 {
            return "少し疲れ気味..."
        } else if condition >= 20 {
            return "お世話が必要です！"
        } else {
            return "緊急！すぐにお世話を！"
        }
    }

    // MARK: - Actions

    /// アプリ起動時の初期化
    func initialize() async {
        isLoading = true
        errorMessage = nil

        if let saved = stateManager.loadPet() {
            pet = stateManager.calculateDecay(for: saved, since: Date().addingTimeInterval(-3600))
            stateManager.savePet(pet)
        }

        stateManager.generateMockHistory()
        isLoading = false
    }

    /// 新しいペットを作成する
    func createPet(name: String, species: PetSpecies) {
        pet = Pet(
            id: UUID(),
            name: name,
            species: species,
            birthday: Date(),
            hunger: 80,
            happiness: 80,
            cleanliness: 80,
            energy: 80,
            lastFedDate: nil,
            lastPlayedDate: nil,
            lastCleanedDate: nil
        )
        stateManager.savePet(pet)
        stateManager.recordStatus(for: pet)
    }

    /// ペットにアクションを実行する
    func performAction(_ actionType: PetActionType) {
        guard !isCooldownActive(for: actionType) else { return }

        pet = stateManager.applyAction(actionType, to: pet)

        let action = PetAction(type: actionType, timestamp: Date())
        actionHistory.append(action)

        stateManager.savePet(pet)
        stateManager.recordStatus(for: pet)

        checkAchievements()
    }

    /// ペットの名前を変更する
    func renamePet(to newName: String) {
        pet.name = newName
        stateManager.savePet(pet)
    }

    // MARK: - Private

    /// 実績のチェックと解除
    private func checkAchievements() {
        // はじめてのごはん
        if !achievements[0].isUnlocked && actionHistory.contains(where: { $0.type == .feed }) {
            achievements[0] = PetAchievement(
                title: achievements[0].title,
                description: achievements[0].description,
                emoji: achievements[0].emoji,
                unlockedDate: Date()
            )
        }

        // お世話マスター
        if !achievements[1].isUnlocked
            && pet.hunger >= 80 && pet.happiness >= 80
            && pet.cleanliness >= 80 && pet.energy >= 80 {
            achievements[1] = PetAchievement(
                title: achievements[1].title,
                description: achievements[1].description,
                emoji: achievements[1].emoji,
                unlockedDate: Date()
            )
        }

        // ごきげんマックス
        if !achievements[3].isUnlocked && pet.happiness >= 100 {
            achievements[3] = PetAchievement(
                title: achievements[3].title,
                description: achievements[3].description,
                emoji: achievements[3].emoji,
                unlockedDate: Date()
            )
        }
    }
}
