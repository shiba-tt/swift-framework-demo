import Foundation

/// 植物の分類・診断を行うマネージャー
/// Core ML + Vision で画像分析を行い、Foundation Models でアドバイスを生成する
@MainActor
@Observable
final class PlantClassificationManager {

    // MARK: - Singleton

    static let shared = PlantClassificationManager()
    private init() {}

    // MARK: - State

    private(set) var isAnalyzing = false
    private(set) var lastError: String?

    // MARK: - Classification

    /// 植物画像を分析して診断結果を返す（モック）
    /// 実際のアプリでは VNCoreMLRequest を使用して画像分類を行う
    func analyzePlant(species: PlantSpecies) async -> DiagnosisResult {
        isAnalyzing = true
        lastError = nil

        // 実際のアプリでは以下のようなパイプラインを実行:
        // 1. VNCoreMLRequest で植物分類モデルを実行
        // 2. VNCoreMLRequest で症状検出モデルを実行
        // 3. Foundation Models で診断アドバイスを生成

        // モックデータの生成を模擬
        try? await Task.sleep(for: .seconds(1.5))

        let result = generateMockDiagnosis(for: species)
        isAnalyzing = false
        return result
    }

    // MARK: - Mock Data Generation

    /// モックの診断結果を生成する
    private func generateMockDiagnosis(for species: PlantSpecies) -> DiagnosisResult {
        let healthScore = Int.random(in: 55...95)
        let symptoms = generateMockSymptoms(healthScore: healthScore)

        let healthStatus: PlantHealthStatus
        if healthScore >= 80 {
            healthStatus = .healthy
        } else if healthScore >= 60 {
            healthStatus = .mildIssue
        } else {
            healthStatus = .moderate
        }

        let causes = generateCauses(for: symptoms)
        let recommendations = generateRecommendations(for: species, symptoms: symptoms)

        return DiagnosisResult(
            plantName: species.rawValue,
            species: species,
            healthScore: healthScore,
            healthStatus: healthStatus,
            symptoms: symptoms,
            possibleCauses: causes,
            careRecommendations: recommendations,
            nextWateringDays: species.wateringIntervalDays,
            diagnosisDate: Date()
        )
    }

    /// モックの症状を生成する
    private func generateMockSymptoms(healthScore: Int) -> [PlantSymptom] {
        if healthScore >= 85 {
            return []
        }

        var symptoms: [PlantSymptom] = []

        if healthScore < 80 {
            symptoms.append(PlantSymptom(
                name: "葉先の黄変",
                type: .yellowing,
                severity: .mild,
                description: "下部の葉の先端がわずかに黄色くなっています",
                affectedArea: "下部の葉"
            ))
        }

        if healthScore < 70 {
            symptoms.append(PlantSymptom(
                name: "褐色の斑点",
                type: .spots,
                severity: .moderate,
                description: "葉の表面に直径2-3mmの褐色斑点が散在しています",
                affectedArea: "中段の葉"
            ))
        }

        if healthScore < 60 {
            symptoms.append(PlantSymptom(
                name: "軽度の萎れ",
                type: .wilting,
                severity: .moderate,
                description: "新芽付近の葉がやや下向きに垂れています",
                affectedArea: "新芽付近"
            ))
        }

        return symptoms
    }

    /// 症状に基づく原因を生成する
    private func generateCauses(for symptoms: [PlantSymptom]) -> [String] {
        if symptoms.isEmpty {
            return ["特に問題は見つかりませんでした"]
        }

        var causes: [String] = []
        for symptom in symptoms {
            switch symptom.type {
            case .yellowing:
                causes.append("水のやりすぎによる根への過剰な水分供給")
                causes.append("窒素不足の可能性")
            case .spots:
                causes.append("真菌性の病気（褐斑病）の可能性")
                causes.append("直射日光による葉焼け")
            case .wilting:
                causes.append("水不足による一時的な萎れ")
                causes.append("根詰まりの可能性")
            default:
                causes.append("環境ストレスによる影響")
            }
        }
        return Array(Set(causes))
    }

    /// 種類と症状に基づくケア推奨を生成する
    private func generateRecommendations(
        for species: PlantSpecies,
        symptoms: [PlantSymptom]
    ) -> [String] {
        var recommendations: [String] = []

        // 基本的なケア推奨
        recommendations.append("水やりは\(species.wateringIntervalDays)日に1回を目安に")
        recommendations.append("置き場所は「\(species.lightRequirement)」が最適です")

        // 症状に基づく追加推奨
        for symptom in symptoms {
            switch symptom.type {
            case .yellowing:
                recommendations.append("水やりの頻度を少し減らし、土の表面が乾いてから水をあげてください")
            case .spots:
                recommendations.append("風通しを良くし、患部の葉を取り除いてください")
            case .wilting:
                recommendations.append("たっぷりと水をあげ、直射日光を避けた場所に移動してください")
            default:
                recommendations.append("定期的に葉の状態を観察してください")
            }
        }

        return recommendations
    }
}
