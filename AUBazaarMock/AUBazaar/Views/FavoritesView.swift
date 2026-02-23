import SwiftUI

struct FavoritesView: View {
    @Bindable var viewModel: AUBazaarViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favoritePlugins.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            summarySection
                            pluginCards
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("お気に入り")
            .sheet(isPresented: $viewModel.showPluginDetail) {
                if let plugin = viewModel.selectedPlugin {
                    PluginDetailView(plugin: plugin, viewModel: viewModel)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("お気に入りなし", systemImage: "heart.slash")
        } description: {
            Text("ブラウズタブからプラグインをお気に入りに追加してみましょう")
        }
    }

    // MARK: - Summary

    private var summarySection: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("\(viewModel.favoritePlugins.count)")
                    .font(.title.bold())
                    .foregroundStyle(.red)
                Text("お気に入り数")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))

            VStack(spacing: 4) {
                let categories = Set(viewModel.favoritePlugins.map(\.category))
                Text("\(categories.count)")
                    .font(.title.bold())
                    .foregroundStyle(.indigo)
                Text("カテゴリ数")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.indigo.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Plugin Cards

    private var pluginCards: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.favoritePlugins) { plugin in
                favoriteCard(plugin)
            }
        }
    }

    private func favoriteCard(_ plugin: AUPlugin) -> some View {
        Button {
            viewModel.selectedPlugin = plugin
            viewModel.showPluginDetail = true
        } label: {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Text(plugin.category.emoji)
                        .font(.title)
                        .frame(width: 56, height: 56)
                        .background(plugin.category.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(plugin.name)
                            .font(.headline)
                        Text(plugin.manufacturer)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.orange)
                            Text(plugin.ratingText)
                        }
                        .font(.subheadline)

                        Text(plugin.category.fullName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 12) {
                    miniStat("CPU", value: plugin.cpuLoadText, icon: "cpu")
                    miniStat("遅延", value: plugin.latencyText, icon: "clock")
                    miniStat("パラメータ", value: "\(plugin.parameterCount)", icon: "slider.horizontal.3")
                    miniStat("プリセット", value: "\(plugin.presetCount)", icon: "archivebox")

                    Spacer()

                    Button {
                        viewModel.toggleFavorite(plugin)
                    } label: {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func miniStat(_ label: String, value: String, icon: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text(value)
                .font(.system(size: 10))
        }
    }
}
