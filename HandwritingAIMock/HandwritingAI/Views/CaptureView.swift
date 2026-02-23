import SwiftUI

struct CaptureView: View {
    @Bindable var viewModel: HandwritingAIViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                cameraPreview
                statusArea
                captureControls
            }
            .padding()
            .navigationTitle("ノート撮影")
        }
    }

    // MARK: - Camera Preview

    @ViewBuilder
    private var cameraPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.viewfinder")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("ノートをフレーム内に収めてください")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

            // フレームガイド
            RoundedRectangle(cornerRadius: 8)
                .stroke(.teal.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                .padding(24)

            // コーナーマーカー
            GeometryReader { geo in
                let inset: CGFloat = 20
                let markerSize: CGFloat = 24
                let lineWidth: CGFloat = 3

                Group {
                    // 左上
                    cornerMarker(at: CGPoint(x: inset, y: inset), corner: .topLeft, size: markerSize, lineWidth: lineWidth)
                    // 右上
                    cornerMarker(at: CGPoint(x: geo.size.width - inset, y: inset), corner: .topRight, size: markerSize, lineWidth: lineWidth)
                    // 左下
                    cornerMarker(at: CGPoint(x: inset, y: geo.size.height - inset), corner: .bottomLeft, size: markerSize, lineWidth: lineWidth)
                    // 右下
                    cornerMarker(at: CGPoint(x: geo.size.width - inset, y: geo.size.height - inset), corner: .bottomRight, size: markerSize, lineWidth: lineWidth)
                }
            }
        }
        .frame(maxHeight: 400)
    }

    @ViewBuilder
    private func cornerMarker(at point: CGPoint, corner: Corner, size: CGFloat, lineWidth: CGFloat) -> some View {
        Path { path in
            switch corner {
            case .topLeft:
                path.move(to: CGPoint(x: point.x, y: point.y + size))
                path.addLine(to: point)
                path.addLine(to: CGPoint(x: point.x + size, y: point.y))
            case .topRight:
                path.move(to: CGPoint(x: point.x - size, y: point.y))
                path.addLine(to: point)
                path.addLine(to: CGPoint(x: point.x, y: point.y + size))
            case .bottomLeft:
                path.move(to: CGPoint(x: point.x, y: point.y - size))
                path.addLine(to: point)
                path.addLine(to: CGPoint(x: point.x + size, y: point.y))
            case .bottomRight:
                path.move(to: CGPoint(x: point.x - size, y: point.y))
                path.addLine(to: point)
                path.addLine(to: CGPoint(x: point.x, y: point.y - size))
            }
        }
        .stroke(.teal, lineWidth: lineWidth)
    }

    private enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight
    }

    // MARK: - Status

    @ViewBuilder
    private var statusArea: some View {
        if viewModel.isCapturing {
            VStack(spacing: 8) {
                HStack {
                    Text("認識処理中...")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(Int(viewModel.ocrManager.progress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: viewModel.ocrManager.progress)
                    .tint(.teal)

                HStack(spacing: 16) {
                    progressStep("前処理", done: viewModel.ocrManager.progress > 0.25)
                    progressStep("OCR", done: viewModel.ocrManager.progress > 0.60)
                    progressStep("図形検出", done: viewModel.ocrManager.progress > 0.85)
                    progressStep("分類", done: viewModel.ocrManager.progress >= 1.0)
                }
                .font(.caption2)
            }
            .padding()
            .background(.teal.opacity(0.05), in: .rect(cornerRadius: 12))
        } else {
            HStack(spacing: 20) {
                featureBadge(icon: "text.viewfinder", label: "手書き認識")
                featureBadge(icon: "arrow.triangle.branch", label: "構造解析")
                featureBadge(icon: "brain", label: "AI 分析")
            }
        }
    }

    @ViewBuilder
    private func progressStep(_ label: String, done: Bool) -> some View {
        HStack(spacing: 2) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? .green : .secondary)
            Text(label)
                .foregroundStyle(done ? .primary : .secondary)
        }
    }

    @ViewBuilder
    private func featureBadge(icon: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.teal)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Controls

    @ViewBuilder
    private var captureControls: some View {
        HStack(spacing: 40) {
            // フォトライブラリ
            Button {} label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 50, height: 50)
            }

            // シャッター
            Button {
                Task {
                    await viewModel.captureAndRecognize()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.teal)
                        .frame(width: 72, height: 72)
                    Circle()
                        .stroke(.white, lineWidth: 3)
                        .frame(width: 62, height: 62)
                    if viewModel.isCapturing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "text.viewfinder")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
            }
            .disabled(viewModel.isCapturing)

            // 連続スキャン
            Button {} label: {
                Image(systemName: "rectangle.stack.badge.plus")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 50, height: 50)
            }
        }
    }
}

#Preview {
    CaptureView(viewModel: HandwritingAIViewModel())
}
