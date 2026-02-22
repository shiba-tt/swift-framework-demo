import SwiftUI

// MARK: - HomeControlView

struct HomeControlView: View {
    @Bindable var viewModel: ControlDeckViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ステータスヘッダー
                    statusHeader

                    // アクティブシーン
                    if let scene = viewModel.activeScene {
                        activeSceneBanner(scene)
                    }

                    // 部屋ごとのコントロール
                    ForEach(viewModel.rooms) { room in
                        RoomCardView(viewModel: viewModel, room: room)
                    }
                }
                .padding()
            }
            .navigationTitle("ControlDeck")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Status Header

    private var statusHeader: some View {
        HStack(spacing: 16) {
            StatusPill(
                icon: "power",
                value: "\(viewModel.totalActiveDevices)",
                label: "稼働中",
                color: .green
            )
            StatusPill(
                icon: "sensor.fill",
                value: "\(viewModel.totalDevices)",
                label: "全デバイス",
                color: .blue
            )
            StatusPill(
                icon: "house.fill",
                value: "\(viewModel.rooms.count)",
                label: "部屋",
                color: .indigo
            )
        }
    }

    // MARK: - Active Scene Banner

    private func activeSceneBanner(_ scene: HomeScene) -> some View {
        HStack(spacing: 12) {
            Image(systemName: scene.icon)
                .font(.title2)
                .foregroundStyle(scene.color)

            VStack(alignment: .leading, spacing: 2) {
                Text("現在のシーン")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(scene.name)
                    .font(.headline)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
        .padding()
        .background(scene.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - StatusPill

struct StatusPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - RoomCardView

struct RoomCardView: View {
    @Bindable var viewModel: ControlDeckViewModel
    let room: Room

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 部屋ヘッダー
            HStack {
                Image(systemName: room.icon)
                    .foregroundStyle(room.color)
                Text(room.name)
                    .font(.headline)

                Spacer()

                let active = viewModel.activeDeviceCount(in: room)
                let total = viewModel.totalDeviceCount(in: room)
                Text("\(active)/\(total) ON")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())

                Button {
                    viewModel.allOffInRoom(room)
                } label: {
                    Image(systemName: "power")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(6)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
            }

            // デバイスグリッド
            let devices = viewModel.devices(in: room)
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(devices) { device in
                    DeviceTileView(viewModel: viewModel, device: device)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - DeviceTileView

struct DeviceTileView: View {
    @Bindable var viewModel: ControlDeckViewModel
    let device: SmartDevice

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(device.type.emoji)
                    .font(.title3)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { device.isOn },
                    set: { _ in viewModel.toggleDevice(device) }
                ))
                .labelsHidden()
                .tint(device.type.color)
            }

            Text(device.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)

            Text(device.statusText)
                .font(.caption2)
                .foregroundStyle(device.isOn ? device.type.color : .secondary)

            // スライダー（対応デバイスのみ）
            if device.type.hasSlider && device.isOn {
                Slider(
                    value: Binding(
                        get: { device.value },
                        set: { viewModel.updateDeviceValue(device, value: $0) }
                    ),
                    in: device.type.sliderRange,
                    step: 1
                )
                .tint(device.type.color)
            }
        }
        .padding(10)
        .background(device.isOn ? device.type.color.opacity(0.08) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
