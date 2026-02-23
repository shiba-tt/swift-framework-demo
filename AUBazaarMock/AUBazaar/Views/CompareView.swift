import SwiftUI

struct CompareView: View {
    @Bindable var viewModel: AUBazaarViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    audioSourceSection
                    slotsSection
                    abToggleSection
                    meterSection
                    parametersSection
                    playbackSection
                    techInfoSection
                }
                .padding()
            }
            .navigationTitle("A/B 比較")
            .sheet(isPresented: $viewModel.showPluginPicker) {
                pluginPickerSheet
            }
        }
    }

    // MARK: - Audio Source

    private var audioSourceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("音源", systemImage: "music.note")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AudioSource.allCases) { source in
                        Button {
                            viewModel.selectAudioSource(source)
                        } label: {
                            VStack(spacing: 4) {
                                Text(source.emoji)
                                    .font(.title3)
                                Text(source.rawValue)
                                    .font(.caption2)
                            }
                            .frame(width: 60, height: 52)
                            .background(
                                viewModel.selectedAudioSource == source
                                    ? Color.indigo.opacity(0.15)
                                    : Color(.systemGray6),
                                in: RoundedRectangle(cornerRadius: 10)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        viewModel.selectedAudioSource == source ? Color.indigo : .clear,
                                        lineWidth: 1.5
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Slots

    private var slotsSection: some View {
        HStack(spacing: 12) {
            slotCard(.slotA, plugin: viewModel.slotAPlugin)
            slotCard(.slotB, plugin: viewModel.slotBPlugin)
        }
    }

    private func slotCard(_ slot: ABCompareSlot, plugin: AUPlugin?) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(slot.rawValue)
                    .font(.headline.bold())
                    .foregroundStyle(slot.color)
                Spacer()
                if plugin != nil {
                    Button {
                        viewModel.clearSlot(slot)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let plugin {
                VStack(spacing: 4) {
                    Text(plugin.category.emoji)
                        .font(.title2)
                    Text(plugin.name)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                    Text(plugin.manufacturer)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button {
                    viewModel.openPluginPicker(for: slot)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                            .foregroundStyle(slot.color)
                        Text("プラグインを選択")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            viewModel.activeSlot == slot
                ? slot.color.opacity(0.08)
                : Color(.systemGray6),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(viewModel.activeSlot == slot ? slot.color : .clear, lineWidth: 2)
        )
        .onTapGesture {
            viewModel.switchToSlot(slot)
        }
    }

    // MARK: - A/B Toggle

    private var abToggleSection: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.switchToSlot(.slotA)
            } label: {
                Text("A を聴く")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        viewModel.activeSlot == .slotA ? Color.blue : Color(.systemGray5),
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                    .foregroundStyle(viewModel.activeSlot == .slotA ? .white : .primary)
            }

            Button {
                viewModel.toggleAB()
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title3)
                    .frame(width: 44, height: 36)
                    .background(Color.indigo.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.indigo)
            }

            Button {
                viewModel.switchToSlot(.slotB)
            } label: {
                Text("B を聴く")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        viewModel.activeSlot == .slotB ? Color.orange : Color(.systemGray5),
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                    .foregroundStyle(viewModel.activeSlot == .slotB ? .white : .primary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Meter

    private var meterSection: some View {
        VStack(spacing: 8) {
            meterBar("Input", level: viewModel.inputLevel, color: .green)
            meterBar("Output", level: viewModel.outputLevel, color: viewModel.activeSlot.color)
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    private func meterBar(_ label: String, level: Float, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption.bold())
                .frame(width: 50, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray4))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(level > 0.85 ? Color.red : color)
                        .frame(width: geo.size.width * CGFloat(level))
                        .animation(.easeOut(duration: 0.1), value: level)
                }
            }
            .frame(height: 12)

            Text(String(format: "%.0f%%", level * 100))
                .font(.caption2.monospacedDigit())
                .frame(width: 36, alignment: .trailing)
        }
    }

    // MARK: - Parameters

    private var parametersSection: some View {
        Group {
            if viewModel.activeSlot == .slotA, !viewModel.slotAParameters.isEmpty {
                parameterList(viewModel.slotAParameters, slot: .slotA, plugin: viewModel.slotAPlugin)
            } else if viewModel.activeSlot == .slotB, !viewModel.slotBParameters.isEmpty {
                parameterList(viewModel.slotBParameters, slot: .slotB, plugin: viewModel.slotBPlugin)
            }
        }
    }

    private func parameterList(_ parameters: [AUPluginParameter], slot: ABCompareSlot, plugin: AUPlugin?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(plugin?.name ?? "パラメータ", systemImage: "slider.horizontal.3")
                    .font(.headline)
                Spacer()
                if plugin?.hasCustomUI == true {
                    Label("カスタム UI", systemImage: "paintbrush")
                        .font(.caption2)
                        .foregroundStyle(.indigo)
                } else {
                    Label("汎用 UI", systemImage: "rectangle.3.group")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(parameters) { param in
                VStack(spacing: 4) {
                    HStack {
                        Text(param.name)
                            .font(.caption.bold())
                        Spacer()
                        Text(param.displayValue)
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }

                    Slider(
                        value: Binding(
                            get: { param.currentValue },
                            set: { viewModel.updateParameter(id: param.id, value: $0, slot: slot) }
                        ),
                        in: param.minValue...param.maxValue
                    )
                    .tint(slot.color)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Playback

    private var playbackSection: some View {
        Button {
            viewModel.togglePlayback()
        } label: {
            HStack {
                Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                Text(viewModel.isPlaying ? "停止" : "再生")
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.isPlaying ? Color.red : Color.indigo, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.white)
        }
    }

    // MARK: - Tech Info

    private var techInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("技術スタック", systemImage: "cpu")
                .font(.headline)

            let techs = [
                ("AVAudioUnitComponentManager", "インストール済み AUv3 プラグインの検出・列挙"),
                ("AVAudioUnit.instantiate", "AUv3 プラグインの動的インスタンス化"),
                ("CoreAudioKit (requestViewController)", "AUv3 カスタム UI の取得・埋込表示"),
                ("AUGenericViewController", "カスタム UI 非対応時の汎用パラメータ UI 生成"),
                ("AVAudioEngine", "デュアル処理パスによる A/B 比較再生"),
                ("AUParameterTree", "パラメータのリアルタイム制御・監視"),
            ]

            ForEach(techs, id: \.0) { tech in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "gearshape.fill")
                        .font(.caption)
                        .foregroundStyle(.indigo)
                        .frame(width: 16)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tech.0)
                            .font(.caption.bold())
                        Text(tech.1)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Plugin Picker Sheet

    private var pluginPickerSheet: some View {
        NavigationStack {
            List(viewModel.filteredPlugins) { plugin in
                Button {
                    viewModel.loadPluginToSlot(plugin, slot: viewModel.pickingSlot)
                } label: {
                    HStack(spacing: 12) {
                        Text(plugin.category.emoji)
                            .font(.title3)
                            .frame(width: 36, height: 36)
                            .background(plugin.category.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading) {
                            Text(plugin.name)
                                .font(.headline)
                            Text("\(plugin.manufacturer) — \(plugin.category.fullName)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text(plugin.ratingText)
                                .font(.caption2)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("スロット \(viewModel.pickingSlot.rawValue) に追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.showPluginPicker = false
                    }
                }
            }
        }
    }
}
