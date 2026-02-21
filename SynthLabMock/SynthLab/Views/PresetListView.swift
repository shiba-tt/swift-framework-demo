import SwiftUI

/// プリセット一覧画面
struct PresetListView: View {
    let viewModel: SynthLabViewModel
    @State private var selectedCategory: PresetCategory?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // カテゴリフィルター
                    CategoryFilterBar(selectedCategory: $selectedCategory)

                    // プリセット一覧
                    let filtered = filteredPresets
                    if filtered.isEmpty {
                        ContentUnavailableView(
                            "プリセットなし",
                            systemImage: "square.grid.2x2",
                            description: Text("このカテゴリにはプリセットがありません")
                        )
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ], spacing: 12) {
                            ForEach(filtered) { preset in
                                PresetCard(
                                    preset: preset,
                                    isSelected: viewModel.selectedPreset?.id == preset.id
                                ) {
                                    viewModel.applyPreset(preset)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("プリセット")
        }
    }

    private var filteredPresets: [SynthPreset] {
        if let category = selectedCategory {
            return viewModel.presets.filter { $0.category == category }
        }
        return viewModel.presets
    }
}

// MARK: - Category Filter Bar

private struct CategoryFilterBar: View {
    @Binding var selectedCategory: PresetCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(title: "すべて", icon: "square.grid.2x2", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(PresetCategory.allCases) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
}

private struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? .indigo.opacity(0.2) : .secondary.opacity(0.08))
            .foregroundStyle(isSelected ? .indigo : .secondary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Preset Card

private struct PresetCard: View {
    let preset: SynthPreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: preset.category.icon)
                        .foregroundStyle(.indigo)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }

                Text(preset.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Text(preset.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                // パラメータサマリー
                HStack(spacing: 8) {
                    MiniParam(label: "WAV", value: String(preset.oscillatorWaveform.rawValue.prefix(3)))
                    MiniParam(label: "CUT", value: formatFreq(preset.filterCutoff))
                    MiniParam(label: "ATK", value: String(format: "%.2f", preset.attackTime))
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .indigo : .clear, lineWidth: 2)
            )
        }
    }

    private func formatFreq(_ freq: Double) -> String {
        if freq >= 1000 {
            return String(format: "%.1fk", freq / 1000)
        }
        return String(format: "%.0f", freq)
    }
}

private struct MiniParam: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}
