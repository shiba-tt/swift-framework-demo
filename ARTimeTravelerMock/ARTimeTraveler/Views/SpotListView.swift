import SwiftUI

struct SpotListView: View {
    @Bindable var viewModel: ARTimeTravelerViewModel

    var body: some View {
        NavigationStack {
            List {
                headerSection

                ForEach(viewModel.spots) { spot in
                    SpotCardView(spot: spot) {
                        viewModel.selectSpot(spot)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("歴史タイムトラベル")
            .sheet(isPresented: $viewModel.showingSpotDetail) {
                if let spot = viewModel.selectedSpot {
                    SpotDetailView(spot: spot, viewModel: viewModel)
                }
            }
        }
    }

    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "clock.arrow.2.circlepath")
                        .font(.largeTitle)
                        .foregroundStyle(.indigo)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("AR タイムトラベラー")
                            .font(.headline)
                        Text("NFCタグをタップして、歴史的建造物の過去の姿をARで体験しよう")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 16) {
                    Label("\(viewModel.spots.count) スポット", systemImage: "mappin.circle")
                    Label("\(viewModel.totalVisits) 訪問済み", systemImage: "checkmark.circle")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - SpotCardView

struct SpotCardView: View {
    let spot: HistoricalSpot
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: spot.category.icon)
                        .font(.title2)
                        .foregroundStyle(.indigo)
                        .frame(width: 40, height: 40)
                        .background(.indigo.opacity(0.12), in: .rect(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(spot.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(spot.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }

                Text(spot.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label(spot.category.rawValue, systemImage: spot.category.icon)
                    Label("\(spot.snapshots.count) 時代", systemImage: "clock")
                    Label(spot.yearRange, systemImage: "calendar")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)

                eraTimeline
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var eraTimeline: some View {
        HStack(spacing: 4) {
            ForEach(spot.snapshots) { snapshot in
                VStack(spacing: 2) {
                    Circle()
                        .fill(snapshot.era.color)
                        .frame(width: 8, height: 8)
                    Text(snapshot.era.name)
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }
                if snapshot.id != spot.snapshots.last?.id {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 10)
                }
            }
        }
    }
}

#Preview {
    SpotListView(viewModel: ARTimeTravelerViewModel())
}
