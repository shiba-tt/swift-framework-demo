import SwiftUI

struct SpotsView: View {
    @Bindable var viewModel: SoraNaviViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("スポットデータを読み込み中...")
                            .padding(.top, 40)
                    } else {
                        conditionFilterSection
                        spotsListSection
                    }
                }
                .padding()
            }
            .navigationTitle("撮影スポット")
        }
    }

    // MARK: - Condition Filter

    private var conditionFilterSection: some View {
        VStack(spacing: 12) {
            Text("撮影タイプで絞り込み")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(label: "すべて", emoji: "📷", isSelected: viewModel.selectedConditionType == nil) {
                        viewModel.selectedConditionType = nil
                    }
                    ForEach(PhotoConditionType.allCases, id: \.rawValue) { type in
                        filterChip(
                            label: type.rawValue, emoji: type.emoji,
                            isSelected: viewModel.selectedConditionType == type
                        ) {
                            viewModel.selectedConditionType = (viewModel.selectedConditionType == type) ? nil : type
                        }
                    }
                }
            }
        }
    }

    private func filterChip(label: String, emoji: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.caption)
                Text(label)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                isSelected ? Color.orange.opacity(0.2) : Color.clear,
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.orange : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Spots List

    private var spotsListSection: some View {
        VStack(spacing: 12) {
            let filteredSpots = filteredSpots()
            if filteredSpots.isEmpty {
                ContentUnavailableView {
                    Label("該当スポットなし", systemImage: "mappin.slash")
                } description: {
                    Text("選択した条件に合うスポットが見つかりませんでした。")
                }
            } else {
                ForEach(filteredSpots) { spot in
                    spotCard(spot)
                }
            }
        }
    }

    private func spotCard(_ spot: PhotoSpot) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(spot.category.emoji)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(spot.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(spot.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(spot.distanceText)
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Text(spot.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Text("おすすめ:")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                ForEach(spot.bestConditions, id: \.rawValue) { condition in
                    Text("\(condition.emoji) \(condition.rawValue)")
                        .font(.system(size: 10))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.orange.opacity(0.1), in: Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // スコア表示
            if let matchingCondition = viewModel.conditions.first(where: { spot.bestConditions.contains($0.type) }) {
                HStack {
                    Text("現在の条件:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(matchingCondition.scorePercent)%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(colorForScore(matchingCondition.score))
                    Text(matchingCondition.label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func filteredSpots() -> [PhotoSpot] {
        guard let selected = viewModel.selectedConditionType else {
            return viewModel.spots
        }
        return viewModel.spots.filter { $0.bestConditions.contains(selected) }
    }

    private func colorForScore(_ score: Double) -> Color {
        switch score {
        case 0.7...: return .green
        case 0.4...: return .orange
        default:     return .red
        }
    }
}

#Preview {
    SpotsView(viewModel: SoraNaviViewModel())
}
