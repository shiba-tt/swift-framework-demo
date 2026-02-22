import SwiftUI

struct PresetListView: View {
    @Bindable var viewModel: SoundForgeViewModel
    @State private var showingSaveSheet = false
    @State private var newPresetName = ""
    @State private var newPresetCategory: PresetCategory = .music

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.presets.isEmpty {
                    emptyState
                } else {
                    presetList
                }
            }
            .navigationTitle("プリセット")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSaveSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .disabled(viewModel.nodes.isEmpty)
                }
            }
            .sheet(isPresented: $showingSaveSheet) {
                savePresetSheet
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("プリセットがありません")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("ノードグラフを構築してから\nプリセットとして保存できます")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    // MARK: - Preset List

    private var presetList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(PresetCategory.allCases, id: \.rawValue) { category in
                    let categoryPresets = viewModel.presets.filter { $0.category == category }
                    if !categoryPresets.isEmpty {
                        Section {
                            ForEach(categoryPresets) { preset in
                                presetCard(preset)
                            }
                        } header: {
                            HStack {
                                Text(category.emoji)
                                Text(category.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func presetCard(_ preset: NodeGraphPreset) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(preset.name)
                            .font(.headline)
                        if preset.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                        }
                    }
                    Text(preset.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Menu {
                    Button {
                        viewModel.loadPreset(preset)
                    } label: {
                        Label("読み込む", systemImage: "arrow.down.doc")
                    }
                    Button {
                        viewModel.togglePresetFavorite(preset)
                    } label: {
                        Label(
                            preset.isFavorite ? "お気に入り解除" : "お気に入り",
                            systemImage: preset.isFavorite ? "star.slash" : "star"
                        )
                    }
                    Divider()
                    Button(role: .destructive) {
                        viewModel.deletePreset(preset)
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.secondary)
                }
            }

            // ノードプレビュー
            HStack(spacing: 6) {
                ForEach(Array(preset.nodeConfigs.enumerated()), id: \.offset) { index, config in
                    HStack(spacing: 2) {
                        Text(config.nodeType.emoji)
                            .font(.caption)
                        if index < preset.nodeConfigs.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Spacer()
                Text("\(preset.nodeConfigs.count) ノード")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .onTapGesture {
            viewModel.loadPreset(preset)
        }
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
                        ForEach(PresetCategory.allCases, id: \.rawValue) { category in
                            HStack {
                                Text(category.emoji)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("プリセットを保存")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        showingSaveSheet = false
                        newPresetName = ""
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        viewModel.saveCurrentAsPreset(name: newPresetName, category: newPresetCategory)
                        showingSaveSheet = false
                        newPresetName = ""
                    }
                    .disabled(newPresetName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    PresetListView(viewModel: SoundForgeViewModel())
}
