import Foundation

/// 登録された植物の情報
struct Plant: Identifiable, Sendable {
    let id: UUID
    var name: String
    var species: PlantSpecies
    var nickname: String
    var registeredDate: Date
    var lastDiagnosisDate: Date?
    var lastWateredDate: Date?
    var healthScore: Int
    var diagnosisHistory: [DiagnosisRecord]

    /// 水やりまでの推奨日数
    var nextWateringDays: Int {
        guard let lastWatered = lastWateredDate else { return 0 }
        let daysSinceWatered = Calendar.current.dateComponents(
            [.day], from: lastWatered, to: Date()
        ).day ?? 0
        let recommended = species.wateringIntervalDays
        return max(0, recommended - daysSinceWatered)
    }

    /// 水やりが必要かどうか
    var needsWatering: Bool {
        nextWateringDays == 0
    }

    /// 水やり状態テキスト
    var wateringStatusText: String {
        if needsWatering {
            return "水やりが必要です"
        } else if nextWateringDays == 1 {
            return "明日水やりしましょう"
        } else {
            return "あと\(nextWateringDays)日後"
        }
    }

    /// 登録からの経過日数
    var daysSinceRegistered: Int {
        Calendar.current.dateComponents([.day], from: registeredDate, to: Date()).day ?? 0
    }

    /// 健康状態
    var healthStatus: PlantHealthStatus {
        if healthScore >= 80 {
            return .healthy
        } else if healthScore >= 60 {
            return .mildIssue
        } else if healthScore >= 40 {
            return .moderate
        } else {
            return .serious
        }
    }
}

// MARK: - PlantSpecies

/// 植物の種類
enum PlantSpecies: String, CaseIterable, Sendable {
    case monstera = "モンステラ"
    case pothos = "ポトス"
    case ficus = "フィカス"
    case succulent = "多肉植物"
    case cactus = "サボテン"
    case herb = "ハーブ"
    case rose = "バラ"
    case orchid = "ラン"

    var emoji: String {
        switch self {
        case .monstera: "🪴"
        case .pothos: "🌿"
        case .ficus: "🌳"
        case .succulent: "🪷"
        case .cactus: "🌵"
        case .herb: "🌱"
        case .rose: "🌹"
        case .orchid: "🌸"
        }
    }

    var scientificName: String {
        switch self {
        case .monstera: "Monstera deliciosa"
        case .pothos: "Epipremnum aureum"
        case .ficus: "Ficus elastica"
        case .succulent: "Echeveria"
        case .cactus: "Cactaceae"
        case .herb: "Ocimum basilicum"
        case .rose: "Rosa"
        case .orchid: "Phalaenopsis"
        }
    }

    /// 推奨水やり間隔（日数）
    var wateringIntervalDays: Int {
        switch self {
        case .monstera: 7
        case .pothos: 7
        case .ficus: 5
        case .succulent: 14
        case .cactus: 21
        case .herb: 3
        case .rose: 4
        case .orchid: 10
        }
    }

    /// 推奨の明るさ
    var lightRequirement: String {
        switch self {
        case .monstera: "明るい間接光"
        case .pothos: "間接光〜半日陰"
        case .ficus: "明るい間接光"
        case .succulent: "直射日光"
        case .cactus: "直射日光"
        case .herb: "日当たり良好"
        case .rose: "日当たり良好"
        case .orchid: "明るい間接光"
        }
    }
}

// MARK: - PlantHealthStatus

/// 植物の健康状態
enum PlantHealthStatus: String, Sendable {
    case healthy = "健康"
    case mildIssue = "軽度の問題"
    case moderate = "要注意"
    case serious = "深刻"

    var emoji: String {
        switch self {
        case .healthy: "💚"
        case .mildIssue: "💛"
        case .moderate: "🧡"
        case .serious: "❤️‍🩹"
        }
    }

    var colorName: String {
        switch self {
        case .healthy: "green"
        case .mildIssue: "yellow"
        case .moderate: "orange"
        case .serious: "red"
        }
    }

    var systemImageName: String {
        switch self {
        case .healthy: "checkmark.circle.fill"
        case .mildIssue: "exclamationmark.circle.fill"
        case .moderate: "exclamationmark.triangle.fill"
        case .serious: "xmark.circle.fill"
        }
    }
}
