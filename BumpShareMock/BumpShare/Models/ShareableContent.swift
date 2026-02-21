import Foundation
import SwiftUI

/// 共有可能なコンテンツの種類
enum ShareableContentType: String, CaseIterable, Identifiable, Sendable {
    case contact = "連絡先"
    case wifiPassword = "Wi-Fi パスワード"
    case appData = "アプリデータ"
    case arContent = "AR コンテンツ"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .contact: "person.crop.circle.fill"
        case .wifiPassword: "wifi"
        case .appData: "app.badge.fill"
        case .arContent: "arkit"
        }
    }

    var color: Color {
        switch self {
        case .contact: .blue
        case .wifiPassword: .green
        case .appData: .orange
        case .arContent: .purple
        }
    }
}

/// 共有可能なコンテンツ
struct ShareableContent: Identifiable, Sendable {
    let id = UUID()
    let type: ShareableContentType
    let title: String
    let subtitle: String
    let data: ShareData
}

/// 共有データ
enum ShareData: Sendable {
    case contact(name: String, phone: String, email: String)
    case wifi(ssid: String, password: String, security: String)
    case appData(appName: String, payload: String)
    case arContent(modelName: String, fileSize: String)
}

/// 共有履歴
struct ShareHistory: Identifiable, Sendable {
    let id = UUID()
    let content: ShareableContent
    let peerName: String
    let direction: ShareDirection
    let date: Date
    let success: Bool
}

/// 共有の方向
enum ShareDirection: String, Sendable {
    case sent = "送信"
    case received = "受信"

    var icon: String {
        switch self {
        case .sent: "arrow.up.circle.fill"
        case .received: "arrow.down.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .sent: .blue
        case .received: .green
        }
    }
}

/// ピアデバイスの情報
struct PeerDevice: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let distance: Float
    let direction: SIMD3<Float>
    let isFacing: Bool
    let signalStrength: Double

    /// 距離の表示テキスト
    var distanceText: String {
        if distance < 1.0 {
            return String(format: "%.0f cm", distance * 100)
        }
        return String(format: "%.1f m", distance)
    }

    /// 距離に基づく接続フェーズ
    var phase: ProximityPhase {
        if isFacing && distance < 0.5 {
            return .readyToShare
        } else if distance < 1.0 {
            return .approaching
        } else if distance < 3.0 {
            return .detected
        }
        return .searching
    }
}

/// 近接フェーズ
enum ProximityPhase: String, Sendable {
    case searching = "検索中"
    case detected = "検出"
    case approaching = "接近中"
    case readyToShare = "共有可能"

    var color: Color {
        switch self {
        case .searching: .secondary
        case .detected: .yellow
        case .approaching: .orange
        case .readyToShare: .green
        }
    }

    var icon: String {
        switch self {
        case .searching: "magnifyingglass"
        case .detected: "antenna.radiowaves.left.and.right"
        case .approaching: "arrow.down.forward.and.arrow.up.backward"
        case .readyToShare: "checkmark.circle.fill"
        }
    }
}
