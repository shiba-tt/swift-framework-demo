import Foundation
import SwiftUI

/// MoodBoard のメインビューモデル
@MainActor
@Observable
final class MoodBoardViewModel {
    // MARK: - State

    /// 今日の気分
    private(set) var todayMood: MoodType?

    /// 記録済みフラグ
    private(set) var hasRecordedToday = false

    /// 全エントリ
    private(set) var entries: [MoodEntry] = []

    /// 統計情報
    private(set) var stats: MoodStats = .default

    /// 週間データ
    private(set) var weeklyMoods: [(weekday: String, mood: MoodType?)] = []

    /// 読み込み中フラグ
    private(set) var isLoading = false

    // MARK: - Dependencies

    let dataManager = MoodDataManager.shared

    // MARK: - Actions

    /// 初期化
    func initialize() async {
        isLoading = true
        await refresh()

        // デモデータが空の場合は生成
        if entries.isEmpty {
            generateDemoData()
        }

        isLoading = false
    }

    /// データの更新
    func refresh() async {
        entries = dataManager.loadEntries()
        todayMood = dataManager.loadTodayMood()
        hasRecordedToday = dataManager.hasRecordedToday()
        stats = dataManager.calculateStats(from: entries)
        weeklyMoods = dataManager.loadWeeklyMoods()
    }

    /// 気分を記録
    func recordMood(_ mood: MoodType, note: String? = nil) {
        dataManager.recordMood(mood, note: note)
        todayMood = mood
        hasRecordedToday = true

        // データを再読み込み
        entries = dataManager.loadEntries()
        stats = dataManager.calculateStats(from: entries)
        weeklyMoods = dataManager.loadWeeklyMoods()
    }

    /// 特定日のエントリを取得
    func entries(for date: Date) -> [MoodEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    /// 直近N件のエントリを取得
    func recentEntries(count: Int) -> [MoodEntry] {
        Array(entries.suffix(count).reversed())
    }

    // MARK: - Demo Data

    private func generateDemoData() {
        let calendar = Calendar.current
        let moods: [MoodType] = [.happy, .good, .neutral, .sad, .fire]

        for dayOffset in (1..<30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }

            // 平日はやや高め、週末は高め
            let weekday = calendar.component(.weekday, from: date)
            let isWeekend = weekday == 1 || weekday == 7

            let weights: [Double]
            if isWeekend {
                weights = [0.35, 0.30, 0.15, 0.05, 0.15]
            } else {
                weights = [0.20, 0.30, 0.25, 0.10, 0.15]
            }

            let selectedMood = weightedRandom(moods: moods, weights: weights)
            let entry = MoodEntry(date: date, mood: selectedMood)

            var allEntries = dataManager.loadEntries()
            allEntries.append(entry)

            // 直接保存（デモ用）
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(allEntries) {
                UserDefaults(suiteName: "group.com.example.moodboard")?.set(data, forKey: "moodEntries")
            }
        }

        // 再読み込み
        entries = dataManager.loadEntries()
        stats = dataManager.calculateStats(from: entries)
        weeklyMoods = dataManager.loadWeeklyMoods()
    }

    private func weightedRandom(moods: [MoodType], weights: [Double]) -> MoodType {
        let totalWeight = weights.reduce(0, +)
        var random = Double.random(in: 0..<totalWeight)

        for (index, weight) in weights.enumerated() {
            random -= weight
            if random <= 0 {
                return moods[index]
            }
        }
        return moods.last!
    }
}
