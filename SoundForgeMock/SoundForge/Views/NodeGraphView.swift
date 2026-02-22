import SwiftUI

struct NodeGraphView: View {
    @Bindable var viewModel: SoundForgeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    engineStatusBar
                    if viewModel.nodes.isEmpty {
                        emptyState
                    } else {
                        nodeGraphCanvas
                        nodeListSection
                    }
                    quickTemplatesSection
                }
                .padding()
            }
            .navigationTitle("SoundForge")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddNode = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.toggleEngine() }
                    } label: {
                        Image(systemName: viewModel.isEngineRunning ? "stop.circle.fill" : "play.circle.fill")
                            .foregroundStyle(viewModel.isEngineRunning ? .red : .green)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddNode) {
                AddNodeView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingNodeDetail) {
                if let node = viewModel.selectedNode {
                    NodeDetailView(viewModel: viewModel, node: node)
                }
            }
        }
    }

    // MARK: - Engine Status Bar

    private var engineStatusBar: some View {
        HStack(spacing: 16) {
            // ステータスインジケータ
            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.isEngineRunning ? .green : .red)
                    .frame(width: 8, height: 8)
                Text(viewModel.isEngineRunning ? "稼働中" : "停止")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            Divider().frame(height: 20)

            // レベルメーター
            VStack(spacing: 2) {
                LevelBar(level: CGFloat(viewModel.inputLevel), label: "IN")
                LevelBar(level: CGFloat(viewModel.outputLevel), label: "OUT")
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 20)

            // テクニカル情報
            VStack(alignment: .trailing, spacing: 2) {
                Text(viewModel.formattedLatency)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(viewModel.formattedSampleRate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "point.3.connected.trianglepath.dotted")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("ノードグラフが空です")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("「＋」ボタンでノードを追加するか、\nクイックテンプレートを選択してください")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    // MARK: - Node Graph Canvas

    private var nodeGraphCanvas: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("シグナルフロー")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.nodes.count) ノード")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(viewModel.nodes.enumerated()), id: \.element.id) { index, node in
                        nodeCard(node)
                            .onTapGesture {
                                viewModel.selectNode(node)
                            }

                        if index < viewModel.nodes.count - 1 {
                            connectionArrow(from: node)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func nodeCard(_ node: AudioNode) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(node.isEnabled ? Color(node.colorName).opacity(0.15) : .gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                node.isEnabled ? Color(node.colorName) : .gray,
                                lineWidth: viewModel.selectedNode?.id == node.id ? 2.5 : 1
                            )
                    )

                VStack(spacing: 4) {
                    Text(node.emoji)
                        .font(.title2)
                    Text(node.name)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
            }
            .opacity(node.isEnabled ? 1 : 0.5)

            // パラメータプレビュー
            if let firstParam = node.parameters.first {
                Text(firstParam.formattedValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func connectionArrow(from node: AudioNode) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(node.isEnabled ? .orange : .gray.opacity(0.3))
                .frame(width: 24, height: 2)
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(node.isEnabled ? .orange : .gray.opacity(0.3))
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 20)
    }

    // MARK: - Node List Section

    private var nodeListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ノード一覧")
                .font(.headline)

            ForEach(viewModel.nodes) { node in
                nodeListRow(node)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func nodeListRow(_ node: AudioNode) -> some View {
        HStack(spacing: 12) {
            Text(node.emoji)
                .font(.title3)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(node.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(node.type.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // パラメータ概要
            if !node.parameters.isEmpty {
                Text("\(node.parameters.count) パラメータ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // 有効/無効トグル
            Button {
                viewModel.toggleNode(node)
            } label: {
                Image(systemName: node.isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(node.isEnabled ? .green : .gray)
            }

            // 削除ボタン
            Button(role: .destructive) {
                viewModel.removeNode(node)
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            viewModel.selectNode(node)
        }
    }

    // MARK: - Quick Templates Section

    private var quickTemplatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("クイックテンプレート")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(QuickTemplate.allCases, id: \.rawValue) { template in
                    Button {
                        viewModel.loadQuickTemplate(template)
                    } label: {
                        VStack(spacing: 8) {
                            Text(template.emoji)
                                .font(.title2)
                            Text(template.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text("\(template.nodeTypes.count) ノード")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - LevelBar

struct LevelBar: View {
    let level: CGFloat
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 24)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 2)
                        .fill(levelColor)
                        .frame(width: geometry.size.width * min(level, 1))
                }
            }
            .frame(height: 6)
        }
    }

    private var levelColor: Color {
        if level > 0.9 { return .red }
        if level > 0.7 { return .yellow }
        return .green
    }
}

#Preview {
    NodeGraphView(viewModel: SoundForgeViewModel())
}
