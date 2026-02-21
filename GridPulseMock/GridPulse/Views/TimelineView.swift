import SwiftUI

/// 24時間グリッドタイムライン画面
struct TimelineView: View {
    let viewModel: GridPulseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 現在の状態
                    currentStateCard

                    // 24時間バー
                    hourlyBarChart

                    // エネルギー構成
                    energyCompositionCard

                    // 詳細リスト
                    hourlyDetailList
                }
                .padding()
            }
            .navigationTitle("タイムライン")
        }
    }

    // MARK: - Subviews

    private var currentStateCard: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(viewModel.currentCleanText)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.currentState?.color ?? .green)
                Text(viewModel.currentLevel.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 4) {
                    Text(viewModel.currentLevel.emoji)
                    Text(viewModel.currentThemeName)
                        .font(.subheadline.bold())
                }

                if let state = viewModel.currentState {
                    HStack(spacing: 12) {
                        Label(
                            "\(Int(state.solarFraction * 100))%",
                            systemImage: "sun.max.fill"
                        )
                        .foregroundStyle(.yellow)

                        Label(
                            "\(Int(state.windFraction * 100))%",
                            systemImage: "wind"
                        )
                        .foregroundStyle(.cyan)
                    }
                    .font(.caption)
                }
            }
        }
        .padding()
        .background(viewModel.currentState?.color.opacity(0.1) ?? .green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var hourlyBarChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("24時間クリーン度")
                .font(.headline)

            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(viewModel.gridStates) { state in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(state.color)
                                .frame(
                                    height: max(4, geometry.size.height * 0.8 * state.cleanEnergyFraction)
                                )
                                .overlay {
                                    if state.id == viewModel.currentState?.id {
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(.primary, lineWidth: 2)
                                    }
                                }

                            if Int(state.hourLabel) ?? 0 % 3 == 0 {
                                Text(state.hourLabel)
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("")
                                    .font(.system(size: 8))
                            }
                        }
                    }
                }
            }
            .frame(height: 140)

            // 凡例
            HStack(spacing: 16) {
                legendItem(color: .green, label: "非常にクリーン 70%+")
                legendItem(color: .mint, label: "クリーン 50%+")
                legendItem(color: .yellow, label: "中程度 30%+")
                legendItem(color: .red, label: "化石燃料")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.fill.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var energyCompositionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("エネルギー構成")
                .font(.headline)

            if let state = viewModel.currentState {
                HStack(spacing: 0) {
                    // 太陽光
                    Rectangle()
                        .fill(.yellow.opacity(0.8))
                        .frame(width: nil)
                        .overlay {
                            if state.solarFraction > 0.1 {
                                VStack(spacing: 2) {
                                    Image(systemName: "sun.max.fill")
                                        .font(.caption)
                                    Text("\(Int(state.solarFraction * 100))%")
                                        .font(.caption2.bold())
                                }
                                .foregroundStyle(.black.opacity(0.7))
                            }
                        }
                        .layoutPriority(state.solarFraction)

                    // 風力
                    Rectangle()
                        .fill(.cyan.opacity(0.8))
                        .overlay {
                            if state.windFraction > 0.1 {
                                VStack(spacing: 2) {
                                    Image(systemName: "wind")
                                        .font(.caption)
                                    Text("\(Int(state.windFraction * 100))%")
                                        .font(.caption2.bold())
                                }
                                .foregroundStyle(.black.opacity(0.7))
                            }
                        }
                        .layoutPriority(state.windFraction)

                    // 化石燃料
                    let fossilFraction = max(0, 1.0 - state.cleanEnergyFraction)
                    Rectangle()
                        .fill(.gray.opacity(0.5))
                        .overlay {
                            if fossilFraction > 0.1 {
                                VStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .font(.caption)
                                    Text("\(Int(fossilFraction * 100))%")
                                        .font(.caption2.bold())
                                }
                                .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                        .layoutPriority(fossilFraction)
                }
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.fill.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var hourlyDetailList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("時間帯別詳細")
                .font(.headline)
                .padding(.horizontal)

            ForEach(viewModel.gridStates) { state in
                HStack(spacing: 12) {
                    Text("\(state.hourLabel):00")
                        .font(.subheadline.monospacedDigit())
                        .frame(width: 44, alignment: .leading)

                    ProgressView(value: state.cleanEnergyFraction)
                        .tint(state.color)

                    Text(state.cleanPercentText)
                        .font(.caption.monospacedDigit().bold())
                        .foregroundStyle(state.color)
                        .frame(width: 40, alignment: .trailing)

                    Text(state.level.emoji)
                        .font(.caption)
                }
                .padding(.horizontal)
                .padding(.vertical, 2)
                .background(
                    state.id == viewModel.currentState?.id
                        ? state.color.opacity(0.1) : .clear
                )
            }
        }
        .padding(.vertical)
        .background(.fill.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }
}
