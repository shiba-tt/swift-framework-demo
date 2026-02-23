import SwiftUI

struct PluginDetailView: View {
    let plugin: AUPlugin
    @Bindable var viewModel: AUBazaarViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    infoGrid
                    descriptionSection
                    tagsSection
                    parametersPreview
                    auComponentSection
                    reviewsSection
                    actionsSection
                }
                .padding()
            }
            .navigationTitle(plugin.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        viewModel.showPluginDetail = false
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.toggleFavorite(plugin)
                    } label: {
                        Image(systemName: viewModel.isFavorite(plugin) ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.isFavorite(plugin) ? .red : .secondary)
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 16) {
            Text(plugin.category.emoji)
                .font(.system(size: 44))
                .frame(width: 72, height: 72)
                .background(plugin.category.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(plugin.name)
                    .font(.title2.bold())
                Text(plugin.manufacturer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.orange)
                        Text(plugin.ratingText)
                            .bold()
                    }
                    .font(.subheadline)

                    Text("(\(plugin.reviewCount)件)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(plugin.category.rawValue)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(plugin.category.color.opacity(0.12), in: Capsule())
                        .foregroundStyle(plugin.category.color)
                }
            }

            Spacer()
        }
    }

    // MARK: - Info Grid

    private var infoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            infoCard("CPU負荷", value: plugin.cpuLoadText, icon: "cpu", color: plugin.cpuLoad > 3 ? .red : .green)
            infoCard("レイテンシ", value: plugin.latencyText, icon: "clock", color: plugin.latencyMs > 0 ? .orange : .green)
            infoCard("パラメータ", value: "\(plugin.parameterCount)", icon: "slider.horizontal.3", color: .blue)
            infoCard("プリセット", value: "\(plugin.presetCount)", icon: "archivebox", color: .purple)
            infoCard("バージョン", value: plugin.version, icon: "number", color: .gray)
            infoCard("UI", value: plugin.hasCustomUI ? "カスタム" : "汎用", icon: plugin.hasCustomUI ? "paintbrush" : "rectangle.3.group", color: .indigo)
        }
    }

    private func infoCard(_ title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.caption.bold())
                .lineLimit(1)
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("概要", systemImage: "doc.text")
                .font(.headline)
            Text(plugin.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Tags

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("タグ", systemImage: "tag")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(plugin.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(.systemGray5), in: Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Parameters Preview

    private var parametersPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("パラメータ (プレビュー)", systemImage: "slider.horizontal.3")
                    .font(.headline)
                Spacer()
                if plugin.hasCustomUI {
                    Label("AUViewController", systemImage: "paintbrush")
                        .font(.caption2)
                        .foregroundStyle(.indigo)
                } else {
                    Label("AUGenericViewController", systemImage: "rectangle.3.group")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            let params = AUPlugin.sampleParameters(for: plugin)
            ForEach(params) { param in
                HStack {
                    Text(param.name)
                        .font(.caption)
                    Spacer()

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(.systemGray4))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(plugin.category.color)
                                .frame(width: geo.size.width * CGFloat(param.normalizedValue))
                        }
                    }
                    .frame(width: 100, height: 10)

                    Text(param.displayValue)
                        .font(.caption2.monospacedDigit())
                        .frame(width: 70, alignment: .trailing)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - AU Component

    private var auComponentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("AudioComponent 情報", systemImage: "cpu")
                .font(.headline)

            Group {
                componentRow("タイプ", value: plugin.category.auType)
                componentRow("タイプ名", value: plugin.category.auTypeDescription)
                componentRow("サブタイプ", value: String(plugin.name.prefix(4)).lowercased())
                componentRow("メーカー", value: String(plugin.manufacturer.prefix(4)))
                componentRow("サンドボックス", value: "Yes")
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }

    private func componentRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.bold().monospaced())
        }
    }

    // MARK: - Reviews

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("レビュー", systemImage: "bubble.left.and.bubble.right")
                .font(.headline)

            ForEach(PluginReview.samples(for: plugin.id)) { review in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(review.ratingStars)
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Spacer()
                        Text(review.dateText)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Text(review.comment)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text(review.author)
                            .font(.caption2.bold())
                        Spacer()
                        Label("\(review.helpfulCount)", systemImage: "hand.thumbsup")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.loadPluginToSlot(plugin, slot: .slotA)
                viewModel.showPluginDetail = false
                viewModel.selectedTab = .compare
            } label: {
                HStack {
                    Image(systemName: "a.circle.fill")
                    Text("スロット A にロード")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
            }

            Button {
                viewModel.loadPluginToSlot(plugin, slot: .slotB)
                viewModel.showPluginDetail = false
                viewModel.selectedTab = .compare
            } label: {
                HStack {
                    Image(systemName: "b.circle.fill")
                    Text("スロット B にロード")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
