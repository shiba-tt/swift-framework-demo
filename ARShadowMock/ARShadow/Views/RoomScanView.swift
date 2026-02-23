import SwiftUI

struct RoomScanView: View {
    var viewModel: ARShadowViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "camera.metering.spot")
                        .font(.system(size: 50))
                        .foregroundStyle(.orange)

                    Text("ルームスキャン")
                        .font(.title2.bold())

                    Text("LiDAR で部屋をスキャンして\n影の投影面と家具配置を認識します")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Scan result or scan button
                if let meshInfo = viewModel.roomMeshInfo {
                    roomInfoCard(meshInfo)
                } else {
                    scanPromptCard
                }

                // Tech info
                techInfoSection

                Spacer()
            }
            .padding()
            .navigationTitle("スキャン")
        }
    }

    // MARK: - Scan Prompt

    private var scanPromptCard: some View {
        VStack(spacing: 16) {
            if viewModel.isScanningRoom {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()

                Text("スキャン中...")
                    .font(.headline)

                Text("デバイスをゆっくり動かして\n部屋全体をスキャンしてください")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Button {
                    Task {
                        await viewModel.scanRoom()
                    }
                } label: {
                    Label("部屋をスキャン", systemImage: "arkit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Room Info Card

    private func roomInfoCard(_ info: RoomMeshInfo) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("スキャン結果")
                    .font(.headline)
                Spacer()
                Label(info.lightCondition.rawValue, systemImage: "light.max")
                    .font(.caption)
                    .foregroundStyle(info.lightCondition.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(info.lightCondition.color.opacity(0.15), in: Capsule())
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                scanMetric(
                    icon: "square.dashed",
                    label: "床面積",
                    value: "\(String(format: "%.1f", info.floorArea))㎡"
                )
                scanMetric(
                    icon: "rectangle.portrait.split.2x1",
                    label: "壁面数",
                    value: "\(info.wallCount)面"
                )
                scanMetric(
                    icon: "chair.lounge.fill",
                    label: "家具",
                    value: "\(info.furnitureCount)個"
                )
                scanMetric(
                    icon: "rectangle.inset.filled",
                    label: "投影面",
                    value: "\(info.projectionSurfaces)箇所"
                )
            }

            Text(info.lightCondition.suitability)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                Task {
                    await viewModel.scanRoom()
                }
            } label: {
                Label("再スキャン", systemImage: "arrow.clockwise")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.orange.opacity(0.15))
                    .foregroundStyle(.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func scanMetric(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.orange)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.orange.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Tech Info

    private var techInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("使用技術")
                .font(.headline)

            techRow(icon: "cube.transparent", title: "Scene Reconstruction", desc: "部屋のメッシュを取得して影の投影面と遮蔽物を計算")
            techRow(icon: "camera.filters", title: "Depth API", desc: "ピクセル単位の深度で正確な影の形を計算")
            techRow(icon: "paintbrush.pointed.fill", title: "Metal シェーダー", desc: "影の形状をリアルタイム計算し目標形状との一致度を算出")
            techRow(icon: "square.3.layers.3d.top.filled", title: "平面検出", desc: "床・壁を影の投影面として使用")
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func techRow(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.orange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    RoomScanView(viewModel: ARShadowViewModel())
}
