import SwiftUI

struct ScanView: View {
    @Bindable var viewModel: CookSnapViewModel
    @State private var isScanning = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    cameraSection
                    if !viewModel.detectedIngredients.isEmpty {
                        ingredientsSection
                        generateButton
                    }
                }
                .padding()
            }
            .navigationTitle("CookSnap")
        }
    }

    // MARK: - Camera Section

    private var cameraSection: some View {
        VStack(spacing: 16) {
            // カメラプレビュー（モック）
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.85))
                    .frame(height: 220)

                if isScanning {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(.white)
                        Text("食材を認識中...")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                } else if viewModel.detectedIngredients.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.6))
                        Text("冷蔵庫の中身を撮影しましょう")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.green)
                        Text("\(viewModel.detectedIngredients.count) 個の食材を認識しました")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                }
            }

            Button {
                Task {
                    isScanning = true
                    await viewModel.scanFridge()
                    isScanning = false
                }
            } label: {
                Label(
                    viewModel.detectedIngredients.isEmpty ? "撮影する" : "もう一度撮影",
                    systemImage: "camera.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(isScanning)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Ingredients Section

    private var ingredientsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("認識された食材")
                    .font(.headline)
                Spacer()
                Button {
                    viewModel.toggleSelectAll()
                } label: {
                    Text(viewModel.selectedIngredients.count == viewModel.detectedIngredients.count
                         ? "全解除" : "全選択")
                        .font(.caption)
                }
            }

            ForEach(viewModel.ingredientsByCategory, id: \.category) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Label(group.category.rawValue, systemImage: group.category.systemImageName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(group.ingredients) { ingredient in
                            ingredientChip(ingredient)
                        }
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func ingredientChip(_ ingredient: Ingredient) -> some View {
        let isSelected = viewModel.selectedIngredients.contains(ingredient)

        return Button {
            viewModel.toggleIngredient(ingredient)
        } label: {
            HStack(spacing: 4) {
                Text(ingredient.emoji)
                Text(ingredient.name)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? .orange.opacity(0.15) : .gray.opacity(0.1),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? .orange : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            Task {
                await viewModel.generateRecipe()
            }
        } label: {
            if viewModel.isGenerating {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.white)
                    Text(viewModel.generationProgress ?? "レシピを考案中...")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            } else {
                Label("レシピを生成 (\(viewModel.selectedIngredients.count)食材)", systemImage: "wand.and.stars")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .disabled(viewModel.selectedIngredients.isEmpty || viewModel.isGenerating)
    }
}

// MARK: - FlowLayout

/// タグのような折り返しレイアウト
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
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

#Preview {
    ScanView(viewModel: CookSnapViewModel())
}
