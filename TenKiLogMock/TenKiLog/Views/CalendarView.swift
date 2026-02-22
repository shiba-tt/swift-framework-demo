import SwiftUI

struct CalendarView: View {
    let viewModel: TenKiLogViewModel

    @State private var displayedMonth = Date()
    @State private var selectedLog: WeatherLog?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    monthSelector()
                    calendarGrid()
                    if let log = selectedLog {
                        selectedDayDetail(log)
                    }
                }
                .padding()
            }
            .navigationTitle("天気カレンダー")
        }
    }

    // MARK: - Month Selector

    private func monthSelector() -> some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(monthYearString())
                .font(.title3)
                .fontWeight(.bold)

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Calendar Grid

    private func calendarGrid() -> some View {
        let calendar = Calendar.current
        let monthLogs = logsForDisplayedMonth()

        return VStack(spacing: 4) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days
            let days = daysInMonth()
            let firstWeekday = firstWeekdayOfMonth()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 4) {
                // Padding for first week
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear.frame(height: 52)
                }

                ForEach(1...days, id: \.self) { day in
                    let date = calendar.date(from: DateComponents(
                        year: calendar.component(.year, from: displayedMonth),
                        month: calendar.component(.month, from: displayedMonth),
                        day: day
                    ))
                    let log = date.flatMap { d in monthLogs.first { calendar.isDate($0.date, inSameDayAs: d) } }

                    dayCell(day: day, log: log, isSelected: log?.id == selectedLog?.id)
                        .onTapGesture {
                            selectedLog = log
                        }
                }
            }
        }
    }

    private func dayCell(day: Int, log: WeatherLog?, isSelected: Bool) -> some View {
        VStack(spacing: 2) {
            Text("\(day)")
                .font(.caption2)
                .foregroundStyle(isSelected ? .white : .primary)

            if let log {
                Text(log.condition.emoji)
                    .font(.system(size: 14))
                if let mood = log.mood {
                    Text(mood.emoji)
                        .font(.system(size: 10))
                }
            } else {
                Text(" ")
                    .font(.system(size: 14))
                Text(" ")
                    .font(.system(size: 10))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
            isSelected ? Color.accentColor.opacity(0.8) : (log != nil ? Color.fill.quaternary : Color.clear),
            in: RoundedRectangle(cornerRadius: 8)
        )
    }

    // MARK: - Selected Day Detail

    private func selectedDayDetail(_ log: WeatherLog) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(log.dateFormatted)
                    .font(.headline)
                Spacer()
                Text(log.condition.emoji)
                    .font(.title2)
                Text(log.condition.displayName)
                    .font(.subheadline)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                detailItem(icon: "thermometer.medium", label: "気温", value: log.temperatureRange, color: .orange)
                detailItem(icon: "humidity.fill", label: "湿度", value: "\(Int(log.humidity * 100))%", color: .cyan)
                detailItem(icon: "gauge.with.dots.needle.33percent", label: "気圧", value: log.pressureFormatted, color: .purple)
                detailItem(icon: "wind", label: "風速", value: String(format: "%.1f m/s", log.windSpeed), color: .teal)
                detailItem(icon: "sun.max.fill", label: "UV", value: "\(log.uvIndex)", color: .yellow)
                detailItem(icon: "drop.fill", label: "降水量", value: String(format: "%.1f mm", log.precipitation), color: .blue)
            }

            if let mood = log.mood {
                HStack {
                    Text("気分:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(mood.emoji)
                    Text(mood.displayName)
                        .font(.subheadline)
                }
            }

            if !log.healthConditions.contains(.none) {
                HStack {
                    Text("体調:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    ForEach(log.healthConditions.filter { $0 != .none }) { condition in
                        HStack(spacing: 2) {
                            Text(condition.emoji)
                            Text(condition.displayName)
                                .font(.caption)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.fill.quaternary, in: Capsule())
                    }
                }
            }

            if let note = log.diaryNote {
                VStack(alignment: .leading, spacing: 4) {
                    Text("日記")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(note)
                        .font(.subheadline)
                }
            }

            if let comparison = log.historicalComparison {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(.orange)
                    Text(comparison)
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func detailItem(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding(8)
        .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Helpers

    private func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy\u{5E74}M\u{6708}"
        return formatter.string(from: displayedMonth)
    }

    private func moveMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newDate
            selectedLog = nil
        }
    }

    private func daysInMonth() -> Int {
        Calendar.current.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30
    }

    private func firstWeekdayOfMonth() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDay = calendar.date(from: components) else { return 0 }
        return calendar.component(.weekday, from: firstDay) - 1
    }

    private func logsForDisplayedMonth() -> [WeatherLog] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: displayedMonth)
        let month = calendar.component(.month, from: displayedMonth)
        return WeatherLogManager.shared.logsForMonth(year: year, month: month)
    }
}
