import Foundation
import SensorKit

/// SRKeyboardMetrics に特化したセンサーデータ管理
@MainActor
@Observable
final class KeyboardMetricsManager: NSObject, SRSensorReaderDelegate, @unchecked Sendable {
    static let shared = KeyboardMetricsManager()

    // MARK: - Sensor Reader

    private let keyboardReader = SRSensorReader(sensor: .keyboardMetrics)

    // MARK: - State

    /// 認可状態
    private(set) var authorizationStatus: SRAuthorizationStatus = .notDetermined

    /// 記録中かどうか
    private(set) var isRecording = false

    /// 最新のバイオマーカーデータ
    private(set) var latestBiomarker: TypingBiomarker?

    /// ベースラインプロファイル
    private(set) var baseline: BaselineProfile = .default

    /// アラート履歴
    private(set) var alerts: [AlertRecord] = []

    /// 認可済みかどうか
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    // MARK: - Setup

    private override init() {
        super.init()
        keyboardReader.delegate = self
    }

    // MARK: - Authorization

    /// キーボードメトリクスの認可をリクエスト
    func requestAuthorization() {
        SRSensorReader.requestAuthorization(sensors: [
            .keyboardMetrics,
        ]) { [weak self] error in
            Task { @MainActor in
                if let error {
                    print("[KeyboardMetricsManager] 認可エラー: \(error)")
                } else {
                    self?.authorizationStatus = .authorized
                }
            }
        }
    }

    // MARK: - Recording

    /// 記録を開始
    func startRecording() {
        guard isAuthorized else { return }
        keyboardReader.startRecording()
        isRecording = true
    }

    /// 記録を停止
    func stopRecording() {
        keyboardReader.stopRecording()
        isRecording = false
    }

    // MARK: - Fetch

    /// 過去24時間のキーボードデータを取得
    func fetchRecentData() {
        let now = Date()
        let yesterday = now.addingTimeInterval(-86400)

        let request = SRFetchRequest()
        request.from = SRAbsoluteTime(yesterday.timeIntervalSinceReferenceDate)
        request.to = SRAbsoluteTime(now.timeIntervalSinceReferenceDate)

        keyboardReader.fetch(request)
    }

    // MARK: - SRSensorReaderDelegate

    nonisolated func sensorReader(
        _ reader: SRSensorReader,
        fetching fetchRequest: SRFetchRequest,
        didFetchResult result: SRFetchResult<AnyObject>
    ) -> Bool {
        Task { @MainActor in
            if let metrics = result.sample as? SRKeyboardMetrics {
                handleKeyboardMetrics(metrics)
            }
        }
        return true
    }

    nonisolated func sensorReader(
        _ reader: SRSensorReader,
        didChange authorizationStatus: SRAuthorizationStatus
    ) {
        Task { @MainActor in
            self.authorizationStatus = authorizationStatus
        }
    }

    nonisolated func sensorReader(
        _ reader: SRSensorReader,
        fetching fetchRequest: SRFetchRequest,
        failedWithError error: Error
    ) {
        print("[KeyboardMetricsManager] データ取得エラー: \(error)")
    }

    // MARK: - Data Processing

    private func handleKeyboardMetrics(_ metrics: SRKeyboardMetrics) {
        let biomarker = TypingBiomarker(
            date: Date(),
            averageWPM: 35.0,
            errorRate: 0.06,
            rhythmVariability: 0.12,
            adjacentKeyErrorRate: 0.03,
            pressureDurationSD: 25.0,
            sentimentScore: 0.15
        )
        latestBiomarker = biomarker
        checkForAlerts(biomarker)
    }

    // MARK: - Baseline

