import Foundation

// MARK: - EmergencyMedicalCardViewModel

@MainActor
@Observable
final class EmergencyMedicalCardViewModel {

    // MARK: - State

    var currentAccessLevel: AccessLevel = .basic
    var isAuthenticating = false
    var pinInput = ""
    var showPINSheet = false
    var showAuthError = false
    var selectedProfile: MedicalProfile?

    // MARK: - Dependencies

    private let profileManager = MedicalProfileManager.shared

    // MARK: - Mock PIN

    private let validPIN = "1234"

    // MARK: - Computed

    var profiles: [MedicalProfile] {
        profileManager.profiles
    }

    var canViewConditions: Bool {
        currentAccessLevel >= .authenticated
    }

    var canViewInsurance: Bool {
        currentAccessLevel >= .full
    }

    var criticalAlertCount: Int {
        guard let profile = selectedProfile else { return 0 }
        return profile.severeAllergies.count + profile.criticalConditions.count
    }

    var lastUpdatedText: String {
        guard let profile = selectedProfile else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.localizedString(for: profile.lastUpdated, relativeTo: .now)
    }

    // MARK: - Actions

    func loadProfile(id: String? = nil) {
        if let id, let profile = profileManager.profile(for: id) {
            selectedProfile = profile
        } else {
            selectedProfile = profileManager.profiles.first
        }
    }

    func requestAuthentication() {
        pinInput = ""
        showAuthError = false
        showPINSheet = true
    }

    func submitPIN() {
        isAuthenticating = true

        if pinInput == validPIN {
            if currentAccessLevel == .basic {
                currentAccessLevel = .authenticated
            } else if currentAccessLevel == .authenticated {
                currentAccessLevel = .full
            }
            showPINSheet = false
            showAuthError = false
        } else {
            showAuthError = true
        }

        isAuthenticating = false
    }

    func resetAccess() {
        currentAccessLevel = .basic
        pinInput = ""
    }

    var nextAccessLevel: AccessLevel? {
        switch currentAccessLevel {
        case .basic: .authenticated
        case .authenticated: .full
        case .full: nil
        }
    }
}
