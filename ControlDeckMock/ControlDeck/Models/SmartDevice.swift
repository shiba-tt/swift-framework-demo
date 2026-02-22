import Foundation
import SwiftUI

// MARK: - SmartDevice

struct SmartDevice: Identifiable, Sendable {
    let id: UUID
    var name: String
    var type: DeviceType
    var roomID: UUID
    var isOn: Bool
    var value: Double
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        name: String,
        type: DeviceType,
        roomID: UUID,
        isOn: Bool = false,
        value: Double = 0,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.roomID = roomID
        self.isOn = isOn
        self.value = value
        self.lastUpdated = lastUpdated
    }

    // MARK: - Computed Properties

    var statusText: String {
        guard isOn else { return "OFF" }
        switch type {
        case .light:
            return "明るさ \(Int(value))%"
        case .airConditioner:
            return "\(Int(value))°C"
        case .lock:
            return value > 0 ? "施錠" : "解錠"
        case .speaker:
            return "音量 \(Int(value))%"
        case .curtain:
            return "開度 \(Int(value))%"
        case .camera:
            return "監視中"
        case .garageDoor:
            return value > 0 ? "閉" : "開"
        case .robot:
            return "稼働中"
        }
    }

    var formattedLastUpdated: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }
}

// MARK: - DeviceType

enum DeviceType: String, Sendable, CaseIterable, Identifiable {
    case light = "light"
    case airConditioner = "air_conditioner"
    case lock = "lock"
    case speaker = "speaker"
    case curtain = "curtain"
    case camera = "camera"
    case garageDoor = "garage_door"
    case robot = "robot"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light: return "照明"
        case .airConditioner: return "エアコン"
        case .lock: return "スマートロック"
        case .speaker: return "スピーカー"
        case .curtain: return "カーテン"
        case .camera: return "カメラ"
        case .garageDoor: return "ガレージ"
        case .robot: return "ロボット掃除機"
        }
    }

    var emoji: String {
        switch self {
        case .light: return "💡"
        case .airConditioner: return "🌡️"
        case .lock: return "🔒"
        case .speaker: return "🎵"
        case .curtain: return "🪟"
        case .camera: return "📹"
        case .garageDoor: return "🚪"
        case .robot: return "🤖"
        }
    }

    var systemImageName: String {
        switch self {
        case .light: return "lightbulb.fill"
        case .airConditioner: return "thermometer.medium"
        case .lock: return "lock.fill"
        case .speaker: return "speaker.wave.2.fill"
        case .curtain: return "blinds.vertical.open"
        case .camera: return "video.fill"
        case .garageDoor: return "door.garage.closed"
        case .robot: return "washer.fill"
        }
    }

    var color: Color {
        switch self {
        case .light: return .yellow
        case .airConditioner: return .cyan
        case .lock: return .red
        case .speaker: return .purple
        case .curtain: return .teal
        case .camera: return .blue
        case .garageDoor: return .brown
        case .robot: return .green
        }
    }

    var hasSlider: Bool {
        switch self {
        case .light, .airConditioner, .speaker, .curtain:
            return true
        case .lock, .camera, .garageDoor, .robot:
            return false
        }
    }

    var sliderRange: ClosedRange<Double> {
        switch self {
        case .light: return 0...100
        case .airConditioner: return 16...30
        case .speaker: return 0...100
        case .curtain: return 0...100
        default: return 0...100
        }
    }

    var sliderUnit: String {
        switch self {
        case .light: return "%"
        case .airConditioner: return "°C"
        case .speaker: return "%"
        case .curtain: return "%"
        default: return ""
        }
    }
}
