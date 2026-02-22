import SwiftUI
import Charts

struct LightTimelineView: View {
    let viewModel: LightLifeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    hourlyLuxChart
                    colorTempChart
                    screenUsageCard
                }
                .padding()
            }
            .navigationTitle("タイムライン")
        }
    }

    // MARK: - Charts

    private var hourlyLuxChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.orange)
                Text("24 時間照度プロファイル")
                    .font(.headline)
                Spacer()
            }

            if let profile = viewModel.todayProfile {
                Chart {
                    ForEach(Array(profile.hourlyLux.enumerated()), id: \.offset) { hour, lux in
                        BarMark(
                            x: .value("時刻", "\(hour)時"),
                            y: .value("照度", min(lux, 3000))
                        )
                        .foregroundStyle(barColor(for: hour))
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: ["0時", "6時", "12時", "18時", "23時"])
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }

                HStack(spacing: 16) {
                    legendItem(color: .indigo, label: "夜間")
                    legendItem(color: .orange, label: "朝")
                    legendItem(color: .yellow, label: "日中")
                    legendItem(color: .purple, label: "夕方")
                }
                .font(.caption2)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var colorTempChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "thermometer.sun.fill")
                    .foregroundStyle(.red)
                Text("色温度の推移")
                    .font(.headline)
                Spacer()
            }

            if let profile = viewModel.todayProfile {
                Chart {
                    ForEach(Array(profile.hourlyColorTemp.enumerated()), id: \.offset) { hour, temp in
                        LineMark(
                            x: .value("時刻", hour),
                            y: .value("色温度", temp)
                        )
                        .foregroundStyle(.orange.gradient)

                        AreaMark(
                            x: .value("時刻", hour),
                            y: .value("色温度", temp)
                        )
                        .foregroundStyle(.orange.opacity(0.1))
                    }

                    RuleMark(y: .value("ブルーライト閾値", 5500))
                        .lineStyle(StrokeStyle(dash: [5, 3]))
                        .foregroundStyle(.blue.opacity(0.5))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("ブルーライト域")
                                .font(.caption2)
                                .foregroundStyle(.blue)
                        }
                }
                .frame(height: 180)
                .chartYScale(domain: 2500...7000)

                Text("色温度が高い（5500K以上）ほどブルーライトが多く含まれます。夜間は低色温度が理想的です。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var screenUsageCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "iphone")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("画面使用状況")
                    .font(.headline)
                Spacer()
            }

            if let report = viewModel.todayReport {
                let screen = report.screenUsage
                HStack(spacing: 16) {
                    screenMetric(
                        title: "合計使用時間",
                        value: formatDuration(screen.totalScreenTime),
                        icon: "clock.fill"
                    )
                    screenMetric(
                        title: "画面起動",
                        value: "\(screen.screenWakes)回",
                        icon: "power"
                    )
                    screenMetric(
                        title: "夜間使用",
                        value: "\(Int(screen.nightScreenTime / 60))分",
                        icon: "moon.fill"
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func barColor(for hour: Int) -> Color {
        switch hour {
        case 0...5: return .indigo
        case 6...8: return .orange
        case 9...16: return .yellow
        case 17...19: return .purple
        default: return .indigo
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
        }
    }

    private func screenMetric(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}
