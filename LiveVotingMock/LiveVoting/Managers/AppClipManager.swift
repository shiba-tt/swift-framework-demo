import Foundation

// MARK: - AppClipManager

@MainActor
@Observable
final class AppClipManager {
    static let shared = AppClipManager()

    private(set) var isAppClipExperience = false
    private(set) var activatedEventID: String?
    private(set) var activatedSeatSection: String?
    private(set) var activatedSeatRow: String?
    private(set) var activatedSeatNumber: String?

    private init() {}

    // MARK: - URL Handling

    func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        isAppClipExperience = true

        let queryItems = components.queryItems ?? []
        activatedEventID = queryItems.first(where: { $0.name == "event" })?.value
        activatedSeatSection = queryItems.first(where: { $0.name == "section" })?.value
        activatedSeatRow = queryItems.first(where: { $0.name == "row" })?.value
        activatedSeatNumber = queryItems.first(where: { $0.name == "seat" })?.value
    }

    var seatInfo: SeatInfo? {
        guard let section = activatedSeatSection,
              let row = activatedSeatRow,
              let seat = activatedSeatNumber else {
            return nil
        }
        return SeatInfo(
            section: section,
            row: row,
            seat: seat,
            nfcTagID: "\(section)-\(row)-\(seat)"
        )
    }

    func reset() {
        isAppClipExperience = false
        activatedEventID = nil
        activatedSeatSection = nil
        activatedSeatRow = nil
        activatedSeatNumber = nil
    }
}