    /// ベースラインを更新
    func updateBaseline(from history: [TypingBiomarker]) {
        guard !history.isEmpty else { return }

        let avgWPM = history.map(\.averageWPM).reduce(0, +) / Double(history.count)
        let avgError = history.map(\.errorRate).reduce(0, +) / Double(history.count)
        let avgRhythm = history.map(\.rhythmVariability).reduce(0, +) / Double(history.count)
        let avgAdjacent = history.map(\.adjacentKeyErrorRate).reduce(0, +) / Double(history.count)
        let avgPressure = history.map(\.pressureDurationSD).reduce(0, +) / Double(history.count)

        baseline = BaselineProfile(
            establishedDate: history.first?.date ?? Date(),
            dataCollectionDays: history.count,
            baselineWPM: avgWPM,
            baselineErrorRate: avgError,
            baselineRhythmVariability: avgRhythm,
            baselineAdjacentKeyErrorRate: avgAdjacent,
            baselinePressureDurationSD: avgPressure
        )
    }

    /// 現在のデータとベースラインの偏差を計算
    func calculateDeviations(current: TypingBiomarker) -> [DeviationResult] {
        guard baseline.isEstablished else { return [] }

        var results: [DeviationResult] = []

        // 速度偏差（低下 = マイナス方向）
        if baseline.baselineWPM > 0 {
            let deviation = (current.averageWPM - baseline.baselineWPM) / baseline.baselineWPM * 100
            results.append(DeviationResult(
                metricType: .speed,
                currentValue: current.averageWPM,
                baselineValue: baseline.baselineWPM,
                deviationPercent: deviation
            ))
        }

        // エラー率偏差（増加 = プラス方向）
        if baseline.baselineErrorRate > 0 {
            let deviation = (current.errorRate - baseline.baselineErrorRate) / baseline.baselineErrorRate * 100
            results.append(DeviationResult(
                metricType: .errorRate,
                currentValue: current.errorRate,
                baselineValue: baseline.baselineErrorRate,
                deviationPercent: deviation
            ))
        }

        // リズム偏差
        if baseline.baselineRhythmVariability > 0 {
            let deviation = (current.rhythmVariability - baseline.baselineRhythmVariability) / baseline.baselineRhythmVariability * 100
            results.append(DeviationResult(
                metricType: .rhythm,
                currentValue: current.rhythmVariability,
                baselineValue: baseline.baselineRhythmVariability,
                deviationPercent: deviation
            ))
        }

        // 隣接キーエラー偏差
        if baseline.baselineAdjacentKeyErrorRate > 0 {
            let deviation = (current.adjacentKeyErrorRate - baseline.baselineAdjacentKeyErrorRate) / baseline.baselineAdjacentKeyErrorRate * 100
            results.append(DeviationResult(
                metricType: .adjacentError,
                currentValue: current.adjacentKeyErrorRate,
                baselineValue: baseline.baselineAdjacentKeyErrorRate,
                deviationPercent: deviation
            ))
        }

        // 押下時間偏差
        if baseline.baselinePressureDurationSD > 0 {
            let deviation = (current.pressureDurationSD - baseline.baselinePressureDurationSD) / baseline.baselinePressureDurationSD * 100
            results.append(DeviationResult(
                metricType: .pressureSD,
                currentValue: current.pressureDurationSD,
                baselineValue: baseline.baselinePressureDurationSD,
                deviationPercent: deviation
            ))
        }

        return results
    }

    // MARK: - Alerts

    private func checkForAlerts(_ biomarker: TypingBiomarker) {
        guard baseline.isEstablished else { return }

        let deviations = calculateDeviations(current: biomarker)
        let significantDeviations = deviations.filter { $0.level == .significant }

        if !significantDeviations.isEmpty {
            let metrics = significantDeviations.map(\.metricType)
            let alert = AlertRecord(
                date: Date(),
                title: "タイピングパターンに有意な変化",
                description: "ベースラインと比較して\(metrics.map(\.rawValue).joined(separator: "・"))に変化が検出されました。",
                severity: .warning,
                relatedMetrics: metrics
            )
            alerts.insert(alert, at: 0)
        }
    }
}
