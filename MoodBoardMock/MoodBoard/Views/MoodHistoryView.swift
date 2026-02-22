import SwiftUI

/// 気分の履歴カレンダービュー
struct MoodHistoryView: View {
    let viewModel: MoodBoardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 月間カレンダー風表示
                    MonthlyCalendarView(entries: viewModel.entries)

                    // 全履歴リスト
                    AllEntriesSection(entries: viewModel.entries)
                }
                .padding()
            }
            .navigationTitle("履歴")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Monthly Calendar View

private struct MonthlyCalendarView: View {
    let entries: [MoodEntry]

    private var last30DaysData: [(date: Date, mood: MoodType?)] {
        let calendar = Calendar.current
        return (0..<30).reversed().compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { return nil }
            let dayEntry = entries.last { calendar.isDate($0.date, inSameDayAs: date) }
            return (date: date, mood: dayEntry?.mood)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("直近30日間")
                .font(.headline)
                .padding(.leading, 4)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(Array(last30DaysData.enumerated()), id: \.offset) { _, item in
                    DayCell(date: item.date, mood: item.mood)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct DayCell: View {
    let date: Date
    let mood: MoodType?

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        VStack(spacing: 2) {
            if let mood {
                Text(mood.emoji)
                    .font(.system(size: 18))
            } else {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 18, height: 18)
            }

            Text(dayNumber)
                .font(.system(size: 9))
                .foregroundStyle(isToday ? .pink : .secondary)
                .fontWeight(isToday ? .bold : .regular)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(isToday ? Color.pink.opacity(0.08) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - All Entries Section

private struct AllEntriesSection: View {
    let entries: [MoodEntry]

    private var groupedByDate: [(date: String, entries: [MoodEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries.reversed()) { entry in
            calendar.startOfDay(for: entry.date)
        }

        return grouped
            .sorted { $0.key > $1.key }
            .prefix(14)
            .map { (date, entries) in
                let formatter = DateFormatter()
                formatter.dateFormat = "M月d日（E）"
                formatter.locale = Locale(identifier: "ja_JP")
                return (date: formatter.string(from: date), entries: entries)
            }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("日別一覧")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(Array(groupedByDate.enumerated()), id: \.offset) { _, group in
                VStack(alignment: .leading, spacing: 6) {
                    Text(group.date)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)

                    ForEach(group.entries) { entry in
                        EntryRow(entry: entry)
                    }
                }
            }
        }
    }
}

private struct EntryRow: View {
    let entry: MoodEntry

    var body: some View {
        HStack(spacing: 12) {
            Text(entry.mood.emoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.mood.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(entry.timeText)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(entry.mood.color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
