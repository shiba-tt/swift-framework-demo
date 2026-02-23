import SwiftUI

struct StatsView: View {
    @Bindable var viewModel: SoundScapeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overviewCards
                    categoryBreakdownSection
                    healthTipsSection
                    techStackSection
                }
                .padding()
            }
            .navigationTitle("統計")
        }
    }

    // MARK: - Overview Cards

    private var overviewCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(
                title: "平均騒音",
                value: String(format: "%.0f dB", viewModel.todayAverageDecibel),
                icon: "speaker.wave.2",
                color: .cyan
            )
            statCard(
                title: "ピーク騒音",
                value: String(format: "%.0f dB", viewModel.todayPeakDecibel),
                icon: "speaker.wave.3",
                color: .orange
            )
            statCard(
                title: "リスニング",
                value: viewModel.totalListeningTimeText,
                icon: "clock",
                color: .blue
            )
            statCard(
                title: "検出数",
                value: "\(viewModel.soundLog.count)件",
                icon: "waveform.badge.magnifyingglass",
                color: .green
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Category Breakdown

    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリ別サマリー")
                .font(.headline)

            let breakdown = viewModel.categoryBreakdown
            let maxDuration = breakdown.first?.totalDuration ?? 1

            ForEach(breakdown, id: \.category) { item in
                HStack(spacing: 12) {
                    Text(item.category.emoji)
                        .frame(width: 28)

                    Text(item.category.rawValue)
                        .font(.subheadline)
                        .frame(width: 80, alignment: .leading)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.gray.opacity(0.1))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(item.category.color)
                                .frame(
                                    width: geometry.size.width
                                        * (item.totalDuration / maxDuration)
                                )
                        }
                    }
                    .frame(height: 10)

                    Text(durationText(item.totalDuration))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes >= 60 {
            return "\(minutes / 60)h\(minutes % 60)m"
        }
        return "\(minutes)m"
    }

    // MARK: - Health Tips

    private var healthTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("聴覚保護アドバイス")
                    .font(.headline)
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            }

            tipRow(
                icon: "ear.trianglebadge.exclamationmark",
                color: .orange,
                title: "騒音レベルに注意",
                description: "85dB以上の環境に長時間いると聴覚にダメージを与える可能性があります。"
            )

            tipRow(
                icon: "headphones",
                color: .blue,
                title: "イヤホンの音量",
                description: "音量を60%以下にし、連続使用は60分以内がおすすめです。"
            )

            tipRow(
                icon: "leaf",
                color: .green,
                title: "静かな環境の効果",
                description: "自然音（鳥の声、水の音）はストレス軽減に効果があることが知られています。"
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func tipRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Tech Stack

    private var techStackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("使用フレームワーク")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                techItem("AVAudioEngine", detail: "リアルタイム音声入力・バッファリング")
                techItem("SoundAnalysis", detail: "Core ML ベースの環境音分類 (300+ カテゴリ)")
                techItem("Accelerate (vDSP)", detail: "FFT によるスペクトログラム生成")
                techItem("Metal", detail: "スペクトログラムの GPU レンダリング")
                techItem("Core Location", detail: "位置情報を紐づけた音マップ生成")
                techItem("HealthKit", detail: "騒音レベルの健康データ記録")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func techItem(_ name: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.cyan)
                .frame(width: 12)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.bold())
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    StatsView(viewModel: SoundScapeViewModel())
}
