import SwiftUI

struct MenuListView: View {
    @Bindable var viewModel: AllergyGuardViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                restaurantHeader

                categoryFilter

                menuList
            }
            .navigationTitle(viewModel.selectedRestaurant?.name ?? "メニュー")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "メニューを検索")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle(isOn: $viewModel.showSafeOnly) {
                        Label("安全のみ", systemImage: "shield.checkered")
                    }
                    .toggleStyle(.button)
                    .tint(viewModel.showSafeOnly ? .green : .gray)
                }
            }
            .sheet(item: $viewModel.selectedMenuItem) { item in
                MenuItemDetailView(item: item, viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Restaurant Header

    @ViewBuilder
    private var restaurantHeader: some View {
        if let restaurant = viewModel.selectedRestaurant {
            VStack(spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(restaurant.cuisine)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(restaurant.address)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    if viewModel.hasSelectedAllergens {
                        safetyBadge
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
    }

    @ViewBuilder
    private var safetyBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.shield")
                .font(.caption)
            Text("\(viewModel.safeCount)/\(viewModel.totalCount) 安全")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.green)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(.green.opacity(0.12), in: .capsule)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "すべて", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectCategory(nil)
                }
                ForEach(viewModel.availableCategories) { category in
                    filterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func filterChip(title: String, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray5), in: .capsule)
            .foregroundStyle(isSelected ? .white : .primary)
        }
    }

    // MARK: - Menu List

    private var menuList: some View {
        List {
            ForEach(viewModel.filteredMenuItems) { item in
                MenuItemRow(item: item, viewModel: viewModel)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectMenuItem(item)
                    }
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.filteredMenuItems.isEmpty {
                ContentUnavailableView(
                    "該当メニューなし",
                    systemImage: "magnifyingglass",
                    description: Text("条件に合うメニューが見つかりませんでした")
                )
            }
        }
    }
}

// MARK: - MenuItemRow

struct MenuItemRow: View {
    let item: MenuItem
    let viewModel: AllergyGuardViewModel

    var body: some View {
        HStack(spacing: 12) {
            // プレースホルダー画像
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: item.category.icon)
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    safetyIndicator
                }

                Text(item.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack {
                    Text(item.priceText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.accentColor)

                    Spacer()

                    allergenTags
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var safetyIndicator: some View {
        let status = viewModel.safetyStatus(for: item)
        if status != .unknown {
            Image(systemName: status.icon)
                .font(.caption)
                .foregroundStyle(status.badgeColor)
        }
    }

    @ViewBuilder
    private var allergenTags: some View {
        let dangers = item.dangerousAllergens(for: viewModel.selectedAllergens)
        if !dangers.isEmpty {
            HStack(spacing: 2) {
                ForEach(dangers.prefix(3), id: \.0) { allergen, severity in
                    Text(allergen.rawValue)
                        .font(.system(size: 9))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(severity.color.opacity(0.15), in: .capsule)
                        .foregroundStyle(severity.color)
                }
                if dangers.count > 3 {
                    Text("+\(dangers.count - 3)")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    MenuListView(viewModel: AllergyGuardViewModel())
}
