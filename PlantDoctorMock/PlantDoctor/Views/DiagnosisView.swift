import SwiftUI

/// 診断結果を表示する画面
struct DiagnosisView: View {
    let diagnosis: DiagnosisResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    healthScoreCard
                    if diagnosis.hasSymptoms {
                        symptomsSection
                        causesSection
                    }
                    recommendationsSection
                }
                .padding()
            }
            .navigationTitle("診断結果")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Health Score Card

    private var healthScoreCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text(diagnosis.species.emoji)
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text(diagnosis.plantName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(diagnosis.species.scientificName)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.secondary)
                }
            }

            // 健康スコアリング
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 16)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: CGFloat(diagnosis.healthScore) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(diagnosis.healthScore)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("健康スコア")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // ステータスバッジ
            HStack(spacing: 8) {
                Image(systemName: diagnosis.healthStatus.systemImageName)
                Text(diagnosis.healthStatus.rawValue)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(scoreColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(scoreColor.opacity(0.1))
            .clipShape(Capsule())

            Text(diagnosis.summaryText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Symptoms Section

    private var symptomsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("検出された症状")
                    .font(.headline)
            }

            ForEach(diagnosis.symptoms) { symptom in
                symptomRow(symptom)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func symptomRow(_ symptom: PlantSymptom) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(symptom.type.emoji)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(symptom.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(symptom.affectedArea)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(symptom.severity.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(severityColor(symptom.severity).opacity(0.2))
                    .foregroundStyle(severityColor(symptom.severity))
                    .clipShape(Capsule())
            }

            Text(symptom.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Image(systemName: "clock.fill")
                    .font(.caption2)
                Text(symptom.urgencyText)
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Causes Section

    private var causesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.blue)
                Text("推定される原因")
                    .font(.headline)
            }

            ForEach(diagnosis.possibleCauses, id: \.self) { cause in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .padding(.top, 2)
                    Text(cause)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Recommendations Section

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.green)
                Text("ケアのアドバイス")
                    .font(.headline)
            }

            ForEach(Array(diagnosis.careRecommendations.enumerated()), id: \.offset) { index, recommendation in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 24, height: 24)
                        .background(Color.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(Circle())

                    Text(recommendation)
                        .font(.subheadline)
                }
            }

            // 次の水やり
            HStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.blue)
                Text("次の水やり: \(diagnosis.nextWateringDays)日後が目安です")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private var scoreColor: Color {
        if diagnosis.healthScore >= 80 { return .green }
        if diagnosis.healthScore >= 60 { return .yellow }
        return .red
    }

    private func severityColor(_ severity: SymptomSeverity) -> Color {
        switch severity {
        case .mild: .yellow
        case .moderate: .orange
        case .severe: .red
        }
    }
}

#Preview {
    DiagnosisView(diagnosis: DiagnosisResult(
        plantName: "モンステラ",
        species: .monstera,
        healthScore: 72,
        healthStatus: .mildIssue,
        symptoms: [
            PlantSymptom(
                name: "葉先の黄変",
                type: .yellowing,
                severity: .mild,
                description: "下部の葉の先端がわずかに黄色くなっています",
                affectedArea: "下部の葉"
            )
        ],
        possibleCauses: ["水のやりすぎ", "窒素不足"],
        careRecommendations: ["水やりの頻度を減らす", "液体肥料を与える"],
        nextWateringDays: 7,
        diagnosisDate: Date()
    ))
}
