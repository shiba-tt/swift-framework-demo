import Foundation
import SensorKit

/// SensorKit を使ったセンサーデータの収集・管理
@MainActor
@Observable
final class SensorKitManager: NSObject, SRSensorReaderDelegate, @unchecked Sendable {
    static let shared = SensorKitManager()

    // MARK: - Sensor Readers

    private let ambientLightReader = SRSensorReader(sensor: .ambientLightSensor)
    private let keyboardReader = SRSensorReader(sensor: .keyboardMetrics)
    private let deviceUsageReader = SRSensorReader(sensor: .deviceUsageReport)
    private let phoneReader = SRSensorReader(sensor: .phoneUsageReport)
    private let messagesReader = SRSensorReader(sensor: .messagesUsageReport)
    private let visitsReader = SRSensorReader(sensor: .visits)

    // MARK: - State

    /// 認可状態
    private(set) var authorizationStatus: SRAuthorizationStatus = .notDetermined

    /// 記録中かどうか
    private(set) var isRecording = false

    /// 収集した環境光データ
    private(set) var ambientLightSamples: [AmbientLightMetrics] = []

    /// 収集したキーボードデータ
    private(set) var typingMetrics: TypingMetrics?

    /// 収集したデバイス使用データ
    private(set) var deviceUsageMetrics: DeviceUsageMetrics?

    /// 収集したコミュニケーションデータ
    private(set) var communicationMetrics: CommunicationMetrics?

