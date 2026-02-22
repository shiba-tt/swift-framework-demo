import SwiftUI

/// エフェクトチェーン編集画面
struct EffectChainView: View {
    let viewModel: VoiceStudioViewModel

    var body: some View {
        NavigationStack {
            List {
                // エフェクト一覧
                Section("エフェクトチェーン") {
                    ForEach(viewModel.sortedEffects) { effect in
                        EffectRow(
                            effect: effect,
                            viewModel: viewModel
                        )
                    }
                    .onMove { source, destination in
                        viewModel.moveEffect(from: source, to: destination)
                    }
                    .onDelete { indexSet in
                        let sorted = viewModel.sortedEffects
                        for index in indexSet {
                            viewModel.removeEffect(sorted[index])
                        }
                    }
                }

                // エフェクト追加
                Section {
                    Button {
                        viewModel.showingAddEffect = true
                    } label: {
                        Label("エフェクトを追加", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("エフェクト")
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: Binding(
                get: { viewModel.showingAddEffect },
                set: { viewModel.showingAddEffect = $0 }
            )) {
                AddEffectSheet(viewModel: viewModel)
            }
            .sheet(item: Binding(
                get: { viewModel.selectedEffect },
                set: { viewModel.selectedEffect = $0 }
            )) { effect in
                EffectDetailSheet(effect: effect, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Effect Row

private struct EffectRow: View {
    let effect: AudioEffect
    let viewModel: VoiceStudioViewModel

    var body: some View {
        Button {
            viewModel.selectedEffect = effect
        } label: {
            HStack(spacing: 12) {
                // エフェクトアイコン
                Image(systemName: effect.type.systemImageName)
                    .font(.title3)
                    .foregroundStyle(effect.isEnabled ? .purple : .secondary)
                    .frame(width: 32)

                // エフェクト情報
                VStack(alignment: .leading, spacing: 2) {
                    Text(effect.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(effect.isEnabled ? .primary : .secondary)
                    Text(effect.type.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // パラメータプレビュー
                VStack(alignment: .trailing, spacing: 2) {
                    if let firstParam = effect.parameters.first {
                        Text(firstParam.displayValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // ON/OFF トグル
                Toggle("", isOn: Binding(
                    get: { effect.isEnabled },
                    set: { _ in viewModel.toggleEffect(effect) }
                ))
                .labelsHidden()
                .tint(.purple)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add Effect Sheet

private struct AddEffectSheet: View {
    let viewModel: VoiceStudioViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(AudioEffectType.allCases) { type in
                    Button {
                        viewModel.addEffect(type: type)
                        viewModel.showingAddEffect = false
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: type.systemImageName)
                                .font(.title3)
                                .foregroundStyle(.purple)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(type.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("エフェクトを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        viewModel.showingAddEffect = false
                    }
                }
            }
        }
    }
}

// MARK: - Effect Detail Sheet

private struct EffectDetailSheet: View {
    let effect: AudioEffect
    let viewModel: VoiceStudioViewModel

    var body: some View {
        NavigationStack {
            List {
                // AUv3 プラグイン情報
                Section("AUv3 プラグイン") {
                    HStack {
                        Text("タイプ")
                        Spacer()
                        Text(effect.type.displayName)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("状態")
                        Spacer()
                        Text(effect.isEnabled ? "有効" : "バイパス")
                            .foregroundStyle(effect.isEnabled ? .green : .secondary)
                    }
                }

                // パラメータ
                Section("パラメータ") {
                    ForEach(Array(effect.parameters.enumerated()), id: \.element.id) { index, param in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(param.name)
                                    .font(.subheadline)
                                Spacer()
                                Text(param.displayValue)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.purple)
                            }

                            Slider(
                                value: Binding(
                                    get: { param.value },
                                    set: { viewModel.updateParameter(effectID: effect.id, parameterIndex: index, value: $0) }
                                ),
                                in: param.minValue...param.maxValue
                            )
                            .tint(.purple)
                        }
                    }
                }
            }
            .navigationTitle(effect.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.selectedEffect = nil
                    }
                }
            }
        }
    }
}
