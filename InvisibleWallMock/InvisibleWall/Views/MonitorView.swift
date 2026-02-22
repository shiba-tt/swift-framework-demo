import SwiftUI

struct MonitorView: View {
    let viewModel: InvisibleWallViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    monitoringStatus()
                    radarVisualization()
                    quickStats()
                    recentAlerts()
                }
                .padding()
            }
            .navigationTitle("InvisibleWall")
        }
    }

    // MARK: - Monitoring Status

    private func monitoringStatus() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(viewModel.isMonitoring ? .green : .gray)
                        .frame(width: 10, height: 10)
                    Text(viewModel.isMonitoring ? "監視中" : "停止中")
                        .font(.headline)
                }
                Text("\(viewModel.connectedDeviceCount)台のデバイスを追跡中")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                Task { await viewModel.toggleMonitoring() }
            } label: {
                Text(viewModel.isMonitoring ? "停止" : "開始")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(viewModel.isMonitoring ? .red : .green, in: Capsule())
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Radar Visualization

    private func radarVisualization() -> some View {
        VStack(spacing: 8) {
            Text("空間レーダー")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                // Zone circles
                Circle()
                    .stroke(ZoneType.outer.color.opacity(0.3), lineWidth: 1)
                    .frame(width: 240, height: 240)
                Circle()
                    .stroke(ZoneType.middle.color.opacity(0.4), lineWidth: 1)
                    .frame(width: 160, height: 160)
                Circle()
                    .stroke(ZoneType.inner.color.opacity(0.5), lineWidth: 1)
                    .frame(width: 80, height: 80)

                // Zone fills
                Circle()
                    .fill(ZoneType.outer.color.opacity(0.05))
                    .frame(width: 240, height: 240)
                Circle()
                    .fill(ZoneType.middle.color.opacity(0.08))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(ZoneType.inner.color.opacity(0.12))
                    .frame(width: 80, height: 80)

                // Center (self)
                Image(systemName: "iphone")
                    .font(.title3)
                    .foregroundStyle(.primary)

                // Zone labels
                Text("3m")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                    .offset(x: 45, y: 0)
                Text("10m")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                    .offset(x: 85, y: 0)

                // Device dots
                ForEach(viewModel.devices.filter(\.isConnected)) { device in
                    deviceDot(device)
                }
            }
            .frame(height: 260)
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func deviceDot(_ device: MonitoredDevice) -> some View {
        let offset = deviceOffset(device)
        return VStack(spacing: 2) {
            Image(systemName: device.deviceType.icon)
                .font(.system(size: 12))
                .foregroundStyle(device.currentZone.color)
            Text(device.distanceFormatted)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .offset(x: offset.x, y: offset.y)
    }

    private func deviceOffset(_ device: MonitoredDevice) -> CGPoint {
        guard let distance = device.distance else {
            return CGPoint(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: -100...100))
        }

        let maxRadius: CGFloat = 120
        let normalizedDistance = min(CGFloat(distance) / 15.0, 1.0) * maxRadius

        if let direction = device.direction {
            let x = CGFloat(direction.x) * normalizedDistance
            let y = CGFloat(direction.z) * normalizedDistance
            return CGPoint(x: x, y: y)
        }

        let angle = CGFloat(device.name.hashValue % 360) * .pi / 180
        return CGPoint(
            x: cos(angle) * normalizedDistance,
            y: sin(angle) * normalizedDistance
        )
    }

    // MARK: - Quick Stats

    private func quickStats() -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            quickStatCard(
                icon: "antenna.radiowaves.left.and.right",
                value: "\(viewModel.connectedDeviceCount)",
                label: "接続中",
                color: .blue
            )
            quickStatCard(
                icon: "exclamationmark.triangle.fill",
                value: "\(viewModel.activeAlertCount)",
                label: "アラート",
                color: .red
            )
            quickStatCard(
                icon: "clock.fill",
                value: "\(viewModel.todayEventCount)",
                label: "今日のイベント",
                color: .orange
            )
        }
    }

    private func quickStatCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Recent Alerts

    private func recentAlerts() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最近のイベント")
                .font(.headline)

            ForEach(viewModel.recentEvents(count: 5)) { event in
                HStack(spacing: 10) {
                    Image(systemName: event.eventType.icon)
                        .foregroundStyle(event.eventType.color)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.eventType.displayName)
                            .font(.subheadline)
                        Text(event.device)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(event.timeFormatted)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let d = event.distance {
                            Text(String(format: "%.1fm", d))
                                .font(.caption2)
                                .foregroundStyle(event.zone.color)
                        }
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
