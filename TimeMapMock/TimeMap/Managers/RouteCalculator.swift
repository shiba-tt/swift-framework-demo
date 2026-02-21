import Foundation
import CoreLocation

/// イベント間の移動ルートを計算するユーティリティ
struct RouteCalculator: Sendable {

    /// 2つの座標間の直線距離（メートル）を計算
    static func straightLineDistance(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) -> Double {
        let originLocation = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return originLocation.distance(from: destinationLocation)
    }

    /// 移動時間を推定（分）
    /// - Parameters:
    ///   - origin: 出発地点
    ///   - destination: 到着地点
    ///   - transportType: 移動手段
    /// - Returns: 推定移動時間（分）
    static func estimateTravelMinutes(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        transportType: TransportType
    ) -> Int {
        let distanceMeters = straightLineDistance(from: origin, to: destination)
        // 直線距離に迂回係数を掛ける
        let detourFactor: Double = switch transportType {
        case .walking: 1.3
        case .transit: 1.5
        case .automobile: 1.4
        }
        let actualDistanceKm = distanceMeters * detourFactor / 1000.0
        let travelHours = actualDistanceKm / transportType.estimatedSpeedKmH
        return max(1, Int(ceil(travelHours * 60)))
    }

    /// イベント列から移動ルートを計算
    static func calculateRoutes(
        for events: [ScheduleEvent],
        transportType: TransportType
    ) -> [TravelRoute] {
        let locatedEvents = events.filter { $0.hasCoordinate && !$0.isAllDay }
        guard locatedEvents.count >= 2 else { return [] }

        var routes: [TravelRoute] = []
        for i in 0..<(locatedEvents.count - 1) {
            let current = locatedEvents[i]
            let next = locatedEvents[i + 1]

            guard let originCoord = current.coordinate,
                  let destCoord = next.coordinate else { continue }

            let travelMinutes = estimateTravelMinutes(
                from: originCoord,
                to: destCoord,
                transportType: transportType
            )

            routes.append(TravelRoute(
                origin: originCoord,
                destination: destCoord,
                estimatedTravelMinutes: travelMinutes,
                transportType: transportType,
                originEventTitle: current.title,
                destinationEventTitle: next.title
            ))
        }
        return routes
    }

    /// 空き時間スロットを検出
    static func findTimeSlots(
        in events: [ScheduleEvent],
        dayStart: Date,
        dayEnd: Date,
        minimumMinutes: Int = 15
    ) -> [TimeSlot] {
        let sortedEvents = events
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }

        var slots: [TimeSlot] = []
        var currentTime = dayStart

        for event in sortedEvents {
            if event.startDate > currentTime {
                let gap = event.startDate.timeIntervalSince(currentTime) / 60
                if Int(gap) >= minimumMinutes {
                    let previousEvent = slots.isEmpty ? nil : sortedEvents.first { $0.endDate <= currentTime }
                    slots.append(TimeSlot(
                        startDate: currentTime,
                        endDate: event.startDate,
                        previousEvent: previousEvent,
                        nextEvent: event
                    ))
                }
            }
            if event.endDate > currentTime {
                currentTime = event.endDate
            }
        }

        // 最後のイベント後の空き時間
        if currentTime < dayEnd {
            let gap = dayEnd.timeIntervalSince(currentTime) / 60
            if Int(gap) >= minimumMinutes {
                slots.append(TimeSlot(
                    startDate: currentTime,
                    endDate: dayEnd,
                    previousEvent: sortedEvents.last,
                    nextEvent: nil
                ))
            }
        }

        return slots
    }

    /// 空き時間に基づいたアクティビティ提案
    static func suggestActivities(for slot: TimeSlot) -> [SuggestedActivity] {
        let minutes = slot.durationMinutes
        var suggestions: [SuggestedActivity] = []

        if minutes >= 15 {
            suggestions.append(SuggestedActivity(
                name: "近くのカフェで休憩",
                category: .cafe,
                estimatedMinutes: min(minutes, 30),
                systemImageName: ActivityCategory.cafe.systemImageName
            ))
        }
        if minutes >= 20 {
            suggestions.append(SuggestedActivity(
                name: "周辺を散歩",
                category: .walk,
                estimatedMinutes: min(minutes, 20),
                systemImageName: ActivityCategory.walk.systemImageName
            ))
        }
        if minutes >= 30 {
            suggestions.append(SuggestedActivity(
                name: "読書タイム",
                category: .reading,
                estimatedMinutes: min(minutes, 45),
                systemImageName: ActivityCategory.reading.systemImageName
            ))
        }
        if minutes >= 45 {
            suggestions.append(SuggestedActivity(
                name: "ジムでトレーニング",
                category: .exercise,
                estimatedMinutes: min(minutes, 60),
                systemImageName: ActivityCategory.exercise.systemImageName
            ))
        }
        if minutes >= 30 {
            suggestions.append(SuggestedActivity(
                name: "買い物",
                category: .shopping,
                estimatedMinutes: min(minutes, 40),
                systemImageName: ActivityCategory.shopping.systemImageName
            ))
        }

        return suggestions
    }
}
