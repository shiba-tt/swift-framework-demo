import SwiftUI

struct NodeDetailView: View {
    @Bindable var viewModel: SoundForgeViewModel
    let node: AudioNode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    nodeHeader
                    if !node.parameters.isEmpty {
                        parametersSection
                    }
                    connectionsSection
                    auv3Section
                }
                .padding()
            }
            .navigationTitle(node.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }

    // MARK: - Node Header

    private var nodeHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(node.colorName).opacity(0.15))
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color(node.colorName), lineWidth: 2))

                Text(node.emoji)
                    .font(.largeTitle)
            }

            VStack(spacing: 4) {
                Text(node.name)
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 8) {
                    Label(node.type.category.rawValue, systemImage: node.type.category.systemImage)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(node.isEnabled ? "有効" : "無効")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            (node.isEnabled ? Color.green : .gray).opacity(0.2),
                            in: Capsule()
                        )
                }
            }

            // トグルボタン
            Button {
                viewModel.toggleNode(node)
            } label: {
                Label(
                    node.isEnabled ? "無効にする" : "有効にする",
                    systemImage: node.isEnabled ? "pause.circle" : "play.circle"
                )
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(node.isEnabled ? .gray : .green)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Parameters Section

    private var parametersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("パラメータ")
                .font(.headline)

            ForEach(Array(node.parameters.enumerated()), id: \.element.id) { index, param in
                VStack(spacing: 8) {
                    HStack {
                        Text(param.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text(param.formattedValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }

                    Slider(
                        value: Binding(
                            get: { param.value },
                            set: { viewModel.updateParameter(nodeID: node.id, parameterIndex: index, value: $0) }
                        ),
                        in: param.range
                    )
                    .tint(.orange)
                }
                .padding(.vertical, 4)

                if index < node.parameters.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Connections Section

    private var connectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("接続")
                .font(.headline)

            if node.connections.isEmpty {
                HStack {
                    Image(systemName: "arrow.triangle.branch")
                        .foregroundStyle(.secondary)
                    Text("出力先なし")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(node.connections, id: \.self) { connID in
                    if let target = viewModel.nodes.first(where: { $0.id == connID }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text(target.emoji)
                            Text(target.name)
                                .font(.subheadline)

                            Spacer()

                            Button {
                                viewModel.disconnectNodes(from: node.id, to: connID)
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - AUv3 Section

    private var auv3Section: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AUv3 プラグイン UI")
                .font(.headline)

            VStack(spacing: 12) {
                Image(systemName: "puzzlepiece.extension")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)

                Text("CoreAudioKit による\nAUv3 プラグイン UI を表示")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text("AUViewController / AUGenericViewController")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NodeDetailView(
        viewModel: SoundForgeViewModel(),
        node: AudioNode(name: "Reverb", type: .reverb)
    )
}
