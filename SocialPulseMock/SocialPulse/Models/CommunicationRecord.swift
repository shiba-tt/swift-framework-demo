import Foundation

/// 1日のコミュニケーション記録
struct CommunicationRecord: Identifiable, Sendable {
    let id = UUID()
    /// 記録日
    let date: Date
    /// 発信回数
    let outgoingCalls: Int
    /// 着信回数
    let incomingCalls: Int
    /// 合計通話時間（分）
    let callDurationMinutes: Int
    /// 送信メッセージ数
    let outgoingMessages: Int
    /// 受信メッセージ数
    let incomingMessages: Int
    /// ユニーク連絡先数
    let uniqueContacts: Int

    /// 総通話回数
    var totalCalls: Int {
        outgoingCalls + incomingCalls
    }

    /// 総メッセージ数
    var totalMessages: Int {
        outgoingMessages + incomingMessages
    }

    /// 発信比率（0.0〜1.0）
    var outgoingCallRatio: Double {
        guard totalCalls > 0 else { return 0.0 }
        return Double(outgoingCalls) / Double(totalCalls)
    }

    /// 送信メッセージ比率（0.0〜1.0）
    var outgoingMessageRatio: Double {
        guard totalMessages > 0 else { return 0.0 }
        return Double(outgoingMessages) / Double(totalMessages)
    }

    /// コミュニケーションの活発さレベル
    var activityLevel: CommunicationLevel {
        let totalInteractions = totalCalls + totalMessages
        switch totalInteractions {
        case 30...: .veryActive
        case 15..<30: .active
        case 5..<15: .moderate
        default: .low
        }
    }

    /// 平均通話時間（分）
    var averageCallDuration: Double {
        guard totalCalls > 0 else { return 0.0 }
        return Double(callDurationMinutes) / Double(totalCalls)
    }
}

/// コミュニケーション活発さレベル
enum CommunicationLevel: String, Sendable, CaseIterable {
    case veryActive = "非常に活発"
    case active = "活発"
    case moderate = "普通"
    case low = "少ない"

    var colorName: String {
        switch self {
        case .veryActive: "green"
        case .active: "blue"
        case .moderate: "orange"
        case .low: "red"
        }
    }

    var systemImageName: String {
        switch self {
        case .veryActive: "person.3.fill"
        case .active: "person.2.fill"
        case .moderate: "person.fill"
        case .low: "person.fill.questionmark"
        }
    }
}

/// コミュニケーションの時間帯別統計
struct HourlyCommunication: Identifiable, Sendable {
    let id = UUID()
    /// 時間帯（0〜23）
    let hour: Int
    /// その時間帯の通話数
    let calls: Int
    /// その時間帯のメッセージ数
    let messages: Int

    /// 合計インタラクション数
    var total: Int {
        calls + messages
    }
}
