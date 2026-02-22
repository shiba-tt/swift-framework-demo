import SwiftUI

/// 「On This Day」— 過去の同じ日のイベントを表示
struct OnThisDayView: View {
    @Bindable var viewModel: LifeRewindViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    onThisDayCards
                    futureInsightsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("On This Day")
        }
    }

    // MARK: - ヘッダー

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(todayFormatted)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("過去のこの日に\nあなたは何をしていましたか？")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }

    // MARK: - On This Day カード

    private var onThisDayCards: some View {
        VStack(spacing: 12) {
            if viewModel.onThisDayEntries.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.onThisDayEntries) { entry in
                    onThisDayCard(entry)
                }
            }
        }
    }

    private func onThisDayCard(_ entry: OnThisDayEntry) -> some View {
        HStack(spacing: 16) {
            VStack {
                Text("\(entry.yearsAgo)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(entry.event.category.color)
                Text("年前")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.event.category.emoji)
                    Text(entry.event.title)
                        .font(.headline)
                }
                Text(entry.event.calendarName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatDate(entry.event.startDate))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: entry.event.category.systemImage)
                .font(.title2)
                .foregroundStyle(entry.event.category.color.opacity(0.6))
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("この日の過去のイベントはありません")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(40)
    }

    // MARK: - 将来の見通し

    private var futureInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("インサイト", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(.orange)

            ForEach(viewModel.futureInsights) { insight in
                HStack(spacing: 12) {
                    Image(systemName: insight.icon)
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 32)

                    Text(insight.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - ヘルパー

    private var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日 (E)"
        return formatter.string(from: Date())
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }
}
