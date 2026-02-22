import Foundation

// MARK: - SpotCategory

enum SpotCategory: String, CaseIterable, Identifiable, Sendable {
    case castle = "城"
    case temple = "寺社仏閣"
    case bridge = "橋"
    case street = "街並み"
    case station = "駅"
    case landmark = "ランドマーク"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .castle: "building.columns"
        case .temple: "house.lodge"
        case .bridge: "road.lanes"
        case .street: "building.2"
        case .station: "tram"
        case .landmark: "mappin.and.ellipse"
        }
    }
}

// MARK: - EraSnapshot

struct EraSnapshot: Identifiable, Sendable {
    let id: UUID
    let era: HistoricalEra
    let title: String
    let description: String
    let modelName: String
    let audioGuideDuration: TimeInterval

    init(
        id: UUID = UUID(),
        era: HistoricalEra,
        title: String,
        description: String,
        modelName: String,
        audioGuideDuration: TimeInterval = 60
    ) {
        self.id = id
        self.era = era
        self.title = title
        self.description = description
        self.modelName = modelName
        self.audioGuideDuration = audioGuideDuration
    }

    var durationText: String {
        let minutes = Int(audioGuideDuration) / 60
        let seconds = Int(audioGuideDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - HistoricalSpot

struct HistoricalSpot: Identifiable, Sendable {
    let id: UUID
    let name: String
    let subtitle: String
    let description: String
    let category: SpotCategory
    let latitude: Double
    let longitude: Double
    let nfcTagID: String
    let snapshots: [EraSnapshot]

    init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        description: String,
        category: SpotCategory,
        latitude: Double,
        longitude: Double,
        nfcTagID: String,
        snapshots: [EraSnapshot]
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.description = description
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.nfcTagID = nfcTagID
        self.snapshots = snapshots
    }

    var availableEras: [HistoricalEra] {
        snapshots.map(\.era)
    }

    var yearRange: String {
        guard let oldest = snapshots.map(\.era.year).min(),
              let newest = snapshots.map(\.era.year).max() else {
            return ""
        }
        return "\(oldest)年 〜 \(newest)年"
    }

    func snapshot(for era: HistoricalEra) -> EraSnapshot? {
        snapshots.first { $0.era.id == era.id }
    }
}
