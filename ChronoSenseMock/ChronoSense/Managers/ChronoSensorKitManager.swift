import Foundation
import SensorKit

/// SensorKit の全センサーを統合管理して概日リズムデータを収集する
@MainActor
@Observable
final class ChronoSensorKitManager: NSObject, SRSensorReaderDelegate, @unchecked Sendable {
    static let shared = ChronoSensorKitManager()

    // MARK: - Sensor Readers

    private let accelerometerReader = SRSensorReader(sensor: .accelerometer)
    private let rotationReader = SRSensorReader(sensor: .rotationRate)
    private let ambientLightReader = SRSensorReader(sensor: .ambientLightSensor)
    private let keyboardReader = SRSensorReader(sensor: .keyboardMetrics)
    private let deviceUsageReader = SRSensorReader(sensor: .deviceUsageReport)
    private let phoneReader = SRSensorReader(sensor: .phoneUsageReport)
    private let messagesReader = SRSensorReader(sensor: .messagesUsageReport)
    private let visitsReader = SRSensorReader(sensor: .visits)
    private let pedometerReader = SRSensorReader(sensor: .pedometerData)
    private let wristReader = SRSensorReader(sensor: .onWristState)

    // MARK: - State

    /// 認可状態
    private(set) var authorizationStatus: SRAuthorizationStatus = .notDetermined

    /// 記録中かどうか
    private(set) var isRecording = false

    /// 時間帯別の加速度平均
    private(set) var hourlyAcceleration: [Int: Double] = [:]

    /// 時間帯別の環境光（lux）
    private(set) var hourlyLux: [Int: Double] = [:]

    /// 時間帯別のキーストローク数
    private(set) var hourlyKeystrokes: [Int: Int] = [:]

    /// 時間帯別の歩数
    private(set) var hourlySteps: [Int: Int] = [:]

    /// 時間帯別のスクリーンタイム（分）
    private(set) var hourlyScreenTime: [Int: Int] = [:]

    /// 時間帯別のソーシャルインタラクション数
    private(set) var hourlySocial: [Int: Int] = [:]

    /// 時間帯別のリスト装着状態
    private(set) var hourlyWristOn: [Int: Bool] = [:]

    /// 認可済みかどうか
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    // MARK: - Setup

    private override init() {
        super.init()
        setupReaders()
    }

    private func setupReaders() {
        let readers = [
            accelerometerReader, rotationReader, ambientLightReader,
            keyboardReader, deviceUsageReader, phoneReader,
            messagesReader, visitsReader, pedometerReader, wristReader,
        ]
        for reader in readers {
            reader.delegate = self
        }
    }

    // MARK: - Authorization

    /// 全センサーの認可をリクエスト
    func requestAuthorization() {
        SRSensorReader.requestAuthorization(sensors: [
            .accelerometer,
            .rotationRate,
            .ambientLightSensor,
            .keyboardMetrics,
            .deviceUsageReport,
            .phoneUsageReport,
            .messagesUsageReport,
            .visits,
            .pedometerData,
            .onWristState,
        ]) { [weak self] error in
            Task { @MainActor in
                if let error {
                    print("[ChronoSensorKitManager] 認可エラー: \(error)")
                } else {
                    self?.authorizationStatus = .authorized
                }
            }
        }
    }

    // MARK: - Recording

    /// 全センサーの記録を開始
    func startRecording() {
        guard isAuthorized else { return }

        accelerometerReader.startRecording()
        rotationReader.startRecording()
        ambientLightReader.startRecording()
        keyboardReader.startRecording()
        deviceUsageReader.startRecording()
        phoneReader.startRecording()
        messagesReader.startRecording()
        visitsReader.startRecording()
        pedometerReader.startRecording()
        wristReader.startRecording()

        isRecording = true
    }

