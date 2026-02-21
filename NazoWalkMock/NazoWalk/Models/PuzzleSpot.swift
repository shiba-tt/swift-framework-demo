import Foundation
import CoreLocation

/// 謎解きスポットを表すモデル
struct PuzzleSpot: Identifiable, Codable, Sendable, Hashable {
    let id: String
    /// スポット名
    let name: String
    /// スポットの説明
    let spotDescription: String
    /// 緯度
    let latitude: Double
    /// 経度
    let longitude: Double
    /// スポットの画像名（ローカルアセット or URL）
    let imageName: String
    /// このスポットに紐づく謎のID
    let puzzleID: String
    /// スポットの順番（1始まり）
    let order: Int
    /// 次のスポットへのヒント
    let nextHint: String?

    /// CLLocationCoordinate2D への変換
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// App Clip 起動 URL
    var appClipURL: URL {
        URL(string: "https://nazowalk.example.com/spot/\(id)")!
    }

    // MARK: - サンプルデータ

    static let sampleSpots: [PuzzleSpot] = [
        PuzzleSpot(
            id: "spot_01",
            name: "商店街入口の時計台",
            spotDescription: "レトロな時計台の下に隠された最初の手がかり",
            latitude: 35.6812,
            longitude: 139.7671,
            imageName: "clock_tower",
            puzzleID: "puzzle_01",
            order: 1,
            nextHint: "時計が示す方角にある赤い建物を探せ"
        ),
        PuzzleSpot(
            id: "spot_02",
            name: "赤レンガのパン屋",
            spotDescription: "老舗パン屋の壁に刻まれた暗号",
            latitude: 35.6815,
            longitude: 139.7675,
            imageName: "bakery",
            puzzleID: "puzzle_02",
            order: 2,
            nextHint: "パンの形が示す道を進むと池が見える"
        ),
        PuzzleSpot(
            id: "spot_03",
            name: "蓮池公園のベンチ",
            spotDescription: "池のほとりのベンチに刻まれた数式",
            latitude: 35.6820,
            longitude: 139.7680,
            imageName: "pond_bench",
            puzzleID: "puzzle_03",
            order: 3,
            nextHint: "数式の答えの数だけ歩いて神社の鳥居へ"
        ),
        PuzzleSpot(
            id: "spot_04",
            name: "稲荷神社の鳥居",
            spotDescription: "鳥居に掛けられた最後の謎",
            latitude: 35.6825,
            longitude: 139.7685,
            imageName: "torii",
            puzzleID: "puzzle_04",
            order: 4,
            nextHint: nil
        ),
    ]
}
