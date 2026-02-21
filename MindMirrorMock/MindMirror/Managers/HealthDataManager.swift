import Foundation
import HealthKit

/// HealthKit との連携マネージャー
@MainActor
@Observable
final class HealthDataManager {
    static let shared = HealthDataManager()

    private let healthStore = HKHealthStore()

    /// HealthKit が利用可能か
    let isAvailable = HKHealthStore.isHealthDataAvailable()

    /// 認可済みか
    private(set) var isAuthorized = false

    private init() {}

    // MARK: - Authorization

    /// HealthKit のアクセスをリクエスト
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            return true
        } catch {
            print("[HealthDataManager] 認可エラー: \(error)")
            return false
        }
    }

    // MARK: - Fetch Data

    /// 今日の歩数を取得
    func fetchTodayStepCount() async -> Int {
        guard isAuthorized,
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            healthStore.execute(query)
        }
    }

    /// 昨日の睡眠時間を取得（分）
    func fetchLastNightSleepMinutes() async -> Int {
        guard isAuthorized,
              let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            return 0
        }

        let calendar = Calendar.current
        let now = Date()
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: now) else {
            return 0
        }
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfYesterday,
            end: now,
            options: .strictStartDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                let totalMinutes = (samples ?? []).compactMap { sample -> Int? in
                    guard let categorySample = sample as? HKCategorySample,
                          categorySample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue
                            || categorySample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue
                            || categorySample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue
                            || categorySample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
                    else { return nil }
                    return Int(categorySample.endDate.timeIntervalSince(categorySample.startDate) / 60)
                }.reduce(0, +)
                continuation.resume(returning: totalMinutes)
            }
            healthStore.execute(query)
        }
    }

    /// 今日の平均心拍数を取得
    func fetchTodayAverageHeartRate() async -> Double {
        guard isAuthorized,
              let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return 0
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, _ in
                let bpm = result?.averageQuantity()?.doubleValue(
                    for: HKUnit.count().unitDivided(by: .minute())
                ) ?? 0
                continuation.resume(returning: bpm)
            }
            healthStore.execute(query)
        }
    }
}