    /// 全センサーの記録を停止
    func stopRecording() {
        accelerometerReader.stopRecording()
        rotationReader.stopRecording()
        ambientLightReader.stopRecording()
        keyboardReader.stopRecording()
        deviceUsageReader.stopRecording()
        phoneReader.stopRecording()
        messagesReader.stopRecording()
        visitsReader.stopRecording()
        pedometerReader.stopRecording()
        wristReader.stopRecording()

        isRecording = false
    }

    // MARK: - Fetch

    /// 過去24時間のデータを取得
    func fetchRecentData() {
        let now = Date()
        let yesterday = now.addingTimeInterval(-86400)

        let request = SRFetchRequest()
        request.from = SRAbsoluteTime(yesterday.timeIntervalSinceReferenceDate)
        request.to = SRAbsoluteTime(now.timeIntervalSinceReferenceDate)

        accelerometerReader.fetch(request)
        ambientLightReader.fetch(request)
        keyboardReader.fetch(request)
        deviceUsageReader.fetch(request)
        phoneReader.fetch(request)
        messagesReader.fetch(request)
        visitsReader.fetch(request)
        pedometerReader.fetch(request)
        wristReader.fetch(request)
    }

    // MARK: - SRSensorReaderDelegate

    nonisolated func sensorReader(
        _ reader: SRSensorReader,
        fetching fetchRequest: SRFetchRequest,
        didFetchResult result: SRFetchResult<AnyObject>
    ) -> Bool {
        Task { @MainActor in
            switch reader.sensor {
            case .accelerometer:
                if let sample = result.sample as? SRAccelerometerData {
                    handleAccelerometer(sample, timestamp: result.timestamp)
                }
            case .ambientLightSensor:
                if let sample = result.sample as? SRAmbientLightSample {
                    handleAmbientLight(sample, timestamp: result.timestamp)
                }
            case .keyboardMetrics:
                if let metrics = result.sample as? SRKeyboardMetrics {
                    handleKeyboard(metrics, timestamp: result.timestamp)
                }
            case .deviceUsageReport:
                if let report = result.sample as? SRDeviceUsageReport {
                    handleDeviceUsage(report, timestamp: result.timestamp)
                }
            case .phoneUsageReport:
                if let report = result.sample as? SRPhoneUsageReport {
                    handlePhone(report, timestamp: result.timestamp)
                }
            case .messagesUsageReport:
                if let report = result.sample as? SRMessagesUsageReport {
                    handleMessages(report, timestamp: result.timestamp)
                }
            case .pedometerData:
                if let data = result.sample as? SRPedometerData {
                    handlePedometer(data, timestamp: result.timestamp)
                }
            case .onWristState:
                if let state = result.sample as? SRWristDetection {
                    handleWristState(state, timestamp: result.timestamp)
                }
            default:
                break
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
        print("[ChronoSensorKitManager] \(reader.sensor) データ取得エラー: \(error)")
    }

    // MARK: - Data Handlers

    private func handleAccelerometer(_ sample: SRAccelerometerData, timestamp: SRAbsoluteTime) {
        let hour = hourFromTimestamp(timestamp)
        let magnitude = sqrt(
            pow(sample.acceleration.x, 2)
                + pow(sample.acceleration.y, 2)
                + pow(sample.acceleration.z, 2)
        )
        hourlyAcceleration[hour] = max(hourlyAcceleration[hour] ?? 0, min(1.0, magnitude / 3.0))
    }

    private func handleAmbientLight(_ sample: SRAmbientLightSample, timestamp: SRAbsoluteTime) {
        let hour = hourFromTimestamp(timestamp)
        let lux = sample.lux.converted(to: .lux).value
        hourlyLux[hour] = max(hourlyLux[hour] ?? 0, lux)
    }

    private func handleKeyboard(_ metrics: SRKeyboardMetrics, timestamp: SRAbsoluteTime) {
        let hour = hourFromTimestamp(timestamp)
        hourlyKeystrokes[hour] = (hourlyKeystrokes[hour] ?? 0) + 100
    }

    private func handleDeviceUsage(_ report: SRDeviceUsageReport, timestamp: SRAbsoluteTime) {
        let hour = hourFromTimestamp(timestamp)
        hourlyScreenTime[hour] = (hourlyScreenTime[hour] ?? 0) + Int(report.totalScreenWakes)
    }

    private func handlePhone(_ report: SRPhoneUsageReport, timestamp: SRAbsoluteTime) {
        let hour = hourFromTimestamp(timestamp)
        let interactions = report.totalOutgoingCalls + report.totalIncomingCalls
        hourlySocial[hour] = (hourlySocial[hour] ?? 0) + interactions
    }

    private func handleMessages(_ report: SRMessagesUsageReport, timestamp: SRAbsoluteTime) {
        let hour = hourFromTimestamp(timestamp)
        let messages = report.totalOutgoingMessages + report.totalIncomingMessages
        hourlySocial[hour] = (hourlySocial[hour] ?? 0) + messages
    }

    private func handlePedometer(_ data: SRPedometerData, timestamp: SRAbsoluteTime) {
        let hour = hourFromTimestamp(timestamp)
        hourlySteps[hour] = (hourlySteps[hour] ?? 0) + data.stepCount
    }

    private func handleWristState(_ state: SRWristDetection, timestamp: SRAbsoluteTime) {
        let hour = hourFromTimestamp(timestamp)
        hourlyWristOn[hour] = state.onWrist
    }

    // MARK: - Helpers

    private func hourFromTimestamp(_ timestamp: SRAbsoluteTime) -> Int {
        let date = Date(timeIntervalSinceReferenceDate: timestamp.rawValue)
        return Calendar.current.component(.hour, from: date)
    }

    /// 現在の時間帯別データから SensorReading 配列を構築
    func buildReadings() -> [SensorReading] {
        (0..<24).map { hour in
            SensorReading(
                hour: hour,
                activityLevel: hourlyAcceleration[hour] ?? 0,
                ambientLux: hourlyLux[hour] ?? 0,
                screenTimeMinutes: hourlyScreenTime[hour] ?? 0,
                keystrokes: hourlyKeystrokes[hour] ?? 0,
                steps: hourlySteps[hour] ?? 0,
                socialInteractions: hourlySocial[hour] ?? 0,
                isWristOn: hourlyWristOn[hour] ?? false
            )
        }
    }

    /// リズム整合度スコアを計算
    func calculateRhythmScore(readings: [SensorReading]) -> Int {
        // 理想的なリズム: 日中活動、夜間休息のパターン
        var score = 100

        // 日中（6-18時）の活動量チェック
        let daytimeReadings = readings.filter { (6...18).contains($0.hour) }
        let daytimeActivity = daytimeReadings.reduce(0.0) { $0 + $1.activityLevel } / max(1, Double(daytimeReadings.count))
        if daytimeActivity < 0.2 { score -= 15 }

        // 夜間（22-5時）の休息チェック
        let nightReadings = readings.filter { $0.hour >= 22 || $0.hour <= 5 }
        let nightActivity = nightReadings.reduce(0.0) { $0 + $1.activityLevel } / max(1, Double(nightReadings.count))
        if nightActivity > 0.3 { score -= 15 }

        // 日中の光曝露チェック
        let daytimeLight = daytimeReadings.reduce(0.0) { $0 + $1.ambientLux } / max(1, Double(daytimeReadings.count))
        if daytimeLight < 200 { score -= 10 }

        // 夜間のスクリーンタイムチェック
        let nightScreen = nightReadings.reduce(0) { $0 + $1.screenTimeMinutes }
        if nightScreen > 60 { score -= 10 }

        // 活動のピーク時間帯チェック（10-16時が理想）
        let peakHour = readings.max(by: { $0.activityLevel < $1.activityLevel })?.hour ?? 12
        if !(10...16).contains(peakHour) { score -= 10 }

        return max(0, min(100, score))
    }
}
