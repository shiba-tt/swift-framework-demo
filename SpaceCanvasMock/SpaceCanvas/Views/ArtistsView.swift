import SwiftUI

struct ArtistsView: View {
    @Bindable var viewModel: SpaceCanvasViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("接続中のアーティスト") {
                    ForEach(viewModel.artists) { artist in
                        ArtistRow(artist: artist)
                    }
                }

                Section("UWB 空間マップ") {
                    SpatialMapCard(artists: viewModel.artists)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section("セッション統計") {
                    StatRow(
                        icon: "scribble", label: "合計ストローク",
                        value: "\(viewModel.totalStrokes)"
                    )
                    StatRow(
                        icon: "circle.fill", label: "合計ポイント",
                        value: "\(viewModel.totalPoints)"
                    )
                    StatRow(
                        icon: "clock", label: "セッション時間",
                        value: viewModel.sessionDurationText
                    )
                    StatRow(
                        icon: "person.2", label: "参加者数",
                        value: "\(viewModel.connectedArtists)人"
                    )
                }

                Section("デバイス情報") {
                    HStack {
                        Label("UWB サポート", systemImage: "antenna.radiowaves.left.and.right")
                        Spacer()
                        Text("対応")
                            .foregroundStyle(.green)
                    }
                    HStack {
                        Label("チップ", systemImage: "cpu")
                        Spacer()
                        Text("U2")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("精度", systemImage: "ruler")
                        Spacer()
                        Text("~10 cm")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("範囲", systemImage: "scope")
                        Spacer()
                        Text("~20 m")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("アーティスト")
        }
    }
}

private struct ArtistRow: View {
    let artist: Artist

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(artist.assignedColor.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                Text(String(artist.name.prefix(1)))
                    .font(.headline)
                    .foregroundStyle(artist.assignedColor.color)

                VStack {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(artist.statusColor)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                    Spacer()
                }
                .frame(width: 44, height: 44)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(artist.name)
                        .font(.body.bold())
                    if artist.name == "あなた" {
                        Text("自分")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.cyan.opacity(0.1))
                            .foregroundStyle(.cyan)
                            .clipShape(Capsule())
                    }
                }
                HStack(spacing: 12) {
                    if let _ = artist.distance {
                        Label(artist.distanceText, systemImage: "ruler")
                    }
                    Label(
                        "\(artist.strokeCount) ストローク",
                        systemImage: "scribble"
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Circle()
                .fill(artist.assignedColor.color)
                .frame(width: 20, height: 20)
        }
    }
}

// MARK: - Spatial Map Card

private struct SpatialMapCard: View {
    let artists: [Artist]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("空間配置図")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

                ZStack {
                    // Range circles
                    ForEach([1, 2, 3, 4], id: \.self) { radius in
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                            .frame(
                                width: CGFloat(radius) * geo.size.width / 5,
                                height: CGFloat(radius) * geo.size.width / 5
                            )
                    }

                    // Cross lines
                    Path { path in
                        path.move(to: CGPoint(x: center.x, y: 0))
                        path.addLine(to: CGPoint(x: center.x, y: geo.size.height))
                        path.move(to: CGPoint(x: 0, y: center.y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: center.y))
                    }
                    .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)

                    // Self indicator
                    VStack(spacing: 2) {
                        Image(systemName: "iphone.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.cyan)
                        Text("あなた")
                            .font(.system(size: 9).bold())
                    }
                    .position(center)

                    // Peer indicators
                    ForEach(artists.filter({ $0.name != "あなた" })) { artist in
                        let scale = geo.size.width / 10
                        let dx = CGFloat(artist.direction?.x ?? 0) * scale
                            * CGFloat(artist.distance ?? 2)
                        let dz = CGFloat(artist.direction?.z ?? -1) * scale
                            * CGFloat(artist.distance ?? 2)

                        VStack(spacing: 2) {
                            Circle()
                                .fill(artist.assignedColor.color)
                                .frame(width: 14, height: 14)
                            Text(artist.name)
                                .font(.system(size: 8).bold())
                            Text(artist.distanceText)
                                .font(.system(size: 7))
                                .foregroundStyle(.secondary)
                        }
                        .position(
                            x: center.x + dx,
                            y: center.y + dz
                        )
                    }
                }
            }
            .frame(height: 200)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

private struct StatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
