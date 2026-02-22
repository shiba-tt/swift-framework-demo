import Foundation

// MARK: - AppClipManager

@MainActor
@Observable
final class AppClipManager {
    static let shared = AppClipManager()

    private(set) var isAppClipExperience = false
    private(set) var activatedSpotID: String?
    private(set) var activatedAdventureID: String?

    private init() {}

    // MARK: - URL Handling

    func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        isAppClipExperience = true

        let queryItems = components.queryItems ?? []
        activatedSpotID = queryItems.first(where: { $0.name == "spot" })?.value
        activatedAdventureID = queryItems.first(where: { $0.name == "adventure" })?.value
    }

    func reset() {
        isAppClipExperience = false
        activatedSpotID = nil
        activatedAdventureID = nil
    }
}
