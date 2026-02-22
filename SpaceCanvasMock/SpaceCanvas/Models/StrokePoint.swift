import SwiftUI

struct StrokePoint: Identifiable, Sendable {
    let id: UUID
    let position: SIMD3<Float>
    let color: StrokeColor
    let thickness: Float
    let timestamp: Date

    init(
        id: UUID = UUID(),
        position: SIMD3<Float>,
        color: StrokeColor,
        thickness: Float = 3.0,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.position = position
        self.color = color
        self.thickness = thickness
        self.timestamp = timestamp
    }
}

struct Stroke: Identifiable, Sendable {
    let id: UUID
    let artistName: String
    let color: StrokeColor
    let thickness: Float
    var points: [StrokePoint]
    let createdAt: Date

    init(
        id: UUID = UUID(),
        artistName: String,
        color: StrokeColor,
        thickness: Float = 3.0,
        points: [StrokePoint] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.artistName = artistName
        self.color = color
        self.thickness = thickness
        self.points = points
        self.createdAt = createdAt
    }

    var pointCount: Int { points.count }
}

enum StrokeColor: String, CaseIterable, Identifiable, Sendable {
    case red, orange, yellow, green, cyan, blue, purple, pink, white

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .cyan: return .cyan
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .white: return .white
        }
    }

    var displayName: String {
        switch self {
        case .red: return "赤"
        case .orange: return "オレンジ"
        case .yellow: return "黄"
        case .green: return "緑"
        case .cyan: return "水色"
        case .blue: return "青"
        case .purple: return "紫"
        case .pink: return "ピンク"
        case .white: return "白"
        }
    }
}

enum BrushThickness: Float, CaseIterable, Identifiable, Sendable {
    case thin = 1.5
    case medium = 3.0
    case thick = 6.0
    case extraThick = 10.0

    var id: Float { rawValue }

    var displayName: String {
        switch self {
        case .thin: return "極細"
        case .medium: return "標準"
        case .thick: return "太"
        case .extraThick: return "極太"
        }
    }
}
