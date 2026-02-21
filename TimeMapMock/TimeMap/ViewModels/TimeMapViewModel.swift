import Foundation
import CoreLocation
import SwiftUI

/// TimeMap のメインビューモデル
@MainActor
@Observable
final class TimeMapViewModel {
    // MARK: - State

    /// 選択中の日付
    var selectedDate: Date = .now

    /// 取得されたイベント一覧
    private(set) var events: [ScheduleEvent] = []

    /// 座標付きイベント（地図表示用）
    var locatedEvents: [ScheduleEvent] {
        events.filter { $0.hasCoordinate && !$0.isAllDay }
    }

    /// 移動ルート
    private(set) var routes: [TravelRoute] = []

    /// 空き時間スロット
    private(set) var timeSlots: [TimeSlot] = []

    /// 選択中のアクティビティ提案
    private(set) var suggestedActivities: [SuggestedActivity] = []

    /// 選択中の空き時間スロット
    var selectedTimeSlot: TimeSlot? {
        didSet {
            if let slot = selectedTimeSlot {
                suggestedActivities = RouteCalculator.suggestActivities(for: slot)
            } else {
                suggestedActivities = []
            }
        }
    }

    /// 選択中の移動手段
    var selectedTransportType: TransportType = .transit {
        didSet {
            recalculateRoutes()
        }
    }

    /// 読み込み中フラグ
    private(set) var isLoading = false

    /// エラーメッセージ
    private(set) var errorMessage: String?

    /// カレンダー認可状態
    var isAuthorized: Bool {
        eventKitManager.isAuthorized
    }

    // MARK: - Statistics

    /// 今日の総イベント数
    var totalEventCount: Int { events.count }

    /// 座標付きイベント数
    var locatedEventCount: Int { locatedEvents.count }

    /// 空き時間の合計（分）
    var totalFreeMinutes: Int {
        timeSlots.reduce(0) { $0 + $1.durationMinutes }
    }

    /// 移動時間の合計（分）
    var totalTravelMinutes: Int {
        routes.reduce(0) { $0 + $1.estimatedTravelMinutes }
    }

    /// 総移動時間のテキスト
    var totalTravelTimeText: String {
        let hours = totalTravelMinutes / 60
        let minutes = totalTravelMinutes % 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        }
        return "\(minutes)分"
    }

    /// 総空き時間のテキスト
    var totalFreeTimeText: String {
        let hours = totalFreeMinutes / 60
        let minutes = totalFreeMinutes % 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        }
        return "\(minutes)分"
    }

    // MARK: - Dependencies

    private let eventKitManager = EventKitManager.shared

    // MARK: - Actions

    /// カレンダーアクセスをリクエスト
    func requestAccess() async {
        let granted = await eventKitManager.requestAccess()
        if granted {
            await loadEvents()
        }
    }

    /// 選択日のイベントを読み込み
    func loadEvents() async {
        isLoading = true
        errorMessage = nil

        let fetchedEvents = await eventKitManager.fetchEvents(for: selectedDate)
        events = fetchedEvents
        recalculateRoutes()
        recalculateTimeSlots()

        isLoading = false
    }

    /// 提案されたアクティビティをカレンダーに追加
    func addActivityToCalendar(
        _ activity: SuggestedActivity,
        in slot: TimeSlot
    ) async {
        let endDate = Calendar.current.date(
            byAdding: .minute,
            value: activity.estimatedMinutes,
            to: slot.startDate
        ) ?? slot.endDate

        do {
            try await eventKitManager.addEvent(
                title: activity.name,
                startDate: slot.startDate,
                endDate: min(endDate, slot.endDate),
                location: nil,
                coordinate: nil
            )
            // リロード
            await loadEvents()
        } catch {
            errorMessage = "イベントの追加に失敗しました: \(error.localizedDescription)"
        }
    }

    /// 日付を変更してイベントをリロード
    func changeDate(to date: Date) async {
        selectedDate = date
        selectedTimeSlot = nil
        await loadEvents()
    }

    // MARK: - Private

    /// ルートを再計算
    private func recalculateRoutes() {
        routes = RouteCalculator.calculateRoutes(
            for: events,
            transportType: selectedTransportType
        )
    }

    /// 空き時間スロットを再計算
    private func recalculateTimeSlots() {
        let calendar = Calendar.current
        let dayStart = calendar.date(
            bySettingHour: 7, minute: 0, second: 0, of: selectedDate
        ) ?? selectedDate
        let dayEnd = calendar.date(
            bySettingHour: 22, minute: 0, second: 0, of: selectedDate
        ) ?? selectedDate

        timeSlots = RouteCalculator.findTimeSlots(
            in: events,
            dayStart: dayStart,
            dayEnd: dayEnd
        )
    }
}
