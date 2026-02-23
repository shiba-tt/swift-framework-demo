import SwiftUI

// MARK: - NearbyMapView

struct NearbyMapView: View {
    var viewModel: ARTimeMachineViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    mapPlaceholder
                    spotSummary
                    categoryBreakdown
                    nearbyList
                }
                .padding()
            }
            .navigationTitle("マップ")
        }
    }

    // MARK: - Map Placeholder

    private var mapPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .frame(height: 250)

            VStack(spacing: 12) {
                Image(systemName: "map.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.indigo.opacity(0.5))

                Text("マップ表示エリア")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("MapKit で周辺の歴史スポットを表示")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                // モック: スポットピン
                HStack(spacing: 20) {
                    ForEach(viewModel.spots.prefix(4)) { spot in
                        VStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(spot.category.color)
                            Text(spot.name)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Summary

    private var spotSummary: some View {
        HStack(spacing: 16) {
            SummaryCard(
                title: "スポット数",
                value: "\(viewModel.spots.count)",
                systemImage: "mappin.and.ellipse",
                color: .indigo
            )
            SummaryCard(
                title: "お気に入り",
                value: "\(viewModel.favoriteCount)",
                systemImage: "heart.fill",
                color: .red
            )
            SummaryCard(
                title: "対応都市",
                value: viewModel.locationManager.currentCity,
                systemImage: "building.2.fill",
                color: .blue
            )
        }
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリー別")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 10) {
                ForEach(SpotCategory.allCases, id: \.self) { category in
                    let count = viewModel.spots.filter { $0.category == category }.count
                    HStack {
                        Image(systemName: category.systemImage)
                            .foregroundStyle(category.color)
                            .frame(width: 24)
                        Text(category.rawValue)
                            .font(.caption)
                        Spacer()
                        Text("\(count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    // MARK: - Nearby List

    private var nearbyList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("距離順")
                .font(.headline)

            ForEach(viewModel.spots.sorted(by: { ($0.distance ?? 0) < ($1.distance ?? 0) })) { spot in
                HStack(spacing: 12) {
                    Image(systemName: spot.category.systemImage)
                        .foregroundStyle(spot.category.color)
                        .frame(width: 30)

                    VStack(alignment: .leading) {
                        Text(spot.name)
                            .font(.subheadline)
                        Text("\(spot.timePeriods.count)つの時代")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(spot.distanceText)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - SummaryCard

struct SummaryCard: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NearbyMapView(viewModel: ARTimeMachineViewModel())
}
