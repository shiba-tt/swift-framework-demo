import Foundation
import CoreLocation

/// 謎解きスポットの管理マネージャー
@Observable
final class SpotManager: NSObject, CLLocationManagerDelegate {
    static let shared = SpotManager()

    private let locationManager = CLLocationManager()

    private(set) var currentLocation: CLLocation?
    private(set) var isAuthorized = false
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    /// 全スポット
    let spots = PuzzleSpot.sampleSpots

    /// スポットへの近接判定距離（メートル）
    private let proximityThreshold: CLLocationDistance = 100

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Authorization

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Spot Discovery

    /// 現在地から指定スポットまでの距離（メートル）
    func distance(to spot: PuzzleSpot) -> CLLocationDistance? {
        guard let current = currentLocation else { return nil }
        let spotLocation = CLLocation(latitude: spot.latitude, longitude: spot.longitude)
        return current.distance(from: spotLocation)
    }

    /// 現在地が指定スポットの近くにいるか
    func isNearSpot(_ spot: PuzzleSpot) -> Bool {
        guard let distance = distance(to: spot) else { return false }
        return distance <= proximityThreshold
    }

    /// 最も近いスポット
    var nearestSpot: PuzzleSpot? {
        guard currentLocation != nil else { return nil }
        return spots.min { spot1, spot2 in
            (distance(to: spot1) ?? .infinity) < (distance(to: spot2) ?? .infinity)
        }
    }

    /// URL からスポットを検索（App Clip 起動用）
    func findSpot(from url: URL) -> PuzzleSpot? {
        // URL 形式: https://nazowalk.example.com/spot/{spot_id}
        let pathComponents = url.pathComponents
        guard let spotID = pathComponents.last else { return nil }
        return spots.first { $0.id == spotID }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            startLocationUpdates()
        case .denied, .restricted:
            isAuthorized = false
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[SpotManager] 位置情報エラー: \(error)")
    }
}
