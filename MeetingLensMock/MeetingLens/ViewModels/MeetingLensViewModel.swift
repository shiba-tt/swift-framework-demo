import Foundation
import SwiftUI

/// MeetingLens のメインビューモデル
@MainActor
@Observable
final class MeetingLensViewModel {
    // MARK: - State

    /// 今日の会議一覧
    private(set) var todayMeetings: [MeetingEvent] = []

    /// 今週の会議一覧
    private(set) var weekMeetings: [MeetingEvent] = []

    /// 今月の会議一覧
    private(set) var monthMeetings: [MeetingEvent] = []

    /// 今日の統計
    private(set) var todayStats: MeetingStats = .empty

    /// 今週の統計
    private(set) var weekStats: MeetingStats = .empty

    /// 時間帯別会議密度（今週）
    private(set) var hourlyDensity: [HourlyMeetingDensity] = []

    /// 最適化提案
    private(set) var suggestions: [OptimizationSuggestion] = []

    /// 推定時給（円）
    var hourlyRate: Double = 5000

    /// 読み込み中フラグ
    private(set) var isLoading = false

    /// エラーメッセージ
    private(set) var errorMessage: String?

    /// カレンダー認可状態
    var isAuthorized: Bool {
        eventKitManager.isAuthorized
    }

    /// 今日のコストテキスト
    var todayCostText: String {
        todayStats.totalCostText
    }

    /// 今週のコストテキスト
    var weekCostText: String {
        weekStats.totalCostText
    }

    // MARK: - Dependencies

    private let eventKitManager = MeetingEventKitManager.shared

    // MARK: - Actions

    /// カレンダーアクセスをリクエスト
    func requestAccess() async {
        let granted = await eventKitManager.requestAccess()
        if granted {
            await loadAllData()
        }
    }

    /// 全データを読み込み
    func loadAllData() async {
        isLoading = true
        errorMessage = nil

        async let todayResult = eventKitManager.fetchMeetings(for: Date())
        async let weekResult = eventKitManager.fetchThisWeekMeetings()
        async let monthResult = eventKitManager.fetchThisMonthMeetings()

        todayMeetings = await todayResult
        weekMeetings = await weekResult
        monthMeetings = await monthResult

        // デモデータがない場合はデモを生成
        if todayMeetings.isEmpty && weekMeetings.isEmpty {
            generateDemoData()
        }

        todayStats = calculateStats(for: todayMeetings)
        weekStats = calculateStats(for: weekMeetings)
        hourlyDensity = calculateHourlyDensity(for: weekMeetings)
        suggestions = generateSuggestions(weekMeetings: weekMeetings, monthMeetings: monthMeetings)

        isLoading = false
    }

    /// 時給を変更して再計算
    func updateHourlyRate(_ rate: Double) {
        hourlyRate = rate
        todayStats = calculateStats(for: todayMeetings)
        weekStats = calculateStats(for: weekMeetings)
        suggestions = generateSuggestions(weekMeetings: weekMeetings, monthMeetings: monthMeetings)
    }

    // MARK: - Calculations

    /// 会議リストから統計を計算
    private func calculateStats(for meetings: [MeetingEvent]) -> MeetingStats {
        guard !meetings.isEmpty else { return .empty }

        let totalMinutes = meetings.reduce(0) { $0 + $1.durationMinutes }
        let totalCost = meetings.reduce(0.0) { $0 + $1.estimatedCost(hourlyRate: hourlyRate) }
        let avgAttendees = Double(meetings.reduce(0) { $0 + $1.attendeeCount }) / Double(meetings.count)
        let avgDuration = totalMinutes / meetings.count
        let recurringCount = meetings.filter(\.isRecurring).count
        let deepWorkScore = calculateDeepWorkScore(for: meetings)

        let mostExpensive = meetings
            .max { $0.estimatedCost(hourlyRate: hourlyRate) < $1.estimatedCost(hourlyRate: hourlyRate) }

        return MeetingStats(
            totalMeetings: meetings.count,
            totalMinutes: totalMinutes,
            totalCost: totalCost,
            averageAttendees: avgAttendees,
            averageDurationMinutes: avgDuration,
            deepWorkScore: deepWorkScore,
            mostExpensiveMeeting: mostExpensive?.title,
            recurringRate: meetings.isEmpty ? 0 : Double(recurringCount) / Double(meetings.count)
        )
    }

    /// ディープワークスコアを計算（連続空き時間の多さで評価）
    private func calculateDeepWorkScore(for meetings: [MeetingEvent]) -> Double {
        guard !meetings.isEmpty else { return 1.0 }

        let calendar = Calendar.current
        let sortedMeetings = meetings.sorted { $0.startDate < $1.startDate }

        // 日別にグループ化
        let grouped = Dictionary(grouping: sortedMeetings) { meeting in
            calendar.startOfDay(for: meeting.startDate)
        }

        var totalScore: Double = 0
        let workdayCount = max(1, grouped.count)

        for (day, dayMeetings) in grouped {
            guard let workStart = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: day),
                  let workEnd = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: day) else {
                continue
            }

