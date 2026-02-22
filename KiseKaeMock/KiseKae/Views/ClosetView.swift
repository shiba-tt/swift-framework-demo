import SwiftUI

struct ClosetView: View {
    @Bindable var viewModel: KiseKaeViewModel
    @State private var selectedCategory: ClothingCategory = .outer

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // カテゴリピッカー
                Picker("カテゴリ", selection: $selectedCategory) {
                    ForEach(ClothingCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                ScrollView {
                    VStack(spacing: 12) {
                        weatherContextBanner

                        ForEach(viewModel.itemsForCategory(selectedCategory)) { item in
                            itemCard(item)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("クローゼット")
        }
    }

    // MARK: - Weather Context

    private var weatherContextBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.currentWeather.condition.systemImageName)
                .symbolRenderingMode(.multicolor)

            Text("\(viewModel.currentWeather.condition.rawValue) \(viewModel.currentWeather.temperatureText)")
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            Text("の適合度")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Item Card

    private func itemCard(_ item: ClothingItem) -> some View {
        let score = item.suitability(for: viewModel.currentWeather)

        return HStack(spacing: 14) {
            Text(item.emoji)
                .font(.largeTitle)
                .frame(width: 50, height: 50)
                .background(.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(item.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    if item.rainSuitable {
                        Label("防水", systemImage: "drop.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                    if item.uvProtection {
                        Label("UV", systemImage: "sun.max.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                    if item.windProtection {
                        Label("防風", systemImage: "wind")
                            .font(.caption2)
                            .foregroundStyle(.teal)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(score * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(scoreColor(score))

                ProgressView(value: score)
                    .frame(width: 50)
                    .tint(scoreColor(score))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Helpers

    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 0.7...: return .green
        case 0.4...: return .orange
        default:     return .red
        }
    }
}

#Preview {
    ClosetView(viewModel: KiseKaeViewModel())
}
