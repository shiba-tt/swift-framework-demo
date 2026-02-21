import SwiftUI

/// 植物撮影・診断開始画面
struct CaptureView: View {
    @Bindable var viewModel: PlantDoctorViewModel
    @State private var selectedSpecies: PlantSpecies = .monstera

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    cameraPreviewArea
                    plantSelectorSection
                    diagnosisInfoSection
                }
                .padding()
            }
            .navigationTitle("診断")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Camera Preview Area

    private var cameraPreviewArea: some View {
        VStack(spacing: 16) {
            // モックのカメラプレビュー
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .frame(height: 280)

                if viewModel.isAnalyzing {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("分析中...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("植物をカメラに映してください")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("実際のアプリではカメラ映像がここに表示されます")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            // 撮影・診断ボタン
            if !viewModel.plants.isEmpty {
                Button {
                    Task {
                        if let plant = viewModel.plants.first(where: { $0.species == selectedSpecies })
                            ?? viewModel.plants.first {
                            await viewModel.diagnosePlant(plant)
                        }
                    }
                } label: {
                    Label("診断を開始", systemImage: "magnifyingglass")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(viewModel.isAnalyzing)
            }
        }
    }

    // MARK: - Plant Selector

    private var plantSelectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("登録済み植物から選択")
                .font(.headline)

            if viewModel.plants.isEmpty {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                    Text("マイ植物タブで植物を登録してください")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.plants) { plant in
                            plantChip(plant)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func plantChip(_ plant: Plant) -> some View {
        let isSelected = plant.species == selectedSpecies

        return Button {
            selectedSpecies = plant.species
        } label: {
            VStack(spacing: 6) {
                Text(plant.species.emoji)
                    .font(.title2)
                Text(plant.nickname)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
            }
            .frame(width: 72, height: 72)
            .background(isSelected ? Color.green.opacity(0.2) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Diagnosis Info

    private var diagnosisInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI 診断について")
                .font(.headline)

            infoRow(
                systemImage: "cpu",
                title: "オンデバイス処理",
                description: "Core ML を使用し、すべての分析はデバイス上で実行。写真データは外部に送信されません。"
            )
            infoRow(
                systemImage: "eye.fill",
                title: "Vision で画像解析",
                description: "植物の種類を識別し、葉の変色・斑点・害虫被害などの症状を自動検出します。"
            )
            infoRow(
                systemImage: "brain",
                title: "Foundation Models で診断",
                description: "検出された症状をもとに、原因の推定とケアアドバイスを自然言語で生成します。"
            )
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func infoRow(systemImage: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.green)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CaptureView(viewModel: PlantDoctorViewModel())
}
