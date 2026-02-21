import SwiftUI

/// 時間帯別会議ヒートマップ画面
struct HeatmapView: View {
    let viewModel: MeetingLensViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ヒートマップ
                    heatmapCard

                    // ディープワークスコア
                    deepWorkCard

                    // 時間帯別詳細
                    hourlyDetailCard
                }
                .padding()
            }
            .navigationTitle("ヒートマップ")
        }
    }

    // MARK: - Subviews

    private var heatmapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.grid.3x3.fill")
                    .foregroundStyle(.red)
                Text("会議密度ヒートマップ")
                    .font(.headline)
                Spacer()
            }

            Text("今週の時間帯別会議密度")
                .font(.caption)
                .foregroundStyle(.secondary)

            // ヒートマップバー
            VStack(spacing: 4) {
                ForEach(viewModel.hourlyDensity) { density in
                    HStack(spacing: 8) {
                        Text(density.hourLabel)
                            .font(.caption.monospacedDigit())
                            .frame(width: 24, alignment: .trailing)
                            .foregroundStyle(.secondary)

                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(densityColor(density.density))
                                .frame(
                                    width: max(4, geometry.size.width * density.density)
                                )
                        }
                        .frame(height: 20)

                        if density.meetingCount > 0 {
                            Text("\(density.meetingCount)件")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 32)
                        } else {
                            Text("")
                                .frame(width: 32)
                        }
                    }
                }
            }

            // 凡例
            HStack(spacing: 16) {
                legendItem(color: .green.opacity(0.3), label: "少ない")
                legendItem(color: .yellow, label: "中程度")
                legendItem(color: .orange, label: "多い")
                legendItem(color: .red, label: "過密")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.fill.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var deepWorkCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .foregroundStyle(.indigo)
                Text("ディープワークスコア")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: viewModel.weekStats.deepWorkScore)
                        .stroke(
                            deepWorkColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text(viewModel.weekStats.deepWorkScoreText)
                            .font(.title.bold())
                        Text("/ 100")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 100, height: 100)

                VStack(alignment: .leading, spacing: 8) {
                    Text(deepWorkMessage)
                        .font(.subheadline.bold())

                    Text(deepWorkDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.indigo.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var hourlyDetailCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.blue)
                Text("時間帯別の会議時間")
                    .font(.headline)
                Spacer()
            }

            ForEach(viewModel.hourlyDensity.filter { $0.meetingMinutes > 0 }) { density in
                HStack {
                    Text("\(density.hour):00")
                        .font(.subheadline.monospacedDigit())
                        .frame(width: 50, alignment: .leading)

                    ProgressView(value: density.density)
                        .tint(densityColor(density.density))

                    Text("\(density.meetingMinutes)分")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 44, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(.fill.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func densityColor(_ density: Double) -> Color {
        switch density {
        case 0.75...: return .red
        case 0.5..<0.75: return .orange
        case 0.25..<0.5: return .yellow
        default: return .green.opacity(0.3)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
        }
    }

    private var deepWorkColor: Color {
        switch viewModel.weekStats.deepWorkScore {
        case 0.7...: return .green
        case 0.4..<0.7: return .yellow
        default: return .red
        }
    }

    private var deepWorkMessage: String {
        switch viewModel.weekStats.deepWorkScore {
        case 0.7...: return "集中時間は十分確保できています"
        case 0.4..<0.7: return "もう少し集中時間を確保しましょう"
        default: return "会議が多すぎます"
        }
    }

    private var deepWorkDescription: String {
        switch viewModel.weekStats.deepWorkScore {
        case 0.7...: return "90分以上の連続空き時間が十分にあり、ディープワークに適した環境です。"
        case 0.4..<0.7: return "一部の日で会議が集中しています。ノー会議デーの導入を検討しましょう。"
        default: return "ほとんどの時間が会議で埋まっています。緊急に会議の整理が必要です。"
        }
    }
}
