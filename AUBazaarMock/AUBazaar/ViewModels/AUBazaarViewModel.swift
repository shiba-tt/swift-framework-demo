import SwiftUI

@MainActor
@Observable
final class AUBazaarViewModel {

    // MARK: - Tab

    enum Tab: String, Sendable {
        case browse = "ブラウズ"
        case compare = "A/B比較"
        case favorites = "お気に入り"
    }

    var selectedTab: Tab = .browse

    // MARK: - State

    var searchQuery = ""
    var selectedCategory: AUPluginCategory?
    var selectedPlugin: AUPlugin?
    var showPluginDetail = false
    var showPluginPicker = false
    var pickingSlot: ABCompareSlot = .slotA

    private let manager = PluginHostManager.shared

    // MARK: - Proxied State

    var isPlaying: Bool { manager.isPlaying }
    var selectedAudioSource: AudioSource { manager.selectedAudioSource }
    var activeSlot: ABCompareSlot { manager.activeSlot }
    var slotAPlugin: AUPlugin? { manager.slotAPlugin }
    var slotBPlugin: AUPlugin? { manager.slotBPlugin }
    var slotAParameters: [AUPluginParameter] { manager.slotAParameters }
    var slotBParameters: [AUPluginParameter] { manager.slotBParameters }
    var inputLevel: Float { manager.inputLevel }
    var outputLevel: Float { manager.outputLevel }
    var totalPluginCount: Int { manager.totalPluginCount }
    var averageRating: Double { manager.averageRating }
    var categoryCounts: [(AUPluginCategory, Int)] { manager.categoryCounts }

    // MARK: - Computed

    var filteredPlugins: [AUPlugin] {
        var results = manager.plugins(for: selectedCategory)
        if !searchQuery.isEmpty {
            let lowered = searchQuery.lowercased()
            results = results.filter {
                $0.name.lowercased().contains(lowered) ||
                $0.manufacturer.lowercased().contains(lowered) ||
                $0.tags.contains(where: { $0.lowercased().contains(lowered) })
            }
        }
        return results
    }

    var favoritePlugins: [AUPlugin] {
        manager.installedPlugins.filter { manager.isFavorite($0) }
    }

    var canCompare: Bool {
        slotAPlugin != nil && slotBPlugin != nil
    }

    // MARK: - Actions

    func togglePlayback() {
        manager.togglePlayback()
    }

    func selectAudioSource(_ source: AudioSource) {
        manager.selectAudioSource(source)
    }

    func switchToSlot(_ slot: ABCompareSlot) {
        manager.switchToSlot(slot)
    }

    func toggleAB() {
        manager.toggleAB()
    }

    func loadPluginToSlot(_ plugin: AUPlugin, slot: ABCompareSlot) {
        switch slot {
        case .slotA: manager.loadPluginToSlotA(plugin)
        case .slotB: manager.loadPluginToSlotB(plugin)
        }
        showPluginPicker = false
    }

    func clearSlot(_ slot: ABCompareSlot) {
        switch slot {
        case .slotA: manager.clearSlotA()
        case .slotB: manager.clearSlotB()
        }
    }

    func toggleFavorite(_ plugin: AUPlugin) {
        manager.toggleFavorite(plugin)
    }

    func isFavorite(_ plugin: AUPlugin) -> Bool {
        manager.isFavorite(plugin)
    }

    func updateParameter(id: UUID, value: Float, slot: ABCompareSlot) {
        switch slot {
        case .slotA: manager.updateSlotAParameter(id: id, value: value)
        case .slotB: manager.updateSlotBParameter(id: id, value: value)
        }
    }

    func openPluginPicker(for slot: ABCompareSlot) {
        pickingSlot = slot
        showPluginPicker = true
    }
}
