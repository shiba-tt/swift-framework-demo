import SwiftUI

/// 24時間クロノグラフ表示画面
struct ChronographView: View {
    let viewModel: ChronoSenseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let profile = viewModel.displayProfile {
                        // リズムスコアカード
                        ScoreHeaderCard(profile: profile)

                        // 24時間クロノグラフ
                        ChronographRing(
                            profile: profile,
                            selectedChannel: viewModel.selectedChannel
                        )

                        // チャンネル選択
                        ChannelPicker(selected: Binding(
                            get: { viewModel.selectedChannel },
                            set: { viewModel.selectedChannel = $0 }
                        ))

                        // サマリーカード
                        SummaryCards(profile: profile)
                    } else {
                        ProgressView("データを読み込み中...")
                    }
                }
                .padding()
            }
            .navigationTitle("ChronoSense")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Score Header Card

private struct ScoreHeaderCard: View {
    let profile: CircadianProfile

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("リズム整合度")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(profile.rhythmScore)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                        Text("/ 100")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: profile.scoreLevel.systemImageName)
                        .font(.title)
                        .foregroundStyle(Color(profile.scoreLevel.colorName))

                    Text(profile.scoreLevel.rawValue)
                        .font(.headline)
                        .foregroundStyle(Color(profile.scoreLevel.colorName))

                    if let change = profile.changeFromPrevious {
                        HStack(spacing: 2) {
                            Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                            Text("\(abs(change))")
                        }
                        .font(.caption)
                        .foregroundStyle(change >= 0 ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 24-Hour Chronograph Ring

private struct ChronographRing: View {
    let profile: CircadianProfile
    let selectedChannel: SensorChannel

    var body: some View {
        VStack(spacing: 8) {
            Text("24 時間クロノグラフ")
                .font(.headline)

            ZStack {
                // 外枠の時計
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 2)

                // 時刻ラベル
                ForEach([0, 3, 6, 9, 12, 15, 18, 21], id: \.self) { hour in
                    let angle = angleForHour(hour)
                    Text(String(format: "%02d", hour))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .offset(
                            x: cos(angle) * 130,
                            y: sin(angle) * 130
                        )
                }

                // データリング
                ForEach(profile.readings) { reading in
                    let angle = angleForHour(reading.hour)
                    let value = selectedChannel.normalizedValue(from: reading)
                    let radius = 40 + value * 70

                    Circle()
                        .fill(Color(selectedChannel.colorName).opacity(0.3 + value * 0.7))
                        .frame(width: 16, height: 16)
                        .offset(
                            x: cos(angle) * radius,
                            y: sin(angle) * radius
                        )
                }

                // 睡眠時間帯の表示
                ForEach(profile.sleepHours, id: \.self) { hour in
                    let angle = angleForHour(hour)
                    Image(systemName: "moon.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.purple.opacity(0.5))
                        .offset(
                            x: cos(angle) * 30,
                            y: sin(angle) * 30
                        )
                }

                // 中心テキスト
                VStack(spacing: 2) {
                    Image(systemName: selectedChannel.systemImageName)
                        .font(.title2)
                        .foregroundStyle(Color(selectedChannel.colorName))
                    Text(selectedChannel.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 280, height: 280)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    /// 時刻からラジアンへ変換（12時が上、時計回り）
    private func angleForHour(_ hour: Int) -> Double {
        let fraction = Double(hour) / 24.0
        return (fraction * 2 * .pi) - (.pi / 2)
    }
}

// MARK: - Channel Picker

private struct ChannelPicker: View {
    @Binding var selected: SensorChannel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SensorChannel.allCases) { channel in
                    Button {
                        selected = channel
                    } label: {
                        Label(channel.rawValue, systemImage: channel.systemImageName)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selected == channel
                                    ? Color(channel.colorName).opacity(0.2)
                                    : Color(.systemGray6)
                            )
                            .foregroundStyle(
                                selected == channel
                                    ? Color(channel.colorName)
                                    : .secondary
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Summary Cards

private struct SummaryCards: View {
    let profile: CircadianProfile

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 12) {
            SummaryCard(
                title: "総歩数",
                value: "\(profile.totalSteps)",
                unit: "歩",
                systemImage: "shoeprints.fill",
                color: .green
            )
            SummaryCard(
                title: "スクリーンタイム",
                value: "\(profile.totalScreenTime)",
                unit: "分",
                systemImage: "iphone",
                color: .blue
            )
            SummaryCard(
                title: "活動ピーク",
                value: "\(profile.peakActivityHour):00",
                unit: "",
                systemImage: "figure.walk",
                color: .orange
            )
            SummaryCard(
                title: "光ピーク",
                value: "\(profile.peakLightHour):00",
                unit: "",
                systemImage: "sun.max.fill",
                color: .yellow
            )
        }
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String
    let unit: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
