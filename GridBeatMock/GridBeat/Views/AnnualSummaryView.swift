import SwiftUI

struct AnnualSummaryView: View {
    @Bindable var viewModel: GridBeatViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroCard
                    metricsGrid
                    communityCard
                    shareCard
                }
                .padding()
            }
            .navigationTitle("\u{5E74}\u{9593}\u{30EC}\u{30DD}\u{30FC}\u{30C8}")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        VStack(spacing: 16) {
            if let summary = viewModel.annualSummary {
                Text("\(summary.year)\u{5E74} \u{3042}\u{306A}\u{305F}\u{306E} GridBeat")
                    .font(.title2)
                    .fontWeight(.bold)

                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.vertical, 8)

                Text(String(format: "\u{5E74}\u{9593} CO\u{2082} \u{524A}\u{6E1B}\u{91CF}: %.0f kg", summary.totalCO2ReductionKg))
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("\u{690D}\u{6A39}\u{63DB}\u{7B97}: \(summary.treesEquivalent) \u{672C}\u{5206}")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            } else {
                ProgressView()
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.15),
                            Color.blue.opacity(0.1),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .background(RoundedRectangle(cornerRadius: 20).fill(.regularMaterial))
    }

    // MARK: - Metrics Grid

    private var metricsGrid: some View {
        VStack(spacing: 12) {
            Text("\u{8A73}\u{7D30}\u{30E1}\u{30C8}\u{30EA}\u{30AF}\u{30B9}")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let summary = viewModel.annualSummary {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    MetricCard(
                        icon: "dollarsign.circle.fill",
                        iconColor: .orange,
                        label: "\u{5E74}\u{9593}\u{7BC0}\u{7D04}\u{984D}",
                        value: String(format: "$%.0f", summary.totalCostSavings)
                    )
                    MetricCard(
                        icon: "bolt.fill",
                        iconColor: .green,
                        label: "\u{30AF}\u{30EA}\u{30FC}\u{30F3}\u{5145}\u{96FB}\u{7387}",
                        value: String(format: "%.0f%%", summary.cleanChargeRate * 100)
                    )
                    MetricCard(
                        icon: "calendar",
                        iconColor: .blue,
                        label: "\u{30B0}\u{30EA}\u{30FC}\u{30F3}\u{65E5}\u{6570}",
                        value: "\(summary.greenDays) / \(summary.totalDays) \u{65E5}"
                    )
                    MetricCard(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: .purple,
                        label: "\u{30B0}\u{30EA}\u{30FC}\u{30F3}\u{65E5}\u{7387}",
                        value: String(format: "%.0f%%", summary.greenDayRate)
                    )
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Community Card

    private var communityCard: some View {
        VStack(spacing: 12) {
            Text("\u{30B3}\u{30DF}\u{30E5}\u{30CB}\u{30C6}\u{30A3}\u{30E9}\u{30F3}\u{30AD}\u{30F3}\u{30B0}")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let summary = viewModel.annualSummary {
                HStack(spacing: 16) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.yellow)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\u{3042}\u{306A}\u{305F}\u{306E}\u{74B0}\u{5883}\u{8CA2}\u{732E}\u{5EA6}")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(String(format: "\u{4E0A}\u{4F4D} %.0f%%", summary.communityRank * 100))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }

                    Spacer()
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * (1.0 - summary.communityRank))
                    }
                }
                .frame(height: 12)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Share Card

    private var shareCard: some View {
        Button {
            // Share action
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("\u{30B7}\u{30A7}\u{30A2}\u{3059}\u{308B}")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .foregroundStyle(.white)
        }
    }
}

// MARK: - Metric Card Component

private struct MetricCard: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
    }
}

#Preview {
    AnnualSummaryView(viewModel: GridBeatViewModel())
}
