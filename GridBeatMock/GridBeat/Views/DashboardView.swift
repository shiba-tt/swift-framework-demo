import SwiftUI

struct DashboardView: View {
    @Bindable var viewModel: GridBeatViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todayCarbonCard
                    deviceBreakdownCard
                    gridStatusCard
                    actionSuggestionsCard
                }
                .padding()
            }
            .navigationTitle("GridBeat")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Today's Carbon Footprint

    private var todayCarbonCard: some View {
        VStack(spacing: 16) {
            Text("\u{4ECA}\u{65E5}\u{306E}\u{30AB}\u{30FC}\u{30DC}\u{30F3}\u{30D5}\u{30C3}\u{30C8}\u{30D7}\u{30EA}\u{30F3}\u{30C8}")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)
                        .font(.title2)

                    Text(String(format: "%.1f", viewModel.todayTotalKg))
                        .font(.system(size: 48, weight: .bold, design: .rounded))

                    Text("kg CO\u{2082}")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Text(viewModel.comparedToAverageText)
                    .font(.subheadline)
                    .foregroundStyle(viewModel.todayTotalKg <= viewModel.averageDailyKg ? .green : .red)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Device Breakdown

    private var deviceBreakdownCard: some View {
        VStack(spacing: 12) {
            Text("\u{30C7}\u{30D0}\u{30A4}\u{30B9}\u{5225}\u{5185}\u{8A33}")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.deviceBreakdown) { device in
                HStack(spacing: 12) {
                    Image(systemName: device.icon)
                        .font(.title3)
                        .foregroundStyle(device.color)
                        .frame(width: 32)

                    Text(device.deviceName)
                        .font(.subheadline)

                    Spacer()

                    Text(device.carbonText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    // Mini bar
                    let maxKg = viewModel.todayTotalKg > 0 ? viewModel.todayTotalKg : 1.0
                    RoundedRectangle(cornerRadius: 4)
                        .fill(device.color.opacity(0.8))
                        .frame(width: CGFloat(device.carbonKg / maxKg) * 60, height: 8)
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Grid Status

    private var gridStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\u{30B0}\u{30EA}\u{30C3}\u{30C9}\u{72B6}\u{614B}")
                    .font(.headline)
                Spacer()
                if let overview = viewModel.gridOverview {
                    Text(overview.statusLabel)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(overview.statusColor.opacity(0.2)))
                        .foregroundStyle(overview.statusColor)
                }
            }

            if let overview = viewModel.gridOverview {
                HStack(spacing: 20) {
                    MiniStat(
                        icon: "bolt.fill",
                        label: "\u{30AF}\u{30EA}\u{30FC}\u{30F3}\u{5EA6}",
                        value: "\(overview.currentCleanPercentage)%",
                        color: overview.statusColor
                    )
                    MiniStat(
                        icon: "dollarsign.circle",
                        label: "\u{73FE}\u{5728}\u{6599}\u{91D1}",
                        value: String(format: "$%.2f", overview.currentPricePerKWh),
                        color: .orange
                    )
                    MiniStat(
                        icon: "smoke.fill",
                        label: "CO\u{2082}\u{5F37}\u{5EA6}",
                        value: String(format: "%.0f", overview.currentCarbonIntensity),
                        color: .purple
                    )
                }

                // Hourly bar chart
                HStack(spacing: 2) {
                    ForEach(overview.hourlyData) { slot in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(slot.cleanColor.opacity(0.8))
                                .frame(height: CGFloat(slot.cleanFraction) * 40)

                            if slot.hour % 6 == 0 {
                                Text("\(slot.hour)")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 50)
                .padding(.top, 4)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }

    // MARK: - Action Suggestions

    private var actionSuggestionsCard: some View {
        VStack(spacing: 12) {
            Text("\u{30A2}\u{30AF}\u{30B7}\u{30E7}\u{30F3}\u{63D0}\u{6848}")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.actionSuggestions) { suggestion in
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(suggestion.message)
                            .font(.subheadline)
                        Text("\u{30AF}\u{30EA}\u{30FC}\u{30F3}\u{5EA6}: \(Int(suggestion.cleanFraction * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button(suggestion.actionLabel) {}
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .controlSize(.small)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
    }
}

// MARK: - Mini Stat Component

private struct MiniStat: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
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

#Preview {
    DashboardView(viewModel: GridBeatViewModel())
}
