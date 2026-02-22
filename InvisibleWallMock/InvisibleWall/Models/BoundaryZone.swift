import Foundation
import SwiftUI

// MARK: - ZoneType

enum ZoneType: String, Sendable, CaseIterable, Identifiable {
    case inner
    case middle
    case outer

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .inner: "近距離ゾーン"
        case .middle: "中距離ゾーン"
        case .outer: "遠距離ゾーン"
        }
    }

    var distanceLabel: String {
        switch self {
        case .inner: "0 ~ 3m"
        case .middle: "3 ~ 10m"
        case .outer: "10m+"
        }
    }

    var color: Color {
        switch self {
        case .inner: .green
        case .middle: .yellow
        case .outer: .red
        }
    }

    var icon: String {
        switch self {
        case .inner: "lock.open.fill"
        case .middle: "lock.trianglebadge.exclamationmark.fill"
        case .outer: "lock.fill"
        }
    }
}

// MARK: - SecurityAction

enum SecurityAction: String, Sendable, CaseIterable, Identifiable {
    case unlockAll
    case limitedAccess
    case lockDevice
    case sendNotification
    case triggerAlarm
    case hideApps

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .unlockAll: "全機能アンロック"
        case .limitedAccess: "限定アクセス"
        case .lockDevice: "デバイスロック"
        case .sendNotification: "通知送信"
        case .triggerAlarm: "アラーム発動"
        case .hideApps: "アプリ非表示"
        }
    }

    var icon: String {
        switch self {
        case .unlockAll: "lock.open.fill"
        case .limitedAccess: "eye.slash"
        case .lockDevice: "lock.fill"
        case .sendNotification: "bell.fill"
        case .triggerAlarm: "light.beacon.max.fill"
        case .hideApps: "app.badge.fill"
        }
    }

    var color: Color {
        switch self {
        case .unlockAll: .green
        case .limitedAccess: .yellow
        case .lockDevice: .red
        case .sendNotification: .blue
        case .triggerAlarm: .orange
        case .hideApps: .purple
        }
    }
}

// MARK: - BoundaryZone

struct BoundaryZone: Identifiable, Sendable {
    let id: UUID
    let name: String
    let zoneType: ZoneType
    let radiusMin: Double
    let radiusMax: Double
    let actions: [SecurityAction]
    let isActive: Bool

    var radiusLabel: String {
        if radiusMax == .infinity {
            return "\(String(format: "%.0f", radiusMin))m+"
        }
        return "\(String(format: "%.0f", radiusMin)) ~ \(String(format: "%.0f", radiusMax))m"
    }
}

// MARK: - MonitoredDevice

struct MonitoredDevice: Identifiable, Sendable {
    let id: UUID
    let name: String
    let deviceType: DeviceType
    let distance: Float?
    let direction: SIMD3<Float>?
    let currentZone: ZoneType
    let lastSeen: Date
    let isConnected: Bool

    var distanceFormatted: String {
        guard let d = distance else { return "不明" }
        if d < 1.0 {
            return String(format: "%.0f cm", d * 100)
        }
        return String(format: "%.1f m", d)
    }

    var timeSinceLastSeen: String {
        let interval = Date().timeIntervalSince(lastSeen)
        if interval < 60 { return "たった今" }
        if interval < 3600 { return "\(Int(interval / 60))分前" }
        return "\(Int(interval / 3600))時間前"
    }
}

// MARK: - DeviceType

enum DeviceType: String, Sendable, CaseIterable, Identifiable {
    case iPhone
    case appleWatch
    case uwbAccessory
    case airTag

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .iPhone: "iPhone"
        case .appleWatch: "Apple Watch"
        case .uwbAccessory: "UWBアクセサリ"
        case .airTag: "AirTag"
        }
    }

    var icon: String {
        switch self {
        case .iPhone: "iphone"
        case .appleWatch: "applewatch"
        case .uwbAccessory: "sensor.fill"
        case .airTag: "airtag"
        }
    }
}

// MARK: - SecurityEvent

struct SecurityEvent: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let device: String
    let eventType: SecurityEventType
    let zone: ZoneType
    let distance: Float?

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d HH:mm"
        return formatter.string(from: date)
    }

    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: - SecurityEventType

enum SecurityEventType: String, Sendable, CaseIterable, Identifiable {
    case zoneEnter
    case zoneExit
    case lockTriggered
    case unlockTriggered
    case alertSent
    case deviceLost

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .zoneEnter: "ゾーン進入"
        case .zoneExit: "ゾーン退出"
        case .lockTriggered: "ロック実行"
        case .unlockTriggered: "アンロック実行"
        case .alertSent: "アラート送信"
        case .deviceLost: "デバイスロスト"
        }
    }

    var icon: String {
        switch self {
        case .zoneEnter: "arrow.right.circle.fill"
        case .zoneExit: "arrow.left.circle.fill"
        case .lockTriggered: "lock.fill"
        case .unlockTriggered: "lock.open.fill"
        case .alertSent: "exclamationmark.triangle.fill"
        case .deviceLost: "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .zoneEnter: .green
        case .zoneExit: .orange
        case .lockTriggered: .red
        case .unlockTriggered: .green
        case .alertSent: .yellow
        case .deviceLost: .red
        }
    }
}

// MARK: - AppTab

enum AppTab: String, Sendable {
    case monitor
    case zones
    case devices
    case events
}
