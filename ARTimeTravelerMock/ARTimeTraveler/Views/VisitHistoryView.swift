import SwiftUI

struct VisitHistoryView: View {
    @Bindable var viewModel: ARTimeTravelerViewModel

    var body: some View {
        NavigationStack {
            List {
                statsSection

                if viewModel.visitRecords.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "訪問記録なし",
                            systemImage: "clock.arrow.circlepath",
                            description: Text("歴史スポットを訪問すると記録が残ります")
                        )
                    }
                } else {
                    recordsSection
                }

                allSpotsSection
            }
            .navigationTitle("訪問記録")
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        Section("統計") {
            HStack(spacing: 20) {
                statItem(
                    title: "総訪問数",
                    value: "\(viewModel.totalVisits)",
                    icon: "figure.walk",
                    color: .indigo
                )
                statItem(
                    title: "スポット数",
                    value: "\(viewModel.uniqueSpotsVisited)/\(viewModel.spots.count)",
                    icon: "mappin.circle",
                    color: .orange
                )
                statItem(
                    title: "制覇率",
                    value: completionRate,
                    icon: "trophy",
                    color: .yellow
                )
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
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
    }

    private var completionRate: String {
        guard !viewModel.spots.isEmpty else { return "0%" }
        let rate = Double(viewModel.uniqueSpotsVisited) / Double(viewModel.spots.count) * 100
        return "\(Int(rate))%"
    }

    // MARK: - Records Section

    private var recordsSection: some View {
        Section("訪問履歴") {
            ForEach(viewModel.visitRecords) { record in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(record.spotName)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        Text(record.visitDateText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 8) {
                        ForEach(record.erasViewed) { era in
                            Text(era.name)
                                .font(.system(size: 9))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(era.color.opacity(0.15), in: .capsule)
                                .foregroundStyle(era.color)
                        }
                    }

                    HStack(spacing: 12) {
                        Label(
                            "\(record.erasViewed.count) 時代閲覧",
                            systemImage: "clock"
                        )
                        if record.audioGuideListened {
                            Label("音声ガイド", systemImage: "speaker.wave.2.fill")
                                .foregroundStyle(.indigo)
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - All Spots Section

    private var allSpotsSection: some View {
        Section("全スポット一覧") {
            ForEach(viewModel.spots) { spot in
                let isVisited = viewModel.visitRecords.contains { $0.spotID == spot.id }
                HStack {
                    Image(systemName: spot.category.icon)
                        .foregroundStyle(isVisited ? .indigo : .gray)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(spot.name)
                            .font(.subheadline)
                        Text("\(spot.snapshots.count) 時代 ・ \(spot.category.rawValue)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if isVisited {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    VisitHistoryView(viewModel: ARTimeTravelerViewModel())
}
