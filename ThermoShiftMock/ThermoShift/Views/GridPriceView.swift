import SwiftUI

/// グリッド料金 × クリーン度の詳細ビュー
struct GridPriceView: View {
    let viewModel: ThermoShiftViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 二軸チャート
                    DualAxisChart(gridData: viewModel.gridPriceData)

                    // 温度履歴
                    TemperatureHistoryChart(records: viewModel.temperatureHistory)

                    // 時間別データ
                    HourlyDataSection(gridData: viewModel.gridPriceData)
                }
                .padding()
            }
            .navigationTitle("グリッド × 料金")
            .refreshable {
                await viewModel.loadGridData()
            }
        }
    }
}

// MARK: - Dual Axis Chart

private struct DualAxisChart: View {
    let gridData: [GridPriceData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("電力料金 × クリーン度")
                .font(.headline)

            // 2行のバーチャート
            VStack(spacing: 8) {
                // クリーン度バー
                VStack(alignment: .leading, spacing: 4) {
                    Text("クリーン度")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(gridData) { data in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cleanColor(data.cleanFraction).gradient)
                                .frame(height: CGFloat(data.cleanFraction) * 50)
                        }
                    }
                    .frame(height: 55)
                }

                // 料金バー
                VStack(alignment: .leading, spacing: 4) {
                    Text("料金レベル")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(gridData) { data in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(priceColor(data.priceLevel).gradient)
                                .frame(height: priceHeight(data.priceLevel))
                        }
                    }
                    .frame(height: 35)
                }
            }

            // 時刻ラベル
            HStack {
                Text("0")
                Spacer()
                Text("6")
                Spacer()
                Text("12")
                Spacer()
                Text("18")
                Spacer()
                Text("24")
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)

            // 凡例
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Circle().fill(.green).frame(width: 6, height: 6)
                    Text("オフピーク")
                }
                HStack(spacing: 4) {
                    Circle().fill(.yellow).frame(width: 6, height: 6)
                    Text("ミッドピーク")
                }
                HStack(spacing: 4) {
                    Circle().fill(.red).frame(width: 6, height: 6)
                    Text("ピーク")
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
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

    private func priceHeight(_ level: PriceLevel) -> CGFloat {
        switch level {
        case .offPeak: 10
        case .midPeak: 20
        case .onPeak: 30
        }
    }
}

// MARK: - Temperature History Chart

private struct TemperatureHistoryChart: View {
    let records: [TemperatureRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("室温推移")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 3) {
                ForEach(records) { record in
                    VStack(spacing: 2) {
                        // 温度バー（20〜26°C をマッピング）
                        let normalizedHeight = (record.temperature - 18.0) / 10.0
                        RoundedRectangle(cornerRadius: 2)
                            .fill(temperatureColor(record.comfortScore).gradient)
                            .frame(height: CGFloat(max(0, min(1, normalizedHeight))) * 60)
                    }
                }
            }
            .frame(height: 65)

            HStack {
                Text("0")
                Spacer()
                Text("6")
                Spacer()
                Text("12")
                Spacer()
                Text("18")
                Spacer()
                Text("24")
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func temperatureColor(_ score: Int) -> Color {
        switch score {
        case 90...: .green
        case 70..<90: .yellow
        default: .red
        }
    }
}

// MARK: - Hourly Data Section

private struct HourlyDataSection: View {
    let gridData: [GridPriceData]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("時間別データ")
                .font(.headline)

            ForEach(gridData) { data in
                HStack {
                    Text(data.shortTimeText)
                        .font(.subheadline)
                        .frame(width: 36, alignment: .leading)

                    // クリーン度バー
                    ProgressView(value: data.cleanFraction)
                        .tint(cleanTint(data.cleanFraction))

                    Text("\(Int(data.cleanFraction * 100))%")
                        .font(.caption)
                        .frame(width: 36, alignment: .trailing)

                    // 料金バッジ
                    Text(data.priceLevel.rawValue)
                        .font(.system(size: 9))
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(priceBadgeColor(data.priceLevel).opacity(0.12))
                        .foregroundStyle(priceBadgeColor(data.priceLevel))
                        .clipShape(Capsule())
                        .frame(width: 76)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func cleanTint(_ fraction: Double) -> Color {
        switch fraction {
        case 0.6...: .green
        case 0.4..<0.6: .yellow
        default: .red
        }
    }

    private func priceBadgeColor(_ level: PriceLevel) -> Color {
        switch level {
        case .offPeak: .green
        case .midPeak: .yellow
        case .onPeak: .red
        }
    }
}
