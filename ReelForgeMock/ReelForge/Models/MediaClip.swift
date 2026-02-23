import SwiftUI

// MARK: - MediaClip

struct MediaClip: Identifiable, Sendable {
    let id: UUID
    let type: MediaType
    let duration: TimeInterval
    let thumbnail: String
    let createdAt: Date
    let smileScore: Double
    let stabilityScore: Double
    let sceneCategory: SceneCategory
    let isSelected: Bool
    let trimStart: TimeInterval
    let trimEnd: TimeInterval

    var trimmedDuration: TimeInterval {
        trimEnd - trimStart
    }

    var durationText: String {
        let seconds = Int(duration)
        if seconds >= 60 {
            return String(format: "%d:%02d", seconds / 60, seconds % 60)
        }
        return String(format: "0:%02d", seconds)
    }

    var overallScore: Double {
        (smileScore * 0.4 + stabilityScore * 0.3 + sceneCategory.interestScore * 0.3)
    }

    var scoreColor: Color {
        switch overallScore {
        case 0.8...: return .green
        case 0.5...: return .yellow
        default: return .orange
        }
    }
}

// MARK: - MediaType

enum MediaType: String, Sendable, CaseIterable, Identifiable {
    case video = "動画"
    case photo = "写真"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .video: return "🎬"
        case .photo: return "📸"
        }
    }

    var systemImageName: String {
        switch self {
        case .video: return "video.fill"
        case .photo: return "photo.fill"
        }
    }
}

// MARK: - SceneCategory

enum SceneCategory: String, Sendable, CaseIterable, Identifiable {
    case landscape = "景色"
    case food = "食事"
    case people = "人物"
    case animal = "動物"
    case architecture = "建築"
    case action = "アクション"
    case night = "夜景"
    case nature = "自然"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .landscape: return "🏔️"
        case .food: return "🍽️"
        case .people: return "👥"
        case .animal: return "🐾"
        case .architecture: return "🏛️"
        case .action: return "⚡"
        case .night: return "🌃"
        case .nature: return "🌿"
        }
    }

    var color: Color {
        switch self {
        case .landscape: return .blue
        case .food: return .orange
        case .people: return .pink
        case .animal: return .brown
        case .architecture: return .gray
        case .action: return .red
        case .night: return .indigo
        case .nature: return .green
        }
    }

    var interestScore: Double {
        switch self {
        case .people: return 0.9
        case .action: return 0.85
        case .animal: return 0.8
        case .food: return 0.75
        case .landscape: return 0.7
        case .night: return 0.7
        case .nature: return 0.65
        case .architecture: return 0.6
        }
    }
}

// MARK: - Sample Data

extension MediaClip {
    static let samples: [MediaClip] = {
        let calendar = Calendar.current
        let now = Date()
        return [
            MediaClip(
                id: UUID(), type: .video, duration: 12.5, thumbnail: "beach",
                createdAt: calendar.date(byAdding: .hour, value: -3, to: now)!,
                smileScore: 0.92, stabilityScore: 0.85, sceneCategory: .landscape,
                isSelected: true, trimStart: 1.0, trimEnd: 10.5
            ),
            MediaClip(
                id: UUID(), type: .video, duration: 8.0, thumbnail: "dinner",
                createdAt: calendar.date(byAdding: .hour, value: -5, to: now)!,
                smileScore: 0.78, stabilityScore: 0.90, sceneCategory: .food,
                isSelected: true, trimStart: 0.0, trimEnd: 6.0
            ),
            MediaClip(
                id: UUID(), type: .photo, duration: 3.0, thumbnail: "group",
                createdAt: calendar.date(byAdding: .hour, value: -6, to: now)!,
                smileScore: 0.95, stabilityScore: 1.0, sceneCategory: .people,
                isSelected: true, trimStart: 0.0, trimEnd: 3.0
            ),
            MediaClip(
                id: UUID(), type: .video, duration: 15.0, thumbnail: "dog",
                createdAt: calendar.date(byAdding: .hour, value: -8, to: now)!,
                smileScore: 0.88, stabilityScore: 0.60, sceneCategory: .animal,
                isSelected: false, trimStart: 0.0, trimEnd: 15.0
            ),
            MediaClip(
                id: UUID(), type: .video, duration: 20.0, thumbnail: "temple",
                createdAt: calendar.date(byAdding: .hour, value: -10, to: now)!,
                smileScore: 0.50, stabilityScore: 0.95, sceneCategory: .architecture,
                isSelected: true, trimStart: 3.0, trimEnd: 12.0
            ),
            MediaClip(
                id: UUID(), type: .video, duration: 6.0, thumbnail: "sunset",
                createdAt: calendar.date(byAdding: .hour, value: -12, to: now)!,
                smileScore: 0.40, stabilityScore: 0.92, sceneCategory: .night,
                isSelected: true, trimStart: 0.5, trimEnd: 5.5
            ),
            MediaClip(
                id: UUID(), type: .photo, duration: 3.0, thumbnail: "flowers",
                createdAt: calendar.date(byAdding: .hour, value: -14, to: now)!,
                smileScore: 0.30, stabilityScore: 1.0, sceneCategory: .nature,
                isSelected: false, trimStart: 0.0, trimEnd: 3.0
            ),
            MediaClip(
                id: UUID(), type: .video, duration: 10.0, thumbnail: "surfing",
                createdAt: calendar.date(byAdding: .hour, value: -16, to: now)!,
                smileScore: 0.85, stabilityScore: 0.55, sceneCategory: .action,
                isSelected: true, trimStart: 2.0, trimEnd: 8.0
            ),
            MediaClip(
                id: UUID(), type: .video, duration: 18.0, thumbnail: "market",
                createdAt: calendar.date(byAdding: .hour, value: -20, to: now)!,
                smileScore: 0.72, stabilityScore: 0.78, sceneCategory: .people,
                isSelected: false, trimStart: 0.0, trimEnd: 18.0
            ),
            MediaClip(
                id: UUID(), type: .photo, duration: 3.0, thumbnail: "sushi",
                createdAt: calendar.date(byAdding: .hour, value: -22, to: now)!,
                smileScore: 0.65, stabilityScore: 1.0, sceneCategory: .food,
                isSelected: true, trimStart: 0.0, trimEnd: 3.0
            ),
        ]
    }()
}
