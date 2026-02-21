import Foundation

/// 気象アラート情報
struct WeatherAlertInfo: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let severity: AlertSeverity
    let description: String
    let effectiveDate: Date
    let expiresDate: Date?

    /// アラートが有効かどうか
    var isActive: Bool {
        let now = Date()
        if let expires = expiresDate {
            return effectiveDate <= now && now < expires
        }
        return effectiveDate <= now
    }
}

/// アラートの深刻度
enum AlertSeverity: String, Sendable {
    case minor = "注意"
    case moderate = "警報"
    case severe = "重大"
    case extreme = "特別警報"

    var systemImageName: String {
        switch self {
        case .minor: "exclamationmark.triangle"
        case .moderate: "exclamationmark.triangle.fill"
        case .severe: "exclamationmark.octagon"
        case .extreme: "exclamationmark.octagon.fill"
        }
    }

    var colorName: String {
        switch self {
        case .minor: "yellow"
        case .moderate: "orange"
        case .severe: "red"
        case .extreme: "purple"
        }
    }
}
