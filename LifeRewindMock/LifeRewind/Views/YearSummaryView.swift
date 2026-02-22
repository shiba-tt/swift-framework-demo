import SwiftUI

/// 年間サマリービュー — カテゴリ別時間配分・月別推移・よく訪れた場所
struct YearSummaryView: View {
    @Bindable var viewModel: LifeRewindViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    yearSelector
                    if let summary = viewModel.yearSummary {
                        overviewCard(summary)
                        monthlyChart(summary)
                        categoryBreakdown(summary)
                        topLocationsCard(summary)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("年間サマリー")
        }
    }

    // MARK: - 年セレクタ

    private var yearSelector: some View {
        let currentYear = Calendar.current.component(.year, from: Date())
        return HStack(spacing: 12) {
            ForEach((currentYear - 2)...currentYear, id: \.self) { year in
                Button {
                    viewModel.changeYear(to: year)
                } label: {
                    Text("\(String(year))年")
                        .font(.subheadline)
                        .fontWeight(viewModel.selectedYear == year ? .bold : .regular)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedYear == year
                                ? Color.indigo : Color.clear,
                            in: Capsule()
                        )
                        .foregroundStyle(viewModel.selectedYear == year ? .white : .primary)
                }
            }
        }
    }

    // MARK: - 概要カード

    private func overviewCard(_ summary: YearSummary) -> some View {
        VStack(spacing: 16) {
            Text("\(String(summary.year))年の記録")
                .font(.headline)

            HStack(spacing: 24) {
                statBadge(
                    value: "\(summary.totalEvents)",
                    label: "イベント",
                    icon: "calendar",
                    color: .indigo
                )
                statBadge(
                    value: "\(Int(summary.totalHours))",
                    label: "時間",
                    icon: "clock.fill",
                    color: .orange
                )
                statBadge(
                    value: monthName(summary.busiestMonth),
                    label: "最多月",
                    icon: "flame.fill",
                    color: .red
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func statBadge(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 月別チャート

    private func monthlyChart(_ summary: YearSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("月別イベント数", systemImage: "chart.bar.fill")
                .font(.headline)

            let maxCount = summary.monthlyEventCounts.max() ?? 1

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<12, id: \.self) { index in
                    VStack(spacing: 4) {
                        let count = summary.monthlyEventCounts[index]
                        Text("\(count)")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor(for: index))
                            .frame(
                                height: maxCount > 0
                                    ? CGFloat(count) / CGFloat(maxCount) * 120
                                    : 0
                            )

                        Text("\(index + 1)月")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func barColor(for monthIndex: Int) -> Color {
        let currentMonth = Calendar.current.component(.month, from: Date()) - 1
        if monthIndex == currentMonth && viewModel.selectedYear == Calendar.current.component(.year, from: Date()) {
            return .indigo
        }
        return .indigo.opacity(0.4)
    }

    // MARK: - カテゴリ別内訳

    private func categoryBreakdown(_ summary: YearSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("カテゴリ別時間配分", systemImage: "chart.pie.fill")
                .font(.headline)

            ForEach(summary.categoryBreakdown) { stat in
                HStack(spacing: 12) {
                    Text(stat.category.emoji)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(stat.category.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(stat.eventCount)件 / \(Int(stat.totalHours))h")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        GeometryReader { geometry in
                            let totalHours = summary.categoryBreakdown.reduce(0.0) { $0 + $1.totalHours }
                            let ratio = totalHours > 0 ? stat.totalHours / totalHours : 0

                            RoundedRectangle(cornerRadius: 4)
                                .fill(stat.category.color.opacity(0.7))
                                .frame(width: geometry.size.width * ratio)
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - よく訪れた場所

    private func topLocationsCard(_ summary: YearSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("よく訪れた場所", systemImage: "mappin.and.ellipse")
                .font(.headline)

            ForEach(Array(summary.topLocations.enumerated()), id: \.element.id) { index, location in
                HStack {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(rankColor(index), in: Circle())

                    Text(location.name)
                        .font(.subheadline)

                    Spacer()

                    Text("\(location.visitCount)回")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - ヘルパー

    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.shortMonthSymbols[month - 1]
    }

    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: .yellow
        case 1: .gray
        case 2: .orange
        default: .indigo.opacity(0.5)
        }
    }
}
