import Foundation

/// EnergyKit を活用したエネルギーデータ管理マネージャー
@MainActor
final class WattWiseEnergyManager {
    static let shared = WattWiseEnergyManager()

    private init() {}

    // MARK: - グリッドタイムスロット生成

    func generateGridTimeSlots() -> [GridTimeSlot] {
        (0..<24).map { hour in
            GridTimeSlot(
                id: UUID(),
                hour: hour,
                cleanLevel: cleanLevel(for: hour),
                cost: costLevel(for: hour)
            )
        }
    }

    // MARK: - クイズ生成

    func generateQuiz(gridSlots: [GridTimeSlot]) -> EnergyQuiz {
        let quizTemplates: [EnergyQuiz] = [
            EnergyQuiz(
                id: UUID(),
                question: "今日、一番クリーンな電力が使える時間はいつでしょう？",
                options: ["朝 8時", "昼 12時", "夕方 17時", "夜 22時"],
                correctIndex: 2,
                explanation: "太陽光発電が多い夕方は、余った電力でグリッドがクリーンになるよ!",
                points: 10
            ),
            EnergyQuiz(
                id: UUID(),
                question: "電力のピーク料金が一番高い時間帯は？",
                options: ["朝 6時〜8時", "昼 12時〜14時", "夕方 16時〜19時", "夜 21時〜23時"],
                correctIndex: 2,
                explanation: "夕方はみんなが電気を使うからピーク料金になるよ。この時間を避けると節約できる!",
                points: 10
            ),
            EnergyQuiz(
                id: UUID(),
                question: "再生可能エネルギーに含まれないのは？",
                options: ["太陽光", "風力", "天然ガス", "水力"],
                correctIndex: 2,
                explanation: "天然ガスは化石燃料で、CO2を排出するよ。太陽光・風力・水力は再生可能エネルギー!",
                points: 10
            ),
            EnergyQuiz(
                id: UUID(),
                question: "EV（電気自動車）を充電するベストなタイミングは？",
                options: ["通勤前の朝", "お昼休み", "深夜のオフピーク", "帰宅直後"],
                correctIndex: 2,
                explanation: "深夜は電力需要が低くて料金も安い。クリーンエネルギーの割合も高くなることが多いよ!",
                points: 10
            ),
            EnergyQuiz(
                id: UUID(),
                question: "エアコンの効率を上げる方法は？",
                options: ["温度を極端に下げる", "24時間つけっぱなし", "事前冷暖房して ピーク時に OFF", "窓を開けながら運転"],
                correctIndex: 2,
                explanation: "ピーク前に部屋を冷やして（暖めて）おくと、ピーク時に OFF でも快適に過ごせるよ!",
                points: 10
            ),
        ]

        return quizTemplates.randomElement() ?? quizTemplates[0]
    }

    // MARK: - デイリーインサイト生成

    func generateDailyInsight() -> DailyInsight {
        DailyInsight(
            id: UUID(),
            date: Date(),
            co2Reduction: Double.random(in: 1.5...3.5),
            costSaving: Double.random(in: 1.2...2.8),
            cleanRate: Double.random(in: 0.65...0.85),
            comparedToLastWeek: Double.random(in: -0.1...0.15)
        )
    }

    // MARK: - ウィジェットデータ永続化

    func persistWidgetData(_ data: WattWiseWidgetData) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        let defaults = UserDefaults(suiteName: "group.com.example.wattwise")
        defaults?.set(encoded, forKey: "widgetData")
    }

    // MARK: - ヘルパー

    private func cleanLevel(for hour: Int) -> CleanLevel {
        switch hour {
        case 0...5: .clean
        case 6...8: .moderate
        case 9...11: .clean
        case 12...14: .veryClean
        case 15...17: .veryClean
        case 18...20: .dirty
        case 21...23: .moderate
        default: .moderate
        }
    }

    private func costLevel(for hour: Int) -> CostLevel {
        switch hour {
        case 0...5: .low
        case 6...8: .medium
        case 9...11: .low
        case 12...14: .medium
        case 15...17: .medium
        case 18...20: .peak
        case 21...23: .high
        default: .medium
        }
    }
}
