import Foundation

/// 植物の診断結果
struct DiagnosisResult: Identifiable, Sendable {
    let id = UUID()
    let plantName: String
    let species: PlantSpecies
    let healthScore: Int
    let healthStatus: PlantHealthStatus
    let symptoms: [PlantSymptom]
    let possibleCauses: [String]
    let careRecommendations: [String]
    let nextWateringDays: Int
    let diagnosisDate: Date

    /// 症状の有無
    var hasSymptoms: Bool {
        !symptoms.isEmpty
    }

    /// 診断サマリーテキスト
    var summaryText: String {
        if symptoms.isEmpty {
            return "\(plantName)は健康な状態です。このまま適切なケアを続けてください。"
        } else {
            let symptomNames = symptoms.map(\.name).joined(separator: "、")
            return "\(plantName)に\(symptomNames)の症状が見られます。早めの対処をおすすめします。"
        }
    }
}

// MARK: - PlantSymptom

/// 検出された症状
struct PlantSymptom: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let type: SymptomType
    let severity: SymptomSeverity
    let description: String
    let affectedArea: String

    /// 緊急度テキスト
    var urgencyText: String {
        switch severity {
        case .mild: "経過観察"
        case .moderate: "早めに対処"
        case .severe: "すぐに対処が必要"
        }
    }
}

// MARK: - SymptomType

/// 症状の種類
enum SymptomType: String, CaseIterable, Sendable {
    case yellowing = "黄変"
    case browning = "褐変"
    case wilting = "萎れ"
    case spots = "斑点"
    case pestDamage = "害虫被害"
    case rootRot = "根腐れ"
    case leafDrop = "落葉"
    case mold = "カビ"

    var emoji: String {
        switch self {
        case .yellowing: "🟡"
        case .browning: "🟤"
        case .wilting: "🥀"
        case .spots: "⚫"
        case .pestDamage: "🐛"
        case .rootRot: "🫠"
        case .leafDrop: "🍂"
        case .mold: "🦠"
        }
    }

    var systemImageName: String {
        switch self {
        case .yellowing: "circle.fill"
        case .browning: "leaf.fill"
        case .wilting: "arrow.down.circle"
        case .spots: "circle.dotted"
        case .pestDamage: "ant.fill"
        case .rootRot: "drop.triangle.fill"
        case .leafDrop: "leaf.arrow.triangle.circlepath"
        case .mold: "aqi.medium"
        }
    }
}

// MARK: - SymptomSeverity

/// 症状の重症度
enum SymptomSeverity: String, Sendable {
    case mild = "軽度"
    case moderate = "中度"
    case severe = "重度"

    var colorName: String {
        switch self {
        case .mild: "yellow"
        case .moderate: "orange"
        case .severe: "red"
        }
    }
}

// MARK: - DiagnosisRecord

/// 診断履歴のレコード
struct DiagnosisRecord: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let healthScore: Int
    let symptomCount: Int

    /// 日付テキスト
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E) HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    /// 短い日付テキスト
    var shortDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
