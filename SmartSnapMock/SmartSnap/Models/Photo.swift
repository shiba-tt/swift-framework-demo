import Foundation

// MARK: - Photo（写真エントリ）

struct Photo: Identifiable, Sendable {
    let id: UUID
    let fileName: String
    let takenAt: Date
    var tags: [String]
    var caption: String?
    var detectedObjects: [String]
    var detectedText: String?
    var location: PhotoLocation?

    init(
        fileName: String,
        takenAt: Date,
        tags: [String] = [],
        caption: String? = nil,
        detectedObjects: [String] = [],
        detectedText: String? = nil,
        location: PhotoLocation? = nil
    ) {
        self.id = UUID()
        self.fileName = fileName
        self.takenAt = takenAt
        self.tags = tags
        self.caption = caption
        self.detectedObjects = detectedObjects
        self.detectedText = detectedText
        self.location = location
    }

    var systemImageName: String {
        if detectedObjects.contains(where: { $0.contains("人") || $0.contains("顔") }) {
            return "person.crop.rectangle"
        }
        if detectedObjects.contains(where: { $0.contains("食") || $0.contains("料理") }) {
            return "fork.knife"
        }
        if location != nil {
            return "mappin.and.ellipse"
        }
        return "photo"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: takenAt)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return formatter.string(from: takenAt)
    }
}

// MARK: - PhotoLocation

struct PhotoLocation: Sendable {
    let name: String
    let latitude: Double
    let longitude: Double
}

// MARK: - サンプルデータ

extension Photo {
    static let samplePhotos: [Photo] = [
        Photo(
            fileName: "IMG_0001.heic",
            takenAt: date(2025, 7, 15, 10, 30),
            tags: ["旅行", "海", "夏"],
            caption: "沖縄の美しいビーチ。エメラルドグリーンの海が広がる。",
            detectedObjects: ["海", "砂浜", "空", "雲"],
            location: PhotoLocation(name: "沖縄県恩納村", latitude: 26.4975, longitude: 127.8553)
        ),
        Photo(
            fileName: "IMG_0002.heic",
            takenAt: date(2025, 7, 15, 12, 0),
            tags: ["旅行", "グルメ", "沖縄"],
            caption: "沖縄名物のソーキそばランチ",
            detectedObjects: ["料理", "器", "テーブル"],
            location: PhotoLocation(name: "沖縄県那覇市", latitude: 26.3344, longitude: 127.6809)
        ),
        Photo(
            fileName: "IMG_0003.heic",
            takenAt: date(2025, 7, 16, 9, 0),
            tags: ["旅行", "自然", "沖縄"],
            caption: "首里城公園からの眺望",
            detectedObjects: ["建物", "木", "空", "人"],
            location: PhotoLocation(name: "首里城公園", latitude: 26.2170, longitude: 127.7195)
        ),
        Photo(
            fileName: "IMG_0010.heic",
            takenAt: date(2025, 8, 3, 18, 30),
            tags: ["家族", "誕生日", "パーティー"],
            caption: "お母さんの誕生日パーティー。ケーキのろうそくを吹き消す瞬間。",
            detectedObjects: ["人", "顔", "ケーキ", "ろうそく", "テーブル"],
            detectedText: "Happy Birthday"
        ),
        Photo(
            fileName: "IMG_0011.heic",
            takenAt: date(2025, 8, 3, 19, 0),
            tags: ["家族", "誕生日", "集合写真"],
            caption: "家族全員での集合写真",
            detectedObjects: ["人", "顔", "室内"]
        ),
        Photo(
            fileName: "IMG_0020.heic",
            takenAt: date(2025, 9, 10, 8, 0),
            tags: ["仕事", "カンファレンス"],
            caption: "iOS Dev Conference 基調講演の様子",
            detectedObjects: ["人", "スクリーン", "椅子", "室内"],
            detectedText: "WWDC Recap Session",
            location: PhotoLocation(name: "東京国際フォーラム", latitude: 35.6764, longitude: 139.7635)
        ),
        Photo(
            fileName: "IMG_0021.heic",
            takenAt: date(2025, 9, 10, 12, 30),
            tags: ["仕事", "グルメ", "ランチ"],
            caption: "カンファレンスの合間にラーメン",
            detectedObjects: ["料理", "ラーメン", "器"],
            location: PhotoLocation(name: "東京都千代田区", latitude: 35.6812, longitude: 139.7671)
        ),
        Photo(
            fileName: "IMG_0030.heic",
            takenAt: date(2025, 10, 20, 14, 0),
            tags: ["紅葉", "散歩", "秋"],
            caption: "近所の公園で紅葉狩り。色づいたもみじが美しい。",
            detectedObjects: ["木", "葉", "道", "空"],
            location: PhotoLocation(name: "代々木公園", latitude: 35.6715, longitude: 139.6950)
        ),
        Photo(
            fileName: "IMG_0040.heic",
            takenAt: date(2025, 12, 24, 19, 0),
            tags: ["クリスマス", "イルミネーション"],
            caption: "表参道のクリスマスイルミネーション",
            detectedObjects: ["イルミネーション", "木", "通り", "人"],
            location: PhotoLocation(name: "表参道", latitude: 35.6654, longitude: 139.7121)
        ),
        Photo(
            fileName: "IMG_0050.heic",
            takenAt: date(2025, 11, 5, 7, 30),
            tags: ["ペット", "犬", "散歩"],
            caption: "朝の散歩中のポチ",
            detectedObjects: ["犬", "道", "公園"]
        ),
        Photo(
            fileName: "IMG_0051.heic",
            takenAt: date(2025, 11, 15, 16, 0),
            tags: ["ペット", "猫"],
            caption: "窓辺で日向ぼっこするミケ",
            detectedObjects: ["猫", "窓", "室内"]
        ),
        Photo(
            fileName: "IMG_0060.heic",
            takenAt: date(2025, 6, 1, 11, 0),
            tags: ["料理", "自炊"],
            caption: "初めて作ったパスタが意外と上手にできた",
            detectedObjects: ["料理", "パスタ", "皿", "フォーク"]
        ),
    ]

    private static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? .now
    }
}
