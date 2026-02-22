import Foundation
import SwiftUI

// MARK: - SmartHomeManager

/// HomeKit / Matter と連携してスマートホームデバイスを管理するマネージャー。
/// 実デバイスでは HMHomeManager を使い、モック環境ではシミュレーションデータを返す。
/// コントロールセンター、ロック画面、Action ボタン向けのデータも
/// App Group 経由で Widget Extension に共有する。

@MainActor
@Observable
final class SmartHomeManager {
    static let shared = SmartHomeManager()

    // MARK: - State

    private(set) var rooms: [Room] = []
    private(set) var devices: [SmartDevice] = []
    private(set) var scenes: [HomeScene] = []
    private(set) var logs: [DeviceLog] = []

    private let appGroupID = "group.com.example.controldeck"

    private init() {
        setupMockData()
    }

    // MARK: - Room Queries

    func devices(in room: Room) -> [SmartDevice] {
        devices.filter { $0.roomID == room.id }
    }

    func activeDeviceCount(in room: Room) -> Int {
        devices(in: room).filter { $0.isOn }.count
    }

    func totalDeviceCount(in room: Room) -> Int {
        devices(in: room).count
    }

    // MARK: - Device Actions

    func toggleDevice(_ device: SmartDevice) {
        guard let index = devices.firstIndex(where: { $0.id == device.id }) else { return }
        devices[index].isOn.toggle()
        devices[index].lastUpdated = Date()

        let action = devices[index].isOn ? "ON" : "OFF"
        addLog(deviceName: device.name, deviceEmoji: device.type.emoji, action: action)
        syncToWidget()
    }

    func updateDeviceValue(_ device: SmartDevice, value: Double) {
        guard let index = devices.firstIndex(where: { $0.id == device.id }) else { return }
        devices[index].value = value
        devices[index].lastUpdated = Date()

        let unit = device.type.sliderUnit
        addLog(deviceName: device.name, deviceEmoji: device.type.emoji, action: "\(Int(value))\(unit)に変更")
        syncToWidget()
    }

    // MARK: - Scene Actions

    func executeScene(_ scene: HomeScene) {
        guard let index = scenes.firstIndex(where: { $0.id == scene.id }) else { return }

        // 他のシーンを非アクティブに
        for i in scenes.indices {
            scenes[i].isActive = false
        }
        scenes[index].isActive = true

        // シーンのアクションを実行（モック）
        for action in scene.actions {
            addLog(deviceName: action.deviceName, deviceEmoji: "🎬", action: action.description)
        }

        // シーンに基づいてデバイス状態を更新
        applySceneEffects(scene)
        syncToWidget()
    }

    // MARK: - Convenience

    func allOffInRoom(_ room: Room) {
        let roomDevices = devices(in: room)
        for device in roomDevices {
            if let index = devices.firstIndex(where: { $0.id == device.id }) {
                devices[index].isOn = false
                devices[index].lastUpdated = Date()
            }
        }
        addLog(deviceName: room.name, deviceEmoji: "🏠", action: "全デバイスOFF")
        syncToWidget()
    }

    var totalActiveDevices: Int {
        devices.filter { $0.isOn }.count
    }

    var totalDevices: Int {
        devices.count
    }

    var activeScene: HomeScene? {
        scenes.first { $0.isActive }
    }

    // MARK: - Widget Sync

    private func syncToWidget() {
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(totalActiveDevices, forKey: "activeDevices")
        defaults?.set(totalDevices, forKey: "totalDevices")
        defaults?.set(activeScene?.name ?? "なし", forKey: "activeScene")

        // 部屋ごとのサマリー
        for room in rooms {
            let active = activeDeviceCount(in: room)
            let total = totalDeviceCount(in: room)
            defaults?.set("\(active)/\(total)", forKey: "room_\(room.name)")
        }
    }

    // MARK: - Private Helpers

    private func addLog(deviceName: String, deviceEmoji: String, action: String) {
        let log = DeviceLog(
            deviceName: deviceName,
            deviceEmoji: deviceEmoji,
            action: action,
            timestamp: Date()
        )
        logs.insert(log, at: 0)

        // 最新50件だけ保持
        if logs.count > 50 {
            logs = Array(logs.prefix(50))
        }
    }

    private func applySceneEffects(_ scene: HomeScene) {
        switch scene.name {
        case "おはよう":
            setDevicesByType(.light, isOn: true, value: 80)
            setDevicesByType(.curtain, isOn: true, value: 100)
            setDevicesByType(.airConditioner, isOn: true, value: 24)
        case "おやすみ":
            setDevicesByType(.light, isOn: false, value: 0)
            setDevicesByType(.curtain, isOn: true, value: 0)
            setDevicesByType(.lock, isOn: true, value: 1)
        case "外出":
            for i in devices.indices {
                if devices[i].type != .lock && devices[i].type != .camera {
                    devices[i].isOn = false
                }
            }
            setDevicesByType(.lock, isOn: true, value: 1)
            setDevicesByType(.camera, isOn: true, value: 1)
        case "帰宅":
            setDevicesByType(.light, isOn: true, value: 70)
            setDevicesByType(.airConditioner, isOn: true, value: 24)
            setDevicesByType(.lock, isOn: true, value: 0)
        case "映画":
            setDevicesByType(.light, isOn: true, value: 10)
            setDevicesByType(.curtain, isOn: true, value: 0)
            setDevicesByType(.speaker, isOn: true, value: 60)
        default:
            break
        }
    }

