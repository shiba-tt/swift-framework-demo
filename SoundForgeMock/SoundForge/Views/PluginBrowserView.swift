import SwiftUI

struct PluginBrowserView: View {
    @Bindable var viewModel: SoundForgeViewModel
    @State private var isScanning = false
    @State private var searchText = ""

    /// モックのプラグインデータ
    private let mockPlugins: [MockPlugin] = [
        MockPlugin(name: "Apple: AUMatrixReverb", manufacturer: "Apple", category: "Reverb", hasCustomUI: true),
        MockPlugin(name: "Apple: AUDelay", manufacturer: "Apple", category: "Delay", hasCustomUI: true),
        MockPlugin(name: "Apple: AUDistortion", manufacturer: "Apple", category: "Distortion", hasCustomUI: true),
        MockPlugin(name: "Apple: AUBandpass", manufacturer: "Apple", category: "Filter", hasCustomUI: false),
        MockPlugin(name: "Apple: AUHighShelfFilter", manufacturer: "Apple", category: "EQ", hasCustomUI: false),
        MockPlugin(name: "Apple: AULowShelfFilter", manufacturer: "Apple", category: "EQ", hasCustomUI: false),
        MockPlugin(name: "Apple: AUParametricEQ", manufacturer: "Apple", category: "EQ", hasCustomUI: false),
        MockPlugin(name: "Apple: AUPeakLimiter", manufacturer: "Apple", category: "Dynamics", hasCustomUI: false),
        MockPlugin(name: "Apple: AUDynamicsProcessor", manufacturer: "Apple", category: "Dynamics", hasCustomUI: true),
        MockPlugin(name: "Apple: AUNewPitch", manufacturer: "Apple", category: "Pitch", hasCustomUI: false),
        MockPlugin(name: "Apple: AUSampleDelay", manufacturer: "Apple", category: "Delay", hasCustomUI: false),
        MockPlugin(name: "Apple: AURoundTripAAC", manufacturer: "Apple", category: "Utility", hasCustomUI: false),
    ]

    private var filteredPlugins: [MockPlugin] {
        if searchText.isEmpty {
            return mockPlugins
        }
        return mockPlugins.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedPlugins: [(category: String, plugins: [MockPlugin])] {
        let grouped = Dictionary(grouping: filteredPlugins) { $0.category }
        return grouped
            .sorted { $0.key < $1.key }
            .map { (category: $0.key, plugins: $0.value) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    scanSection
                    pluginListSection
                    auv3InfoSection
                }
                .padding()
            }
            .navigationTitle("プラグイン")
            .searchable(text: $searchText, prompt: "プラグインを検索")
        }
    }

    // MARK: - Scan Section

    private var scanSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.title3)
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("AUv3 プラグインスキャン")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("AVAudioUnitComponentManager でインストール済みプラグインを検出")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Button {
                Task {
                    isScanning = true
                    try? await Task.sleep(for: .seconds(1))
                    isScanning = false
                }
            } label: {
                if isScanning {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("スキャン中...")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                } else {
                    Label("プラグインをスキャン", systemImage: "magnifyingglass")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(isScanning)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Plugin List

    private var pluginListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("検出されたプラグイン")
                    .font(.headline)
                Spacer()
                Text("\(filteredPlugins.count) 件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(groupedPlugins, id: \.category) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    ForEach(group.plugins) { plugin in
                        pluginRow(plugin)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func pluginRow(_ plugin: MockPlugin) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "puzzlepiece.extension.fill")
                .font(.title3)
                .foregroundStyle(.orange.opacity(0.7))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(plugin.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 8) {
                    Text(plugin.manufacturer)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if plugin.hasCustomUI {
                        Label("カスタムUI", systemImage: "paintbrush")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }
            }

            Spacer()

            Text(plugin.category)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.quaternary, in: Capsule())
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - AUv3 Info

    private var auv3InfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CoreAudioKit 技術情報")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                infoRow(icon: "rectangle.on.rectangle", title: "AUViewController", detail: "AUv3 プラグインのカスタム UI を表示")
                infoRow(icon: "slider.horizontal.3", title: "AUGenericViewController", detail: "カスタム UI がない場合の汎用パラメータ UI")
                infoRow(icon: "arrow.triangle.branch", title: "AUParameterTree", detail: "プラグインパラメータのリアルタイム制御")
                infoRow(icon: "rectangle.compress.vertical", title: "AUAudioUnitViewConfiguration", detail: "プラグイン UI のサイズ最適化")
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func infoRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.orange)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - MockPlugin

private struct MockPlugin: Identifiable {
    let id = UUID()
    let name: String
    let manufacturer: String
    let category: String
    let hasCustomUI: Bool

    var displayName: String {
        if let colonIndex = name.firstIndex(of: ":") {
            return String(name[name.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
        }
        return name
    }
}

#Preview {
    PluginBrowserView(viewModel: SoundForgeViewModel())
}
