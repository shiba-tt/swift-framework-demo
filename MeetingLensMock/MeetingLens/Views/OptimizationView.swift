import SwiftUI

/// 最適化提案画面
struct OptimizationView: View {
    @Bindable var viewModel: MeetingLensViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 時給設定
                    hourlyRateCard

                    // 最適化提案
                    if viewModel.suggestions.isEmpty {
                        emptyState
                    } else {
                        totalSavingsCard

                        ForEach(viewModel.suggestions) { suggestion in
                            suggestionCard(suggestion)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("最適化")
        }
    }

    // MARK: - Subviews

    private var hourlyRateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "yensign.circle")
                    .foregroundStyle(.orange)
                Text("推定時給の設定")
                    .font(.headline)
                Spacer()
            }

            Text("会議コストの計算に使用する1人あたりの推定時給を設定してください。")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Text("¥\(Int(viewModel.hourlyRate))")
                    .font(.title3.bold().monospacedDigit())
                    .frame(width: 80)

                Slider(
                    value: $viewModel.hourlyRate,
                    in: 1000...20000,
                    step: 500
                ) {
                    Text("時給")
                } onEditingChanged: { editing in
                    if !editing {
                        viewModel.updateHourlyRate(viewModel.hourlyRate)
                    }
                }
                .tint(.orange)
            }
        }
        .padding()
        .background(.fill.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var totalSavingsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
                Text("最適化のポテンシャル")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    let totalMinutes = viewModel.suggestions.reduce(0) { $0 + $1.savingMinutes }
                    let hours = totalMinutes / 60
                    Text("\(hours)時間+")
                        .font(.title.bold())
                        .foregroundStyle(.green)
                    Text("時間節約/月")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider().frame(height: 40)

                VStack(spacing: 4) {
                    let totalCost = viewModel.suggestions.reduce(0.0) { $0 + $1.savingCost }
                    let formatter = NumberFormatter()
                    let _ = (formatter.numberStyle = .currency)
                    let _ = (formatter.currencyCode = "JPY")
                    let _ = (formatter.maximumFractionDigits = 0)
                    Text(formatter.string(from: NSNumber(value: totalCost)) ?? "¥0")
                        .font(.title.bold())
                        .foregroundStyle(.green)
                    Text("コスト削減/月")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func suggestionCard(_ suggestion: OptimizationSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: suggestion.icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.title)
                        .font(.subheadline.bold())
                    Text(suggestion.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            HStack(spacing: 16) {
                if suggestion.savingMinutes > 0 {
                    Label(suggestion.savingTimeText, systemImage: "clock.arrow.circlepath")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }

                if suggestion.savingCost > 0 {
                    Label(suggestion.savingCostText, systemImage: "yensign.circle")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }

                Spacer()
            }
        }
        .padding()
        .background(.fill.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("最適化の提案はありません")
                .font(.headline)

            Text("現在の会議スケジュールは効率的です。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
