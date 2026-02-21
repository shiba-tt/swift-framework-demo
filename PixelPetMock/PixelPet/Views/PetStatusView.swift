import SwiftUI

/// ペットのステータス推移を表示する画面
struct PetStatusView: View {
    @Bindable var viewModel: PixelPetViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overallConditionCard
                    statusChartSection
                    achievementsSection
                }
                .padding()
            }
            .navigationTitle("ステータス")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Overall Condition

    private var overallConditionCard: some View {
        VStack(spacing: 16) {
            Text("総合コンディション")
                .font(.headline)

            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.pet.overallCondition) / 100)
                    .stroke(conditionColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(viewModel.pet.overallCondition)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("/ 100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(viewModel.conditionSummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Status Chart

    private var statusChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("24時間推移")
                .font(.headline)

            if viewModel.statusHistory.isEmpty {
                Text("まだデータがありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                ForEach(PetStatusType.allCases, id: \.rawValue) { statusType in
                    statusChart(for: statusType)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statusChart(for statusType: PetStatusType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(statusType.emoji)
                Text(statusType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(currentValueText(for: statusType))
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            // 簡易バーチャート
            HStack(spacing: 1) {
                ForEach(Array(viewModel.statusHistory.suffix(24).enumerated()), id: \.offset) { _, record in
                    let value = statusValue(record: record, type: statusType)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(colorForStatusType(statusType))
                        .frame(height: CGFloat(value) * 0.4)
                }
            }
            .frame(height: 40)
        }
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("実績")
                .font(.headline)

            ForEach(viewModel.achievements) { achievement in
                achievementRow(achievement)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func achievementRow(_ achievement: PetAchievement) -> some View {
        HStack(spacing: 12) {
            Text(achievement.emoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color(.systemGray5))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private var conditionColor: Color {
        let condition = viewModel.pet.overallCondition
        if condition >= 70 {
            return .green
        } else if condition >= 40 {
            return .yellow
        } else {
            return .red
        }
    }

    private func currentValueText(for statusType: PetStatusType) -> String {
        let value: Int
        switch statusType {
        case .hunger: value = viewModel.pet.hunger
        case .happiness: value = viewModel.pet.happiness
        case .cleanliness: value = viewModel.pet.cleanliness
        case .energy: value = viewModel.pet.energy
        }
        return "\(value)/100"
    }

    private func statusValue(record: PetStatusRecord, type: PetStatusType) -> Int {
        switch type {
        case .hunger: record.hunger
        case .happiness: record.happiness
        case .cleanliness: record.cleanliness
        case .energy: record.energy
        }
    }

    private func colorForStatusType(_ type: PetStatusType) -> Color {
        switch type {
        case .hunger: .red
        case .happiness: .yellow
        case .cleanliness: .cyan
        case .energy: .orange
        }
    }
}

#Preview {
    PetStatusView(viewModel: PixelPetViewModel())
}
