import Foundation
import CoreLocation

/// イベント間の移動ルート情報
struct TravelRoute: Identifiable, Sendable {
    let id = UUID()
    let origin: CLLocationCoordinate2D
    let destination: CLLocationCoordinate2D
    let estimatedTravelMinutes: Int
    let transportType: TransportType
    let originEventTitle: String
    let destinationEventTitle: String

    /// 移動時間の表示テキスト
    var travelTimeText: String {
        let hours = estimatedTravelMinutes / 60
        let minutes = estimatedTravelMinutes % 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        }
        return "\(minutes)分"
    }
}

/// 移動手段の種類
enum TransportType: String, Sendable, CaseIterable {
    case walking = "徒歩"
    case transit = "電車"
    case automobile = "車"

    var systemImageName: String {
        switch self {
        case .walking: "figure.walk"
        case .transit: "tram.fill"
        case .automobile: "car.fill"
        }
    }

    /// MapKit の MKDirectionsTransportType に対応する想定速度 (km/h)
    var estimatedSpeedKmH: Double {
        switch self {
        case .walking: 4.5
        case .transit: 30.0
        case .automobile: 40.0
        }
    }
}
