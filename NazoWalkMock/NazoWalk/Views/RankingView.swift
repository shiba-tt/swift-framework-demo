import SwiftUI
import StoreKit

/// ランキング・実績画面
struct RankingView: View {
    @Bindable var viewModel: AdventureViewModel

    /// サンプルランキングデータ
    private let sampleRanking: [(name: String, points: Int, time: String)] = [
        ("探偵マスター", 750, "45:30"),
        ("謎解き王", 700, "52:10"),
        ("あなた", 0, "--:--"),
        ("冒険好き", 550, "1:05:20"),
        ("パズル愛好家", 400, "1:15:45"),
    ]

    var body: some View {
        NavigationStack {
            List {
                // 自分のステータス
                Section("あなたの成績") {
                    VStack(spacing: 12) {
                        HStack(spacing: 24) {
                            statItem(
                                value: "\(viewModel.currentProgress?.totalPoints ?? 0)",
                                label: "ポイント",
                                icon: "star.fill",
                                color: .orange
                            )

                            statItem(
                                value: "\(viewModel.currentProgress?.clearedCount ?? 0)/\(viewModel.spots.count)",
                                label: "クリア",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )

                            statItem(
                                value: viewModel.isAllCleared ? "完" : "途中",
                                label: "ステータス",
                                icon: viewModel.isAllCleared ? "trophy.fill" : "hourglass",
                                color: viewModel.isAllCleared ? .yellow : .secondary
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }

                // ランキング
                Section("ランキング") {
                    ForEach(Array(sampleRanking.enumerated()), id: \.offset) { index, entry in
                        HStack {
                            Text("#\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .frame(width: 30)
                                .foregroundStyle(index < 3 ? .orange : .secondary)

                            Text(entry.name == "あなた" ? "あなた" : entry.name)
                                .fontWeight(entry.name == "あなた" ? .bold : .regular)

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text(entry.name == "あなた" ? "\(viewModel.currentProgress?.totalPoints ?? 0) pt" : "\(entry.points) pt")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(entry.time)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                // フルアプリへの誘導（App Clip からの流れ）
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("フルアプリで更に楽しもう", systemImage: "arrow.down.app.fill")
                            .font(.headline)

                        Text("過去のイベントアーカイブ、全国ランキング、オリジナル謎作成機能が使えます。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("ランキング")
        }
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
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
