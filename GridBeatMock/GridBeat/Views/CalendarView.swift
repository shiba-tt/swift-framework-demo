import SwiftUI

struct CalendarView: View {
    @Bindable var viewModel: GridBeatViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["\u{6708}", "\u{706B}", "\u{6C34}", "\u{6728}", "\u{91D1}", "\u{571F}", "\u{65E5}"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    calendarGrid
                    legendCard
                    weeklyTrendCard
                }
                .padding()
            }
            .navigationTitle("\u{30AB}\u{30FC}\u{30DC}\u{30F3}\u{30AB}\u{30EC}\u{30F3}\u{30C0}\u{30FC}")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        VStack(spacing: 12) {
            // Month header
            HStack {
                Text(currentMonthText)
                    .font(.headline)
                Spacer()
                Text(String(format: "\u{30B0}\u{30EA}\u{30FC}\u{30F3}\u{65E5}\u{7387}: %.0f%%", viewModel.greenDayRate))
                    .font(.subheadline)
                    .foregroundStyle(.green)
            }

            // Weekday headers
            HStack(spacing: 4) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar days
            LazyVGrid(columns: columns, spacing: 4) {
                // Leading empty cells for first day offset
                ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                    Color.clear
                        .frame(height: 36)
                }

                ForEach(viewModel.calendarDays) { day in
                    VStack(spacing: 2) {
                        Text("\(day.dayNumber)")
                            .font(.caption2)
                            .foregroundStyle(day.isToday ? .white : .primary)

                        Circle()
                            .fill(day.rating.color.opacity(0.8))
                            .frame(width: 8, height: 8)
                    }
                    .frame(height: 36)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(day.isToday ? Color.green.opacity(0.3) : Color.clear)
                    )
                }
            }

            // Summary
            HStack(spacing: 16) {
                DayCountBadge(count: viewModel.greenDaysCount, color: .green, label: "\u{65E5}")
                DayCountBadge(count: viewModel.yellowDaysCount, color: .yellow, label: "\u{65E5}")
                DayCountBadge(count: viewModel.redDaysCount, color: .red, label: "\u{65E5}")
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Legend

    private var legendCard: some View {
        VStack(spacing: 8) {
            Text("\u{51E1}\u{4F8B}")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 20) {
                LegendItem(color: .green, label: "< 1.5 kg CO\u{2082}")
                LegendItem(color: .yellow, label: "1.5\u{2013}3.0 kg")
                LegendItem(color: .red, label: "> 3.0 kg")
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Weekly Trend

    private var weeklyTrendCard: some View {
        VStack(spacing: 12) {
            Text("\u{904E}\u{53BB}14\u{65E5}\u{9593}\u{306E}\u{63A8}\u{79FB}")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(viewModel.carbonHistory) { record in
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(CarbonDayRating.from(totalKg: record.totalKg).color.opacity(0.8))
                            .frame(height: CGFloat(record.totalKg) * 16)

                        Text(record.dateText)
                            .font(.system(size: 7))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 80)

            if let monthly = viewModel.monthlySummary {
                HStack(spacing: 16) {
                    MonthlyStatItem(
                        label: "CO\u{2082} \u{7DCF}\u{91CF}",
                        value: String(format: "%.0f kg", monthly.totalCO2Kg)
                    )
                    MonthlyStatItem(
                        label: "\u{30AF}\u{30EA}\u{30FC}\u{30F3}\u{5145}\u{96FB}\u{7387}",
                        value: String(format: "%.0f%%", monthly.cleanChargeRate * 100)
                    )
                    MonthlyStatItem(
                        label: "\u{7BC0}\u{7D04}\u{984D}",
                        value: String(format: "$%.0f", monthly.costSavings)
                    )
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Helpers

    private var currentMonthText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy\u{5E74}M\u{6708}"
        return formatter.string(from: Date())
    }

    private var firstWeekdayOffset: Int {
        let calendar = Calendar.current
        guard let firstOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: Date())
        ) else { return 0 }
        // Monday = 0
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        return (weekday + 5) % 7
    }
}

// MARK: - Components

private struct DayCountBadge: View {
    let count: Int
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text("\(count)\(label)")
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

private struct MonthlyStatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CalendarView(viewModel: GridBeatViewModel())
}
