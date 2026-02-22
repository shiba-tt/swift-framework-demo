import Foundation

/// 撮影条件の評価結果
struct PhotoCondition: Identifiable, Sendable {
    let id = UUID()
    let type: PhotoConditionType
    let score: Double
    let label: String
    let detail: String

    var scorePercent: Int { Int(score * 100) }

    var scoreColor: String {
        switch score {
        case 0.8...: return "green"
        case 0.5...: return "yellow"
        default:     return "red"
        }
    }
}

/// 撮影条件の種別
enum PhotoConditionType: String, CaseIterable, Sendable {
    case sunset = "夕焼け"
    case sunrise = "朝焼け"
    case goldenHour = "ゴールデンアワー"
    case blueHour = "ブルーアワー"
    case rainbow = "虹"
    case stargazing = "星空"
    case landscape = "風景"
    case portrait = "ポートレート"

    var emoji: String {
        switch self {
        case .sunset:     return "🌅"
        case .sunrise:    return "🌄"
        case .goldenHour: return "✨"
        case .blueHour:   return "🌆"
        case .rainbow:    return "🌈"
        case .stargazing: return "🌌"
        case .landscape:  return "🏔️"
        case .portrait:   return "📸"
        }
    }

    var systemImageName: String {
        switch self {
        case .sunset:     return "sunset.fill"
        case .sunrise:    return "sunrise.fill"
        case .goldenHour: return "sun.and.horizon.fill"
        case .blueHour:   return "moon.and.stars"
        case .rainbow:    return "rainbow"
        case .stargazing: return "star.fill"
        case .landscape:  return "mountain.2.fill"
        case .portrait:   return "person.fill"
        }
    }

    var description: String {
        switch self {
        case .sunset:     return "高層雲が多く低層雲が少ない条件で美しい夕焼けに"
        case .sunrise:    return "東の空の雲量と視程が朝焼けの美しさを決定"
        case .goldenHour: return "日の出/日の入り前後の暖かく柔らかい光"
        case .blueHour:   return "日没後/日の出前の深い青の時間帯"
        case .rainbow:    return "雨上がり+太陽光の条件で虹が出現"
        case .stargazing: return "低雲量・低湿度・新月に近い条件が最適"
        case .landscape:  return "高視程・適度な雲量がドラマチックな風景に"
        case .portrait:   return "柔らかい光・低UV・適度な気温が快適な撮影条件"
        }
    }
}
