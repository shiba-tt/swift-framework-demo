import Foundation

// MARK: - AppClipManager

@MainActor
@Observable
final class AppClipManager {

    static let shared = AppClipManager()

    private(set) var isAppClipMode = false
    private(set) var spotID: String?

    private init() {}

    func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        isAppClipMode = true

        if let spotParam = components.queryItems?.first(where: { $0.name == "spot" })?.value {
            spotID = spotParam
        } else {
            let pathComponents = components.path.split(separator: "/")
            if let lastComponent = pathComponents.last {
                spotID = String(lastComponent)
            }
        }
    }
}
