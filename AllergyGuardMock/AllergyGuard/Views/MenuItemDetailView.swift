import SwiftUI

struct MenuItemDetailView: View {
    let item: MenuItem
    let viewModel: AllergyGuardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerImage

                    VStack(alignment: .leading, spacing: 16) {
                        titleSection

                        safetyBanner

                        allergenDetailSection

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("メニュー詳細")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header Image

    private var headerImage: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(.systemGray5), Color(.systemGray4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)

            VStack(spacing: 8) {
                Image(systemName: item.category.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("写真は AsyncImage で読み込み")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Text(item.priceText)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.accentColor)
            }

            Text(item.description)
                .font(.body)
                .foregroundStyle(.secondary)

            Text(item.category.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(.systemGray5), in: .capsule)
        }
    }

    // MARK: - Safety Banner

    @ViewBuilder
    private var safetyBanner: some View {
        let status = viewModel.safetyStatus(for: item)
        HStack(spacing: 8) {
            Image(systemName: status.icon)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(status.displayName)
                    .font(.headline)
                Text(safetyMessage(for: status))
                    .font(.caption)
            }

            Spacer()
        }
        .padding()
        .foregroundStyle(status == .unknown ? .primary : .white)
        .background(status.badgeColor.gradient, in: .rect(cornerRadius: 12))
    }

    private func safetyMessage(for status: SafetyStatus) -> String {
        switch status {
        case .safe:
            "選択したアレルゲンは含まれていません"
        case .caution:
            "含まれる可能性のあるアレルゲンがあります"
        case .danger:
            "選択したアレルゲンが含まれています"
        case .unknown:
            "アレルギー設定タブでアレルゲンを選択してください"
        }
    }

    // MARK: - Allergen Detail

    private var allergenDetailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("アレルゲン情報")
                .font(.headline)

            if item.allergens.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("特定原材料等の表示対象アレルゲンは含まれていません")
                        .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.08), in: .rect(cornerRadius: 8))
            } else {
                VStack(spacing: 0) {
                    ForEach(Allergen.allCases) { allergen in
                        if let severity = item.allergens[allergen] {
                            allergenDetailRow(allergen: allergen, severity: severity)
                            Divider()
                        }
                    }
                }
                .background(Color(.systemGray6), in: .rect(cornerRadius: 8))
            }
        }
    }

    @ViewBuilder
    private func allergenDetailRow(allergen: Allergen, severity: AllergenSeverity) -> some View {
        let isUserAllergen = viewModel.selectedAllergens.contains(allergen)
        HStack {
            Image(systemName: allergen.icon)
                .foregroundStyle(allergen.color)
                .frame(width: 24)

            Text(allergen.rawValue)
                .font(.subheadline)
                .fontWeight(isUserAllergen ? .bold : .regular)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: severity.icon)
                Text(severity.rawValue)
                    .font(.caption)
            }
            .foregroundStyle(severity.color)

            if isUserAllergen {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isUserAllergen ? severity.color.opacity(0.08) : .clear)
    }
}

#Preview {
    let item = MenuItem(
        name: "カルボナーラ",
        description: "自家製パンチェッタの濃厚カルボナーラ",
        category: .pasta,
        price: 1400,
        allergens: [.egg: .contains, .milk: .contains, .wheat: .contains]
    )
    MenuItemDetailView(item: item, viewModel: AllergyGuardViewModel())
}
