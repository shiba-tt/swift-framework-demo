import Foundation
import WidgetKit

/// 気分データの管理マネージャー
/// App Group 経由で Widget と状態を共有する
@MainActor
@Observable
final class MoodDataManager {

    // MARK: - Singleton

    static let shared = MoodDataManager()
    private init() {}

    // MARK: - Constants

    private let appGroupID = "group.com.example.moodboard"
    private let entriesKey = "moodEntries"
    private let todayMoodKey = "todayMood"
    private let todayMoodDateKey = "todayMoodDate"
    private let streakKey = "streakDays"

    // MARK: - Data Access

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: - Entry Management

    /// 気分を記録する
    func recordMood(_ mood: MoodType, note: String? = nil) {
        let entry = MoodEntry(mood: mood, note: note)

        // 保存
        var entries = loadEntries()
        entries.append(entry)
        saveEntries(entries)

        // 今日の気分をウィジェット用に保存
        saveTodayMood(mood)

        // 連続記録日数を更新
        updateStreak(entries: entries)

        // ウィジェットの更新を通知
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// 全エントリを読み込む
    func loadEntries() -> [MoodEntry] {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: entriesKey) else {
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([MoodEntry].self, from: data)) ?? []
    }

    /// エントリを保存する
    private func saveEntries(_ entries: [MoodEntry]) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(entries) else { return }
        sharedDefaults?.set(data, forKey: entriesKey)
    }

    /// 今日の気分を保存
    private func saveTodayMood(_ mood: MoodType) {
        sharedDefaults?.set(mood.rawValue, forKey: todayMoodKey)
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: todayMoodDateKey)
    }

    /// 今日の気分を取得
    func loadTodayMood() -> MoodType? {
        guard let defaults = sharedDefaults,
              let moodRaw = defaults.string(forKey: todayMoodKey) else {
            return nil
        }

        let dateInterval = defaults.double(forKey: todayMoodDateKey)
        let moodDate = Date(timeIntervalSince1970: dateInterval)

        // 今日の記録か確認
        guard Calendar.current.isDateInToday(moodDate) else { return nil }

        return MoodType(rawValue: moodRaw)
    }

    /// 今日の気分が記録済みかどうか
    func hasRecordedToday() -> Bool {
        loadTodayMood() != nil
    }

    // MARK: - Streak

    /// 連続記録日数を更新
    private func updateStreak(entries: [MoodEntry]) {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // 今日から遡って連続記録日数を計算
        while true {
            let hasEntry = entries.contains { entry in
                calendar.isDate(entry.date, inSameDayAs: checkDate)
            }
            if hasEntry {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previousDay
            } else {
                break
            }
        }

        sharedDefaults?.set(streak, forKey: streakKey)
    }

    /// 連続記録日数を取得
    func loadStreak() -> Int {
        sharedDefaults?.integer(forKey: streakKey) ?? 0
    }

    // MARK: - Statistics

    /// 統計情報を計算
    func calculateStats(from entries: [MoodEntry]) -> MoodStats {
        guard !entries.isEmpty else { return .default }

        // 各気分のカウント
        var moodCounts: [MoodType: Int] = [:]
        for entry in entries {
            moodCounts[entry.mood, default: 0] += 1
        }

        // 最も多い気分
        let dominantMood = moodCounts.max { $0.value < $1.value }?.key

        // 週間データ
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let thisWeekEntries = entries.filter { $0.date >= weekAgo }
        let weeklyAvg = thisWeekEntries.isEmpty ? 0 :
            Double(thisWeekEntries.map { $0.mood.score }.reduce(0, +)) / Double(thisWeekEntries.count)

        // 先週のデータ
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        let lastWeekEntries = entries.filter { $0.date >= twoWeeksAgo && $0.date < weekAgo }
        let lastWeekAvg = lastWeekEntries.isEmpty ? weeklyAvg :
            Double(lastWeekEntries.map { $0.mood.score }.reduce(0, +)) / Double(lastWeekEntries.count)

        // 連続記録
        let streak = loadStreak()

        // 最長連続記録
        let longestStreak = calculateLongestStreak(entries: entries)

        return MoodStats(
            totalEntries: entries.count,
            streakDays: streak,
            longestStreak: longestStreak,
            moodCounts: moodCounts,
            weeklyAverageScore: weeklyAvg,
            weeklyScoreChange: weeklyAvg - lastWeekAvg,
            dominantMood: dominantMood
        )
    }

    private func calculateLongestStreak(entries: [MoodEntry]) -> Int {
        let calendar = Calendar.current
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.date) }).sorted()

        guard !uniqueDays.isEmpty else { return 0 }

        var maxStreak = 1
        var currentStreak = 1

        for i in 1..<uniqueDays.count {
            let expectedNext = calendar.date(byAdding: .day, value: 1, to: uniqueDays[i - 1])!
            if calendar.isDate(uniqueDays[i], inSameDayAs: expectedNext) {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return maxStreak
    }

    // MARK: - Week Data

    /// 今週の日別気分データを取得（ウィジェット用）
    func loadWeeklyMoods() -> [(weekday: String, mood: MoodType?)] {
        let calendar = Calendar.current
        let entries = loadEntries()
        var result: [(weekday: String, mood: MoodType?)] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }

            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            formatter.locale = Locale(identifier: "ja_JP")
            let weekday = formatter.string(from: date)

            let dayEntry = entries.last { calendar.isDate($0.date, inSameDayAs: date) }
            result.append((weekday: weekday, mood: dayEntry?.mood))
        }

        return result
    }
}
