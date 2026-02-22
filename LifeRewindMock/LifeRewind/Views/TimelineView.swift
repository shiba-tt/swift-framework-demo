import SwiftUI

/// 人生のタイムラインビュー — 主要イベントを時系列で表示
struct TimelineView: View {
    @Bindable var viewModel: LifeRewindViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    timelineHeader
                    timelineContent
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("タイムライン")
        }
    }

    // MARK: - ヘッダー

    private var timelineHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "book.pages.fill")
                .font(.system(size: 40))
                .foregroundStyle(.indigo)
            Text("人生のハイライト")
                .font(.title2)
                .fontWeight(.bold)
            Text("カレンダーから抽出した主要イベント")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 24)
    }

    // MARK: - タイムラインコンテンツ

    private var timelineContent: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.timelineEntries.enumerated()), id: \.element.id) { index, entry in
                timelineItem(entry, isLast: index == viewModel.timelineEntries.count - 1)
            }
        }
    }

    private func timelineItem(_ entry: TimelineEntry, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // 日付列
            VStack {
                Text(shortDate(entry.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 60)
            }

            // タイムラインライン + ドット
            VStack(spacing: 0) {
                Circle()
                    .fill(entry.category.color)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .fill(.white)
                            .frame(width: 6, height: 6)
                    )

                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 2, height: 60)
                }
            }

            // イベントカード
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(entry.category.emoji)
                    Text(entry.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                HStack(spacing: 8) {
                    Label(entry.category.rawValue, systemImage: entry.category.systemImage)
                        .font(.caption)
                        .foregroundStyle(entry.category.color)

                    Text(relativeDate(entry.date))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                entry.category.color.opacity(0.08),
                in: RoundedRectangle(cornerRadius: 12)
            )

            Spacer()
        }
    }

    // MARK: - ヘルパー

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
