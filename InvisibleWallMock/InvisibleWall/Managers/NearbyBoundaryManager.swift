import Foundation

@MainActor
@Observable
final class NearbyBoundaryManager {
    static let shared = NearbyBoundaryManager()

    // MARK: - State

    private(set) var isLoading = false
    private(set) var isMonitoring = false
    private(set) var zones: [BoundaryZone] = []
    private(set) var devices: [MonitoredDevice] = []
    private(set) var events: [SecurityEvent] = []

    private init() {
        setupDefaultZones()
        setupSampleDevices()
        generateSampleEvents()
    }

    // MARK: - Monitoring

    func startMonitoring() async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(for: .seconds(1))
        isMonitoring = true
    }

    func stopMonitoring() {
        isMonitoring = false
    }

    // MARK: - Device Updates

    func refreshDevices() async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(for: .seconds(0.5))
        updateDeviceDistances()
    }

    // MARK: - Zone Management

    func zone(for distance: Float) -> ZoneType {
        if distance <= 3.0 { return .inner }
        if distance <= 10.0 { return .middle }
        return .outer
    }

    func actionsForZone(_ zoneType: ZoneType) -> [SecurityAction] {
        zones.first { $0.zoneType == zoneType }?.actions ?? []
    }

    // MARK: - Stats

    var connectedDeviceCount: Int {
        devices.filter(\.isConnected).count
    }

    var activeAlertCount: Int {
        devices.filter { $0.currentZone == .outer && $0.isConnected }.count
    }

    var todayEventCount: Int {
        let calendar = Calendar.current
        return events.filter { calendar.isDateInToday($0.date) }.count
    }

    // MARK: - Sample Data

    private func setupDefaultZones() {
        zones = [
            BoundaryZone(
                id: UUID(),
                name: "セーフゾーン",
                zoneType: .inner,
                radiusMin: 0,
                radiusMax: 3,
                actions: [.unlockAll],
                isActive: true
            ),
            BoundaryZone(
                id: UUID(),
                name: "警戒ゾーン",
                zoneType: .middle,
                radiusMin: 3,
                radiusMax: 10,
                actions: [.limitedAccess, .sendNotification],
                isActive: true
            ),
            BoundaryZone(
                id: UUID(),
                name: "制限ゾーン",
                zoneType: .outer,
                radiusMin: 10,
                radiusMax: .infinity,
                actions: [.lockDevice, .hideApps, .triggerAlarm],
                isActive: true
            ),
        ]
    }

    private func setupSampleDevices() {
        devices = [
            MonitoredDevice(
                id: UUID(),
                name: "子供の iPhone",
                deviceType: .iPhone,
                distance: 2.3,
                direction: SIMD3<Float>(0.5, 0.0, -0.87),
                currentZone: .inner,
                lastSeen: Date(),
                isConnected: true
            ),
            MonitoredDevice(
                id: UUID(),
                name: "オフィス UWBタグ",
                deviceType: .uwbAccessory,
                distance: 5.8,
                direction: SIMD3<Float>(-0.3, 0.1, -0.95),
                currentZone: .middle,
                lastSeen: Date().addingTimeInterval(-120),
                isConnected: true
            ),
            MonitoredDevice(
                id: UUID(),
                name: "ペットの首輪",
                deviceType: .airTag,
                distance: 12.5,
                direction: nil,
                currentZone: .outer,
                lastSeen: Date().addingTimeInterval(-600),
                isConnected: true
            ),
            MonitoredDevice(
                id: UUID(),
                name: "Apple Watch (Taro)",
                deviceType: .appleWatch,
                distance: 0.8,
                direction: SIMD3<Float>(0.1, -0.2, -0.97),
                currentZone: .inner,
                lastSeen: Date(),
                isConnected: true
            ),
            MonitoredDevice(
                id: UUID(),
                name: "展示物タグ A",
                deviceType: .uwbAccessory,
                distance: nil,
                direction: nil,
                currentZone: .outer,
                lastSeen: Date().addingTimeInterval(-7200),
                isConnected: false
            ),
        ]
    }

    private func generateSampleEvents() {
        let calendar = Calendar.current
        let now = Date()

        events = [
            SecurityEvent(
                id: UUID(), date: now.addingTimeInterval(-300),
                device: "子供の iPhone", eventType: .zoneEnter, zone: .inner, distance: 2.8
            ),
            SecurityEvent(
                id: UUID(), date: now.addingTimeInterval(-600),
                device: "子供の iPhone", eventType: .unlockTriggered, zone: .inner, distance: 1.5
            ),
            SecurityEvent(
                id: UUID(), date: now.addingTimeInterval(-1800),
                device: "ペットの首輪", eventType: .zoneExit, zone: .outer, distance: 11.2
            ),
            SecurityEvent(
                id: UUID(), date: now.addingTimeInterval(-1900),
                device: "ペットの首輪", eventType: .alertSent, zone: .outer, distance: 12.0
            ),
            SecurityEvent(
                id: UUID(), date: now.addingTimeInterval(-3600),
                device: "オフィス UWBタグ", eventType: .zoneEnter, zone: .middle, distance: 5.0
            ),
            SecurityEvent(
                id: UUID(), date: now.addingTimeInterval(-5400),
                device: "オフィス UWBタグ", eventType: .lockTriggered, zone: .outer, distance: 15.0
            ),
            SecurityEvent(
                id: UUID(),
                date: calendar.date(byAdding: .hour, value: -8, to: now) ?? now,
                device: "展示物タグ A", eventType: .deviceLost, zone: .outer, distance: nil
            ),
            SecurityEvent(
                id: UUID(),
                date: calendar.date(byAdding: .hour, value: -10, to: now) ?? now,
                device: "Apple Watch (Taro)", eventType: .zoneEnter, zone: .inner, distance: 0.5
            ),
        ]
    }

    private func updateDeviceDistances() {
        devices = devices.map { device in
            guard device.isConnected, let currentDistance = device.distance else { return device }
            let delta = Float.random(in: -0.5...0.5)
            let newDistance = max(0.1, currentDistance + delta)
            let newZone = zone(for: newDistance)
            return MonitoredDevice(
                id: device.id,
                name: device.name,
                deviceType: device.deviceType,
                distance: newDistance,
                direction: device.direction,
                currentZone: newZone,
                lastSeen: Date(),
                isConnected: device.isConnected
            )
        }
    }
}
