import Foundation
import SwiftData
import FoundationModels

// MARK: - DreamJournalViewModel

@MainActor
@Observable
final class DreamJournalViewModel {

    // MARK: - Public State

    var dreams: [DreamEntry] = []
    var selectedDream: DreamEntry?
    var isAnalyzing = false
    var analysisProgress: String?
    var errorMessage: String?
    var showingRecordView = false
    var showingStatsView = false
    var searchText = ""
    var selectedEmotionFilter: EmotionalTone?

    // MARK: - Dependencies

    private let modelManager = FoundationModelManager.shared
    private let speechManager = SpeechRecognitionManager.shared
    private var modelContext: ModelContext?

    // MARK: - Computed Properties

    var filteredDreams: [DreamEntry] {
        var result = dreams

        if !searchText.isEmpty {
            result = result.filter { dream in
                dream.displayTitle.localizedCaseInsensitiveContains(searchText) ||
                dream.rawTranscription.localizedCaseInsensitiveContains(searchText) ||
                dream.themes.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                (dream.narrative?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        if let filter = selectedEmotionFilter {
            result = result.filter { $0.emotionalTone == filter }
        }

        return result.sorted { $0.recordedAt > $1.recordedAt }
    }

    var recentDreams: [DreamEntry] {
        Array(filteredDreams.prefix(10))
    }

    var isModelAvailable: Bool {
        modelManager.isAvailable
    }

    var dreamCount: Int {
        dreams.count
    }

    var analyzedCount: Int {
        dreams.filter(\.isAnalyzed).count
    }

    // MARK: - Setup

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadDreams()

        // Foundation Models のプリウォーム
        Task {
            await modelManager.prewarmModel()
        }
    }

    // MARK: - CRUD Operations

    func loadDreams() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<DreamEntry>(
            sortBy: [SortDescriptor(\.recordedAt, order: .reverse)]
        )
        do {
            dreams = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "夢の読み込みに失敗しました: \(error.localizedDescription)"
        }
    }

    func saveDream(transcription: String, lucidity: Int, vividness: Int) async {
        guard let modelContext else { return }

        let entry = DreamEntry(
            rawTranscription: transcription,
            lucidity: lucidity,
            vividness: vividness
        )

        modelContext.insert(entry)
        try? modelContext.save()
        loadDreams()

        // Foundation Models で自動分析
        await analyzeDream(entry)
    }

    func deleteDream(_ dream: DreamEntry) {
        guard let modelContext else { return }
        modelContext.delete(dream)
        try? modelContext.save()
        loadDreams()
    }

    // MARK: - AI Analysis

    func analyzeDream(_ dream: DreamEntry) async {
        guard modelManager.isAvailable else {
            errorMessage = "Foundation Models が利用できません"
            return
        }

        isAnalyzing = true
        analysisProgress = "AI が夢を分析中..."

        do {
            let analysis = try await modelManager.analyzeDream(
                transcription: dream.rawTranscription
            )

            // DreamEntry に分析結果を適用
            dream.title = analysis.title
            dream.narrative = analysis.narrative
            dream.themes = analysis.themes
            dream.emotionalToneRawValue = analysis.emotionalTone.rawValue
            dream.symbols = analysis.symbols.map {
                DreamSymbolData(name: $0.name, interpretation: $0.interpretation)
            }
            dream.isAnalyzed = true

            try? modelContext?.save()
            loadDreams()
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .guardrailViolation:
                errorMessage = "この内容は分析できません。別の表現をお試しください。"
            default:
                errorMessage = "分析エラー: \(error.localizedDescription)"
            }
        } catch {
            errorMessage = "分析に失敗しました: \(error.localizedDescription)"
        }

        isAnalyzing = false
        analysisProgress = nil
    }

    func reanalyzeDream(_ dream: DreamEntry) async {
        dream.isAnalyzed = false
        await analyzeDream(dream)
    }

    // MARK: - Statistics

    func calculateStatistics() -> DreamStatistics {
        let analyzedDreams = dreams.filter(\.isAnalyzed)

        // 感情分布
        var emotionDist: [EmotionalTone: Int] = [:]
        for dream in analyzedDreams {
            if let tone = dream.emotionalTone {
                emotionDist[tone, default: 0] += 1
            }
        }

        // テーマ集計
        var themeCounts: [String: Int] = [:]
        for dream in analyzedDreams {
            for theme in dream.themes {
                themeCounts[theme, default: 0] += 1
            }
        }
        let topThemes = themeCounts.sorted { $0.value > $1.value }
            .prefix(5)
            .map { (theme: $0.key, count: $0.value) }

        // シンボル集計
        var symbolCounts: [String: Int] = [:]
        for dream in analyzedDreams {
            for symbol in dream.symbols {
                symbolCounts[symbol.name, default: 0] += 1
            }
        }
        let topSymbols = symbolCounts.sorted { $0.value > $1.value }
            .prefix(5)
            .map { (symbol: $0.key, count: $0.value) }

        // 平均明晰度・鮮明度
        let avgLucidity = dreams.isEmpty ? 0 :
            Double(dreams.map(\.lucidity).reduce(0, +)) / Double(dreams.count)
        let avgVividness = dreams.isEmpty ? 0 :
            Double(dreams.map(\.vividness).reduce(0, +)) / Double(dreams.count)

        // 連続記録日数
        let streak = calculateStreak()

        // 曜日別カウント
        let weeklyCount = calculateWeekdayCounts()

        return DreamStatistics(
            totalDreams: dreams.count,
            analyzedDreams: analyzedDreams.count,
            emotionDistribution: emotionDist,
            topThemes: topThemes,
            topSymbols: topSymbols,
            averageLucidity: avgLucidity,
            averageVividness: avgVividness,
            streakDays: streak,
            weeklyCount: weeklyCount
        )
    }

    // MARK: - Calendar

    func calendarEntries(for month: Date) -> [DreamCalendarEntry] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }

        return range.map { day in
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
            let dayDreams = dreams.filter { calendar.isDate($0.recordedAt, inSameDayAs: date) }
            let primaryEmotion = dayDreams.first(where: { $0.isAnalyzed })?.emotionalTone
            return DreamCalendarEntry(
                date: date,
                dreamCount: dayDreams.count,
                primaryEmotion: primaryEmotion
            )
        }
    }

    // MARK: - Private Helpers

    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        let sortedDates = Set(dreams.map {
            calendar.startOfDay(for: $0.recordedAt)
        }).sorted(by: >)

        guard !sortedDates.isEmpty else { return 0 }

        var streak = 0
        var expectedDate = calendar.startOfDay(for: .now)

        for date in sortedDates {
            if date == expectedDate {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
            } else if date < expectedDate {
                break
            }
        }

        return streak
    }

    private func calculateWeekdayCounts() -> [WeekdayCount] {
        let calendar = Calendar.current
        let weekdayNames = ["日", "月", "火", "水", "木", "金", "土"]
        var counts = [Int: Int]()

        for dream in dreams {
            let weekday = calendar.component(.weekday, from: dream.recordedAt)
            counts[weekday, default: 0] += 1
        }

        return (1...7).map { weekday in
            WeekdayCount(
                weekday: weekdayNames[weekday - 1],
                count: counts[weekday] ?? 0
            )
        }
    }
}
