import Foundation
import SwiftUI

// MARK: - SoundEvent

struct SoundEvent: Identifiable, Sendable {
    let id: UUID
    var category: SoundCategory
    var label: String
    var confidence: Double
    var direction: SoundDirection?
    var detectedAt: Date
    var alertLevel: AlertLevel

    init(
        id: UUID = UUID(),
        category: SoundCategory,
        label: String,
        confidence: Double,
        direction: SoundDirection? = nil,
        detectedAt: Date = Date(),
        alertLevel: AlertLevel = .safe
    ) {
        self.id = id
        self.category = category
        self.label = label
        self.confidence = confidence
        self.direction = direction
        self.detectedAt = detectedAt
        self.alertLevel = alertLevel
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: detectedAt)
    }

    var confidencePercent: Int {
        Int(confidence * 100)
    }
}

// MARK: - SoundCategory

enum SoundCategory: String, CaseIterable, Sendable {
    case vehicle = "乗り物"
    case alarm = "アラーム"
    case animal = "動物"
    case human = "人の声"
    case nature = "自然"
    case music = "音楽"
    case household = "家庭"
    case machinery = "機械"
    case other = "その他"

    var systemImage: String {
        switch self {
        case .vehicle: "car.fill"
        case .alarm: "bell.badge.fill"
        case .animal: "pawprint.fill"
        case .human: "person.wave.2.fill"
        case .nature: "leaf.fill"
        case .music: "music.note"
        case .household: "house.fill"
        case .machinery: "gearshape.2.fill"
        case .other: "waveform"
        }
    }

    var color: Color {
        switch self {
        case .vehicle: .blue
        case .alarm: .red
        case .animal: .green
        case .human: .purple
        case .nature: .teal
        case .music: .pink
        case .household: .orange
        case .machinery: .gray
        case .other: .secondary
        }
    }
}

// MARK: - AlertLevel

enum AlertLevel: String, CaseIterable, Sendable {
    case safe = "安全"
    case caution = "注意"
    case danger = "危険"

    var color: Color {
        switch self {
        case .safe: .green
        case .caution: .yellow
        case .danger: .red
        }
    }

    var systemImage: String {
        switch self {
        case .safe: "checkmark.shield.fill"
        case .caution: "exclamationmark.triangle.fill"
        case .danger: "xmark.octagon.fill"
        }
    }

    var hapticDescription: String {
        switch self {
        case .safe: "通知なし"
        case .caution: "軽い振動で注意喚起"
        case .danger: "強い振動で即座に通知"
        }
    }
}

// MARK: - SoundDirection

enum SoundDirection: String, CaseIterable, Sendable {
    case front = "前方"
    case back = "後方"
    case left = "左"
    case right = "右"
    case above = "上"
    case unknown = "不明"

    var systemImage: String {
        switch self {
        case .front: "arrow.up"
        case .back: "arrow.down"
        case .left: "arrow.left"
        case .right: "arrow.right"
        case .above: "arrow.up.circle"
        case .unknown: "circle.dotted"
        }
    }

    var rotationAngle: Double {
        switch self {
        case .front: 0
        case .back: 180
        case .left: 270
        case .right: 90
        case .above: 0
        case .unknown: 0
        }
    }
}

// MARK: - SituationSummary

struct SituationSummary: Identifiable, Sendable {
    let id: UUID
    var description: String
    var alertLevel: AlertLevel
    var soundEvents: [SoundEvent]
    var generatedAt: Date

    init(
        id: UUID = UUID(),
        description: String,
        alertLevel: AlertLevel,
        soundEvents: [SoundEvent],
        generatedAt: Date = Date()
    ) {
        self.id = id
        self.description = description
        self.alertLevel = alertLevel
        self.soundEvents = soundEvents
        self.generatedAt = generatedAt
    }
}

// MARK: - ListeningProfile

struct ListeningProfile: Identifiable, Sendable {
    let id: UUID
    var name: String
    var description: String
    var prioritySounds: [SoundCategory]
    var isActive: Bool
    var systemImage: String

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        prioritySounds: [SoundCategory],
        isActive: Bool = false,
        systemImage: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.prioritySounds = prioritySounds
        self.isActive = isActive
        self.systemImage = systemImage
    }
}

// MARK: - Sample Data

extension SoundEvent {
    static let samples: [SoundEvent] = [
        SoundEvent(
            category: .vehicle,
            label: "救急車のサイレン",
            confidence: 0.95,
            direction: .right,
            detectedAt: Date().addingTimeInterval(-5),
            alertLevel: .danger
        ),
        SoundEvent(
            category: .human,
            label: "会話（2人以上）",
            confidence: 0.88,
            direction: .left,
            detectedAt: Date().addingTimeInterval(-12),
            alertLevel: .safe
        ),
        SoundEvent(
            category: .music,
            label: "BGM（ジャズ）",
            confidence: 0.82,
            direction: .front,
            detectedAt: Date().addingTimeInterval(-20),
            alertLevel: .safe
        ),
        SoundEvent(
            category: .alarm,
            label: "ドアベル",
            confidence: 0.91,
            direction: .back,
            detectedAt: Date().addingTimeInterval(-30),
            alertLevel: .caution
        ),
        SoundEvent(
            category: .animal,
            label: "犬の鳴き声",
            confidence: 0.87,
            direction: .right,
            detectedAt: Date().addingTimeInterval(-45),
            alertLevel: .safe
        ),
        SoundEvent(
            category: .nature,
            label: "雨音",
            confidence: 0.93,
            direction: .above,
            detectedAt: Date().addingTimeInterval(-60),
            alertLevel: .safe
        ),
        SoundEvent(
            category: .household,
            label: "電子レンジ",
            confidence: 0.79,
            direction: .back,
            detectedAt: Date().addingTimeInterval(-90),
            alertLevel: .caution
        ),
        SoundEvent(
            category: .vehicle,
            label: "クラクション",
            confidence: 0.96,
            direction: .front,
            detectedAt: Date().addingTimeInterval(-120),
            alertLevel: .danger
        ),
    ]
}

extension ListeningProfile {
    static let samples: [ListeningProfile] = [
        ListeningProfile(
            name: "外出モード",
            description: "交通音や危険な音を優先的に検出",
            prioritySounds: [.vehicle, .alarm, .human],
            isActive: true,
            systemImage: "figure.walk"
        ),
        ListeningProfile(
            name: "自宅モード",
            description: "家庭の音やドアベルを中心に検出",
            prioritySounds: [.household, .alarm, .animal],
            systemImage: "house.fill"
        ),
        ListeningProfile(
            name: "オフィスモード",
            description: "会話や電話の着信を検出",
            prioritySounds: [.human, .alarm, .machinery],
            systemImage: "building.2.fill"
        ),
        ListeningProfile(
            name: "睡眠モード",
            description: "アラームや緊急音のみ検出",
            prioritySounds: [.alarm],
            systemImage: "moon.fill"
        ),
    ]
}
