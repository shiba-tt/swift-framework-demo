import Foundation
import SwiftUI

// MARK: - HistoricalSpot

struct HistoricalSpot: Identifiable, Sendable {
    let id: UUID
    var name: String
    var category: SpotCategory
    var coordinate: Coordinate
    var currentDescription: String
    var timePeriods: [TimePeriod]
    var distance: Double?
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        name: String,
        category: SpotCategory,
        coordinate: Coordinate = .zero,
        currentDescription: String = "",
        timePeriods: [TimePeriod] = [],
        distance: Double? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.coordinate = coordinate
        self.currentDescription = currentDescription
        self.timePeriods = timePeriods
        self.distance = distance
        self.isFavorite = isFavorite
    }

    var oldestYear: Int? {
        timePeriods.map(\.year).min()
    }

    var newestYear: Int? {
        timePeriods.map(\.year).max()
    }

    var distanceText: String {
        guard let d = distance else { return "不明" }
        if d < 1000 {
            return "\(Int(d))m"
        }
        return String(format: "%.1fkm", d / 1000)
    }
}

// MARK: - SpotCategory

enum SpotCategory: String, CaseIterable, Sendable {
    case landmark = "ランドマーク"
    case temple = "寺社仏閣"
    case station = "駅・交通"
    case bridge = "橋梁"
    case castle = "城郭"
    case park = "公園・庭園"
    case street = "街並み"
    case monument = "記念碑・モニュメント"

    var systemImage: String {
        switch self {
        case .landmark: "building.columns.fill"
        case .temple: "house.lodge.fill"
        case .station: "tram.fill"
        case .bridge: "road.lanes"
        case .castle: "building.2.fill"
        case .park: "leaf.fill"
        case .street: "building.2.crop.circle"
        case .monument: "star.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .landmark: .orange
        case .temple: .red
        case .station: .blue
        case .bridge: .teal
        case .castle: .purple
        case .park: .green
        case .street: .brown
        case .monument: .yellow
        }
    }
}

// MARK: - TimePeriod

struct TimePeriod: Identifiable, Sendable {
    let id: UUID
    var year: Int
    var era: HistoricalEra
    var title: String
    var description: String
    var modelName: String
    var photoCount: Int

    init(
        id: UUID = UUID(),
        year: Int,
        era: HistoricalEra,
        title: String,
        description: String = "",
        modelName: String = "",
        photoCount: Int = 0
    ) {
        self.id = id
        self.year = year
        self.era = era
        self.title = title
        self.description = description
        self.modelName = modelName
        self.photoCount = photoCount
    }

    var yearText: String {
        if year < 0 {
            return "紀元前\(abs(year))年"
        }
        return "\(year)年"
    }
}

// MARK: - HistoricalEra

enum HistoricalEra: String, CaseIterable, Sendable {
    case ancient = "古代"
    case medieval = "中世"
    case edo = "江戸時代"
    case meiji = "明治"
    case taisho = "大正"
    case showa = "昭和"
    case heisei = "平成"
    case reiwa = "令和"
    case future = "未来"

    var color: Color {
        switch self {
        case .ancient: .brown
        case .medieval: .orange
        case .edo: .purple
        case .meiji: .red
        case .taisho: .pink
        case .showa: .blue
        case .heisei: .cyan
        case .reiwa: .green
        case .future: .indigo
        }
    }

    var systemImage: String {
        switch self {
        case .ancient: "fossil.shell.fill"
        case .medieval: "shield.fill"
        case .edo: "house.fill"
        case .meiji: "train.side.front.car"
        case .taisho: "building.fill"
        case .showa: "car.fill"
        case .heisei: "desktopcomputer"
        case .reiwa: "iphone"
        case .future: "sparkles"
        }
    }
}

// MARK: - Coordinate

struct Coordinate: Sendable {
    var latitude: Double
    var longitude: Double

    static let zero = Coordinate(latitude: 0, longitude: 0)
}

// MARK: - AROverlayMode

