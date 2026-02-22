import Foundation

// MARK: - AppClipManager

@MainActor
@Observable
final class AppClipManager {

    static let shared = AppClipManager()

    private(set) var isAppClipMode = false
    private(set) var restaurantID: String?

    private init() {}

    func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        isAppClipMode = true

        if let restaurantParam = components.queryItems?.first(where: { $0.name == "restaurant" })?.value {
            restaurantID = restaurantParam
        } else {
            // パスからレストランIDを推測
            let pathComponents = components.path.split(separator: "/")
            if let lastComponent = pathComponents.last {
                restaurantID = String(lastComponent)
            }
        }
    }
}
