import SwiftUI

/// ホーム画面：現在の室温 + 快適度 + 運転状態
struct HomeView: View {
    let viewModel: ThermoShiftViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 室温カード
                    TemperatureCard(viewModel: viewModel)

                    // 現在の運転モード
                    CurrentModeCard(viewModel: viewModel)

                    // 料金 × グリッド ミニチャート
                    GridMiniChart(gridData: viewModel.gridPriceData)

                    // サマリーカード
                    SummaryCard(viewModel: viewModel)

                    // 温度調整ボタン
                    TemperatureControls(viewModel: viewModel)
                }
                .padding()
            }
            .navigationTitle("ThermoShift")
            .refreshable {
                await viewModel.loadGridData()
            }
            .sheet(isPresented: Binding(
                get: { viewModel.showSettings },
                set: { viewModel.showSettings = $0 }
            )) {
                SettingsSheet(viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
        }
    }
}

// MARK: - Temperature Card

private struct TemperatureCard: View {
    let viewModel: ThermoShiftViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("現在の室温")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", viewModel.currentTemperature))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("°C")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 20) {
                Label("目標: \(Int(viewModel.targetTemperature))°C", systemImage: "target")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label(
                    "快適度: \(viewModel.comfortScoreText)",
                    systemImage: comfortIcon(score: viewModel.currentComfortScore)
                )
                .font(.caption)
                .foregroundStyle(comfortColor(score: viewModel.currentComfortScore))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.orange.opacity(0.08))
        )
    }

    private func comfortIcon(score: Int) -> String {
        switch score {
        case 90...: "face.smiling.inverse"
        case 70..<90: "face.smiling"
        default: "exclamationmark.triangle"
        }
    }

    private func comfortColor(score: Int) -> Color {
        switch score {
        case 90...: .green
        case 70..<90: .yellow
        default: .red
        }
    }
}

// MARK: - Current Mode Card

private struct CurrentModeCard: View {
    let viewModel: ThermoShiftViewModel

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: viewModel.currentModeIcon)
                .font(.title2)
                .foregroundStyle(modeColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text("現在の運転")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.currentModeText)
                    .font(.headline)
            }

            Spacer()

            if let slot = viewModel.activeSlot {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(slot.targetTemperature))°C")
                        .font(.headline)
                    Text(slot.timeRangeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var modeColor: Color {
        guard let slot = viewModel.activeSlot else { return .secondary }
        switch slot.mode {
        case .preHeat: .orange
        case .preCool: .cyan
        case .normal: .green
        case .passive: .yellow
        case .off: .red
        }
    }
}

// MARK: - Grid Mini Chart

private struct GridMiniChart: View {
    let gridData: [GridPriceData]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("電力料金 × グリッド")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 3) {
                    ForEach(gridData) { data in
                        VStack(spacing: 2) {
                            // クリーン度バー
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cleanColor(data.cleanFraction).gradient)
                                .frame(width: 12, height: CGFloat(data.cleanFraction) * 40)

                            // 料金インジケーター
                            Circle()
                                .fill(priceColor(data.priceLevel))
                                .frame(width: 6, height: 6)

                            Text(data.shortTimeText)
                                .font(.system(size: 7))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .frame(height: 70)

            // 凡例
            HStack(spacing: 12) {
                LegendDot(color: .green, label: "安+緑")
                LegendDot(color: .yellow, label: "中+黄")
                LegendDot(color: .red, label: "高+赤")
            }
            .font(.caption2)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func cleanColor(_ fraction: Double) -> Color {
        switch fraction {
        case 0.6...: .green
        case 0.4..<0.6: .yellow
        default: .red
        }
    }

    private func priceColor(_ level: PriceLevel) -> Color {
        switch level {
        case .offPeak: .green
        case .midPeak: .yellow
        case .onPeak: .red
        }
    }
}

private struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Summary Card

private struct SummaryCard: View {
    let viewModel: ThermoShiftViewModel

    var body: some View {
        HStack(spacing: 16) {
            MiniStat(
                icon: "dollarsign.circle.fill",
                value: viewModel.savingsText,
                label: "予測節約",
                color: .green
            )
            MiniStat(
                icon: "face.smiling.inverse",
                value: viewModel.comfortScoreText,
                label: "快適度",
                color: .orange
            )
            MiniStat(
                icon: "bolt.fill",
                value: viewModel.energyText,
                label: "消費電力",
                color: .blue
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct MiniStat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Temperature Controls

private struct TemperatureControls: View {
    let viewModel: ThermoShiftViewModel

    var body: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.adjustTargetTemperature(by: -0.5)
            } label: {
                Label("-0.5°C", systemImage: "minus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.opacity(0.15))
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                viewModel.adjustTargetTemperature(by: 0.5)
            } label: {
                Label("+0.5°C", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red.opacity(0.15))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}

// MARK: - Settings Sheet

private struct SettingsSheet: View {
    let viewModel: ThermoShiftViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("快適度設定") {
                    HStack {
                        Text("最低温度")
                        Spacer()
                        Text("\(Int(viewModel.comfortProfile.minimumTemperature))°C")
                            .foregroundStyle(.secondary)
                    }
                    Slider(
                        value: Binding(
                            get: { viewModel.comfortProfile.minimumTemperature },
                            set: { viewModel.comfortProfile.minimumTemperature = $0 }
                        ),
                        in: 16...24,
                        step: 1
                    )
                    .tint(.blue)

                    HStack {
                        Text("最高温度")
                        Spacer()
                        Text("\(Int(viewModel.comfortProfile.maximumTemperature))°C")
                            .foregroundStyle(.secondary)
                    }
                    Slider(
                        value: Binding(
                            get: { viewModel.comfortProfile.maximumTemperature },
                            set: { viewModel.comfortProfile.maximumTemperature = $0 }
                        ),
                        in: 22...32,
                        step: 1
                    )
                    .tint(.red)
                }

                Section("目標快適度スコア") {
                    HStack {
                        Text("最低スコア")
                        Spacer()
                        Text("\(viewModel.comfortProfile.targetComfortScore)%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.comfortProfile.targetComfortScore) },
                            set: { viewModel.comfortProfile.targetComfortScore = Int($0) }
                        ),
                        in: 70...100,
                        step: 5
                    )
                    .tint(.orange)
                }

                Section("特殊モード温度") {
                    HStack {
                        Text("就寝時")
                        Spacer()
                        Text("\(Int(viewModel.comfortProfile.sleepTemperature))°C")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("外出時")
                        Spacer()
                        Text("\(Int(viewModel.comfortProfile.awayTemperature))°C")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button("AI プランを再生成") {
                        viewModel.generateOptimizedPlan()
                        viewModel.showSettings = false
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("快適度設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.showSettings = false
                    }
                }
            }
        }
    }
}
