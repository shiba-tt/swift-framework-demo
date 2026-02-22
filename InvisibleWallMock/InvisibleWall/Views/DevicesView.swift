import SwiftUI

struct DevicesView: View {
    let viewModel: InvisibleWallViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    deviceSummary()
                    ForEach(viewModel.devices) { device in
                        deviceCard(device)
                    }
                }
                .padding()
            }
            .navigationTitle("デバイス管理")
            .refreshable {
                await viewModel.refreshDevices()
            }
        }
    }

    // MARK: - Device Summary

    private func deviceSummary() -> some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("\(viewModel.devices.count)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("登録デバイス")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            VStack(spacing: 4) {
                Text("\(viewModel.connectedDeviceCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                Text("接続中")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            VStack(spacing: 4) {
                Text("\(viewModel.devices.count - viewModel.connectedDeviceCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                Text("未接続")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Device Card

    private func deviceCard(_ device: MonitoredDevice) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(device.isConnected ? device.currentZone.color.opacity(0.2) : .gray.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: device.deviceType.icon)
                        .font(.title3)
                        .foregroundStyle(device.isConnected ? device.currentZone.color : .gray)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(device.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        if !device.isConnected {
                            Text("未接続")
                                .font(.system(size: 9))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.red.opacity(0.1), in: Capsule())
                        }
                    }
                    Text(device.deviceType.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if device.isConnected {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(device.distanceFormatted)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(device.currentZone.color)
                        Text(device.currentZone.displayName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if device.isConnected {
                HStack(spacing: 16) {
                    detailItem(icon: "scope", label: "ゾーン", value: device.currentZone.displayName, color: device.currentZone.color)
                    detailItem(icon: "ruler", label: "距離", value: device.distanceFormatted, color: .blue)
                    detailItem(icon: "clock", label: "最終確認", value: device.timeSinceLastSeen, color: .gray)
                }

                // Direction indicator
                if let direction = device.direction {
                    HStack(spacing: 8) {
                        Image(systemName: "location.north.fill")
                            .rotationEffect(.radians(Double(atan2(direction.x, -direction.z))))
                            .foregroundStyle(.blue)
                        Text("方向: x=\(String(format: "%.2f", direction.x)), z=\(String(format: "%.2f", direction.z))")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            } else {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(.orange)
                    Text("最終確認: \(device.timeSinceLastSeen)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func detailItem(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.caption2)
                .fontWeight(.medium)
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
