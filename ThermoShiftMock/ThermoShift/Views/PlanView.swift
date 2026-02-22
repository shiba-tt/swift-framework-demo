import SwiftUI

/// 今日の運転プラン画面
struct PlanView: View {
    let viewModel: ThermoShiftViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // プランサマリー
                    if let plan = viewModel.currentPlan {
                        PlanSummaryCard(plan: plan)

                        // タイムライン
                        PlanTimeline(
                            slots: plan.slots,
                            activeSlot: viewModel.activeSlot
                        )
                    } else {
                        ContentUnavailableView(
                            "プランなし",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("グリッドデータを取得して運転プランを生成します")
                        )
                    }

                    // 再生成ボタン
                    Button {
                        viewModel.generateOptimizedPlan()
                    } label: {
                        Label("AI プランを再生成", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.orange.gradient)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding()
            }
            .navigationTitle("運転プラン")
            .refreshable {
                await viewModel.loadGridData()
            }
        }
    }
}

// MARK: - Plan Summary Card

private struct PlanSummaryCard: View {
    let plan: DailyOperationPlan

    var body: some View {
        VStack(spacing: 12) {
            Text("今日の AI 最適化プラン")
                .font(.headline)

            HStack(spacing: 16) {
                PlanStatItem(
                    label: "予測節約",
                    value: String(format: "$%.2f", plan.estimatedSavings),
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                PlanStatItem(
                    label: "快適度",
                    value: "\(plan.comfortScore)%",
                    icon: "face.smiling.inverse",
                    color: .orange
                )
                PlanStatItem(
                    label: "消費電力",
                    value: String(format: "%.1f kWh", plan.estimatedEnergyKWh),
                    icon: "bolt.fill",
                    color: .blue
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct PlanStatItem: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Plan Timeline

private struct PlanTimeline: View {
    let slots: [OperationSlot]
    let activeSlot: OperationSlot?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("運転スケジュール")
                .font(.headline)
                .padding(.bottom, 12)

            ForEach(Array(slots.enumerated()), id: \.element.id) { index, slot in
                HStack(spacing: 12) {
                    // タイムラインインジケーター
                    VStack(spacing: 0) {
                        Circle()
                            .fill(modeColor(slot.mode))
                            .frame(width: 12, height: 12)
                            .overlay {
                                if slot.id == activeSlot?.id {
                                    Circle()
                                        .stroke(modeColor(slot.mode), lineWidth: 2)
                                        .frame(width: 20, height: 20)
                                }
                            }

                        if index < slots.count - 1 {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: 2, height: 40)
                        }
                    }

                    // スロット情報
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: slot.mode.systemImageName)
                                    .font(.caption)
                                    .foregroundStyle(modeColor(slot.mode))
                                Text(slot.mode.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                if slot.id == activeSlot?.id {
                                    Text("実行中")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.orange.opacity(0.15))
                                        .foregroundStyle(.orange)
                                        .clipShape(Capsule())
                                }
                            }
                            Text(slot.timeRangeText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(Int(slot.targetTemperature))°C")
                                .font(.subheadline)
                                .fontWeight(.bold)

                            HStack(spacing: 4) {
                                Circle()
                                    .fill(priceColor(slot.priceLevel))
                                    .frame(width: 6, height: 6)
                                Text(slot.priceLevel.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(
                        slot.id == activeSlot?.id
                            ? modeColor(slot.mode).opacity(0.08)
                            : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func modeColor(_ mode: OperationMode) -> Color {
        switch mode {
        case .preHeat: .orange
        case .preCool: .cyan
        case .normal: .green
        case .passive: .yellow
        case .off: .red
        }
    }

    private func priceColor(_ level: PriceLevel) -> Color {
        switch level {
        case .offPeak: .green
        case .midPeak: .yellow
        case .onPeak: .red
        }
    }
}
