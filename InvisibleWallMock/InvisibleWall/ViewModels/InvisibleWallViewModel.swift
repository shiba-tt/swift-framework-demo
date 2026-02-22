import Foundation

@MainActor
@Observable
final class InvisibleWallViewModel {
    // MARK: - State

    var selectedTab: AppTab = .monitor
    var isLoading: Bool { manager.isLoading }
    var isMonitoring: Bool { manager.isMonitoring }

    var zones: [BoundaryZone] { manager.zones }
    var devices: [MonitoredDevice] { manager.devices }
    var events: [SecurityEvent] { manager.events }
    var connectedDeviceCount: Int { manager.connectedDeviceCount }
    var activeAlertCount: Int { manager.activeAlertCount }
    var todayEventCount: Int { manager.todayEventCount }

    // MARK: - Dependencies

    private let manager = NearbyBoundaryManager.shared

    // MARK: - Init

    init() {}

    // MARK: - Actions

    func toggleMonitoring() async {
        if manager.isMonitoring {
            manager.stopMonitoring()
        } else {
            await manager.startMonitoring()
        }
    }

    func refreshDevices() async {
        await manager.refreshDevices()
    }

    func devicesByZone(_ zoneType: ZoneType) -> [MonitoredDevice] {
        devices.filter { $0.currentZone == zoneType }
    }

    func recentEvents(count: Int = 10) -> [SecurityEvent] {
        Array(events.prefix(count))
    }
}
