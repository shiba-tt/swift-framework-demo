import Foundation
import HealthKit

/// HealthKit の睡眠ステージデータを監視するモニター
@Observable
final class SleepMonitor {
    static let shared = SleepMonitor()

    private let healthStore = HKHealthStore()
    private(set) var isAuthorized = false
    private(set) var currentPhase: SleepPhase = .awake
    private(set) var sleepScore: Int = 0
    private(set) var isMonitoring = false

    /// 過去の睡眠ステージ履歴（直近の記録）
    private(set) var phaseHistory: [(phase: SleepPhase, date: Date)] = []

    private init() {}

    // MARK: - Authorization

    /// HealthKit の読み取り権限をリクエスト
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("[SleepMonitor] HealthKit 利用不可")
            return false
        }

        let sleepType = HKCategoryType(.sleepAnalysis)
        let readTypes: Set<HKSampleType> = [sleepType]
        let writeTypes: Set<HKSampleType> = [sleepType]

        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
            isAuthorized = true
            return true
        } catch {
            print("[SleepMonitor] HealthKit 認可失敗: \(error)")
            return false
        }
    }

    // MARK: - Sleep Monitoring

    /// 睡眠モニタリングを開始
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        phaseHistory = []
        print("[SleepMonitor] 睡眠モニタリング開始")

        // バックグラウンドで HealthKit の睡眠データを定期的にチェック
        Task {
            await pollSleepData()
        }
    }

    /// 睡眠モニタリングを停止
    func stopMonitoring() {
        isMonitoring = false
        print("[SleepMonitor] 睡眠モニタリング停止")
    }

    /// 睡眠データをポーリング（実プロダクトでは HKObserverQuery を使用）
    private func pollSleepData() async {
        while isMonitoring {
            await fetchLatestSleepStage()
            try? await Task.sleep(for: .seconds(60))
        }
    }

    /// 最新の睡眠ステージを取得
    private func fetchLatestSleepStage() async {
        let sleepType = HKCategoryType(.sleepAnalysis)
        let now = Date.now
        let sixHoursAgo = now.addingTimeInterval(-6 * 3600)
        let predicate = HKQuery.predicateForSamples(
            withStart: sixHoursAgo,
            end: now,
            options: .strictEndDate
        )
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        do {
            let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKCategorySample], Error>) in
                let query = HKSampleQuery(
                    sampleType: sleepType,
                    predicate: predicate,
                    limit: 10,
                    sortDescriptors: [sortDescriptor]
                ) { _, results, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: results as? [HKCategorySample] ?? [])
                    }
                }
                healthStore.execute(query)
            }

            if let latest = samples.first {
                let phase = mapHealthKitToSleepPhase(latest.value)
                currentPhase = phase
                phaseHistory.append((phase: phase, date: now))
                calculateSleepScore()
                print("[SleepMonitor] 現在の睡眠ステージ: \(phase.label)")
            }
        } catch {
            print("[SleepMonitor] 睡眠データ取得失敗: \(error)")
        }
    }

    /// HealthKit の睡眠値を SleepPhase にマッピング
    private func mapHealthKitToSleepPhase(_ value: Int) -> SleepPhase {
        switch HKCategoryValueSleepAnalysis(rawValue: value) {
        case .awake:
            return .awake
        case .asleepREM:
            return .rem
        case .asleepCore:
            return .core
        case .asleepDeep:
            return .deep
        default:
            return .core
        }
    }

    /// 睡眠スコアを計算
    private func calculateSleepScore() {
        guard !phaseHistory.isEmpty else {
            sleepScore = 0
            return
        }

        // 簡易スコア: 深い睡眠が多いほど高スコア
        let deepCount = phaseHistory.filter { $0.phase == .deep }.count
        let remCount = phaseHistory.filter { $0.phase == .rem }.count
        let coreCount = phaseHistory.filter { $0.phase == .core }.count
        let total = phaseHistory.count

        guard total > 0 else {
            sleepScore = 0
            return
        }

        let deepRatio = Double(deepCount) / Double(total)
        let remRatio = Double(remCount) / Double(total)
        let coreRatio = Double(coreCount) / Double(total)

        // 深い睡眠 20-25% + REM 20-25% + Core 残り が理想
        var score = 50.0
        score += deepRatio * 100  // 深い睡眠が多いほど加点
        score += remRatio * 80    // REM も加点
        score += coreRatio * 40   // Core は基本加点

        sleepScore = min(100, max(0, Int(score)))
    }
}
