import SwiftUI

/// 共有履歴画面
struct HistoryView: View {
    let viewModel: BumpShareViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.shareHistory.isEmpty {
                    ContentUnavailableView(
                        "共有履歴なし",
                        systemImage: "clock",
                        description: Text("コンテンツを共有すると、ここに履歴が表示されます")
                    )
                } else {
                    List {
                        // 統計サマリー
                        Section {
                            HistoryStatsCard(history: viewModel.shareHistory)
                        }

                        // 履歴一覧
                        Section("最近の共有") {
                            ForEach(viewModel.shareHistory) { item in
                                HistoryRow(item: item)
                            }
                        }
                    }
                }
            }
            .navigationTitle("履歴")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.simulateReceive()
                    } label: {
                        Label("デモ受信", systemImage: "arrow.down.circle")
                    }
                }
            }
        }
    }
}

// MARK: - History Stats Card

private struct HistoryStatsCard: View {
    let history: [ShareHistory]

    private var sentCount: Int {
        history.filter { $0.direction == .sent }.count
    }

    private var receivedCount: Int {
        history.filter { $0.direction == .received }.count
    }

    private var successRate: Double {
        guard !history.isEmpty else { return 0 }
        return Double(history.filter(\.success).count) / Double(history.count)
    }

    var body: some View {
        HStack(spacing: 16) {
            StatBadge(icon: "arrow.up.circle.fill", value: "\(sentCount)", label: "送信", color: .blue)
            StatBadge(icon: "arrow.down.circle.fill", value: "\(receivedCount)", label: "受信", color: .green)
            StatBadge(icon: "checkmark.shield.fill", value: "\(Int(successRate * 100))%", label: "成功率", color: .orange)
        }
        .padding(.vertical, 4)
    }
}

private struct StatBadge: View {
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

// MARK: - History Row

private struct HistoryRow: View {
    let item: ShareHistory

    var body: some View {
        HStack(spacing: 12) {
            // 方向アイコン
            Image(systemName: item.direction.icon)
                .foregroundStyle(item.direction.color)
                .font(.title3)

            // コンテンツ情報
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.content.title)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if !item.success {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: item.content.type.icon)
                        .font(.system(size: 10))
                        .foregroundStyle(item.content.type.color)
                    Text(item.peerName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(formattedDate(item.date))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // ステータス
            Text(item.success ? "成功" : "失敗")
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(item.success ? .green.opacity(0.12) : .red.opacity(0.12))
                .foregroundStyle(item.success ? .green : .red)
                .clipShape(Capsule())
        }
        .padding(.vertical, 2)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
