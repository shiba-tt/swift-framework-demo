import Foundation
import CoreLocation

/// 位置情報の取得を管理するマネージャー
@MainActor
@Observable
final class LocationManager: NSObject {
    private let manager = CLLocationManager()

    private(set) var currentLocation: CLLocation?
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var locationError: String?

    /// 位置情報が利用可能かどうか
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse ||
        authorizationStatus == .authorizedAlways
    }

    /// 位置情報の表示テキスト（緯度経度の概略）
    var locationText: String {
        guard let location = currentLocation else {
            return "位置情報なし"
        }
        return String(
            format: "%.2f, %.2f",
            location.coordinate.latitude,
            location.coordinate.longitude
        )
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = manager.authorizationStatus
    }

    /// 位置情報のアクセスをリクエスト
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    /// 現在地を取得
    func requestLocation() {
        locationError = nil
        manager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: @preconcurrency CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        currentLocation = locations.last
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        locationError = error.localizedDescription
        print("[LocationManager] 位置情報取得失敗: \(error)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isAuthorized {
            requestLocation()
        }
    }
}
