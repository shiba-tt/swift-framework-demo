import SwiftUI

struct HistoryView: View {
    var viewModel: SoundTranslatorViewModel

    var body: some View {
        NavigationStack {
            List {
                // Stats section
                Section {
                    statsCard
                }

                // Category filter
                Section("カテゴリフィルター") {
                    categoryFilterChips
                }

                // Sound event list
                Section("検出履歴 (\(viewModel.filteredSounds.count)件)") {
                    if viewModel.filteredSounds.isEmpty {
                        ContentUnavailableView(
                            "履歴なし",
                            systemImage: "clock",
                            description: Text("リスニングを開始すると検出された音がここに表示されます")
                        )
                    } else {
                        ForEach(viewModel.filteredSounds) { event in
                            SoundEventRow(event: event)
                        }
                    }
                }
            }
            .navigationTitle("履歴")
            .toolbar {
                if !viewModel.detectedSounds.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("クリア") {
                            viewModel.clearHistory()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        HStack(spacing: 16) {
            statItem(
                icon: "waveform",
                value: "\(viewModel.detectedSounds.count)",
                label: "総検出数",
                color: .teal
            )
            statItem(
                icon: "exclamationmark.triangle.fill",
                value: "\(viewModel.cautionCount)",
                label: "注意",
                color: .yellow
            )
            statItem(
                icon: "xmark.octagon.fill",
                value: "\(viewModel.dangerCount)",
                label: "危険",
                color: .red
            )
        }
        .padding(.vertical, 4)
    }

    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Category Filter

    private var categoryFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    label: "すべて",
                    systemImage: "list.bullet",
                    isSelected: viewModel.selectedCategory == nil,
                    color: .teal
                ) {
                    viewModel.filterByCategory(nil)
                }

                ForEach(viewModel.categoryStats, id: \.0) { category, count in
                    FilterChip(
                        label: "\(category.rawValue) (\(count))",
                        systemImage: category.systemImage,
                        isSelected: viewModel.selectedCategory == category,
                        color: category.color
                    ) {
                        viewModel.filterByCategory(category)
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let label: String
    let systemImage: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: systemImage)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.2) : .gray.opacity(0.1), in: Capsule())
                .foregroundStyle(isSelected ? color : .secondary)
        }
    }
}

#Preview {
    HistoryView(viewModel: SoundTranslatorViewModel())
}
