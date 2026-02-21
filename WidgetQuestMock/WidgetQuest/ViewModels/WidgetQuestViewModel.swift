import Foundation
import SwiftUI

/// WidgetQuest アプリのメイン ViewModel
@MainActor
@Observable
final class WidgetQuestViewModel {

    // MARK: - State

    private(set) var hero: Hero = .default
    private(set) var currentEvent: QuestEvent?
    private(set) var questLog: [QuestLogEntry] = []
    private(set) var stats: QuestStats = .default
    private(set) var currentLocation: QuestLocation = QuestGameManager.locations[0]
    private(set) var isLoading = false
    private(set) var lastChoiceResult: String?
    private(set) var showingResult = false

    // MARK: - Dependencies

    private let gameManager = QuestGameManager.shared

    // MARK: - Computed Properties

    /// 利用可能なロケーション
    var availableLocations: [QuestLocation] {
        QuestGameManager.locations.filter { $0.difficulty <= hero.level + 1 }
    }

    /// 次のイベントまでの時間テキスト
    var nextEventTimeText: String {
        guard let event = currentEvent else { return "イベント待機中..." }
        let elapsed = Date().timeIntervalSince(event.occurredAt)
        let remaining = max(0, 7200 - elapsed) // 2時間間隔
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分後"
        } else {
            return "\(minutes)分後"
        }
    }

    /// レベルアップ可能か
    var canLevelUp: Bool {
        hero.experience >= hero.expToNextLevel
    }

    /// 冒険日数テキスト
    var dayCountText: String {
        "Day \(hero.dayCount)"
    }

    /// 統計のサマリーデータ
    var statsSummary: [(label: String, value: String, emoji: String)] {
        [
            ("総バトル", "\(stats.totalBattles)回", "⚔️"),
            ("宝箱獲得", "\(stats.totalTreasures)個", "🎁"),
            ("獲得ゴールド", "\(stats.totalGoldEarned)G", "💰"),
            ("獲得経験値", "\(stats.totalExpEarned)", "✨"),
            ("ボス討伐", "\(stats.bossesDefeated)体", "🐉"),
            ("完了イベント", "\(stats.eventsCompleted)件", "📜"),
        ]
    }

    // MARK: - Actions

    /// アプリ起動時の初期化
    func initialize() async {
        isLoading = true

        if let saved = gameManager.loadHero() {
            hero = saved
        }

        questLog = gameManager.generateMockLog(for: hero)
        stats = QuestStats(
            totalBattles: questLog.filter { $0.eventType == .battle }.count,
            totalTreasures: questLog.filter { $0.eventType == .treasure }.count,
            totalGoldEarned: questLog.filter { $0.goldChange > 0 }.reduce(0) { $0 + $1.goldChange },
            totalExpEarned: questLog.filter { $0.expChange > 0 }.reduce(0) { $0 + $1.expChange },
            bossesDefeated: questLog.filter { $0.eventType == .boss }.count,
            eventsCompleted: questLog.count,
            longestStreak: 3
        )

        generateNewEvent()
        isLoading = false
    }

    /// 新しいイベントを生成する
    func generateNewEvent() {
        currentEvent = gameManager.generateEvent(for: currentLocation, hero: hero)
        showingResult = false
        lastChoiceResult = nil
    }

    /// 選択肢を選ぶ
    func selectChoice(_ choice: EventChoice) {
        hero = gameManager.applyChoice(choice, to: hero)

        // ログに記録
        let logEntry = QuestLogEntry(
            id: UUID(),
            date: Date(),
            eventType: currentEvent?.type ?? .battle,
            message: currentEvent?.title ?? "",
            choiceLabel: choice.label,
            hpChange: choice.hpEffect,
            mpChange: choice.mpEffect,
            goldChange: choice.goldEffect,
            expChange: choice.expEffect
        )
        questLog.insert(logEntry, at: 0)

        // 統計更新
        stats.eventsCompleted += 1
        if currentEvent?.type == .battle { stats.totalBattles += 1 }
        if currentEvent?.type == .treasure { stats.totalTreasures += 1 }
        if currentEvent?.type == .boss { stats.bossesDefeated += 1 }
        if choice.goldEffect > 0 { stats.totalGoldEarned += choice.goldEffect }
        if choice.expEffect > 0 { stats.totalExpEarned += choice.expEffect }

        // レベルアップチェック
        if canLevelUp {
            hero = gameManager.levelUp(hero)
        }

        lastChoiceResult = choice.resultDescription
        showingResult = true

        gameManager.saveHero(hero)
    }

    /// ロケーションを変更する
    func changeLocation(to location: QuestLocation) {
        currentLocation = location
        generateNewEvent()
    }

    /// 新しい冒険を開始する
    func startNewAdventure(name: String, heroClass: HeroClass) {
        hero = Hero(
            id: UUID(),
            name: name,
            heroClass: heroClass,
            level: 1,
            experience: 0,
            hp: heroClass.baseHP,
            maxHP: heroClass.baseHP,
            mp: heroClass.baseMP,
            maxMP: heroClass.baseMP,
            gold: 50,
            attack: heroClass.baseAttack,
            defense: heroClass.baseDefense,
            dayCount: 1
        )
        gameManager.saveHero(hero)
        generateNewEvent()
    }
}
