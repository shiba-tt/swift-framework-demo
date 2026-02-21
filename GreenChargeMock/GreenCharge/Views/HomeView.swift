import SwiftUI

/// ホーム画面：グリッド状態 + スコア + アクション
struct HomeView: View {
    let viewModel: GreenChargeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 現在のグリッド状態
                    CurrentGridCard(viewModel: viewModel)

                    // グリッドタイムライン
                    GridTimelineCard(forecasts: viewModel.gridForecasts)

                    // 次のクリーンウィンドウ
                    if let window = viewModel.nextCleanWindow {
                        NextCleanWindowCard(window: window)
                    }

                    // スコアサマリー
                    ScoreSummaryCard(score: viewModel.greenScore)

                    // アクションボタン
                    ActionButtons(viewModel: viewModel)
                }
                .padding()
            }
            .navigationTitle("GreenCharge")
            .refreshable {
                await viewModel.loadGridForecast()
            }
            .sheet(isPresented: Binding(
                get: { viewModel.showScheduleSheet },
                set: { viewModel.showScheduleSheet = $0 }
            )) {
                SmartScheduleSheet(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Current Grid Card

private struct CurrentGridCard: View {
    let viewModel: GreenChargeViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("現在のグリッド")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                GuidanceBadge(level: viewModel.currentGuidance)
            }

            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.currentCleanText)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(colorForGuidance(viewModel.currentGuidance))
                Text("クリーン")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(colorForGuidance(viewModel.currentGuidance).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func colorForGuidance(_ level: GuidanceLevel) -> Color {
        switch level {
        case .good: .green
        case .neutral: .yellow
        case .bad: .red
        }
    }
}

// MARK: - Grid Timeline Card

private struct GridTimelineCard: View {
    let forecasts: [GridForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("今日のグリッド予測")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(forecasts) { forecast in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(barColor(for: forecast).gradient)
                                .frame(
                                    width: 16,
                                    height: CGFloat(forecast.cleanEnergyFraction) * 60
                                )

                            Text(forecast.shortTimeText)
                                .font(.system(size: 8))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .frame(height: 80)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func barColor(for forecast: GridForecast) -> Color {
        switch forecast.guidanceLevel {
        case .good: .green
        case .neutral: .yellow
        case .bad: .red
        }
    }
}

// MARK: - Next Clean Window Card

private struct NextCleanWindowCard: View {
    let window: CleanWindow

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 4) {
                Text("次のクリーン窓")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(window.timeRangeText)
                    .font(.headline)
                HStack(spacing: 8) {
                    Text("クリーン度: \(Int(window.averageCleanFraction * 100))%")
                    Text("(\(window.durationText))")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Score Summary Card

private struct ScoreSummaryCard: View {
    let score: GreenScore

    var body: some View {
        HStack(spacing: 16) {
            ScoreMiniStat(
                icon: "leaf.fill",
                value: "\(score.totalPoints)",
                label: "ポイント",
                color: .green
            )
            ScoreMiniStat(
                icon: "trophy.fill",
                value: "#\(score.rank)",
                label: "ランキング",
                color: .orange
            )
            ScoreMiniStat(
                icon: "globe.americas.fill",
                value: score.co2Text,
                label: "CO2削減",
                color: .blue
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct ScoreMiniStat: View {
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

// MARK: - Action Buttons

private struct ActionButtons: View {
    let viewModel: GreenChargeViewModel

    var body: some View {
        HStack(spacing: 12) {
            Button {
                Task { await viewModel.startCharging() }
            } label: {
                Label("今すぐ充電", systemImage: "bolt.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green.gradient)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                viewModel.showScheduleSheet = true
            } label: {
                Label("スマート予約", systemImage: "calendar.badge.clock")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.gradient)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}

// MARK: - Guidance Badge

private struct GuidanceBadge: View {
    let level: GuidanceLevel

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.systemImageName)
                .font(.caption2)
            Text(level.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.12))
        .foregroundStyle(badgeColor)
        .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch level {
        case .good: .green
        case .neutral: .yellow
        case .bad: .red
        }
    }
}

// MARK: - Smart Schedule Sheet

private struct SmartScheduleSheet: View {
    let viewModel: GreenChargeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 設定
                    VStack(alignment: .leading, spacing: 12) {
                        Text("充電設定")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("目標充電率: \(Int(viewModel.targetChargeLevel * 100))%")
                                .font(.subheadline)
                            Slider(
                                value: Binding(
                                    get: { viewModel.targetChargeLevel },
                                    set: { viewModel.targetChargeLevel = $0 }
                                ),
                                in: 0.5...1.0,
                                step: 0.1
                            )
                            .tint(.green)
                        }

                        DatePicker(
                            "出発時刻",
                            selection: Binding(
                                get: { viewModel.departureDate },
                                set: { viewModel.departureDate = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // プラン生成ボタン
                    Button {
                        viewModel.generatePlan()
                    } label: {
                        Text("AI 最適化プランを生成")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.indigo.opacity(0.15))
                            .foregroundStyle(.indigo)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // プラン表示
                    if let plan = viewModel.currentPlan {
                        PlanDetailView(plan: plan)

                        Button {
                            viewModel.confirmPlan()
                        } label: {
                            Text("この予約を確定する")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green.gradient)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("スマート充電予約")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.showScheduleSheet = false
                    }
                }
            }
        }
    }
}

private struct PlanDetailView: View {
    let plan: SmartChargePlan

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI 最適化プラン")
                .font(.headline)

            ForEach(plan.slots) { slot in
                HStack(spacing: 10) {
                    Image(systemName: slot.action.systemImageName)
                        .foregroundStyle(slot.action == .charge ? .green : .secondary)
                        .frame(width: 24)
                    Text(slot.timeRangeText)
                        .font(.subheadline)
                    Spacer()
                    Text(slot.action.rawValue)
                        .font(.caption)
                        .foregroundStyle(slot.action == .charge ? .green : .secondary)
                    if slot.action == .charge {
                        Text("(\(Int(slot.cleanFraction * 100))%)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()

            HStack(spacing: 16) {
                PlanStat(label: "獲得 pt", value: "+\(plan.estimatedPoints)")
                PlanStat(label: "コスト削減", value: String(format: "-$%.2f", plan.estimatedCostSaving))
                PlanStat(label: "CO2 削減", value: String(format: "-%.1f kg", plan.estimatedCO2Saving))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct PlanStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.green)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
