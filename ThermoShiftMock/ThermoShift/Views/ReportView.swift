import SwiftUI

/// 月次レポート画面
struct ReportView: View {
    let viewModel: ThermoShiftViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 累計サマリー
                    TotalSummaryCard(reports: viewModel.monthlyReports)

                    // 月次レポート一覧
                    MonthlyReportList(reports: viewModel.monthlyReports)
                }
                .padding()
            }
            .navigationTitle("節約レポート")
        }
    }
}

// MARK: - Total Summary Card

private struct TotalSummaryCard: View {
    let reports: [MonthlySavingsReport]

    private var totalSavings: Double {
        reports.reduce(0) { $0 + $1.totalSavings }
    }

    private var totalCO2: Double {
        reports.reduce(0) { $0 + $1.co2Savings }
    }

    private var averageComfort: Int {
        guard !reports.isEmpty else { return 0 }
        return reports.reduce(0) { $0 + $1.averageComfortScore } / reports.count
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("累計パフォーマンス")
                .font(.headline)

            HStack(spacing: 20) {
                VStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    Text(String(format: "$%.0f", totalSavings))
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("累計節約額")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    Text(String(format: "%.0f kg", totalCO2))
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("CO2 削減")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 6) {
                    Image(systemName: "face.smiling.inverse")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    Text("\(averageComfort)%")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("平均快適度")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(.orange.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Monthly Report List

private struct MonthlyReportList: View {
    let reports: [MonthlySavingsReport]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("月次レポート")
                .font(.headline)

            ForEach(reports) { report in
                MonthlyReportRow(report: report)
            }
        }
    }
}

private struct MonthlyReportRow: View {
    let report: MonthlySavingsReport

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(report.monthText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(report.savingsText)
                    .font(.headline)
                    .foregroundStyle(.green)
            }

            HStack(spacing: 16) {
                ReportStat(
                    icon: "bolt.fill",
                    value: String(format: "%.0f kWh", report.totalEnergyKWh)
                )
                ReportStat(
                    icon: "face.smiling",
                    value: "\(report.averageComfortScore)%"
                )
                ReportStat(
                    icon: "leaf.fill",
                    value: String(format: "%.0f kg", report.co2Savings)
                )
                ReportStat(
                    icon: "calendar",
                    value: "\(report.operatingDays)日"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct ReportStat: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
        }
    }
}
