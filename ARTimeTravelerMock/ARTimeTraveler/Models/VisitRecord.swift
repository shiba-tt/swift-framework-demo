import Foundation

// MARK: - VisitRecord

struct VisitRecord: Identifiable, Sendable {
    let id: UUID
    let spotID: UUID
    let spotName: String
    let visitedAt: Date
    let erasViewed: [HistoricalEra]
    let audioGuideListened: Bool
    let favorited: Bool

    init(
        id: UUID = UUID(),
        spotID: UUID,
        spotName: String,
        visitedAt: Date = .now,
        erasViewed: [HistoricalEra] = [],
        audioGuideListened: Bool = false,
        favorited: Bool = false
    ) {
        self.id = id
        self.spotID = spotID
        self.spotName = spotName
        self.visitedAt = visitedAt
        self.erasViewed = erasViewed
        self.audioGuideListened = audioGuideListened
        self.favorited = favorited
    }

    var visitDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: visitedAt)
    }
}
