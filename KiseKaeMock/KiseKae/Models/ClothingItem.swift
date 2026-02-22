import Foundation

/// 衣類のカテゴリ
enum ClothingCategory: String, Sendable, CaseIterable {
    case outer = "アウター"
    case top = "トップス"
    case bottom = "ボトムス"
    case shoes = "シューズ"
    case accessory = "アクセサリー"

    var systemImageName: String {
        switch self {
        case .outer:     return "jacket.fill"
        case .top:       return "tshirt.fill"
        case .bottom:    return "figure.stand"
        case .shoes:     return "shoe.fill"
        case .accessory: return "bag.fill"
        }
    }

    var sortOrder: Int {
        switch self {
        case .outer:     return 0
        case .top:       return 1
        case .bottom:    return 2
        case .shoes:     return 3
        case .accessory: return 4
        }
    }
}

/// 衣類アイテム
struct ClothingItem: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let category: ClothingCategory
    let emoji: String
    let minTemp: Double
    let maxTemp: Double
    let rainSuitable: Bool
    let uvProtection: Bool
    let windProtection: Bool
    let description: String

    /// 現在の天気に対する適合度（0〜1）
    func suitability(for weather: WeatherSnapshot) -> Double {
        var score = 0.0

        // 気温適合度
        if weather.temperature >= minTemp && weather.temperature <= maxTemp {
            score += 0.4
        } else {
            let distance = min(abs(weather.temperature - minTemp), abs(weather.temperature - maxTemp))
            score += max(0, 0.4 - distance * 0.04)
        }

        // 雨対応
        if weather.precipitationChance > 0.5 {
            score += rainSuitable ? 0.25 : 0.0
        } else {
            score += 0.15
        }

        // UV 対策
        if weather.uvIndex >= 6 {
            score += uvProtection ? 0.2 : 0.0
        } else {
            score += 0.1
        }

        // 防風
        if weather.windSpeed > 5 {
            score += windProtection ? 0.15 : 0.0
        } else {
            score += 0.1
        }

        return min(1.0, score)
    }

    // MARK: - アイテムカタログ

    static let allItems: [ClothingItem] = outerItems + topItems + bottomItems + shoeItems + accessoryItems

    static let outerItems: [ClothingItem] = [
        ClothingItem(name: "トレンチコート", category: .outer, emoji: "🧥",
                     minTemp: 10, maxTemp: 20, rainSuitable: true,
                     uvProtection: false, windProtection: true,
                     description: "春秋の定番。風を防ぎつつ軽やかに"),
        ClothingItem(name: "ダウンジャケット", category: .outer, emoji: "🧥",
                     minTemp: -5, maxTemp: 10, rainSuitable: false,
                     uvProtection: false, windProtection: true,
                     description: "真冬の寒さもしっかりガード"),
        ClothingItem(name: "UVカットパーカー", category: .outer, emoji: "🧥",
                     minTemp: 20, maxTemp: 35, rainSuitable: false,
                     uvProtection: true, windProtection: false,
                     description: "日差しの強い日の紫外線対策に"),
        ClothingItem(name: "レインコート", category: .outer, emoji: "🧥",
                     minTemp: 5, maxTemp: 30, rainSuitable: true,
                     uvProtection: false, windProtection: true,
                     description: "雨の日もアクティブに過ごせる"),
        ClothingItem(name: "カーディガン", category: .outer, emoji: "🧥",
                     minTemp: 15, maxTemp: 25, rainSuitable: false,
                     uvProtection: false, windProtection: false,
                     description: "気温差のある日の温度調節に"),
    ]

    static let topItems: [ClothingItem] = [
        ClothingItem(name: "半袖Tシャツ", category: .top, emoji: "👕",
                     minTemp: 25, maxTemp: 40, rainSuitable: false,
                     uvProtection: false, windProtection: false,
                     description: "夏の基本アイテム"),
        ClothingItem(name: "長袖シャツ", category: .top, emoji: "👔",
                     minTemp: 15, maxTemp: 28, rainSuitable: false,
                     uvProtection: true, windProtection: false,
                     description: "オフィスカジュアルにも最適"),
        ClothingItem(name: "ニットセーター", category: .top, emoji: "🧶",
                     minTemp: 0, maxTemp: 15, rainSuitable: false,
                     uvProtection: false, windProtection: false,
                     description: "秋冬のあったかアイテム"),
        ClothingItem(name: "リネンシャツ", category: .top, emoji: "👔",
                     minTemp: 22, maxTemp: 38, rainSuitable: false,
                     uvProtection: false, windProtection: false,
                     description: "通気性抜群で蒸し暑い日に"),
    ]

    static let bottomItems: [ClothingItem] = [
        ClothingItem(name: "デニムパンツ", category: .bottom, emoji: "👖",
                     minTemp: 5, maxTemp: 25, rainSuitable: false,
                     uvProtection: false, windProtection: true,
                     description: "オールシーズン使える定番"),
        ClothingItem(name: "ショートパンツ", category: .bottom, emoji: "🩳",
                     minTemp: 25, maxTemp: 40, rainSuitable: false,
                     uvProtection: false, windProtection: false,
                     description: "暑い日は涼しく軽快に"),
        ClothingItem(name: "撥水チノパン", category: .bottom, emoji: "👖",
                     minTemp: 10, maxTemp: 30, rainSuitable: true,
                     uvProtection: false, windProtection: true,
                     description: "雨の日も安心の撥水加工"),
        ClothingItem(name: "ウールパンツ", category: .bottom, emoji: "👖",
                     minTemp: -5, maxTemp: 12, rainSuitable: false,
                     uvProtection: false, windProtection: true,
                     description: "冬の防寒に暖かいウール素材"),
    ]

    static let shoeItems: [ClothingItem] = [
        ClothingItem(name: "スニーカー", category: .shoes, emoji: "👟",
                     minTemp: 10, maxTemp: 35, rainSuitable: false,
                     uvProtection: false, windProtection: false,
                     description: "歩きやすさ重視の定番"),
        ClothingItem(name: "レインブーツ", category: .shoes, emoji: "🥾",
                     minTemp: 5, maxTemp: 30, rainSuitable: true,
                     uvProtection: false, windProtection: true,
                     description: "雨の日の頼れる相棒"),
        ClothingItem(name: "サンダル", category: .shoes, emoji: "🩴",
                     minTemp: 25, maxTemp: 40, rainSuitable: false,
                     uvProtection: false, windProtection: false,
                     description: "夏の足元は涼しく"),
        ClothingItem(name: "防寒ブーツ", category: .shoes, emoji: "🥾",
                     minTemp: -10, maxTemp: 8, rainSuitable: true,
                     uvProtection: false, windProtection: true,
                     description: "雪や寒さから足を守る"),
    ]

    static let accessoryItems: [ClothingItem] = [
        ClothingItem(name: "折りたたみ傘", category: .accessory, emoji: "🌂",
                     minTemp: -10, maxTemp: 40, rainSuitable: true,
                     uvProtection: false, windProtection: false,
                     description: "降水確率が高い日の必需品"),
        ClothingItem(name: "サングラス", category: .accessory, emoji: "🕶️",
                     minTemp: -10, maxTemp: 40, rainSuitable: false,
                     uvProtection: true, windProtection: false,
                     description: "UV から目を守る"),
        ClothingItem(name: "帽子", category: .accessory, emoji: "🧢",
                     minTemp: -10, maxTemp: 40, rainSuitable: false,
                     uvProtection: true, windProtection: false,
                     description: "直射日光から頭を守る"),
        ClothingItem(name: "マフラー", category: .accessory, emoji: "🧣",
                     minTemp: -10, maxTemp: 10, rainSuitable: false,
                     uvProtection: false, windProtection: true,
                     description: "冬の防寒に首元を暖かく"),
    ]
}
