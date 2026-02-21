import SwiftUI

// MARK: - PresetListView（プリセット一覧）

struct PresetListView: View {
    @Bindable var viewModel: PedalBoardViewModel
    @State private var showingSaveSheet = false
    @State private var newPresetName = ""
    @State private var newPresetCategory: PresetCategory = .custom
    @State private var selectedCategoryFilter: PresetCategory?

    var body: some View {
        NavigationStack {
            List {
                // カテゴリフィルター
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                label: "すべて",
                                isSelected: selectedCategoryFilter == nil
                            ) {
                                selectedCategoryFilter = nil
                            }

                            ForEach(PresetCategory.allCases) { category in
                                FilterChip(
                                    label: "\(category.emoji) \(category.displayName)",
                                    isSelected: selectedCategoryFilter == category
                                ) {
                                    selectedCategoryFilter = category
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }

                // お気に入り
                let favorites = filteredPresets.filter(\.isFavorite)
                if !favorites.isEmpty {
                    Section("お気に入り") {
                        ForEach(favorites) { preset in
                            PresetRow(preset: preset, viewModel: viewModel)
                        }
                    }
                }

                // すべてのプリセット
                Section("プリセット") {
                    ForEach(filteredPresets) { preset in
                        PresetRow(preset: preset, viewModel: viewModel)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deletePreset(filteredPresets[index])
                        }
                    }
                }
            }
            .navigationTitle("プリセット")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSaveSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .disabled(viewModel.pedals.isEmpty)
                }
            }
            .sheet(isPresented: $showingSaveSheet) {
                savePresetSheet
            }
        }
    }

    // MARK: - Filtered Presets

    private var filteredPresets: [PedalBoardPreset] {
        if let filter = selectedCategoryFilter {
            return viewModel.presets.filter { $0.category == filter }
        }
        return viewModel.presets
    }

    // MARK: - Save Preset Sheet

    private var savePresetSheet: some View {
        NavigationStack {
            Form {
                Section("プリセット名") {
                    TextField("名前を入力", text: $newPresetName)
                }

                Section("カテゴリ") {
                    Picker("カテゴリ", selection: $newPresetCategory) {
                        ForEach(PresetCategory.allCases) { category in
                            Text("\(category.emoji) \(category.displayName)")
                                .tag(category)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("含まれるペダル") {
                    ForEach(viewModel.sortedPedals) { pedal in
                        HStack {
                            Text(pedal.emoji)
                            Text(pedal.name)
                                .font(.subheadline)
                            Spacer()
                            Text(pedal.isEnabled ? "ON" : "OFF")
                                .font(.caption)
                                .foregroundStyle(pedal.isEnabled ? .green : .secondary)
                        }
                    }
                }
            }
            .navigationTitle("プリセットを保存")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { showingSaveSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        viewModel.saveCurrentAsPreset(
                            name: newPresetName,
                            category: newPresetCategory
                        )
                        newPresetName = ""
                        showingSaveSheet = false
                    }
                    .disabled(newPresetName.isEmpty)
                }
            }
        }
    }
}

// MARK: - PresetRow

struct PresetRow: View {
    let preset: PedalBoardPreset
    @Bindable var viewModel: PedalBoardViewModel

    var body: some View {
        Button {
            viewModel.loadPreset(preset)
        } label: {
            HStack(spacing: 12) {
                Text(preset.category.emoji)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(preset.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        if viewModel.selectedPreset?.id == preset.id {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }

                    // ペダル構成プレビュー
                    HStack(spacing: 4) {
                        ForEach(preset.pedalConfigs, id: \.id) { config in
                            if let type = config.effectType {
                                Text(type.emoji)
                                    .font(.caption2)
                                    .opacity(config.isEnabled ? 1 : 0.3)
                            }
                        }
                    }
                }

                Spacer()

                // お気に入りボタン
                Button {
                    viewModel.togglePresetFavorite(preset)
                } label: {
                    Image(systemName: preset.isFavorite ? "star.fill" : "star")
                        .font(.subheadline)
                        .foregroundStyle(preset.isFavorite ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? .orange : .gray.opacity(0.15))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
