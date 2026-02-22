import Foundation

// MARK: - AppClipManager

@MainActor
@Observable
final class AppClipManager {

    static let shared = AppClipManager()

    private(set) var isAppClipMode = false
    private(set) var profileID: String?

    private init() {}

    func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        isAppClipMode = true

        if let profileParam = components.queryItems?.first(where: { $0.name == "profile" })?.value {
            profileID = profileParam
        } else {
            let pathComponents = components.path.split(separator: "/")
            if let lastComponent = pathComponents.last {
                profileID = String(lastComponent)
            }
        }
    }
}
