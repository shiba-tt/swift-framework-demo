import SwiftUI

// MARK: - プリセット選択ビュー

/// プリセットカタログからタイマーを選択して開始するビュー
struct PresetSelectionView: View {
    let viewModel: TimerViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                // クイックスタートセクション（よく使うプリセット）
                Section {
                    quickStartGrid
                } header: {
                    Text("クイックスタート")
                }

                // カテゴリ別プリセット
                ForEach(filteredGroups) { group in
                    Section {
                        ForEach(group.presets) { preset in
                            PresetRowView(preset: preset) {
                                Task {
                                    await viewModel.startFromPreset(preset)
                                    dismiss()
                                }
                            }
                        }
                    } header: {
                        Label {
                            Text(group.title)
                        } icon: {
                            Text(group.emoji)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "プリセットを検索")
            .navigationTitle("プリセット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - クイックスタートグリッド

    /// よく使うタイマーのクイック起動グリッド
    private var quickStartGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ],
            spacing: 12
        ) {
            QuickStartButton(
                emoji: "🍝",
                name: "パスタ 8分",
                duration: "8:00"
            ) {
                Task {
                    await viewModel.startFromPreset(PresetCatalog.pasta[0])
                    dismiss()
                }
            }

            QuickStartButton(
                emoji: "🥚",
                name: "半熟卵 7分",
                duration: "7:00"
            ) {
                Task {
                    await viewModel.startFromPreset(PresetCatalog.boiling[0])
                    dismiss()
                }
            }

            QuickStartButton(
                emoji: "🍳",
                name: "3分タイマー",
                duration: "3:00"
            ) {
                let timer = CookingTimer(
                    name: "3分タイマー",
                    category: .custom,
                    duration: 3 * 60
                )
                Task {
                    await viewModel.startTimer(timer)
                    dismiss()
                }
            }

            QuickStartButton(
                emoji: "🥘",
                name: "煮込み 15分",
                duration: "15:00"
            ) {
                Task {
                    await viewModel.startFromPreset(PresetCatalog.simmering[2])
                    dismiss()
                }
            }
        }
    }

    // MARK: - フィルタリング

    private var filteredGroups: [PresetGroup] {
        if searchText.isEmpty {
            return PresetCatalog.allGroups
        }
        return PresetCatalog.allGroups.compactMap { group in
            let filtered = group.presets.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
            if filtered.isEmpty { return nil }
            return PresetGroup(
                title: group.title,
                emoji: group.emoji,
                presets: filtered
            )
        }
    }
}

// MARK: - プリセット行ビュー

struct PresetRowView: View {
    let preset: TimerPreset
    let onStart: () -> Void

    var body: some View {
        Button(action: onStart) {
            HStack(spacing: 12) {
                Text(preset.category.emoji)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(preset.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(formatDuration(preset.duration))
                    .font(.system(.callout, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.orange)
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let minutes = total / 60
        let seconds = total % 60
        if seconds == 0 {
            return "\(minutes)分"
        }
        return "\(minutes)分\(seconds)秒"
    }
}

// MARK: - クイックスタートボタン

struct QuickStartButton: View {
    let emoji: String
    let name: String
    let duration: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.title)

                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(duration)
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.orange.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PresetSelectionView(viewModel: TimerViewModel())
}
