import SwiftUI

struct SafetySummaryView: View {
    @Bindable var viewModel: AllergyGuardViewModel

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.hasSelectedAllergens {
                    Section {
                        ContentUnavailableView(
                            "アレルゲン未設定",
                            systemImage: "shield.checkered",
                            description: Text("アレルギー設定タブでアレルゲンを選択すると、安全なメニューの一覧が表示されます")
                        )
                    }
                } else {
                    overviewSection

                    safeMenuSection

                    cautionMenuSection

                    dangerMenuSection
                }
            }
            .navigationTitle("安全サマリー")
        }
    }

    // MARK: - Overview

    private var overviewSection: some View {
        Section("概要") {
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    statCard(
                        title: "安全",
                        count: safeItems.count,
                        color: .green,
                        icon: "checkmark.shield.fill"
                    )
                    statCard(
                        title: "注意",
                        count: cautionItems.count,
                        color: .orange,
                        icon: "exclamationmark.triangle.fill"
                    )
                    statCard(
                        title: "危険",
                        count: dangerItems.count,
                        color: .red,
                        icon: "xmark.shield.fill"
                    )
                }

                safetyGauge
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func statCard(title: String, count: Int, color: Color, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var safetyGauge: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("安全率")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(viewModel.safeRatio * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(gaugeColor)
                        .frame(width: geometry.size.width * viewModel.safeRatio, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private var gaugeColor: Color {
        switch viewModel.safeRatio {
        case 0.7...: .green
        case 0.4..<0.7: .orange
        default: .red
        }
    }

    // MARK: - Menu Sections

    private var safeMenuSection: some View {
        Section {
            ForEach(safeItems) { item in
                summaryRow(item: item, status: .safe)
            }
        } header: {
            Label("安全なメニュー (\(safeItems.count))", systemImage: "checkmark.shield.fill")
                .foregroundStyle(.green)
        }
    }

    @ViewBuilder
    private var cautionMenuSection: some View {
        if !cautionItems.isEmpty {
            Section {
                ForEach(cautionItems) { item in
                    summaryRow(item: item, status: .caution)
                }
            } header: {
                Label("注意が必要 (\(cautionItems.count))", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
        }
    }

    @ViewBuilder
    private var dangerMenuSection: some View {
        if !dangerItems.isEmpty {
            Section {
                ForEach(dangerItems) { item in
                    summaryRow(item: item, status: .danger)
                }
            } header: {
                Label("避けるべきメニュー (\(dangerItems.count))", systemImage: "xmark.shield.fill")
                    .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    private func summaryRow(item: MenuItem, status: SafetyStatus) -> some View {
        HStack {
            Image(systemName: status.icon)
                .foregroundStyle(status.badgeColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                let dangers = item.dangerousAllergens(for: viewModel.selectedAllergens)
                if !dangers.isEmpty {
                    Text(dangers.map { $0.0.rawValue }.joined(separator: "・"))
                        .font(.caption)
                        .foregroundStyle(status.badgeColor)
                }
            }

            Spacer()

            Text(item.priceText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private var safeItems: [MenuItem] {
        guard let restaurant = viewModel.selectedRestaurant else { return [] }
        return restaurant.menuItems.filter { viewModel.safetyStatus(for: $0) == .safe }
    }

    private var cautionItems: [MenuItem] {
        guard let restaurant = viewModel.selectedRestaurant else { return [] }
        return restaurant.menuItems.filter { viewModel.safetyStatus(for: $0) == .caution }
    }

    private var dangerItems: [MenuItem] {
        guard let restaurant = viewModel.selectedRestaurant else { return [] }
        return restaurant.menuItems.filter { viewModel.safetyStatus(for: $0) == .danger }
    }
}

#Preview {
    SafetySummaryView(viewModel: AllergyGuardViewModel())
}
