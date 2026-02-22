import Foundation

/// 撮影スポットのモデル
struct PhotoSpot: Identifiable, Sendable {
    let id: UUID
    let name: String
    let category: SpotCategory
    let latitude: Double
    let longitude: Double
    let bestConditions: [PhotoConditionType]
    let description: String

    var distanceText: String {
        let distance = Double.random(in: 0.3...15.0)
        if distance < 1.0 {
            return String(format: "%.0f m", distance * 1000)
        }
        return String(format: "%.1f km", distance)
    }

    static let samples: [PhotoSpot] = [
        PhotoSpot(
            id: UUID(), name: "東京タワー展望台",
            category: .landmark,
            latitude: 35.6586, longitude: 139.7454,
            bestConditions: [.sunset, .goldenHour, .landscape],
            description: "東京のシンボルからの絶景。夕焼け時は富士山のシルエットも"
        ),
        PhotoSpot(
            id: UUID(), name: "お台場海浜公園",
            category: .waterfront,
            latitude: 35.6290, longitude: 139.7745,
            bestConditions: [.sunset, .blueHour, .rainbow],
            description: "レインボーブリッジ越しの夕焼けが絶景"
        ),
        PhotoSpot(
            id: UUID(), name: "代々木公園",
            category: .nature,
            latitude: 35.6715, longitude: 139.6949,
            bestConditions: [.goldenHour, .portrait, .landscape],
            description: "木漏れ日のポートレートや四季折々の風景"
        ),
        PhotoSpot(
            id: UUID(), name: "奥多摩湖",
            category: .nature,
            latitude: 35.7920, longitude: 139.0220,
            bestConditions: [.sunrise, .landscape, .stargazing],
            description: "都心から最も近い星空スポット。朝霧の風景も幻想的"
        ),
        PhotoSpot(
            id: UUID(), name: "スカイツリー天望デッキ",
            category: .landmark,
            latitude: 35.7101, longitude: 139.8107,
            bestConditions: [.sunset, .blueHour, .landscape],
            description: "地上350mからの広大な眺望。関東平野を一望"
        ),
        PhotoSpot(
            id: UUID(), name: "井の頭恩賜公園",
            category: .nature,
            latitude: 35.6999, longitude: 139.5724,
            bestConditions: [.goldenHour, .portrait, .rainbow],
            description: "池を囲む緑と光のコントラストが美しい"
        ),
    ]
}

enum SpotCategory: String, CaseIterable, Sendable {
    case landmark = "ランドマーク"
    case nature = "自然"
    case waterfront = "水辺"
    case urban = "都市"

    var emoji: String {
        switch self {
        case .landmark:  return "🏛️"
        case .nature:    return "🌿"
        case .waterfront: return "🌊"
        case .urban:     return "🏙️"
        }
    }

    var systemImageName: String {
        switch self {
        case .landmark:  return "building.columns.fill"
        case .nature:    return "leaf.fill"
        case .waterfront: return "water.waves"
        case .urban:     return "building.2.fill"
        }
    }
}
