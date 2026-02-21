import SwiftUI

// MARK: - DreamCalendarView（夢カレンダー）

struct DreamCalendarView: View {
    @Bindable var viewModel: DreamJournalViewModel
    @State private var displayedMonth = Date.now

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 月ナビゲーション
                    monthNavigation

                    // カレンダーグリッド
                    calendarGrid

                    // 凡例
                    legendView

                    // 選択月の夢一覧
                    monthDreamList
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("カレンダー")
        }
    }

    // MARK: - Month Navigation

    private var monthNavigation: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }

            Spacer()

            Text(monthYearString)
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        VStack(spacing: 4) {
            // 曜日ヘッダー
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(height: 24)
                }
            }

            // 日付セル
            LazyVGrid(columns: columns, spacing: 4) {
                // 月初の空白
                ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                    Color.clear
                        .frame(height: 52)
                }

                // カレンダーエントリー
                ForEach(calendarEntries) { entry in
                    CalendarDayCell(entry: entry)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Legend

    private var legendView: some View {
        HStack(spacing: 16) {
            ForEach([EmotionalTone.joyful, .peaceful, .anxious, .fearful], id: \.rawValue) { tone in
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(tone.colorName))
                        .frame(width: 8, height: 8)
                    Text(tone.displayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Month Dream List

    private var monthDreamList: some View {
        VStack(alignment: .leading, spacing: 12) {
            let monthDreams = dreamsForDisplayedMonth
            HStack {
                Text("\(monthYearString)の記録")
                    .font(.headline)
                Spacer()
                Text("\(monthDreams.count) 件")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if monthDreams.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "moon.zzz")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text("この月の記録はありません")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(monthDreams) { dream in
                    HStack(spacing: 12) {
                        Text(dream.emotionalToneEmoji)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(dream.displayTitle)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(dream.formattedDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if !dream.themes.isEmpty {
                            Text(dream.themes.first ?? "")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.purple.opacity(0.1))
                                .foregroundStyle(.purple)
                                .clipShape(Capsule())
                        }
                    }
                    .padding()
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    // MARK: - Helpers

    private var calendarEntries: [DreamCalendarEntry] {
        viewModel.calendarEntries(for: displayedMonth)
    }

    private var dreamsForDisplayedMonth: [DreamEntry] {
        let calendar = Calendar.current
        return viewModel.dreams.filter { dream in
            let dreamComponents = calendar.dateComponents([.year, .month], from: dream.recordedAt)
            let displayComponents = calendar.dateComponents([.year, .month], from: displayedMonth)
            return dreamComponents.year == displayComponents.year &&
                   dreamComponents.month == displayComponents.month
        }.sorted { $0.recordedAt > $1.recordedAt }
    }

    private var firstWeekdayOffset: Int {
        let calendar = Calendar.current
        guard let firstDay = calendar.date(
            from: calendar.dateComponents([.year, .month], from: displayedMonth)
        ) else { return 0 }
        return (calendar.component(.weekday, from: firstDay) - 1) % 7
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: displayedMonth)
    }

    private func moveMonth(by value: Int) {
        if let newMonth = Calendar.current.date(
            byAdding: .month, value: value, to: displayedMonth
        ) {
            displayedMonth = newMonth
        }
    }
}

// MARK: - CalendarDayCell

struct CalendarDayCell: View {
    let entry: DreamCalendarEntry

    var body: some View {
        VStack(spacing: 2) {
            Text(entry.dateString)
                .font(.caption)
                .fontWeight(entry.hasEntry ? .bold : .regular)
                .foregroundStyle(entry.hasEntry ? .primary : .secondary)

            if entry.hasEntry {
                Circle()
                    .fill(dotColor)
                    .frame(width: 8, height: 8)

                if entry.dreamCount > 1 {
                    Text("\(entry.dreamCount)")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }
            } else {
                Circle()
                    .fill(.clear)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(entry.hasEntry ? dotColor.opacity(0.08) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var dotColor: Color {
        if let emotion = entry.primaryEmotion {
            return Color(emotion.colorName)
        }
        return .purple
    }
}
