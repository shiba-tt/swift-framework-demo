import SwiftUI

struct BrowseView: View {
    @Bindable var viewModel: AUBazaarViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    statsHeader
                    categoryFilter
                    pluginList
                }
                .padding()
            }
            .navigationTitle("AUBazaar")
            .searchable(text: $viewModel.searchQuery, prompt: "プラグイン名・メーカー・タグで検索")
            .sheet(isPresented: $viewModel.showPluginDetail) {
                if let plugin = viewModel.selectedPlugin {
                    PluginDetailView(plugin: plugin, viewModel: viewModel)
                }
            }
        }
    }

    // MARK: - Stats Header

    private var statsHeader: some View {
        HStack(spacing: 12) {
            statBadge("インストール済み", value: "\(viewModel.totalPluginCount)", icon: "puzzlepiece.extension", color: .indigo)
            statBadge("平均評価", value: String(format: "%.1f", viewModel.averageRating), icon: "star.fill", color: .orange)
        }
    }

    private func statBadge(_ title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            VStack(alignment: .leading) {
                Text(value)
                    .font(.headline)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(nil, label: "全て", emoji: "🎛️")
                ForEach(AUPluginCategory.allCases) { category in
                    categoryChip(category, label: category.rawValue, emoji: category.emoji)
                }
            }
        }
    }

    private func categoryChip(_ category: AUPluginCategory?, label: String, emoji: String) -> some View {
        Button {
            viewModel.selectedCategory = category
        } label: {
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.caption)
                Text(label)
                    .font(.caption.bold())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                viewModel.selectedCategory == category
                    ? Color.indigo.opacity(0.15)
                    : Color(.systemGray6),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(viewModel.selectedCategory == category ? Color.indigo : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Plugin List

    private var pluginList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredPlugins) { plugin in
                pluginRow(plugin)
            }
        }
    }

    private func pluginRow(_ plugin: AUPlugin) -> some View {
        Button {
            viewModel.selectedPlugin = plugin
            viewModel.showPluginDetail = true
        } label: {
            HStack(spacing: 12) {
                // Icon
                Text(plugin.category.emoji)
                    .font(.title2)
                    .frame(width: 48, height: 48)
                    .background(plugin.category.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plugin.name)
                            .font(.headline)
                        if plugin.hasCustomUI {
                            Image(systemName: "paintbrush")
                                .font(.caption2)
                                .foregroundStyle(.indigo)
                        }
                    }

                    Text(plugin.manufacturer)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text(plugin.ratingText)
                                .font(.caption2)
                        }

                        Text(plugin.category.rawValue)
                            .font(.system(size: 10).bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(plugin.category.color.opacity(0.1), in: Capsule())
                            .foregroundStyle(plugin.category.color)

                        Text("CPU \(plugin.cpuLoadText)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Favorite
                Button {
                    viewModel.toggleFavorite(plugin)
                } label: {
                    Image(systemName: viewModel.isFavorite(plugin) ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isFavorite(plugin) ? .red : .secondary)
                }

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
