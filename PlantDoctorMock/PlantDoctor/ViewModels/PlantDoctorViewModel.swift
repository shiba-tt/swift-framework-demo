import Foundation
import SwiftUI

/// PlantDoctor アプリのメイン ViewModel
@MainActor
@Observable
final class PlantDoctorViewModel {

    // MARK: - State

    private(set) var plants: [Plant] = []
    private(set) var careSchedules: [CareSchedule] = []
    private(set) var latestDiagnosis: DiagnosisResult?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var showingAddPlant = false
    var showingDiagnosis = false
    var selectedPlant: Plant?

    // MARK: - Dependencies

    let cameraManager = CameraManager()
    private let classificationManager = PlantClassificationManager.shared

    // MARK: - Computed Properties

    /// 水やりが必要な植物の数
    var plantsNeedingWater: Int {
        plants.filter(\.needsWatering).count
    }

    /// 今日のケアスケジュール
    var todaySchedules: [CareSchedule] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return careSchedules.filter { schedule in
            schedule.scheduledDate >= today && schedule.scheduledDate < tomorrow && !schedule.isCompleted
        }
    }

    /// 期限切れのケアスケジュール
    var overdueSchedules: [CareSchedule] {
        careSchedules.filter(\.isOverdue)
    }

    /// 全植物の平均健康スコア
    var averageHealthScore: Int {
        guard !plants.isEmpty else { return 0 }
        let total = plants.reduce(0) { $0 + $1.healthScore }
        return total / plants.count
    }

    /// 分析中かどうか
    var isAnalyzing: Bool {
        classificationManager.isAnalyzing
    }

    /// ケアヒント
    var careTips: [CareTip] {
        CareTip.defaults
    }

    // MARK: - Actions

    /// アプリ起動時の初期化
    func initialize() async {
        isLoading = true
        errorMessage = nil

        generateMockData()

        isLoading = false
    }

    /// 植物を新規登録する
    func addPlant(name: String, species: PlantSpecies, nickname: String) {
        let plant = Plant(
            id: UUID(),
            name: species.rawValue,
            species: species,
            nickname: nickname.isEmpty ? species.rawValue : nickname,
            registeredDate: Date(),
            lastDiagnosisDate: nil,
            lastWateredDate: Date(),
            healthScore: 85,
            diagnosisHistory: []
        )
        plants.append(plant)
        generateCareSchedules(for: plant)
    }

    /// 植物を診断する
    func diagnosePlant(_ plant: Plant) async {
        let result = await classificationManager.analyzePlant(species: plant.species)
        latestDiagnosis = result

        // 植物の健康スコアを更新
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index].healthScore = result.healthScore
            plants[index].lastDiagnosisDate = Date()

            let record = DiagnosisRecord(
                date: Date(),
                healthScore: result.healthScore,
                symptomCount: result.symptoms.count
            )
            plants[index].diagnosisHistory.append(record)
        }

        showingDiagnosis = true
    }

    /// 水やりを記録する
    func recordWatering(for plant: Plant) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[index].lastWateredDate = Date()

        // 関連するケアスケジュールを完了にする
        for i in careSchedules.indices {
            if careSchedules[i].plantId == plant.id
                && careSchedules[i].careType == .watering
                && !careSchedules[i].isCompleted {
                careSchedules[i].isCompleted = true
                break
            }
        }
    }

    /// ケアスケジュールを完了にする
    func completeSchedule(_ schedule: CareSchedule) {
        guard let index = careSchedules.firstIndex(where: { $0.id == schedule.id }) else { return }
        careSchedules[index].isCompleted = true
    }

    /// 植物を削除する
    func removePlant(_ plant: Plant) {
        plants.removeAll { $0.id == plant.id }
        careSchedules.removeAll { $0.plantId == plant.id }
    }

    // MARK: - Private

    /// モックデータを生成する
    private func generateMockData() {
        let mockPlants: [Plant] = [
            Plant(
                id: UUID(),
                name: "モンステラ",
                species: .monstera,
                nickname: "もんちゃん",
                registeredDate: Date().addingTimeInterval(-86400 * 30),
                lastDiagnosisDate: Date().addingTimeInterval(-86400 * 3),
                lastWateredDate: Date().addingTimeInterval(-86400 * 5),
                healthScore: 85,
                diagnosisHistory: [
                    DiagnosisRecord(date: Date().addingTimeInterval(-86400 * 14), healthScore: 90, symptomCount: 0),
                    DiagnosisRecord(date: Date().addingTimeInterval(-86400 * 7), healthScore: 88, symptomCount: 0),
                    DiagnosisRecord(date: Date().addingTimeInterval(-86400 * 3), healthScore: 85, symptomCount: 1),
                ]
            ),
            Plant(
                id: UUID(),
                name: "ポトス",
                species: .pothos,
                nickname: "ぽとちゃん",
                registeredDate: Date().addingTimeInterval(-86400 * 60),
                lastDiagnosisDate: Date().addingTimeInterval(-86400 * 5),
                lastWateredDate: Date().addingTimeInterval(-86400 * 2),
                healthScore: 72,
                diagnosisHistory: [
                    DiagnosisRecord(date: Date().addingTimeInterval(-86400 * 10), healthScore: 80, symptomCount: 0),
                    DiagnosisRecord(date: Date().addingTimeInterval(-86400 * 5), healthScore: 72, symptomCount: 2),
                ]
            ),
            Plant(
                id: UUID(),
                name: "サボテン",
                species: .cactus,
                nickname: "さぼちゃん",
                registeredDate: Date().addingTimeInterval(-86400 * 90),
                lastDiagnosisDate: Date().addingTimeInterval(-86400 * 7),
                lastWateredDate: Date().addingTimeInterval(-86400 * 14),
                healthScore: 92,
                diagnosisHistory: [
                    DiagnosisRecord(date: Date().addingTimeInterval(-86400 * 14), healthScore: 95, symptomCount: 0),
                    DiagnosisRecord(date: Date().addingTimeInterval(-86400 * 7), healthScore: 92, symptomCount: 0),
                ]
            ),
        ]

        plants = mockPlants

        for plant in mockPlants {
            generateCareSchedules(for: plant)
        }
    }

    /// 植物のケアスケジュールを生成する
    private func generateCareSchedules(for plant: Plant) {
        let now = Date()

        // 水やりスケジュール
        let wateringDate = Calendar.current.date(
            byAdding: .day,
            value: plant.nextWateringDays,
            to: now
        ) ?? now

        careSchedules.append(CareSchedule(
            plantId: plant.id,
            plantName: plant.nickname,
            plantEmoji: plant.species.emoji,
            careType: .watering,
            scheduledDate: wateringDate,
            isCompleted: false
        ))

        // 健康チェックスケジュール
        let diagnosisDate = Calendar.current.date(
            byAdding: .day,
            value: CareType.diagnosis.defaultIntervalDays,
            to: now
        ) ?? now

        careSchedules.append(CareSchedule(
            plantId: plant.id,
            plantName: plant.nickname,
            plantEmoji: plant.species.emoji,
            careType: .diagnosis,
            scheduledDate: diagnosisDate,
            isCompleted: false
        ))
    }
}