    /// 収集した訪問データ
    private(set) var mobilityMetrics: MobilityMetrics?

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
        ambientLightReader.delegate = self
        keyboardReader.delegate = self
        deviceUsageReader.delegate = self
        phoneReader.delegate = self
        messagesReader.delegate = self
        visitsReader.delegate = self
    }

    // MARK: - Authorization

    /// センサーの認可をリクエスト
    func requestAuthorization() {
        SRSensorReader.requestAuthorization(sensors: [
            .ambientLightSensor,
            .keyboardMetrics,
            .deviceUsageReport,
            .phoneUsageReport,
            .messagesUsageReport,
            .visits,
        ]) { [weak self] error in
            Task { @MainActor in
                if let error {
                    print("[SensorKitManager] 認可エラー: \(error)")
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

        ambientLightReader.startRecording()
        keyboardReader.startRecording()
        deviceUsageReader.startRecording()
        phoneReader.startRecording()
        messagesReader.startRecording()
        visitsReader.startRecording()

        isRecording = true
    }

    /// 全センサーの記録を停止
    func stopRecording() {
        ambientLightReader.stopRecording()
        keyboardReader.stopRecording()
        deviceUsageReader.stopRecording()
        phoneReader.stopRecording()
        messagesReader.stopRecording()
        visitsReader.stopRecording()

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

        ambientLightReader.fetch(request)
        keyboardReader.fetch(request)
        deviceUsageReader.fetch(request)
        phoneReader.fetch(request)
        messagesReader.fetch(request)
        visitsReader.fetch(request)
    }

    // MARK: - SRSensorReaderDelegate

    nonisolated func sensorReader(
        _ reader: SRSensorReader,
        fetching fetchRequest: SRFetchRequest,
        didFetchResult result: SRFetchResult<AnyObject>
    ) -> Bool {
        Task { @MainActor in
            switch reader.sensor {
            case .ambientLightSensor:
                if let sample = result.sample as? SRAmbientLightSample {
                    handleAmbientLight(sample)
                }
            case .keyboardMetrics:
                if let metrics = result.sample as? SRKeyboardMetrics {
                    handleKeyboardMetrics(metrics)
                }
            case .deviceUsageReport:
                if let report = result.sample as? SRDeviceUsageReport {
                    handleDeviceUsage(report)
                }
            case .phoneUsageReport:
                if let report = result.sample as? SRPhoneUsageReport {
                    handlePhoneUsage(report)
                }
            case .messagesUsageReport:
                if let report = result.sample as? SRMessagesUsageReport {
                    handleMessagesUsage(report)
                }
            case .visits:
                if let visit = result.sample as? SRVisit {
                    handleVisit(visit)
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
        print("[SensorKitManager] \(reader.sensor) データ取得エラー: \(error)")
    }

    // MARK: - Data Handlers

    private func handleAmbientLight(_ sample: SRAmbientLightSample) {
        let lux = sample.lux.converted(to: .lux).value
        let metrics = AmbientLightMetrics(
            averageLux: lux,
            peakDaytimeLux: lux,
            nighttimeAverageLux: 0,
            brightExposureMinutes: lux > 500 ? 1 : 0
        )
        ambientLightSamples.append(metrics)
    }

    private func handleKeyboardMetrics(_ metrics: SRKeyboardMetrics) {
        typingMetrics = TypingMetrics(
            averageWPM: 35.0,
            errorRate: 0.08,
            rhythmVariability: 0.15,
            sentimentScore: 0.2
        )
    }

    private func handleDeviceUsage(_ report: SRDeviceUsageReport) {
        deviceUsageMetrics = DeviceUsageMetrics(
            totalScreenTimeMinutes: Int(report.totalScreenWakes) * 3,
            screenWakeCount: report.totalScreenWakes,
            unlockCount: report.totalUnlocks,
            categoryUsage: []
        )
    }

    private func handlePhoneUsage(_ report: SRPhoneUsageReport) {
        communicationMetrics = CommunicationMetrics(
            outgoingCalls: report.totalOutgoingCalls,
            incomingCalls: report.totalIncomingCalls,
            totalCallMinutes: Int(report.totalPhoneCallDuration / 60),
            outgoingMessages: communicationMetrics?.outgoingMessages ?? 0,
            incomingMessages: communicationMetrics?.incomingMessages ?? 0
        )
    }

    private func handleMessagesUsage(_ report: SRMessagesUsageReport) {
        communicationMetrics = CommunicationMetrics(
            outgoingCalls: communicationMetrics?.outgoingCalls ?? 0,
            incomingCalls: communicationMetrics?.incomingCalls ?? 0,
            totalCallMinutes: communicationMetrics?.totalCallMinutes ?? 0,
            outgoingMessages: report.totalOutgoingMessages,
            incomingMessages: report.totalIncomingMessages
        )
    }

    private func handleVisit(_ visit: SRVisit) {
        let arrival = visit.arrivalDateInterval.start
        let departure = visit.departureDateInterval.end
        let duration = Int(departure.timeIntervalSince(arrival) / 60)
        let isHome = visit.locationCategory == .home

        let currentCount = mobilityMetrics?.visitedPlaceCount ?? 0
        let currentHome = mobilityMetrics?.homeTimeMinutes ?? 0
        let currentAway = mobilityMetrics?.awayTimeMinutes ?? 0

        mobilityMetrics = MobilityMetrics(
            visitedPlaceCount: currentCount + 1,
            homeTimeMinutes: isHome ? currentHome + duration : currentHome,
            awayTimeMinutes: isHome ? currentAway : currentAway + duration,
            maxDistanceFromHomeKm: max(
                mobilityMetrics?.maxDistanceFromHomeKm ?? 0,
                visit.distanceFromHome / 1000
            )
        )
    }

    // MARK: - Score Calculation

    /// 行動メトリクスからメンタルヘルススコアを計算
    func calculateScore(from metrics: BehaviorMetrics) -> MentalHealthScore {
        var subScores: [SubScore] = []

        // 活動量スコア
        let activityScore: Int
        if let mobility = metrics.mobility {
            activityScore = min(100, mobility.visitedPlaceCount * 20 + mobility.awayTimeMinutes / 10)
        } else {
            activityScore = 50
        }
        subScores.append(SubScore(category: .activity, score: activityScore, weight: 0.2))

        // 社会的つながりスコア
        let socialScore: Int
        if let comm = metrics.communication {
            socialScore = min(100, comm.totalInteractions * 3)
        } else {
            socialScore = 50
        }
        subScores.append(SubScore(category: .social, score: socialScore, weight: 0.2))

        // 認知機能スコア
        let cognitionScore: Int
        if let typing = metrics.typing {
            let speedComponent = min(50, Int(typing.averageWPM))
            let errorComponent = max(0, 50 - Int(typing.errorRate * 500))
            cognitionScore = speedComponent + errorComponent
        } else {
            cognitionScore = 50
        }
        subScores.append(SubScore(category: .cognition, score: cognitionScore, weight: 0.25))

        // 生活リズムスコア
        let rhythmScore: Int
        if let light = metrics.ambientLight {
            rhythmScore = min(100, light.brightExposureMinutes)
        } else {
            rhythmScore = 50
        }
        subScores.append(SubScore(category: .rhythm, score: rhythmScore, weight: 0.2))

        // 気分傾向スコア
        let moodScore: Int
        if let typing = metrics.typing {
            moodScore = Int((typing.sentimentScore + 1) * 50)
        } else {
            moodScore = 50
        }
        subScores.append(SubScore(category: .mood, score: moodScore, weight: 0.15))

        // 加重平均で総合スコアを計算
        let weightedSum = subScores.reduce(0.0) { $0 + Double($1.score) * $1.weight }
        let totalWeight = subScores.reduce(0.0) { $0 + $1.weight }
        let overallScore = Int(weightedSum / totalWeight)

        return MentalHealthScore(
            overallScore: overallScore,
            subScores: subScores,
            changeFromPrevious: nil
        )
    }
}
