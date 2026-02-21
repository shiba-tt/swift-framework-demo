import SwiftUI

/// 冒険ログの一覧画面
struct QuestLogView: View {
    @Bindable var viewModel: WidgetQuestViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryCard
                    logListSection
                }
                .padding()
            }
            .navigationTitle("冒険記録")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Summary

    private var summaryCard: some View {
        HStack(spacing: 16) {
            summaryItem(emoji: "📜", label: "総イベント", value: "\(viewModel.stats.eventsCompleted)")
            Divider().frame(height: 40)
            summaryItem(emoji: "⚔️", label: "バトル", value: "\(viewModel.stats.totalBattles)")
            Divider().frame(height: 40)
            summaryItem(emoji: "💰", label: "獲得金", value: "\(viewModel.stats.totalGoldEarned)G")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryItem(emoji: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title3)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Log List

    private var logListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("イベントログ")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.questLog.count)件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if viewModel.questLog.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "scroll")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("まだ記録がありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(viewModel.questLog) { entry in
                    logEntryRow(entry)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func logEntryRow(_ entry: QuestLogEntry) -> some View {
        HStack(spacing: 12) {
            // イベントアイコン
            ZStack {
                Circle()
                    .fill(Color.indigo.opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(entry.eventType.emoji)
                    .font(.body)
            }

            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let choice = entry.choiceLabel {
                        Text(choice)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.indigo.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    Text(entry.resultSummary)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // 日時
            Text(entry.dateTimeText)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)

        Divider()
    }
}

#Preview {
    QuestLogView(viewModel: WidgetQuestViewModel())
}
