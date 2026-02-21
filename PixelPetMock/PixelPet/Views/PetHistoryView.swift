import SwiftUI

/// ペットのお世話履歴を表示する画面
struct PetHistoryView: View {
    @Bindable var viewModel: PixelPetViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todaySummaryCard
                    actionHistorySection
                }
                .padding()
            }
            .navigationTitle("きろく")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Today Summary

    private var todaySummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今日のお世話")
                    .font(.headline)
                Spacer()
                Text(todayDateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 20) {
                summaryItem(
                    emoji: "🍖",
                    label: "ごはん",
                    count: todayCount(for: .feed)
                )
                summaryItem(
                    emoji: "🎾",
                    label: "あそぶ",
                    count: todayCount(for: .play)
                )
                summaryItem(
                    emoji: "🛁",
                    label: "おそうじ",
                    count: todayCount(for: .clean)
                )
                summaryItem(
                    emoji: "💤",
                    label: "おやすみ",
                    count: todayCount(for: .sleep)
                )
            }

            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                Text("合計 \(viewModel.todayActionCount) 回お世話しました")
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryItem(emoji: String, label: String, count: Int) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title2)
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Action History

    private var actionHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("お世話の記録")
                .font(.headline)

            if viewModel.actionHistory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("まだ記録がありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("ペットのお世話をすると、ここに記録が表示されます")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(viewModel.actionHistory.reversed()) { action in
                    actionRow(action)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func actionRow(_ action: PetAction) -> some View {
        HStack(spacing: 12) {
            Text(action.type.emoji)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(Color.pink.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(action.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(action.effectText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(timeText(for: action.timestamp))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private var todayDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: Date())
    }

    private func todayCount(for actionType: PetActionType) -> Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return viewModel.actionHistory
            .filter { $0.type == actionType && $0.timestamp >= startOfDay }
            .count
    }

    private func timeText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

#Preview {
    PetHistoryView(viewModel: PixelPetViewModel())
}
