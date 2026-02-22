import SwiftUI

/// センサーチャンネル別の詳細表示画面
struct SensorDetailView: View {
    let viewModel: ChronoSenseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if let profile = viewModel.displayProfile {
                    VStack(spacing: 20) {
                        ForEach(SensorChannel.allCases) { channel in
                            ChannelDetailCard(
                                channel: channel,
                                readings: profile.readings
                            )
                        }
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "データなし",
                        systemImage: "waveform.path.ecg",
                        description: Text("センサーデータがまだ収集されていません")
                    )
                }
            }
            .navigationTitle("センサー詳細")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Channel Detail Card

private struct ChannelDetailCard: View {
    let channel: SensorChannel
    let readings: [SensorReading]

    private var peakHour: Int {
        readings.max(by: {
            channel.normalizedValue(from: $0) < channel.normalizedValue(from: $1)
        })?.hour ?? 0
    }

    private var peakValue: Double {
        readings.map { channel.normalizedValue(from: $0) }.max() ?? 0
    }

    private var averageValue: Double {
        let values = readings.map { channel.normalizedValue(from: $0) }
        return values.reduce(0, +) / max(1, Double(values.count))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Image(systemName: channel.systemImageName)
                    .font(.title3)
                    .foregroundStyle(Color(channel.colorName))
                Text(channel.rawValue)
                    .font(.headline)
                Spacer()
                Text("ピーク: \(peakHour):00")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // 24時間バーチャート
            HourlyBarChart(
                readings: readings,
                channel: channel
            )

            // 統計
            HStack(spacing: 16) {
                StatItem(label: "ピーク値", value: String(format: "%.0f%%", peakValue * 100))
                StatItem(label: "平均値", value: String(format: "%.0f%%", averageValue * 100))
                StatItem(label: "ピーク時間", value: "\(peakHour):00")
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Hourly Bar Chart

private struct HourlyBarChart: View {
    let readings: [SensorReading]
    let channel: SensorChannel

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(readings) { reading in
                let value = channel.normalizedValue(from: reading)
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(channel.colorName).opacity(0.3 + value * 0.7))
                        .frame(height: max(2, value * 60))

                    if reading.hour % 6 == 0 {
                        Text("\(reading.hour)")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 80)
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
