import SwiftUI

/// 登録済み植物の一覧画面
struct PlantListView: View {
    @Bindable var viewModel: PlantDoctorViewModel
    @State private var newPlantName = ""
    @State private var newPlantSpecies: PlantSpecies = .monstera

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCard
                    plantsSection
                    tipsSection
                }
                .padding()
            }
            .navigationTitle("マイ植物")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddPlant = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddPlant) {
                addPlantSheet
            }
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                summaryItem(
                    value: "\(viewModel.plants.count)",
                    label: "登録数",
                    systemImage: "leaf.fill",
                    color: .green
                )
                summaryItem(
                    value: "\(viewModel.averageHealthScore)",
                    label: "平均健康度",
                    systemImage: "heart.fill",
                    color: .pink
                )
                summaryItem(
                    value: "\(viewModel.plantsNeedingWater)",
                    label: "水やり必要",
                    systemImage: "drop.fill",
                    color: .blue
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryItem(
        value: String,
        label: String,
        systemImage: String,
        color: Color
    ) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Plants Section

    private var plantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("育てている植物")
                .font(.headline)

            if viewModel.plants.isEmpty {
                emptyPlantView
            } else {
                ForEach(viewModel.plants) { plant in
                    plantRow(plant)
                }
            }
        }
    }

    private var emptyPlantView: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.arrow.triangle.circlepath")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("まだ植物が登録されていません")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("植物を追加") {
                viewModel.showingAddPlant = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func plantRow(_ plant: Plant) -> some View {
        HStack(spacing: 12) {
            // 植物のアイコン
            Text(plant.species.emoji)
                .font(.largeTitle)
                .frame(width: 56, height: 56)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // 植物情報
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(plant.nickname)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(plant.healthStatus.emoji)
                }

                Text(plant.species.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Label(plant.wateringStatusText, systemImage: "drop.fill")
                        .font(.caption2)
                        .foregroundStyle(plant.needsWatering ? .red : .blue)
                }
            }

            Spacer()

            // 健康スコア
            VStack(spacing: 2) {
                Text("\(plant.healthScore)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(healthColor(for: plant.healthScore))
                Text("健康度")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contextMenu {
            Button {
                Task { await viewModel.diagnosePlant(plant) }
            } label: {
                Label("診断する", systemImage: "magnifyingglass")
            }

            Button {
                viewModel.recordWatering(for: plant)
            } label: {
                Label("水やり記録", systemImage: "drop.fill")
            }

            Button(role: .destructive) {
                viewModel.removePlant(plant)
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
    }

    // MARK: - Tips Section

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ケアヒント")
                .font(.headline)

            ForEach(viewModel.careTips.prefix(3)) { tip in
                HStack(spacing: 12) {
                    Text(tip.category.emoji)
                        .font(.title3)
                        .frame(width: 36, height: 36)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(tip.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            if let season = tip.season {
                                Text(season.emoji)
                                    .font(.caption)
                            }
                        }
                        Text(tip.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Add Plant Sheet

    private var addPlantSheet: some View {
        NavigationStack {
            Form {
                Section("種類を選択") {
                    Picker("種類", selection: $newPlantSpecies) {
                        ForEach(PlantSpecies.allCases, id: \.rawValue) { species in
                            HStack {
                                Text(species.emoji)
                                Text(species.rawValue)
                            }
                            .tag(species)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("ニックネーム") {
                    TextField("例: もんちゃん", text: $newPlantName)
                }

                Section {
                    HStack {
                        Text("学名")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(newPlantSpecies.scientificName)
                            .italic()
                    }
                    HStack {
                        Text("水やり間隔")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(newPlantSpecies.wateringIntervalDays)日ごと")
                    }
                    HStack {
                        Text("推奨の明るさ")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(newPlantSpecies.lightRequirement)
                    }
                }
            }
            .navigationTitle("植物を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        viewModel.showingAddPlant = false
                        newPlantName = ""
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        viewModel.addPlant(
                            name: newPlantSpecies.rawValue,
                            species: newPlantSpecies,
                            nickname: newPlantName
                        )
                        viewModel.showingAddPlant = false
                        newPlantName = ""
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func healthColor(for score: Int) -> Color {
        if score >= 80 { return .green }
        if score >= 60 { return .yellow }
        return .red
    }
}

#Preview {
    PlantListView(viewModel: PlantDoctorViewModel())
}