enum AROverlayMode: String, CaseIterable, Sendable {
    case fullReplace = "完全置換"
    case semiTransparent = "半透明重畳"
    case sideBySide = "比較表示"
    case fadeTransition = "フェード遷移"

    var systemImage: String {
        switch self {
        case .fullReplace: "square.filled.on.square"
        case .semiTransparent: "square.on.square.dashed"
        case .sideBySide: "rectangle.split.2x1"
        case .fadeTransition: "circle.lefthalf.filled"
        }
    }
}

// MARK: - Sample Data

extension HistoricalSpot {
    static let samples: [HistoricalSpot] = [
        HistoricalSpot(
            name: "東京駅",
            category: .station,
            coordinate: Coordinate(latitude: 35.6812, longitude: 139.7671),
            currentDescription: "1914年に辰野金吾の設計で開業。赤レンガ造りの丸の内駅舎は2012年に復原された国の重要文化財。",
            timePeriods: [
                TimePeriod(year: 1914, era: .taisho, title: "開業当時", description: "辰野金吾設計の赤レンガ駅舎。3階建てドーム屋根の壮麗な姿。", modelName: "tokyo_station_1914", photoCount: 12),
                TimePeriod(year: 1945, era: .showa, title: "戦災後", description: "空襲で3階部分とドーム屋根を焼失。2階建てに改修。", modelName: "tokyo_station_1945", photoCount: 8),
                TimePeriod(year: 1947, era: .showa, title: "戦後復興", description: "応急修復された2階建て駅舎。八角形のドームに変更。", modelName: "tokyo_station_1947", photoCount: 6),
                TimePeriod(year: 2012, era: .heisei, title: "復原完成", description: "開業当時の3階建てドーム屋根を忠実に復原。", modelName: "tokyo_station_2012", photoCount: 20),
                TimePeriod(year: 2050, era: .future, title: "未来予想", description: "緑化された屋上庭園とソーラーパネルを備えた持続可能な駅舎。", modelName: "tokyo_station_2050", photoCount: 4),
            ],
            distance: 150,
            isFavorite: true
        ),
        HistoricalSpot(
            name: "浅草寺 雷門",
            category: .temple,
            coordinate: Coordinate(latitude: 35.7115, longitude: 139.7966),
            currentDescription: "942年創建と伝わる浅草寺の総門。現在の門は1960年に松下幸之助の寄進で再建。",
            timePeriods: [
                TimePeriod(year: 942, era: .ancient, title: "創建", description: "武蔵守・平公雅により創建されたと伝わる。", modelName: "kaminarimon_942", photoCount: 3),
                TimePeriod(year: 1865, era: .edo, title: "焼失前", description: "田原町の大火で焼失する直前の雷門。", modelName: "kaminarimon_1865", photoCount: 5),
                TimePeriod(year: 1960, era: .showa, title: "再建", description: "松下電器・松下幸之助の寄進により95年ぶりに再建。", modelName: "kaminarimon_1960", photoCount: 10),
                TimePeriod(year: 2040, era: .future, title: "未来予想", description: "AR案内システムが統合された次世代の門。", modelName: "kaminarimon_2040", photoCount: 2),
            ],
            distance: 3200,
            isFavorite: true
        ),
        HistoricalSpot(
            name: "日本橋",
            category: .bridge,
            coordinate: Coordinate(latitude: 35.6839, longitude: 139.7744),
            currentDescription: "1603年に架橋された五街道の起点。現在の石造二連アーチ橋は1911年完成の国重要文化財。",
            timePeriods: [
                TimePeriod(year: 1603, era: .edo, title: "初代木橋", description: "徳川家康の命で架橋。五街道の起点として繁栄。", modelName: "nihonbashi_1603", photoCount: 7),
                TimePeriod(year: 1806, era: .edo, title: "10代目木橋", description: "浮世絵にも描かれた賑わいの中心。", modelName: "nihonbashi_1806", photoCount: 9),
                TimePeriod(year: 1911, era: .meiji, title: "現在の石橋", description: "ルネサンス様式の花崗岩アーチ橋として完成。", modelName: "nihonbashi_1911", photoCount: 14),
                TimePeriod(year: 1963, era: .showa, title: "首都高架設後", description: "首都高速道路の高架橋が上空を覆う姿に。", modelName: "nihonbashi_1963", photoCount: 6),
                TimePeriod(year: 2040, era: .future, title: "首都高地下化後", description: "首都高地下化完了後、空が戻った日本橋。", modelName: "nihonbashi_2040", photoCount: 3),
            ],
            distance: 800,
            isFavorite: false
        ),
        HistoricalSpot(
            name: "渋谷スクランブル交差点",
            category: .street,
            coordinate: Coordinate(latitude: 35.6595, longitude: 139.7004),
            currentDescription: "世界最大規模のスクランブル交差点。1回の青信号で約3000人が行き交う。",
            timePeriods: [
                TimePeriod(year: 1950, era: .showa, title: "戦後の渋谷駅前", description: "まだ静かだった渋谷駅前。路面電車が走る風景。", modelName: "shibuya_1950", photoCount: 5),
                TimePeriod(year: 1973, era: .showa, title: "スクランブル化", description: "スクランブル方式が導入された交差点。", modelName: "shibuya_1973", photoCount: 8),
                TimePeriod(year: 2000, era: .heisei, title: "109全盛期", description: "ギャル文化の中心地として世界的に有名に。", modelName: "shibuya_2000", photoCount: 11),
                TimePeriod(year: 2050, era: .future, title: "未来予想", description: "空中歩道と緑化された未来型交差点。", modelName: "shibuya_2050", photoCount: 2),
            ],
            distance: 5400,
            isFavorite: false
        ),
        HistoricalSpot(
            name: "皇居（江戸城跡）",
            category: .castle,
            coordinate: Coordinate(latitude: 35.6852, longitude: 139.7528),
            currentDescription: "徳川将軍家の居城・江戸城の跡地。明治以降は皇居として使用。",
            timePeriods: [
                TimePeriod(year: 1457, era: .medieval, title: "太田道灌築城", description: "太田道灌により江戸城が築かれる。", modelName: "edo_castle_1457", photoCount: 4),
                TimePeriod(year: 1638, era: .edo, title: "寛永の大天守", description: "5層の天守閣がそびえる江戸城最盛期。", modelName: "edo_castle_1638", photoCount: 10),
                TimePeriod(year: 1657, era: .edo, title: "明暦の大火後", description: "天守焼失後、再建されず。石垣のみ残る。", modelName: "edo_castle_1657", photoCount: 7),
                TimePeriod(year: 1888, era: .meiji, title: "明治宮殿", description: "明治宮殿が完成し皇居として整備。", modelName: "kokyo_1888", photoCount: 6),
                TimePeriod(year: 2060, era: .future, title: "未来予想", description: "歴史と自然が調和した開放型の文化施設。", modelName: "kokyo_2060", photoCount: 2),
            ],
            distance: 1200,
            isFavorite: true
        ),
        HistoricalSpot(
            name: "東京タワー",
            category: .landmark,
            coordinate: Coordinate(latitude: 35.6586, longitude: 139.7454),
            currentDescription: "1958年完成の総合電波塔。高さ333m。東京のシンボルとして親しまれる。",
            timePeriods: [
                TimePeriod(year: 1957, era: .showa, title: "建設中", description: "1年半の工期で建設された鉄塔。延べ22万人が従事。", modelName: "tokyo_tower_1957", photoCount: 8),
                TimePeriod(year: 1958, era: .showa, title: "完成", description: "高さ333mで当時世界一の鉄塔として完成。", modelName: "tokyo_tower_1958", photoCount: 15),
                TimePeriod(year: 1989, era: .heisei, title: "ライトアップ開始", description: "ランドマークライトが点灯し夜景の象徴に。", modelName: "tokyo_tower_1989", photoCount: 10),
                TimePeriod(year: 2050, era: .future, title: "未来予想", description: "全面ソーラーパネルと展望デッキの拡張。", modelName: "tokyo_tower_2050", photoCount: 3),
            ],
            distance: 2800,
            isFavorite: false
        ),
    ]
}