            // 空き時間ブロックを計算
            var freeBlocks: [Int] = []
            var lastEnd = workStart

            for meeting in dayMeetings.sorted(by: { $0.startDate < $1.startDate }) {
                let effectiveStart = max(meeting.startDate, workStart)
                let gap = effectiveStart.timeIntervalSince(lastEnd)
                if gap > 0 {
                    freeBlocks.append(Int(gap / 60))
                }
                lastEnd = max(lastEnd, min(meeting.endDate, workEnd))
            }

            // 最後の空き
            let finalGap = workEnd.timeIntervalSince(lastEnd)
            if finalGap > 0 {
                freeBlocks.append(Int(finalGap / 60))
            }

            // 90分以上の連続ブロックが多いほどスコアが高い
            let deepBlocks = freeBlocks.filter { $0 >= 90 }
            let dayScore = min(1.0, Double(deepBlocks.count) * 0.33)
            totalScore += dayScore
        }

        return totalScore / Double(workdayCount)
    }

    /// 時間帯別の会議密度を計算
    private func calculateHourlyDensity(for meetings: [MeetingEvent]) -> [HourlyMeetingDensity] {
        var hourlyMinutes = Array(repeating: 0, count: 24)
        var hourlyCounts = Array(repeating: 0, count: 24)
        let calendar = Calendar.current

        for meeting in meetings {
            let startHour = calendar.component(.hour, from: meeting.startDate)
            let endHour = calendar.component(.hour, from: meeting.endDate)

            for hour in startHour...min(endHour, 23) {
                let minutesInHour: Int
                if hour == startHour && hour == endHour {
                    minutesInHour = meeting.durationMinutes
                } else if hour == startHour {
                    minutesInHour = 60 - calendar.component(.minute, from: meeting.startDate)
                } else if hour == endHour {
                    minutesInHour = calendar.component(.minute, from: meeting.endDate)
                } else {
                    minutesInHour = 60
                }
                hourlyMinutes[hour] += minutesInHour
                if hour == startHour {
                    hourlyCounts[hour] += 1
                }
            }
        }

        return (7...21).map { hour in
            HourlyMeetingDensity(
                id: hour,
                hour: hour,
                meetingMinutes: hourlyMinutes[hour],
                meetingCount: hourlyCounts[hour]
            )
        }
    }

    /// 最適化提案を生成
    private func generateSuggestions(
        weekMeetings: [MeetingEvent],
        monthMeetings: [MeetingEvent]
    ) -> [OptimizationSuggestion] {
        var result: [OptimizationSuggestion] = []

        // 30分会議を15分に短縮する提案
        let thirtyMinMeetings = monthMeetings.filter { $0.durationMinutes == 30 }
        if !thirtyMinMeetings.isEmpty {
            let savingMinutes = thirtyMinMeetings.count * 15
            let savingCost = thirtyMinMeetings.reduce(0.0) {
                $0 + $1.estimatedCost(hourlyRate: hourlyRate) / 2
            }
            result.append(OptimizationSuggestion(
                icon: "scissors",
                title: "30分会議を15分に",
                description: "\(thirtyMinMeetings.count)件の30分会議を15分に短縮すると効率的です",
                savingMinutes: savingMinutes,
                savingCost: savingCost
            ))
        }

        // 繰り返し会議の見直し提案
        let recurringMeetings = monthMeetings.filter(\.isRecurring)
        if !recurringMeetings.isEmpty {
            let totalRecurringMinutes = recurringMeetings.reduce(0) { $0 + $1.durationMinutes }
            let savingMinutes = totalRecurringMinutes / 4
            let savingCost = recurringMeetings.reduce(0.0) {
                $0 + $1.estimatedCost(hourlyRate: hourlyRate)
            } / 4
            result.append(OptimizationSuggestion(
                icon: "arrow.triangle.2.circlepath",
                title: "繰り返し会議の見直し",
                description: "\(recurringMeetings.count)件の定例会議のうち25%を廃止・非同期化できます",
                savingMinutes: savingMinutes,
                savingCost: savingCost
            ))
        }

        // ノー会議デーの提案
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: weekMeetings) { meeting in
            calendar.component(.weekday, from: meeting.startDate)
        }
        let busiestDay = grouped.max { $0.value.count < $1.value.count }
        if let busiest = busiestDay, busiest.value.count >= 3 {
            let dayName = Calendar.current.weekdaySymbols[busiest.key - 1]
            let avgMinutesPerDay = weekMeetings.reduce(0) { $0 + $1.durationMinutes } / max(1, grouped.count)
            let savingCost = Double(avgMinutesPerDay) / 60.0 * hourlyRate * 2.0
            result.append(OptimizationSuggestion(
                icon: "calendar.badge.minus",
                title: "ノー会議デーの導入",
                description: "\(dayName)は会議が\(busiest.value.count)件集中。週1日会議ゼロ日を設けましょう",
                savingMinutes: avgMinutesPerDay * 4,
                savingCost: savingCost
            ))
        }

        // 大人数会議の参加者削減
        let largeMeetings = monthMeetings.filter { $0.attendeeCount >= 5 }
        if !largeMeetings.isEmpty {
            let savingCost = largeMeetings.reduce(0.0) {
                $0 + $1.estimatedCost(hourlyRate: hourlyRate) * 0.3
            }
            result.append(OptimizationSuggestion(
                icon: "person.3.fill",
                title: "大人数会議の参加者精査",
                description: "\(largeMeetings.count)件の会議で参加者を30%削減できる可能性があります",
                savingMinutes: 0,
                savingCost: savingCost
            ))
        }

        return result
    }

    // MARK: - Demo Data

    private func generateDemoData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let titles = [
            "チーム定例ミーティング", "プロジェクトレビュー", "1on1",
            "スプリントプランニング", "デザインレビュー", "全体朝会",
            "クライアント MTG", "技術共有会", "KPI レビュー",
            "採用面接", "新機能ブレスト", "障害振り返り",
        ]

        var todayEvents: [MeetingEvent] = []
        var weekEvents: [MeetingEvent] = []
        var monthEvents: [MeetingEvent] = []

        let colors: [Color] = [.blue, .red, .green, .orange, .purple, .indigo]

        // 今日の会議
        let todaySlots: [(hour: Int, duration: Int, attendees: Int)] = [
            (9, 30, 8), (10, 60, 4), (13, 30, 2), (14, 60, 6), (16, 30, 3),
        ]
        for (index, slot) in todaySlots.enumerated() {
            guard let start = calendar.date(bySettingHour: slot.hour, minute: 0, second: 0, of: today),
                  let end = calendar.date(byAdding: .minute, value: slot.duration, to: start) else {
                continue
            }
            todayEvents.append(MeetingEvent(
                id: "today-\(index)",
                title: titles[index % titles.count],
                startDate: start,
                endDate: end,
                attendeeCount: slot.attendees,
                isRecurring: index % 2 == 0,
                calendarColor: colors[index % colors.count],
                organizer: nil,
                location: nil
            ))
        }

        // 今週の会議（今日 + 他の曜日）
        weekEvents.append(contentsOf: todayEvents)
        for dayOffset in 1...4 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let meetingCount = Int.random(in: 2...5)
            for i in 0..<meetingCount {
                let hour = 9 + i * 2
                let duration = [30, 30, 60, 60, 45].randomElement()!
                guard let start = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day),
                      let end = calendar.date(byAdding: .minute, value: duration, to: start) else {
                    continue
                }
                weekEvents.append(MeetingEvent(
                    id: "week-\(dayOffset)-\(i)",
                    title: titles[(dayOffset + i) % titles.count],
                    startDate: start,
                    endDate: end,
                    attendeeCount: Int.random(in: 2...10),
                    isRecurring: Bool.random(),
                    calendarColor: colors[(dayOffset + i) % colors.count],
                    organizer: nil,
                    location: nil
                ))
            }
        }

        // 今月の会議
        monthEvents.append(contentsOf: weekEvents)
        for weekOffset in 1...3 {
            for dayOffset in 0...4 {
                let totalDayOffset = weekOffset * 7 + dayOffset
                guard let day = calendar.date(byAdding: .day, value: totalDayOffset, to: today) else {
                    continue
                }
                let meetingCount = Int.random(in: 2...4)
                for i in 0..<meetingCount {
                    let hour = 9 + i * 2
                    let duration = [30, 30, 60, 45].randomElement()!
                    guard let start = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day),
                          let end = calendar.date(byAdding: .minute, value: duration, to: start) else {
                        continue
                    }
                    monthEvents.append(MeetingEvent(
                        id: "month-\(totalDayOffset)-\(i)",
                        title: titles[(totalDayOffset + i) % titles.count],
                        startDate: start,
                        endDate: end,
                        attendeeCount: Int.random(in: 2...10),
                        isRecurring: Bool.random(),
                        calendarColor: colors[(totalDayOffset + i) % colors.count],
                        organizer: nil,
                        location: nil
                    ))
                }
            }
        }

        todayMeetings = todayEvents
        self.weekMeetings = weekEvents
        self.monthMeetings = monthEvents
    }
}
