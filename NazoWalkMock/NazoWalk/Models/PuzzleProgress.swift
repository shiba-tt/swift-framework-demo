import Foundation
import SwiftData

/// ユーザーの謎解き進捗データ
@Model
final class PuzzleProgress {
    /// イベントID（同じイベントの進捗をまとめる）
    var eventID: String
    /// クリアしたスポットIDのリスト（カンマ区切り）
    var clearedSpotIDs: String
    /// 合計獲得ポイント
    var totalPoints: Int
    /// 開始日時
    var startedAt: Date
    /// 最終更新日時
    var updatedAt: Date
    /// 全クリアしたか
    var isCompleted: Bool

    init(
        eventID: String,
        clearedSpotIDs: String = "",
        totalPoints: Int = 0,
        startedAt: Date = .now,
        updatedAt: Date = .now,
        isCompleted: Bool = false
    ) {
        self.eventID = eventID
        self.clearedSpotIDs = clearedSpotIDs
        self.totalPoints = totalPoints
        self.startedAt = startedAt
        self.updatedAt = updatedAt
        self.isCompleted = isCompleted
    }

    /// クリア済みスポットIDの配列
    var clearedSpots: [String] {
        clearedSpotIDs.isEmpty ? [] : clearedSpotIDs.split(separator: ",").map(String.init)
    }

    /// スポットをクリア済みに追加
    func markSpotCleared(_ spotID: String, points: Int) {
        var spots = clearedSpots
        guard !spots.contains(spotID) else { return }
        spots.append(spotID)
        clearedSpotIDs = spots.joined(separator: ",")
        totalPoints += points
        updatedAt = .now
    }

    /// 特定のスポットがクリア済みか
    func isSpotCleared(_ spotID: String) -> Bool {
        clearedSpots.contains(spotID)
    }

    /// クリア済みスポット数
    var clearedCount: Int {
        clearedSpots.count
    }
}
