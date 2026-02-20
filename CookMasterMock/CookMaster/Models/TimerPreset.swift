import Foundation

// MARK: - タイマープリセット

/// よく使う料理タイマーのプリセット定義
struct TimerPreset: Identifiable, Codable, Sendable {
    let id: UUID
    /// プリセット名
    let name: String
    /// 料理カテゴリ
    let category: CookingCategory
    /// 時間（秒）
    let duration: TimeInterval
    /// 説明文
    let description: String

    init(
        id: UUID = UUID(),
        name: String,
        category: CookingCategory,
        duration: TimeInterval,
        description: String
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.duration = duration
        self.description = description
    }

    /// CookingTimer に変換
    func toCookingTimer() -> CookingTimer {
        CookingTimer(
            name: name,
            category: category,
            duration: duration,
            note: description
        )
    }
}

// MARK: - プリセットカタログ

/// プリセットのカテゴリ別グループ
struct PresetGroup: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let emoji: String
    let presets: [TimerPreset]
}

/// 組み込みプリセット一覧
enum PresetCatalog {

    // MARK: - パスタ・麺類

    static let pasta: [TimerPreset] = [
        TimerPreset(
            name: "スパゲッティ（アルデンテ）",
            category: .boil,
            duration: 8 * 60,
            description: "標準的なスパゲッティのアルデンテ茹で時間"
        ),
        TimerPreset(
            name: "スパゲッティ（柔らかめ）",
            category: .boil,
            duration: 10 * 60,
            description: "柔らかめに仕上げる場合"
        ),
        TimerPreset(
            name: "ペンネ",
            category: .boil,
            duration: 11 * 60,
            description: "ペンネのアルデンテ茹で時間"
        ),
        TimerPreset(
            name: "そうめん",
            category: .boil,
            duration: 2 * 60,
            description: "そうめんの茹で時間"
        ),
        TimerPreset(
            name: "うどん（冷凍）",
            category: .boil,
            duration: 1 * 60,
            description: "冷凍うどんの茹で時間"
        ),
        TimerPreset(
            name: "ラーメン（インスタント）",
            category: .boil,
            duration: 3 * 60,
            description: "インスタントラーメンの標準茹で時間"
        ),
    ]

    // MARK: - 茹で物

    static let boiling: [TimerPreset] = [
        TimerPreset(
            name: "ゆで卵（半熟）",
            category: .boil,
            duration: 7 * 60,
            description: "黄身がとろっとした半熟卵"
        ),
        TimerPreset(
            name: "ゆで卵（固茹で）",
            category: .boil,
            duration: 12 * 60,
            description: "しっかり固茹での卵"
        ),
        TimerPreset(
            name: "ブロッコリー",
            category: .boil,
            duration: 3 * 60,
            description: "歯ごたえを残した茹で時間"
        ),
        TimerPreset(
            name: "じゃがいも（丸ごと）",
            category: .boil,
            duration: 20 * 60,
            description: "中サイズのじゃがいもを丸ごと茹でる"
        ),
        TimerPreset(
            name: "枝豆",
            category: .boil,
            duration: 4 * 60,
            description: "塩茹で枝豆"
        ),
    ]

    // MARK: - 煮込み

    static let simmering: [TimerPreset] = [
        TimerPreset(
            name: "カレー（煮込み）",
            category: .simmer,
            duration: 20 * 60,
            description: "ルーを入れてからの弱火煮込み"
        ),
        TimerPreset(
            name: "味噌汁",
            category: .simmer,
            duration: 5 * 60,
            description: "具材を入れてからの煮込み時間"
        ),
        TimerPreset(
            name: "トマトソース",
            category: .simmer,
            duration: 15 * 60,
            description: "トマトソースの弱火煮込み"
        ),
        TimerPreset(
            name: "肉じゃが",
            category: .simmer,
            duration: 25 * 60,
            description: "落とし蓋をしての弱火煮込み"
        ),
        TimerPreset(
            name: "おでん",
            category: .simmer,
            duration: 30 * 60,
            description: "弱火でじっくり煮込む"
        ),
    ]

    // MARK: - オーブン

    static let baking: [TimerPreset] = [
        TimerPreset(
            name: "ローストチキン",
            category: .bake,
            duration: 25 * 60,
            description: "200°C でのローストチキン"
        ),
        TimerPreset(
            name: "グラタン",
            category: .bake,
            duration: 15 * 60,
            description: "220°C で表面にこんがり焼き色がつくまで"
        ),
        TimerPreset(
            name: "クッキー",
            category: .bake,
            duration: 12 * 60,
            description: "180°C でのクッキー焼き時間"
        ),
        TimerPreset(
            name: "トースト",
            category: .bake,
            duration: 3 * 60,
            description: "トースターでのパン焼き"
        ),
        TimerPreset(
            name: "ピザ",
            category: .bake,
            duration: 10 * 60,
            description: "250°C での冷凍ピザ"
        ),
    ]

    // MARK: - 蒸し物

    static let steaming: [TimerPreset] = [
        TimerPreset(
            name: "茶碗蒸し",
            category: .steam,
            duration: 15 * 60,
            description: "弱火での蒸し時間"
        ),
        TimerPreset(
            name: "蒸しパン",
            category: .steam,
            duration: 12 * 60,
            description: "強火での蒸し時間"
        ),
        TimerPreset(
            name: "シュウマイ",
            category: .steam,
            duration: 10 * 60,
            description: "強火での蒸し時間"
        ),
    ]

    // MARK: - 炒め・揚げ

    static let frying: [TimerPreset] = [
        TimerPreset(
            name: "唐揚げ",
            category: .fry,
            duration: 6 * 60,
            description: "170°C での揚げ時間（二度揚げ1回目）"
        ),
        TimerPreset(
            name: "天ぷら",
            category: .fry,
            duration: 3 * 60,
            description: "180°C での揚げ時間"
        ),
        TimerPreset(
            name: "ステーキ（片面）",
            category: .fry,
            duration: 3 * 60,
            description: "強火で片面を焼く時間（ミディアムレア）"
        ),
    ]

    // MARK: - 寝かせる・冷ます

    static let resting: [TimerPreset] = [
        TimerPreset(
            name: "ステーキ（レスト）",
            category: .rest,
            duration: 5 * 60,
            description: "焼き上がり後のレスト時間"
        ),
        TimerPreset(
            name: "パン生地（一次発酵）",
            category: .rest,
            duration: 60 * 60,
            description: "室温での一次発酵"
        ),
        TimerPreset(
            name: "ゼリー（冷蔵）",
            category: .rest,
            duration: 120 * 60,
            description: "冷蔵庫での固める時間"
        ),
    ]

    // MARK: - 全グループ

    static let allGroups: [PresetGroup] = [
        PresetGroup(title: "パスタ・麺類", emoji: "🍝", presets: pasta),
        PresetGroup(title: "茹で物", emoji: "🥚", presets: boiling),
        PresetGroup(title: "煮込み", emoji: "🥘", presets: simmering),
        PresetGroup(title: "オーブン", emoji: "🍖", presets: baking),
        PresetGroup(title: "蒸し物", emoji: "🫕", presets: steaming),
        PresetGroup(title: "炒め・揚げ", emoji: "🍳", presets: frying),
        PresetGroup(title: "寝かせる・冷ます", emoji: "❄️", presets: resting),
    ]
}
