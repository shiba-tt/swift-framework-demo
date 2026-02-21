import SwiftUI

/// 1日の統計情報を表示する画面
struct DayStatsView: View {
    @Bindable var viewModel: TimeMapViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("読み込み中...")
                        .padding(.top, 60)
                } else {
                    statsContent
                }
            }
            .navigationTitle("統計")
        }
    }

    private var statsContent: some View {
        VStack(spacing: 20) {
            // 概要カード
            summaryCard

            // 時間配分
            timeDistributionCard

            // 移動サマリー
            if !viewModel.routes.isEmpty {
                travelSummaryCard
            }

            // 空き時間一覧
            if !viewModel.timeSlots.isEmpty {
                freeSlotsCard
            }
        }
        .padding(16)
    }

    // MARK: - Cards

    /// 概要カード
    private var summaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今日の概要")
                    .font(.headline)
                Spacer()
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                statBox(
                    value: "\(viewModel.totalEventCount)",
                    label: "予定",
                    icon: "calendar",
                    color: .blue
                )
                statBox(
                    value: "\(viewModel.locatedEventCount)",
                    label: "場所付き",
                    icon: "mappin.circle",
                    color: .indigo
                )
                statBox(
                    value: viewModel.totalTravelTimeText,
                    label: "移動時間",
                    icon: "arrow.triangle.turn.up.right.diamond",
                    color: .orange
                )
                statBox(
                    value: viewModel.totalFreeTimeText,
                    label: "空き時間",
                    icon: "clock",
                    color: .green
                )
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 時間配分カード
    private var timeDistributionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("時間配分")
                .font(.headline)

            let totalBusyMinutes = viewModel.events
                .filter { !$0.isAllDay }
                .reduce(0) { $0 + $1.durationMinutes }
            let travelMinutes = viewModel.totalTravelMinutes
            let freeMinutes = viewModel.totalFreeMinutes
            let total = max(totalBusyMinutes + travelMinutes + freeMinutes, 1)

            VStack(spacing: 8) {
                distributionBar(
                    label: "予定",
                    minutes: totalBusyMinutes,
                    total: total,
                    color: .blue
                )
                distributionBar(
                    label: "移動",
                    minutes: travelMinutes,
                    total: total,
                    color: .orange
                )
                distributionBar(
                    label: "空き",
                    minutes: freeMinutes,
                    total: total,
                    color: .green
                )
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 移動サマリーカード
    private var travelSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("移動詳細")
                .font(.headline)

            ForEach(viewModel.routes) { route in
                HStack(spacing: 8) {
                    Image(systemName: route.transportType.systemImageName)
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(route.originEventTitle) → \(route.destinationEventTitle)")
                            .font(.caption)
                        Text(route.travelTimeText)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 空き時間一覧カード
    private var freeSlotsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("空き時間")
                .font(.headline)

            ForEach(viewModel.timeSlots) { slot in
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(slot.timeRangeText)
                            .font(.caption.monospacedDigit())
                        Text(slot.durationText)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("提案あり")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.green.opacity(0.1))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Components

    private func statBox(
        value: String,
        label: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func distributionBar(
        label: String,
        minutes: Int,
        total: Int,
        color: Color
    ) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .frame(width: 36, alignment: .trailing)

            GeometryReader { geo in
                let ratio = CGFloat(minutes) / CGFloat(total)
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: max(geo.size.width * ratio, 4))
            }
            .frame(height: 16)

            Text(minutesText(minutes))
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)
        }
    }

    private func minutesText(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 { return "\(h)h\(m)m" }
        return "\(m)m"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: viewModel.selectedDate)
    }
}
