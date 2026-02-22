import SwiftUI

struct ZonesView: View {
    let viewModel: InvisibleWallViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    zoneOverview()
                    ForEach(viewModel.zones) { zone in
                        zoneCard(zone)
                    }
                }
                .padding()
            }
            .navigationTitle("ゾーン設定")
        }
    }

    // MARK: - Zone Overview

    private func zoneOverview() -> some View {
        VStack(spacing: 12) {
            Text("距離ゾーン設計")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Concentric zone diagram
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(ZoneType.outer.color.opacity(0.1))
                    .frame(height: 140)
                    .overlay(
                        Text("Zone 3: 遠距離 (10m+)")
                            .font(.system(size: 10))
                            .foregroundStyle(ZoneType.outer.color)
                            .padding(.top, 8),
                        alignment: .top
                    )

                RoundedRectangle(cornerRadius: 10)
                    .fill(ZoneType.middle.color.opacity(0.15))
                    .frame(width: 260, height: 100)
                    .overlay(
                        Text("Zone 2: 中距離 (3~10m)")
                            .font(.system(size: 10))
                            .foregroundStyle(ZoneType.middle.color)
                            .padding(.top, 6),
                        alignment: .top
                    )

                RoundedRectangle(cornerRadius: 8)
                    .fill(ZoneType.inner.color.opacity(0.2))
                    .frame(width: 160, height: 60)
                    .overlay(
                        Text("Zone 1: 近距離 (0~3m)")
                            .font(.system(size: 10))
                            .foregroundStyle(ZoneType.inner.color)
                    )
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Zone Card

    private func zoneCard(_ zone: BoundaryZone) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: zone.zoneType.icon)
                    .font(.title2)
                    .foregroundStyle(zone.zoneType.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(zone.name)
                        .font(.headline)
                    Text(zone.radiusLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(zone.isActive ? .green : .gray)
                        .frame(width: 8, height: 8)
                    Text(zone.isActive ? "有効" : "無効")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("トリガーアクション")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                FlowLayout(spacing: 6) {
                    ForEach(zone.actions) { action in
                        HStack(spacing: 4) {
                            Image(systemName: action.icon)
                                .font(.system(size: 10))
                            Text(action.displayName)
                                .font(.caption)
                        }
                        .foregroundStyle(action.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(action.color.opacity(0.1), in: Capsule())
                    }
                }
            }

            // Devices in this zone
            let devicesInZone = viewModel.devicesByZone(zone.zoneType)
            if !devicesInZone.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("このゾーンのデバイス (\(devicesInZone.count))")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(devicesInZone) { device in
                        HStack(spacing: 8) {
                            Image(systemName: device.deviceType.icon)
                                .font(.caption)
                                .foregroundStyle(zone.zoneType.color)
                            Text(device.name)
                                .font(.caption)
                            Spacer()
                            Text(device.distanceFormatted)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}
