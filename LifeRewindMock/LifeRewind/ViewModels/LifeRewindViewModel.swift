import Foundation
import SwiftUI

/// LifeRewind のメインビューモデル
@MainActor
@Observable
final class LifeRewindViewModel {
    var yearSummary: YearSummary?
    var onThisDayEntries: [OnThisDayEntry] = []
    var timelineEntries: [TimelineEntry] = []
    var futureInsights: [FutureInsight] = []
    var selectedYear: Int
    var isLoading = false
    var errorMessage: String?

    private let manager = LifeEventKitManager.shared

    init() {
        selectedYear = Calendar.current.component(.year, from: Date())
    }

    // MARK: - 初期化

    func initialize() async {
        isLoading = true
        loadDemoData()
        isLoading = false
    }

    // MARK: - 年変更

    func changeYear(to year: Int) {
        selectedYear = year
        loadDemoDataForYear(year)
    }

    // MARK: - デモデータ

    private func loadDemoData() {
        loadDemoDataForYear(selectedYear)
        generateOnThisDayEntries()
        generateTimeline()
        generateFutureInsights()
        updateWidgetData()
    }

    private func loadDemoDataForYear(_ year: Int) {
        let calendar = Calendar.current
        var monthCounts: [Int] = []
        let categoryData: [(LifeCategory, Int, Double)] = [
            (.work, 156, 624),
            (.personal, 89, 178),
            (.health, 52, 78),
            (.social, 45, 135),
            (.learning, 28, 56),
            (.travel, 12, 96),
            (.hobby, 34, 68),
        ]

        let baseMonthly = [28, 25, 35, 32, 38, 30, 42, 36, 34, 31, 29, 36]
        for i in 0..<12 {
            let variance = Int.random(in: -5...5)
            let adjusted = year == calendar.component(.year, from: Date())
                ? (i < calendar.component(.month, from: Date()) ? baseMonthly[i] + variance : 0)
                : baseMonthly[i] + variance
            monthCounts.append(max(0, adjusted))
        }

        let busiestMonthIndex = monthCounts.enumerated().max(by: { $0.element < $1.element })?.offset ?? 6

        let categoryStats = categoryData.map { cat, count, hours in
            let yearFactor = year == calendar.component(.year, from: Date()) ? 0.8 : 1.0
            return CategoryStat(
                id: UUID(),
                category: cat,
                eventCount: Int(Double(count) * yearFactor),
                totalHours: hours * yearFactor
            )
        }

        let topLocations = [
            LocationStat(id: UUID(), name: "東京駅", visitCount: 45),
            LocationStat(id: UUID(), name: "渋谷オフィス", visitCount: 38),
            LocationStat(id: UUID(), name: "新宿ジム", visitCount: 28),
            LocationStat(id: UUID(), name: "カフェ Macs", visitCount: 22),
            LocationStat(id: UUID(), name: "横浜みなとみらい", visitCount: 15),
        ]

        let totalEvents = monthCounts.reduce(0, +)
        let totalHours = categoryStats.reduce(0.0) { $0 + $1.totalHours }

        yearSummary = YearSummary(
            id: UUID(),
            year: year,
            totalEvents: totalEvents > 0 ? totalEvents : categoryStats.reduce(0) { $0 + $1.eventCount },
            busiestMonth: busiestMonthIndex + 1,
            busiestMonthEventCount: monthCounts[busiestMonthIndex],
            totalHours: totalHours,
            categoryBreakdown: categoryStats,
            topLocations: topLocations,
            monthlyEventCounts: monthCounts
        )
    }

    private func generateOnThisDayEntries() {
        let sampleEvents: [(String, LifeCategory, Int)] = [
            ("チームオフサイト合宿", .work, 1),
            ("友人の結婚式", .social, 2),
            ("京都旅行", .travel, 3),
            ("初マラソン完走", .health, 2),
            ("Swift 勉強会", .learning, 1),
        ]

        let calendar = Calendar.current
        let today = Date()

        onThisDayEntries = sampleEvents.compactMap { title, category, yearsAgo in
            guard let pastDate = calendar.date(byAdding: .year, value: -yearsAgo, to: today) else {
                return nil
            }
            let event = LifeEvent(
                id: UUID(),
                title: title,
                startDate: pastDate,
                endDate: calendar.date(byAdding: .hour, value: 2, to: pastDate) ?? pastDate,
                location: nil,
                calendarName: category.rawValue,
                category: category,
                isAllDay: false
            )
            return OnThisDayEntry(id: UUID(), event: event, yearsAgo: yearsAgo)
        }
    }

    private func generateTimeline() {
        let calendar = Calendar.current
        let today = Date()

        let highlights: [(String, LifeCategory, Int)] = [
            ("プロジェクトローンチ", .work, -300),
            ("沖縄旅行", .travel, -250),
            ("資格試験合格", .learning, -200),
            ("フルマラソン完走", .health, -150),
            ("忘年会", .social, -100),
            ("新年会", .social, -60),
            ("チーム表彰", .work, -30),
            ("新プロジェクト開始", .work, -10),
        ]

        timelineEntries = highlights.compactMap { title, category, dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                return nil
            }
            return TimelineEntry(
                id: UUID(),
                date: date,
                title: title,
                category: category,
                isHighlight: true
            )
        }.sorted { $0.date < $1.date }
    }

    private func generateFutureInsights() {
        guard let summary = yearSummary else { return }

        futureInsights = [
            FutureInsight(
                id: UUID(),
                message: "このペースで年間約 \(Int(summary.totalHours * 1.2)) 時間をイベントに費やします",
                icon: "clock.fill"
            ),
            FutureInsight(
                id: UUID(),
                message: "趣味の時間を週 1 時間増やすと年間 52 時間の充実時間が生まれます",
                icon: "sparkles"
            ),
            FutureInsight(
                id: UUID(),
                message: "月に 1 回の旅行を追加すると、年 12 の新しい思い出が作れます",
                icon: "airplane.departure"
            ),
        ]
    }

    private func updateWidgetData() {
        let widgetData = WidgetData(
            onThisDayTitle: onThisDayEntries.first?.event.title,
            onThisDayYearsAgo: onThisDayEntries.first?.yearsAgo,
            totalEventsThisYear: yearSummary?.totalEvents ?? 0,
            topCategoryEmoji: yearSummary?.categoryBreakdown.first?.category.emoji ?? "📅",
            topCategoryName: yearSummary?.categoryBreakdown.first?.category.rawValue ?? "不明"
        )
        manager.persistWidgetData(widgetData)
    }
}
