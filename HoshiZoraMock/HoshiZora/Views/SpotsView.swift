import SwiftUI

struct SpotsView: View {
    @Bindable var viewModel: HoshiZoraViewModel
    @State private var filterDark = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    filterSection()
                    spotsList()
                }
                .padding()
            }
            .navigationTitle("観測スポット")
        }
    }

    // MARK: - Filter

    private func filterSection() -> some View {
        HStack {
            filterChip(title: "すべて", isSelected: !filterDark) {
                filterDark = false
            }
            filterChip(title: "暗い場所のみ", isSelected: filterDark) {
                filterDark = true
            }
            Spacer()
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(isSelected ? .white : .primary)
                .background(isSelected ? .blue : .fill.tertiary, in: Capsule())
        }
    }

    // MARK: - Spots List

    private func spotsList() -> some View {
        let filteredSpots = filterDark
            ? viewModel.spots.filter { $0.lightPollutionLevel < 0.5 }
            : viewModel.spots

        return VStack(spacing: 12) {
            ForEach(filteredSpots) { spot in
                spotCard(spot)
            }

            if filteredSpots.isEmpty {
                ContentUnavailableView("条件に一致するスポットがありません", systemImage: "mappin.slash")
                    .padding(.top, 40)
            }
        }
    }

    private func spotCard(_ spot: ObservationSpot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: spot.icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(spot.name)
                        .font(.headline)
                    Text("標高 \(spot.altitude)m")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                lightPollutionBadge(spot)
            }

            Text(spot.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Label(spot.lightPollutionText, systemImage: "lightbulb.slash")
                    .font(.caption2)
                    .foregroundStyle(spot.lightPollutionColor)
            }

            lightPollutionBar(spot.lightPollutionLevel)
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 14))
    }

    private func lightPollutionBadge(_ spot: ObservationSpot) -> some View {
        VStack(spacing: 2) {
            starsForSpot(spot)
            Text("おすすめ度")
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
    }

    private func starsForSpot(_ spot: ObservationSpot) -> some View {
        let stars = max(1, 5 - Int(spot.lightPollutionLevel * 5))
        return HStack(spacing: 2) {
            ForEach(0..<5) { i in
                Image(systemName: i < stars ? "star.fill" : "star")
                    .font(.system(size: 10))
                    .foregroundStyle(i < stars ? .yellow : .gray.opacity(0.3))
            }
        }
    }

    private func lightPollutionBar(_ level: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(.fill.secondary)
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [.green, .yellow, .orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * level)
            }
        }
        .frame(height: 6)
    }
}
