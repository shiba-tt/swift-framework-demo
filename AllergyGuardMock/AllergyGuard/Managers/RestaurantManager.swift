import Foundation

// MARK: - RestaurantManager

@MainActor
@Observable
final class RestaurantManager {

    static let shared = RestaurantManager()

    private(set) var restaurants: [Restaurant] = []

    private init() {
        restaurants = Self.generateSampleRestaurants()
    }

    func restaurant(for id: String) -> Restaurant? {
        restaurants.first { $0.id.uuidString == id }
    }

    // MARK: - Sample Data

    private static func generateSampleRestaurants() -> [Restaurant] {
        [
            Restaurant(
                name: "トラットリア・ジョイア",
                description: "本格イタリアンをカジュアルに楽しめるレストラン",
                cuisine: "イタリアン",
                address: "東京都渋谷区神南1-2-3",
                menuItems: [
                    MenuItem(
                        name: "カプレーゼ",
                        description: "フレッシュモッツァレラとトマトのサラダ",
                        category: .appetizer,
                        price: 980,
                        allergens: [.milk: .contains]
                    ),
                    MenuItem(
                        name: "生ハムとルッコラのサラダ",
                        description: "パルミジャーノを添えた季節のサラダ",
                        category: .appetizer,
                        price: 1100,
                        allergens: [.milk: .contains]
                    ),
                    MenuItem(
                        name: "ミネストローネ",
                        description: "たっぷり野菜のトマトスープ",
                        category: .appetizer,
                        price: 780,
                        allergens: [.wheat: .mayContain, .soy: .mayContain]
                    ),
                    MenuItem(
                        name: "カルボナーラ",
                        description: "自家製パンチェッタの濃厚カルボナーラ",
                        category: .pasta,
                        price: 1400,
                        allergens: [.egg: .contains, .milk: .contains, .wheat: .contains]
                    ),
                    MenuItem(
                        name: "ペスカトーレ",
                        description: "シーフードたっぷりのトマトソースパスタ",
                        category: .pasta,
                        price: 1600,
                        allergens: [.wheat: .contains, .shrimp: .contains, .crab: .mayContain, .egg: .mayContain]
                    ),
                    MenuItem(
                        name: "ジェノベーゼ",
                        description: "自家製バジルペーストのパスタ",
                        category: .pasta,
                        price: 1300,
                        allergens: [.wheat: .contains, .milk: .contains, .cashew: .contains]
                    ),
                    MenuItem(
                        name: "マルゲリータピッツァ",
                        description: "薪窯焼きの定番ピッツァ",
                        category: .main,
                        price: 1500,
                        allergens: [.wheat: .contains, .milk: .contains]
                    ),
                    MenuItem(
                        name: "仔羊のグリル",
                        description: "ローズマリー風味の骨付き仔羊",
                        category: .main,
                        price: 2800,
                        allergens: [:]
                    ),
                    MenuItem(
                        name: "鮮魚のアクアパッツァ",
                        description: "本日の鮮魚をトマトとオリーブで煮込みました",
                        category: .main,
                        price: 2200,
                        allergens: [.shrimp: .mayContain]
                    ),
                    MenuItem(
                        name: "ティラミス",
                        description: "マスカルポーネの自家製ティラミス",
                        category: .dessert,
                        price: 680,
                        allergens: [.egg: .contains, .milk: .contains, .wheat: .contains]
                    ),
                    MenuItem(
                        name: "パンナコッタ",
                        description: "バニラ香るなめらかパンナコッタ",
                        category: .dessert,
                        price: 580,
                        allergens: [.milk: .contains]
                    ),
                    MenuItem(
                        name: "ジェラート盛り合わせ",
                        description: "本日のジェラート3種",
                        category: .dessert,
                        price: 750,
                        allergens: [.milk: .contains, .egg: .mayContain, .almond: .mayContain]
                    ),
                    MenuItem(
                        name: "エスプレッソ",
                        description: "イタリア直輸入の豆を使用",
                        category: .drink,
                        price: 400,
                        allergens: [:]
                    ),
                    MenuItem(
                        name: "カフェラテ",
                        description: "エスプレッソにスチームミルクを合わせて",
                        category: .drink,
                        price: 500,
                        allergens: [.milk: .contains]
                    ),
                ],
                supportedLanguages: ["ja", "en", "it"]
            ),
            Restaurant(
                name: "蕎麦処 やまと",
                description: "石臼挽き十割蕎麦と季節の天ぷら",
                cuisine: "和食・蕎麦",
                address: "東京都文京区本郷3-4-5",
                menuItems: [
                    MenuItem(
                        name: "ざるそば",
                        description: "石臼挽きの十割蕎麦",
                        category: .main,
                        price: 900,
                        allergens: [.buckwheat: .contains, .wheat: .mayContain]
                    ),
                    MenuItem(
                        name: "天ざるそば",
                        description: "海老天2本と季節の野菜天付き",
                        category: .main,
                        price: 1500,
                        allergens: [.buckwheat: .contains, .shrimp: .contains, .wheat: .contains, .egg: .contains]
                    ),
                    MenuItem(
                        name: "鴨南蛮そば",
                        description: "合鴨のつくねと九条ねぎの温蕎麦",
                        category: .main,
                        price: 1400,
                        allergens: [.buckwheat: .contains, .wheat: .mayContain, .soy: .contains, .egg: .mayContain]
                    ),
                    MenuItem(
                        name: "うどん（かけ）",
                        description: "国産小麦の手打ちうどん",
                        category: .main,
                        price: 800,
                        allergens: [.wheat: .contains, .soy: .contains]
                    ),
                    MenuItem(
                        name: "天ぷら盛り合わせ",
                        description: "海老・かぼちゃ・なす・しそ・まいたけ",
                        category: .appetizer,
                        price: 1200,
                        allergens: [.shrimp: .contains, .wheat: .contains, .egg: .contains]
                    ),
                    MenuItem(
                        name: "だし巻き卵",
                        description: "ふわふわのだし巻き卵、大根おろし添え",
                        category: .appetizer,
                        price: 650,
                        allergens: [.egg: .contains, .soy: .contains]
                    ),
                    MenuItem(
                        name: "冷奴",
                        description: "国産大豆の絹豆腐、薬味たっぷり",
                        category: .appetizer,
                        price: 450,
                        allergens: [.soy: .contains]
                    ),
                    MenuItem(
                        name: "そばがき",
                        description: "そば粉を練り上げた素朴な一品",
                        category: .appetizer,
                        price: 700,
                        allergens: [.buckwheat: .contains]
                    ),
                    MenuItem(
                        name: "抹茶アイス",
                        description: "宇治抹茶の濃厚アイスクリーム",
                        category: .dessert,
                        price: 500,
                        allergens: [.milk: .contains]
                    ),
                    MenuItem(
                        name: "わらび餅",
                        description: "黒蜜ときな粉のわらび餅",
                        category: .dessert,
                        price: 550,
                        allergens: [.soy: .contains]
                    ),
                    MenuItem(
                        name: "緑茶",
                        description: "静岡産の深蒸し煎茶",
                        category: .drink,
                        price: 300,
                        allergens: [:]
                    ),
                ],
                supportedLanguages: ["ja", "en", "zh"]
            ),
        ]
    }
}
