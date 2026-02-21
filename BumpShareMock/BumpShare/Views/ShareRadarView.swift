import SwiftUI

/// 共有レーダー画面：近くのデバイスをレーダー表示し、共有操作を行う
struct ShareRadarView: View {
    let viewModel: BumpShareViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 選択中コンテンツ
                SelectedContentBar(viewModel: viewModel)

                // レーダービュー
                RadarView(viewModel: viewModel)

                // 共有状態表示
                ShareStatusBar(viewModel: viewModel)
            }
            .navigationTitle("BumpShare")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showContentPicker = true
                    } label: {
                        Image(systemName: "doc.badge.plus")
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel.showContentPicker },
                set: { viewModel.showContentPicker = $0 }
            )) {
                ContentPickerSheet(viewModel: viewModel)
            }
            .alert("共有結果", isPresented: Binding(
                get: { viewModel.showShareResult },
                set: { viewModel.showShareResult = $0 }
            )) {
                Button("OK") {}
            } message: {
                Text(viewModel.shareResultMessage ?? "")
            }
        }
    }
}

// MARK: - Selected Content Bar

private struct SelectedContentBar: View {
    let viewModel: BumpShareViewModel

    var body: some View {
        HStack(spacing: 10) {
            if let content = viewModel.selectedContent {
                Image(systemName: content.type.icon)
                    .foregroundStyle(content.type.color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("共有コンテンツ")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text(content.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            } else {
                Image(systemName: "doc.badge.plus")
                    .foregroundStyle(.secondary)
                Text("共有するコンテンツを選択してください")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.showContentPicker = true
            } label: {
                Text("変更")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.cyan.opacity(0.15))
                    .foregroundStyle(.cyan)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Radar View

private struct RadarView: View {
    let viewModel: BumpShareViewModel

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let maxRadius = min(geometry.size.width, geometry.size.height) / 2 - 40

            ZStack {
                // レーダーリング
                ForEach(1...3, id: \.self) { ring in
                    Circle()
                        .stroke(.cyan.opacity(0.15), lineWidth: 1)
                        .frame(
                            width: maxRadius * 2 * CGFloat(ring) / 3,
                            height: maxRadius * 2 * CGFloat(ring) / 3
                        )
                }

                // 距離ラベル
                ForEach([1, 3, 5], id: \.self) { meters in
                    let index = meters == 1 ? 1 : (meters == 3 ? 2 : 3)
                    Text("\(meters)m")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .offset(y: -maxRadius * CGFloat(index) / 3 - 10)
                }

                // 中心（自分）
                VStack(spacing: 4) {
                    Image(systemName: "iphone")
                        .font(.title3)
                        .foregroundStyle(.cyan)
                    Text("あなた")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                // ピアデバイス
                ForEach(viewModel.nearbyManager.nearbyPeers) { peer in
                    PeerDot(peer: peer, viewModel: viewModel)
                        .position(peerPosition(
                            peer: peer,
                            center: center,
                            maxRadius: maxRadius
                        ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }

    private func peerPosition(peer: PeerDevice, center: CGPoint, maxRadius: CGFloat) -> CGPoint {
        let normalizedDistance = min(CGFloat(peer.distance) / 5.0, 1.0) * maxRadius
        let angle = atan2(CGFloat(peer.direction.x), CGFloat(-peer.direction.z))
        return CGPoint(
            x: center.x + normalizedDistance * sin(angle),
            y: center.y - normalizedDistance * cos(angle)
        )
    }
}

private struct PeerDot: View {
    let peer: PeerDevice
    let viewModel: BumpShareViewModel

    var body: some View {
        Button {
            if peer.phase == .readyToShare || peer.phase == .approaching,
               let content = viewModel.selectedContent {
                Task {
                    await viewModel.shareContent(content, to: peer)
                }
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    // パルスアニメーション（共有可能時）
                    if peer.phase == .readyToShare {
                        Circle()
                            .fill(peer.phase.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                    }

                    Circle()
                        .fill(peer.phase.color.gradient)
                        .frame(width: 32, height: 32)

                    Image(systemName: peer.phase.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text(peer.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.primary)

                Text(peer.distanceText)
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .disabled(peer.phase == .searching || peer.phase == .detected)
    }
}

// MARK: - Share Status Bar

private struct ShareStatusBar: View {
    let viewModel: BumpShareViewModel

    var body: some View {
        VStack(spacing: 8) {
            // 共有進捗バー
            if viewModel.nearbyManager.isSharing {
                VStack(spacing: 4) {
                    Text("共有中...")
                        .font(.caption)
                        .fontWeight(.medium)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.quaternary)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.cyan.gradient)
                                .frame(width: geometry.size.width * viewModel.nearbyManager.shareProgress)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal)
            }

            // ステータス情報
            HStack(spacing: 20) {
                StatusItem(
                    icon: "antenna.radiowaves.left.and.right",
                    label: "検出",
                    value: "\(viewModel.nearbyManager.nearbyPeers.count) 台"
                )

                if let closest = viewModel.nearbyManager.closestPeer {
                    StatusItem(
                        icon: "arrow.down.forward.and.arrow.up.backward",
                        label: "最寄り",
                        value: closest.distanceText
                    )
                }

                StatusItem(
                    icon: viewModel.nearbyManager.isSessionActive ? "wifi" : "wifi.slash",
                    label: "UWB",
                    value: viewModel.nearbyManager.isSessionActive ? "有効" : "無効"
                )
            }
            .padding()
            .background(.ultraThinMaterial)

            // 操作ヒント
            HintBar(viewModel: viewModel)
        }
    }
}

private struct StatusItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.cyan)
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

private struct HintBar: View {
    let viewModel: BumpShareViewModel

    private var hintText: String {
        if viewModel.selectedContent == nil {
            return "共有するコンテンツを選択してください"
        }
        if let ready = viewModel.nearbyManager.readyPeer {
            return "\(ready.name) が共有可能です。タップして共有しましょう"
        }
        if viewModel.nearbyManager.nearbyPeers.isEmpty {
            return "近くのデバイスを検索中..."
        }
        return "デバイスを相手に向けて近づけてください"
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "lightbulb.fill")
                .font(.caption2)
                .foregroundStyle(.yellow)
            Text(hintText)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
}

// MARK: - Content Picker Sheet

private struct ContentPickerSheet: View {
    let viewModel: BumpShareViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(ShareableContentType.allCases) { type in
                    let contents = viewModel.shareableContents.filter { $0.type == type }
                    if !contents.isEmpty {
                        Section(type.rawValue) {
                            ForEach(contents) { content in
                                Button {
                                    viewModel.selectedContent = content
                                    viewModel.showContentPicker = false
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: content.type.icon)
                                            .foregroundStyle(content.type.color)
                                            .frame(width: 24)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(content.title)
                                                .font(.subheadline)
                                                .foregroundStyle(.primary)
                                            Text(content.subtitle)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        if viewModel.selectedContent?.id == content.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.cyan)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("共有コンテンツを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.showContentPicker = false
                    }
                }
            }
        }
    }
}
