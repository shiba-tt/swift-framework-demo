import SwiftUI

/// ペットのメイン表示とアクション画面
struct PetView: View {
    @Bindable var viewModel: PixelPetViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    petDisplayCard
                    statusBarsSection
                    actionButtonsSection
                    conditionSummaryCard
                }
                .padding()
            }
            .navigationTitle(viewModel.pet.name)
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Pet Display

    private var petDisplayCard: some View {
        VStack(spacing: 16) {
            // ペットの表情
            ZStack {
                Circle()
                    .fill(moodGradient)
                    .frame(width: 160, height: 160)

                VStack(spacing: 4) {
                    Text(viewModel.pet.species.emoji)
                        .font(.system(size: 48))
                    Text(viewModel.pet.faceText)
                        .font(.system(size: 28, design: .monospaced))
                        .fontWeight(.bold)
                }
            }

            // ペット情報
            VStack(spacing: 4) {
                Text(viewModel.pet.name)
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 8) {
                    Label(viewModel.pet.species.rawValue, systemImage: viewModel.pet.species.systemImageName)
                    Text("·")
                    Text(viewModel.pet.ageText)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(viewModel.pet.mood.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(moodColor.opacity(0.2))
                    .foregroundStyle(moodColor)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Status Bars

    private var statusBarsSection: some View {
        VStack(spacing: 12) {
            statusBar(type: .hunger, value: viewModel.pet.hunger)
            statusBar(type: .happiness, value: viewModel.pet.happiness)
            statusBar(type: .cleanliness, value: viewModel.pet.cleanliness)
            statusBar(type: .energy, value: viewModel.pet.energy)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statusBar(type: PetStatusType, value: Int) -> some View {
        HStack(spacing: 12) {
            Text(type.emoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(type.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(value)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(colorForValue(value))
                            .frame(width: geometry.size.width * CGFloat(value) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("アクション")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                ForEach(PetActionType.allCases, id: \.rawValue) { actionType in
                    actionButton(for: actionType)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func actionButton(for actionType: PetActionType) -> some View {
        let isCooldown = viewModel.isCooldownActive(for: actionType)

        return Button {
            viewModel.performAction(actionType)
        } label: {
            VStack(spacing: 8) {
                Text(actionType.emoji)
                    .font(.title)
                Text(actionType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if let cooldownText = viewModel.cooldownText(for: actionType) {
                    Text(cooldownText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text(actionType.effectText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isCooldown ? Color(.systemGray5) : Color.pink.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isCooldown)
        .buttonStyle(.plain)
    }

    // MARK: - Condition Summary

    private var conditionSummaryCard: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.pet.mood.systemImageName)
                .font(.title2)
                .foregroundStyle(moodColor)

            VStack(alignment: .leading, spacing: 2) {
                Text("コンディション")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.conditionSummary)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Spacer()

            Text("\(viewModel.pet.overallCondition)")
                .font(.title)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(moodColor)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private var moodColor: Color {
        switch viewModel.pet.mood {
        case .happy: .green
        case .normal: .blue
        case .sad: .orange
        case .hungry: .yellow
        case .critical: .red
        }
    }

    private var moodGradient: LinearGradient {
        LinearGradient(
            colors: [moodColor.opacity(0.3), moodColor.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func colorForValue(_ value: Int) -> Color {
        if value >= 70 {
            return .green
        } else if value >= 40 {
            return .yellow
        } else {
            return .red
        }
    }
}

#Preview {
    PetView(viewModel: PixelPetViewModel())
}
