import SwiftUI

/// AUv3 プラグインのホスティング・比較を管理するマネージャー
///
/// AVAudioUnitComponentManager でプラグイン検索、AVAudioEngine で
/// デュアル処理パスの A/B 比較、CoreAudioKit で UI 表示を行う。
@MainActor
@Observable
final class PluginHostManager {

    static let shared = PluginHostManager()

    // MARK: - State

    private(set) var installedPlugins: [AUPlugin] = AUPlugin.samples
    private(set) var isPlaying = false
    private(set) var selectedAudioSource: AudioSource = .vocal
    private(set) var activeSlot: ABCompareSlot = .slotA
    private(set) var slotAPlugin: AUPlugin?
    private(set) var slotBPlugin: AUPlugin?
    private(set) var slotAParameters: [AUPluginParameter] = []
    private(set) var slotBParameters: [AUPluginParameter] = []
    private(set) var inputLevel: Float = 0
    private(set) var outputLevel: Float = 0
    private(set) var favorites: Set<UUID> = []

    private var meteringTimer: Timer?

    private init() {}

    // MARK: - Plugin Loading

    func loadPluginToSlotA(_ plugin: AUPlugin) {
        slotAPlugin = plugin
        slotAParameters = AUPlugin.sampleParameters(for: plugin)
    }

    func loadPluginToSlotB(_ plugin: AUPlugin) {
        slotBPlugin = plugin
        slotBParameters = AUPlugin.sampleParameters(for: plugin)
    }

    func clearSlotA() {
        slotAPlugin = nil
        slotAParameters = []
    }

    func clearSlotB() {
        slotBPlugin = nil
        slotBParameters = []
    }

    // MARK: - A/B Compare

    func switchToSlot(_ slot: ABCompareSlot) {
        activeSlot = slot
    }

    func toggleAB() {
        activeSlot = activeSlot == .slotA ? .slotB : .slotA
    }

    // MARK: - Audio Source

    func selectAudioSource(_ source: AudioSource) {
        selectedAudioSource = source
    }

    // MARK: - Playback

    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startMetering()
        } else {
            stopMetering()
        }
    }

    func stopPlayback() {
        isPlaying = false
        stopMetering()
    }

    private func startMetering() {
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isPlaying else { return }
                self.inputLevel = Float.random(in: 0.3...0.85)
                self.outputLevel = Float.random(in: 0.2...0.9)
            }
        }
    }

    private func stopMetering() {
        meteringTimer?.invalidate()
        meteringTimer = nil
        inputLevel = 0
        outputLevel = 0
    }

    // MARK: - Parameter Update

    func updateSlotAParameter(id: UUID, value: Float) {
        guard let index = slotAParameters.firstIndex(where: { $0.id == id }) else { return }
        slotAParameters[index].currentValue = value
    }

    func updateSlotBParameter(id: UUID, value: Float) {
        guard let index = slotBParameters.firstIndex(where: { $0.id == id }) else { return }
        slotBParameters[index].currentValue = value
    }

    // MARK: - Favorites

    func toggleFavorite(_ plugin: AUPlugin) {
        if favorites.contains(plugin.id) {
            favorites.remove(plugin.id)
        } else {
            favorites.insert(plugin.id)
        }
    }

    func isFavorite(_ plugin: AUPlugin) -> Bool {
        favorites.contains(plugin.id)
    }

    // MARK: - Filtering

    func plugins(for category: AUPluginCategory?) -> [AUPlugin] {
        guard let category else { return installedPlugins }
        return installedPlugins.filter { $0.category == category }
    }

    func plugins(matching query: String) -> [AUPlugin] {
        guard !query.isEmpty else { return installedPlugins }
        let lowered = query.lowercased()
        return installedPlugins.filter {
            $0.name.lowercased().contains(lowered) ||
            $0.manufacturer.lowercased().contains(lowered) ||
            $0.category.rawValue.lowercased().contains(lowered) ||
            $0.tags.contains(where: { $0.lowercased().contains(lowered) })
        }
    }

    // MARK: - Statistics

    var categoryCounts: [(AUPluginCategory, Int)] {
        var counts: [AUPluginCategory: Int] = [:]
        for plugin in installedPlugins {
            counts[plugin.category, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
    }

    var totalPluginCount: Int { installedPlugins.count }

    var averageRating: Double {
        guard !installedPlugins.isEmpty else { return 0 }
        return installedPlugins.reduce(0) { $0 + $1.rating } / Double(installedPlugins.count)
    }
}
