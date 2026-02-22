import SwiftUI

/// 名刺スキャン画面
struct ScanView: View {
    let viewModel: ContextCardsViewModel
    @State private var isScanning = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // カメラプレビュー風のモック
                CameraPreviewMock(isScanning: isScanning)

                // 分析進捗
                if viewModel.isAnalyzing {
                    VStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.regular)
                        Text(viewModel.analysisProgress ?? "分析中...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }

                // スキャン結果プレビュー
                if let scan = viewModel.currentScanResult {
                    ScanResultPreview(scan: scan)
                }

                // アクションボタン
                VStack(spacing: 12) {
                    if viewModel.currentScanResult != nil {
                        Button {
                            Task { await viewModel.analyzeAndSave() }
                        } label: {
                            Label("AI で分析して保存", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                        .disabled(viewModel.isAnalyzing)

                        Button {
                            viewModel.currentScanResult = nil
                        } label: {
                            Text("やり直す")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button {
                            isScanning = true
                            Task {
                                await viewModel.scanBusinessCard()
                                isScanning = false
                            }
                        } label: {
                            Label("名刺を撮影", systemImage: "camera.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                        .disabled(isScanning)
                    }
                }
                .padding(.horizontal)

                // エラー表示
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("名刺スキャン")
        }
    }
}

// MARK: - Camera Preview Mock

private struct CameraPreviewMock: View {
    let isScanning: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.indigo.opacity(0.3), lineWidth: 2)
                )

            if isScanning {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.white)
                    Text("名刺を検出中...")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("名刺をカメラにかざしてください")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            // 四隅のガイド
            VStack {
                HStack {
                    CornerGuide(rotation: 0)
                    Spacer()
                    CornerGuide(rotation: 90)
                }
                Spacer()
                HStack {
                    CornerGuide(rotation: 270)
                    Spacer()
                    CornerGuide(rotation: 180)
                }
            }
            .padding(12)
        }
        .frame(height: 220)
        .padding(.horizontal)
    }
}

private struct CornerGuide: View {
    let rotation: Double

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 20))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 20, y: 0))
        }
        .stroke(.indigo, lineWidth: 2)
        .frame(width: 20, height: 20)
        .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Scan Result Preview

private struct ScanResultPreview: View {
    let scan: ScanResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text.viewfinder")
                    .foregroundStyle(.indigo)
                Text("OCR 読み取り結果")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                if let name = scan.detectedName {
                    Label(name, systemImage: "person.fill")
                        .font(.subheadline)
                }
                if let company = scan.detectedCompany {
                    Label(company, systemImage: "building.2.fill")
                        .font(.subheadline)
                }
                if let phone = scan.detectedPhone {
                    Label(phone, systemImage: "phone.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let email = scan.detectedEmail {
                    Label(email, systemImage: "envelope.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.indigo.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}
