import Foundation
import SwiftUI

// MARK: - MuseumRoom

struct MuseumRoom: Identifiable, Sendable {
    let id: UUID
    var name: String
    var width: Double
    var depth: Double
    var height: Double
    var wallSegments: [WallSegment]
    var scanDate: Date
    var isScanned: Bool

    init(
        id: UUID = UUID(),
        name: String = "マイルーム",
        width: Double = 4.0,
        depth: Double = 5.0,
        height: Double = 2.5,
        wallSegments: [WallSegment] = [],
        scanDate: Date = Date(),
        isScanned: Bool = false
    ) {
        self.id = id
        self.name = name
        self.width = width
        self.depth = depth
        self.height = height
        self.wallSegments = wallSegments
        self.scanDate = scanDate
        self.isScanned = isScanned
    }

    var floorArea: Double { width * depth }

    var formattedArea: String {
        String(format: "%.1f m\u{00B2}", floorArea)
    }

    var formattedDimensions: String {
        String(format: "%.1f x %.1f x %.1f m", width, depth, height)
    }
}

// MARK: - WallSegment

struct WallSegment: Identifiable, Sendable {
    let id: UUID
    var direction: WallDirection
    var length: Double
    var availableWidth: Double
    var placedArtworkIDs: [UUID]

    init(
        id: UUID = UUID(),
        direction: WallDirection,
        length: Double,
        availableWidth: Double? = nil,
        placedArtworkIDs: [UUID] = []
    ) {
        self.id = id
        self.direction = direction
        self.length = length
        self.availableWidth = availableWidth ?? length
        self.placedArtworkIDs = placedArtworkIDs
    }
}

// MARK: - WallDirection

enum WallDirection: String, CaseIterable, Sendable {
    case north = "北"
    case south = "南"
    case east = "東"
    case west = "西"

    var color: Color {
        switch self {
        case .north: .blue
        case .south: .red
        case .east: .green
        case .west: .orange
        }
    }
}

// MARK: - SpotLight

struct SpotLight: Identifiable, Sendable {
    let id: UUID
    var color: Color
    var intensity: Double
    var temperature: Double
    var targetArtworkID: UUID?

    init(
        id: UUID = UUID(),
        color: Color = .white,
        intensity: Double = 0.8,
        temperature: Double = 4500,
        targetArtworkID: UUID? = nil
    ) {
        self.id = id
        self.color = color
        self.intensity = intensity
        self.temperature = temperature
        self.targetArtworkID = targetArtworkID
    }

    var temperatureLabel: String {
        switch temperature {
        case ..<3000: "暖色"
        case 3000..<4500: "電球色"
        case 4500..<5500: "昼白色"
        default: "昼光色"
        }
    }
}

// MARK: - Sample Data

extension MuseumRoom {
    static let sampleScanned = MuseumRoom(
        name: "リビングルーム",
        width: 5.2,
        depth: 4.8,
        height: 2.4,
        wallSegments: [
            WallSegment(direction: .north, length: 5.2, availableWidth: 3.8),
            WallSegment(direction: .south, length: 5.2, availableWidth: 2.5),
            WallSegment(direction: .east, length: 4.8, availableWidth: 4.0),
            WallSegment(direction: .west, length: 4.8, availableWidth: 1.5),
        ],
        scanDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
        isScanned: true
    )
}
