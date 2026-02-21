import SwiftUI

/// タイムライン形式でイベントと空き時間を表示
struct TimelineView: View {
    @Bindable var viewModel: TimeMapViewModel
    @State private var showActivitySheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("読み込み中...")
                        .padding(.top, 60)
                } else if viewModel.events.isEmpty {
                    emptyState
                } else {
                    timelineContent
                }
            }
            .navigationTitle("タイムライン")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.loadEvents()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showActivitySheet) {
                if let slot = viewModel.selectedTimeSlot {
                    ActivitySuggestionSheet(
                        slot: slot,
                        activities: viewModel.suggestedActivities,
                        onSelect: { activity in
                            Task {
                                await viewModel.addActivityToCalendar(activity, in: slot)
                            }
                            showActivitySheet = false
                        }
                    )
                    .presentationDetents([.medium])
                }
            }
        }
    }

    // MARK: - Content

    private var timelineContent: some View {
        LazyVStack(spacing: 0) {
            // 日付ヘッダー
            dateHeader
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            // イベントと空き時間を時系列で表示
            ForEach(mergedTimelineItems) { item in
                switch item {
                case .event(let event):
                    EventTimelineRow(event: event)
                        .padding(.horizontal, 16)
                case .freeSlot(let slot):
                    FreeSlotRow(slot: slot) {
                        viewModel.selectedTimeSlot = slot
                        showActivitySheet = true
                    }
                    .padding(.horizontal, 16)
                case .travel(let route):
                    TravelRow(route: route)
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var dateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDate)
                    .font(.headline)
                Text("\(viewModel.totalEventCount)件の予定")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("この日の予定はありません")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 60)
    }

    // MARK: - Timeline Items

    /// イベント・空き時間・移動をマージしたタイムラインアイテム
    private var mergedTimelineItems: [TimelineItem] {
        var items: [TimelineItem] = []
        let sortedEvents = viewModel.events
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }

        let slots = viewModel.timeSlots
        let routes = viewModel.routes

        // イベントと空き時間を時系列に並べる
        var slotIndex = 0
        var routeIndex = 0

        for event in sortedEvents {
            // この前の空き時間を追加
            while slotIndex < slots.count && slots[slotIndex].endDate <= event.startDate {
                items.append(.freeSlot(slots[slotIndex]))
                slotIndex += 1
            }

            // 移動情報を追加
            if routeIndex < routes.count &&
                routes[routeIndex].destinationEventTitle == event.title {
                items.append(.travel(routes[routeIndex]))
                routeIndex += 1
            }

            items.append(.event(event))
        }

        // 残りの空き時間
        while slotIndex < slots.count {
            items.append(.freeSlot(slots[slotIndex]))
            slotIndex += 1
        }

        return items
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: viewModel.selectedDate)
    }
}

// MARK: - Timeline Item

enum TimelineItem: Identifiable {
    case event(ScheduleEvent)
    case freeSlot(TimeSlot)
    case travel(TravelRoute)

    var id: String {
        switch self {
        case .event(let e): "event-\(e.id)"
        case .freeSlot(let s): "slot-\(s.id)"
        case .travel(let r): "travel-\(r.id)"
        }
    }
}

// MARK: - Row Views

/// イベント行
struct EventTimelineRow: View {
    let event: ScheduleEvent

    var body: some View {
        HStack(spacing: 12) {
            // タイムラインライン
            VStack(spacing: 0) {
                Rectangle()
                    .fill(colorForEvent.opacity(0.3))
                    .frame(width: 2)
                Circle()
                    .fill(colorForEvent)
                    .frame(width: 12, height: 12)
                Rectangle()
                    .fill(colorForEvent.opacity(0.3))
                    .frame(width: 2)
            }
            .frame(width: 12)

            // 時間表示
            VStack(alignment: .leading, spacing: 0) {
                Text(timeText(event.startDate))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(timeText(event.endDate))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .frame(width: 40)

            // イベント内容
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline.bold())

                if let location = event.location {
                    Label(location, systemImage: "mappin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("\(event.durationMinutes)分")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(colorForEvent.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 4)
    }

    private var colorForEvent: Color {
        switch event.calendarColor {
        case .blue: .blue
        case .red: .red
        case .green: .green
        case .orange: .orange
        case .purple: .purple
        case .yellow: .yellow
        case .brown: .brown
        case .pink: .pink
        }
    }

    private func timeText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

/// 空き時間行
struct FreeSlotRow: View {
    let slot: TimeSlot
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // タイムラインライン（点線）
            VStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { _ in
                    Rectangle()
                        .fill(.secondary.opacity(0.3))
                        .frame(width: 2, height: 4)
                    Spacer()
                        .frame(height: 4)
                }
            }
            .frame(width: 12)

            // 時間表示
            VStack {
                Text(slot.timeRangeText)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .frame(width: 40)

            // 空き時間カード
            Button(action: onTap) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.indigo)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("空き時間: \(slot.durationText)")
                            .font(.caption.bold())
                        Text("タップしてアクティビティを提案")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(.indigo.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}

/// 移動行
struct TravelRow: View {
    let route: TravelRoute

    var body: some View {
        HStack(spacing: 12) {
            // タイムラインライン
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.orange.opacity(0.3))
                    .frame(width: 2)
            }
            .frame(width: 12)

            Spacer()
                .frame(width: 40)

            HStack(spacing: 6) {
                Image(systemName: route.transportType.systemImageName)
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("移動 \(route.travelTimeText)")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.orange.opacity(0.1))
            .clipShape(Capsule())

            Spacer()
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Activity Suggestion Sheet

/// アクティビティ提案シート
struct ActivitySuggestionSheet: View {
    let slot: TimeSlot
    let activities: [SuggestedActivity]
    let onSelect: (SuggestedActivity) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label("空き時間", systemImage: "clock")
                        Spacer()
                        Text(slot.durationText)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("時間帯", systemImage: "calendar.circle")
                        Spacer()
                        Text(slot.timeRangeText)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("空き時間の詳細")
                }

                Section {
                    ForEach(activities) { activity in
                        Button {
                            onSelect(activity)
                        } label: {
                            HStack {
                                Image(systemName: activity.systemImageName)
                                    .font(.title3)
                                    .foregroundStyle(.indigo)
                                    .frame(width: 32)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(activity.name)
                                        .font(.subheadline)
                                    Text(activity.durationText)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.indigo)
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                } header: {
                    Text("おすすめアクティビティ")
                } footer: {
                    Text("タップするとカレンダーに追加されます")
                }
            }
            .navigationTitle("アクティビティ提案")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
