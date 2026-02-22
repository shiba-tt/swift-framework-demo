import Foundation

// MARK: - ControlDeckViewModel

@MainActor
@Observable
final class ControlDeckViewModel {

    // MARK: - Dependencies

    private let homeManager = SmartHomeManager.shared

    // MARK: - State

    var selectedRoom: Room?
    var showingSceneList = false
    var showingDeviceDetail = false
    var selectedDevice: SmartDevice?

    // MARK: - Computed Properties (delegate)

    var rooms: [Room] { homeManager.rooms }
    var scenes: [HomeScene] { homeManager.scenes }
    var logs: [DeviceLog] { homeManager.logs }
    var totalActiveDevices: Int { homeManager.totalActiveDevices }
    var totalDevices: Int { homeManager.totalDevices }
    var activeScene: HomeScene? { homeManager.activeScene }

    func devices(in room: Room) -> [SmartDevice] {
        homeManager.devices(in: room)
    }

    func activeDeviceCount(in room: Room) -> Int {
        homeManager.activeDeviceCount(in: room)
    }

    func totalDeviceCount(in room: Room) -> Int {
        homeManager.totalDeviceCount(in: room)
    }

    // MARK: - Actions

    func toggleDevice(_ device: SmartDevice) {
        homeManager.toggleDevice(device)
    }

    func updateDeviceValue(_ device: SmartDevice, value: Double) {
        homeManager.updateDeviceValue(device, value: value)
    }

    func executeScene(_ scene: HomeScene) {
        homeManager.executeScene(scene)
    }

    func allOffInRoom(_ room: Room) {
        homeManager.allOffInRoom(room)
    }
}
