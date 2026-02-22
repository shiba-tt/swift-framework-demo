import Foundation
import SensorKit

/// SensorKit の電話・メッセージ・訪問センサーを統合管理して社会的つながりデータを収集する
@MainActor
@Observable
final class SocialSensorKitManager: NSObject, SRSensorReaderDelegate, @unchecked Sendable {
    static let shared = SocialSensorKitManager()

    // MARK: - Sensor Readers

    private let phoneReader = SRSensorReader(sensor: .phoneUsageReport)
    private let messagesReader = SRSensorReader(sensor: .messagesUsageReport)
    private let visitsReader = SRSensorReader(sensor: .visits)

    // MARK: - State

    /// 認可状態
    private(set) var authorizationStatus: SRAuthorizationStatus = .notDetermined

    /// 記録中かどうか
    private(set) var isRecording = false

    /// 収集された電話データ
    private(set) var phoneReports: [SRPhoneUsageReport] = []

    /// 収集されたメッセージデータ
    private(set) var messageReports: [SRMessagesUsageReport] = []

    /// 収集された訪問データ
    private(set) var visitData: [SRVisit] = []

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
        let readers = [phoneReader, messagesReader, visitsReader]
        for reader in readers {
            reader.delegate = self
        }
    }

    // MARK: - Authorization

    /// 全センサーの認可をリクエスト
    func requestAuthorization() {
        SRSensorReader.requestAuthorization(sensors: [
            .phoneUsageReport,
            .messagesUsageReport,
            .visits,
        ]) { [weak self] error in
            Task { @MainActor in
                if let error {
                    print("[SocialSensorKitManager] 認可エラー: \(error)")
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

        phoneReader.startRecording()
        messagesReader.startRecording()
        visitsReader.startRecording()

        isRecording = true
    }

    /// 全センサーの記録を停止
    func stopRecording() {
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

        phoneReader.fetch(request)
        messagesReader.fetch(request)
        visitsReader.fetch(request)
    }

    // MARK: - Communication Data

    /// 電話データからコミュニケーション記録を構築
    func fetchCommunicationData(for date: Date) -> CommunicationRecord {
        // 実際のSensorKitデータが利用可能な場合はそこから構築
        // デモ用にはViewModelのgenerateDemoDataで生成
        CommunicationRecord(
            date: date,
            outgoingCalls: 0,
            incomingCalls: 0,
            callDurationMinutes: 0,
            outgoingMessages: 0,
            incomingMessages: 0,
            uniqueContacts: 0
        )
    }

    /// 訪問データから訪問記録を構築
    func fetchVisitData(for date: Date) -> VisitRecord {
        VisitRecord(
            date: date,
            placesVisited: 0,
            timeOutsideMinutes: 0,
            categories: [:],
            distanceFromHomeKm: 0
        )
    }

    // MARK: - Score Calculation

    /// コミュニケーション記録と訪問記録から社会的つながりスコアを計算
    func calculateSocialScore(
        date: Date,
        communication: CommunicationRecord,
        visit: VisitRecord,
        previousScore: Int?
    ) -> SocialScore {
        let phoneScore = calculatePhoneScore(communication: communication)
        let messageScore = calculateMessageScore(communication: communication)
        let visitScore = calculateVisitScore(visit: visit)

        // 重み付き平均（電話30%、メッセージ35%、訪問35%）
        let overall = Int(Double(phoneScore) * 0.30 + Double(messageScore) * 0.35 + Double(visitScore) * 0.35)

        return SocialScore(
            date: date,
            overallScore: min(100, max(0, overall)),
            phoneScore: phoneScore,
            messageScore: messageScore,
            visitScore: visitScore,
            changeFromPrevious: previousScore.map { min(100, max(0, overall)) - $0 }
        )
    }

    /// 電話コミュニケーションスコアを計算
    private func calculatePhoneScore(communication: CommunicationRecord) -> Int {
        var score = 0

        // 通話回数（最大40点）
        let callScore = min(40, communication.totalCalls * 5)
        score += callScore

        // 通話時間（最大30点）
        let durationScore = min(30, communication.callDurationMinutes * 2)
        score += durationScore

        // 発信比率ボーナス（能動的な社会参加、最大15点）
        if communication.outgoingCallRatio >= 0.3 {
            score += 15
        } else if communication.outgoingCallRatio >= 0.1 {
            score += 8
        }

        // ユニーク連絡先ボーナス（最大15点）
        let contactScore = min(15, communication.uniqueContacts * 3)
        score += contactScore

        return min(100, score)
    }

    /// メッセージスコアを計算
    private func calculateMessageScore(communication: CommunicationRecord) -> Int {
        var score = 0

        // メッセージ数（最大40点）
        let messageCount = min(40, communication.totalMessages * 2)
        score += messageCount

        // 送信メッセージ比率ボーナス（能動的な連絡、最大20点）
        if communication.outgoingMessageRatio >= 0.3 {
            score += 20
        } else if communication.outgoingMessageRatio >= 0.1 {
            score += 10
        }

        // ユニーク連絡先ボーナス（最大25点）
        let contactScore = min(25, communication.uniqueContacts * 5)
        score += contactScore

        // メッセージの双方向性ボーナス（最大15点）
        if communication.outgoingMessages > 0 && communication.incomingMessages > 0 {
            let ratio = min(
                Double(communication.outgoingMessages),
                Double(communication.incomingMessages)
            ) / max(
                Double(communication.outgoingMessages),
                Double(communication.incomingMessages)
            )
            score += Int(ratio * 15.0)
        }

        return min(100, score)
    }

    /// 訪問スコアを計算
    private func calculateVisitScore(visit: VisitRecord) -> Int {
        var score = 0

        // 訪問場所数（最大30点）
        let placeScore = min(30, visit.placesVisited * 8)
        score += placeScore

        // 外出時間（最大30点）
        let timeScore = min(30, Int(visit.timeOutsideHours * 5.0))
        score += timeScore

        // カテゴリの多様性（最大20点）
        let diversityScore = Int(visit.categoryDiversity * 20.0)
        score += diversityScore

        // 移動距離ボーナス（最大20点）
        let distanceScore = min(20, Int(visit.distanceFromHomeKm * 2.0))
        score += distanceScore

        return min(100, score)
    }

    // MARK: - SRSensorReaderDelegate

    nonisolated func sensorReader(
        _ reader: SRSensorReader,
        fetching fetchRequest: SRFetchRequest,
        didFetchResult result: SRFetchResult<AnyObject>
    ) -> Bool {
        Task { @MainActor in
            switch reader.sensor {
            case .phoneUsageReport:
                if let report = result.sample as? SRPhoneUsageReport {
                    handlePhone(report)
                }
            case .messagesUsageReport:
                if let report = result.sample as? SRMessagesUsageReport {
                    handleMessages(report)
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
        print("[SocialSensorKitManager] \(reader.sensor) データ取得エラー: \(error)")
    }

    // MARK: - Data Handlers

    private func handlePhone(_ report: SRPhoneUsageReport) {
        phoneReports.append(report)
    }

    private func handleMessages(_ report: SRMessagesUsageReport) {
        messageReports.append(report)
    }

    private func handleVisit(_ visit: SRVisit) {
        visitData.append(visit)
    }
}
