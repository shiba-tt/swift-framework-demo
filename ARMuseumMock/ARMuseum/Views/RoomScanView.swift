import SwiftUI

struct RoomScanView: View {
    @Bindable var viewModel: ARMuseumViewModel

    var body: some View {
        NavigationStack {
            List {
                roomInfoSection
                wallSegmentsSection
                scanSection
            }
            .navigationTitle("ルームスキャン")
        }
    }

    // MARK: - Room Info

    @ViewBuilder
    private var roomInfoSection: some View {
        Section("部屋の情報") {
            if viewModel.room.isScanned {
                VStack(spacing: 16) {
                    roomDiagram
                    roomStats
                }
                .padding(.vertical, 8)
            } else {
                ContentUnavailableView(
                    "部屋がスキャンされていません",
                    systemImage: "room",
                    description: Text("RoomPlan でスキャンを開始してください")
                )
            }
        }
    }

    @ViewBuilder
    private var roomDiagram: some View {
        let room = viewModel.room
        ZStack {
            // 部屋の輪郭
            Rectangle()
                .stroke(.indigo.opacity(0.5), lineWidth: 2)
                .fill(.indigo.opacity(0.05))
                .frame(width: 200, height: 200 * room.depth / room.width)

            // 方向ラベル
            VStack {
                Text("北")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                Spacer()
                Text("南")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
            .frame(height: 200 * room.depth / room.width + 30)

            HStack {
                Text("西")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Spacer()
                Text("東")
                    .font(.caption2)
                    .foregroundStyle(.green)
            }
            .frame(width: 240)

            // 寸法表示
            Text(room.formattedDimensions)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(height: 220)
    }

    @ViewBuilder
    private var roomStats: some View {
        let room = viewModel.room
        HStack(spacing: 20) {
            statBadge(label: "面積", value: room.formattedArea, icon: "square.dashed")
            statBadge(label: "天井高", value: String(format: "%.1f m", room.height), icon: "arrow.up.and.down")
            statBadge(label: "壁面", value: "\(room.wallSegments.count)", icon: "rectangle.split.3x1")
        }
    }

    @ViewBuilder
    private func statBadge(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.indigo)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Wall Segments

    @ViewBuilder
    private var wallSegmentsSection: some View {
        if viewModel.room.isScanned {
            Section("壁面セグメント") {
                ForEach(viewModel.room.wallSegments) { segment in
                    HStack {
                        Circle()
                            .fill(segment.direction.color)
                            .frame(width: 10, height: 10)
                        Text("\(segment.direction.rawValue)壁")
                            .font(.subheadline)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "全長 %.1f m", segment.length))
                                .font(.caption)
                            Text(String(format: "展示可能 %.1f m", segment.availableWidth))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Scan

    @ViewBuilder
    private var scanSection: some View {
        Section {
            Button {
                Task {
                    await viewModel.startRoomScan()
                }
            } label: {
                HStack {
                    if viewModel.isScanning {
                        ProgressView()
                            .padding(.trailing, 4)
                        Text("スキャン中...")
                    } else {
                        Image(systemName: "camera.viewfinder")
                        Text(viewModel.room.isScanned ? "再スキャン" : "RoomPlan スキャンを開始")
                    }
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
            }
            .disabled(viewModel.isScanning)
        } footer: {
            Text("RoomPlan を使って部屋の壁・床・天井を自動検出し、作品配置の最適化に活用します。")
        }
    }
}

#Preview {
    RoomScanView(viewModel: ARMuseumViewModel())
}