    private func setDevicesByType(_ type: DeviceType, isOn: Bool, value: Double) {
        for i in devices.indices where devices[i].type == type {
            devices[i].isOn = isOn
            devices[i].value = value
            devices[i].lastUpdated = Date()
        }
    }

    // MARK: - Mock Data

    private func setupMockData() {
        // 部屋
        let livingRoom = Room(name: "リビング", icon: "sofa.fill", color: .blue, sortOrder: 0)
        let bedroom = Room(name: "寝室", icon: "bed.double.fill", color: .indigo, sortOrder: 1)
        let kitchen = Room(name: "キッチン", icon: "fork.knife", color: .orange, sortOrder: 2)
        let entrance = Room(name: "玄関", icon: "door.left.hand.open", color: .brown, sortOrder: 3)
        let garage = Room(name: "ガレージ", icon: "car.fill", color: .gray, sortOrder: 4)

        rooms = [livingRoom, bedroom, kitchen, entrance, garage]

        // デバイス
        devices = [
            // リビング
            SmartDevice(name: "リビング照明", type: .light, roomID: livingRoom.id, isOn: true, value: 70),
            SmartDevice(name: "リビングエアコン", type: .airConditioner, roomID: livingRoom.id, isOn: true, value: 24),
            SmartDevice(name: "テレビスピーカー", type: .speaker, roomID: livingRoom.id, isOn: false, value: 40),
            SmartDevice(name: "リビングカーテン", type: .curtain, roomID: livingRoom.id, isOn: true, value: 80),
            SmartDevice(name: "ロボット掃除機", type: .robot, roomID: livingRoom.id, isOn: false, value: 0),

            // 寝室
            SmartDevice(name: "寝室照明", type: .light, roomID: bedroom.id, isOn: false, value: 30),
            SmartDevice(name: "寝室エアコン", type: .airConditioner, roomID: bedroom.id, isOn: true, value: 22),
            SmartDevice(name: "寝室カーテン", type: .curtain, roomID: bedroom.id, isOn: true, value: 0),

            // キッチン
            SmartDevice(name: "キッチン照明", type: .light, roomID: kitchen.id, isOn: true, value: 100),

            // 玄関
            SmartDevice(name: "玄関ロック", type: .lock, roomID: entrance.id, isOn: true, value: 1),
            SmartDevice(name: "玄関カメラ", type: .camera, roomID: entrance.id, isOn: true, value: 1),

            // ガレージ
            SmartDevice(name: "ガレージドア", type: .garageDoor, roomID: garage.id, isOn: true, value: 1),
        ]

        // シーン
        scenes = [
            HomeScene(
                name: "おはよう",
                icon: "sunrise.fill",
                color: .orange,
                actions: [
                    SceneAction(deviceName: "照明", action: "on", description: "照明を80%に"),
                    SceneAction(deviceName: "カーテン", action: "open", description: "カーテンを全開"),
                    SceneAction(deviceName: "エアコン", action: "on", description: "エアコンを24°Cに")
                ]
            ),
            HomeScene(
                name: "おやすみ",
                icon: "moon.fill",
                color: .indigo,
                actions: [
                    SceneAction(deviceName: "照明", action: "off", description: "全照明OFF"),
                    SceneAction(deviceName: "カーテン", action: "close", description: "カーテンを閉める"),
                    SceneAction(deviceName: "ロック", action: "lock", description: "玄関を施錠")
                ]
            ),
            HomeScene(
                name: "外出",
                icon: "figure.walk",
                color: .green,
                actions: [
                    SceneAction(deviceName: "照明・エアコン", action: "off", description: "家電をすべてOFF"),
                    SceneAction(deviceName: "ロック", action: "lock", description: "施錠"),
                    SceneAction(deviceName: "カメラ", action: "on", description: "監視カメラON")
                ]
            ),
            HomeScene(
                name: "帰宅",
                icon: "house.fill",
                color: .blue,
                actions: [
                    SceneAction(deviceName: "照明", action: "on", description: "照明を70%に"),
                    SceneAction(deviceName: "エアコン", action: "on", description: "エアコンを24°Cに"),
                    SceneAction(deviceName: "ロック", action: "unlock", description: "玄関を解錠")
                ],
                isActive: true
            ),
            HomeScene(
                name: "映画",
                icon: "film.fill",
                color: .purple,
                actions: [
                    SceneAction(deviceName: "照明", action: "dim", description: "照明を10%に"),
                    SceneAction(deviceName: "カーテン", action: "close", description: "カーテンを閉める"),
                    SceneAction(deviceName: "スピーカー", action: "on", description: "スピーカー音量60%")
                ]
            )
        ]

        // 初期ログ
        let now = Date()
        logs = [
            DeviceLog(deviceName: "リビング照明", deviceEmoji: "💡", action: "ON (70%)", timestamp: now.addingTimeInterval(-120)),
            DeviceLog(deviceName: "リビングエアコン", deviceEmoji: "🌡️", action: "24°Cに設定", timestamp: now.addingTimeInterval(-300)),
            DeviceLog(deviceName: "玄関ロック", deviceEmoji: "🔒", action: "解錠", timestamp: now.addingTimeInterval(-600)),
            DeviceLog(deviceName: "帰宅シーン", deviceEmoji: "🎬", action: "実行", timestamp: now.addingTimeInterval(-610)),
            DeviceLog(deviceName: "玄関カメラ", deviceEmoji: "📹", action: "動体検知", timestamp: now.addingTimeInterval(-1800)),
            DeviceLog(deviceName: "ロボット掃除機", deviceEmoji: "🤖", action: "清掃完了", timestamp: now.addingTimeInterval(-3600))
        ]

        syncToWidget()
    }
}
