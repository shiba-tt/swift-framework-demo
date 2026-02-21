import Foundation
import AVFoundation
import AudioToolbox
import CoreAudioKit

// MARK: - AUv3PluginManager（AUv3 プラグイン管理）

@MainActor
@Observable
final class AUv3PluginManager {
    static let shared = AUv3PluginManager()

    // MARK: - Public State

    private(set) var availableEffects: [AUv3PluginInfo] = []
    private(set) var availableInstruments: [AUv3PluginInfo] = []
    private(set) var isScanning = false

    // MARK: - Private

    private let componentManager = AVAudioUnitComponentManager.shared()

    private init() {}

    // MARK: - Plugin Discovery

    /// インストール済みの AUv3 プラグインをスキャン
    func scanInstalledPlugins() {
        isScanning = true

        // エフェクトプラグインの検索
        let effectDescription = AudioComponentDescription(
            componentType: kAudioUnitType_Effect,
            componentSubType: 0,
            componentManufacturer: 0,
            componentFlags: 0,
            componentFlagsMask: 0
        )
        let effects = componentManager.components(matching: effectDescription)
        availableEffects = effects.map { AUv3PluginInfo(component: $0, category: .effect) }

        // インストゥルメントプラグインの検索
        let instrumentDescription = AudioComponentDescription(
            componentType: kAudioUnitType_MusicDevice,
            componentSubType: 0,
            componentManufacturer: 0,
            componentFlags: 0,
            componentFlagsMask: 0
        )
        let instruments = componentManager.components(matching: instrumentDescription)
        availableInstruments = instruments.map { AUv3PluginInfo(component: $0, category: .instrument) }

        isScanning = false
    }

    // MARK: - Plugin UI

    /// AUv3 プラグインのカスタム UI を取得
    /// CoreAudioKit の AUViewController を返す
    func requestViewController(
        for audioUnit: AUAudioUnit
    ) async -> UIViewController? {
        await withCheckedContinuation { continuation in
            audioUnit.requestViewController { viewController in
                continuation.resume(returning: viewController)
            }
        }
    }

    /// カスタム UI がない場合の汎用 UI を生成
    /// CoreAudioKit の AUGenericViewController を使用
    func createGenericViewController(
        for audioUnit: AUAudioUnit
    ) -> AUGenericViewController {
        let genericVC = AUGenericViewController()
        genericVC.auAudioUnit = audioUnit
        return genericVC
    }

    /// プラグイン UI を取得（カスタム UI → 汎用 UI フォールバック）
    func getPluginViewController(
        for audioUnit: AUAudioUnit
    ) async -> UIViewController {
        if let customVC = await requestViewController(for: audioUnit) {
            return customVC
        }
        return createGenericViewController(for: audioUnit)
    }

    // MARK: - Plugin Instantiation

    /// AUv3 プラグインをインスタンス化
    func instantiatePlugin(
        _ pluginInfo: AUv3PluginInfo
    ) async throws -> AVAudioUnit {
        try await AVAudioUnit.instantiate(
            with: pluginInfo.audioComponentDescription
        )
    }

    // MARK: - View Configuration

    /// プラグインがサポートするビュー構成を取得
    func supportedViewConfigurations(
        for audioUnit: AUAudioUnit
    ) -> [AUAudioUnitViewConfiguration] {
        audioUnit.supportedViewConfigurations
    }

    /// 最適なビュー構成を選択
    func selectViewConfiguration(
        for audioUnit: AUAudioUnit,
        containerSize: CGSize
    ) {
        let configs = audioUnit.supportedViewConfigurations
        let best = configs.first { config in
            config.width <= containerSize.width &&
            config.height <= containerSize.height
        }
        if let selected = best {
            audioUnit.select(selected)
        }
    }

    // MARK: - Preset Management

    /// ファクトリープリセット一覧を取得
    func factoryPresets(for audioUnit: AUAudioUnit) -> [AUAudioUnitPreset] {
        audioUnit.factoryPresets ?? []
    }

    /// ユーザープリセット一覧を取得
    func userPresets(for audioUnit: AUAudioUnit) -> [AUAudioUnitPreset] {
        audioUnit.userPresets
    }

    /// プリセットを適用
    func applyPreset(_ preset: AUAudioUnitPreset, to audioUnit: AUAudioUnit) {
        audioUnit.currentPreset = preset
    }

    /// ユーザープリセットを保存
    func saveUserPreset(
        name: String,
        to audioUnit: AUAudioUnit
    ) throws {
        let preset = AUAudioUnitPreset()
        preset.name = name
        preset.number = -1
        try audioUnit.saveUserPreset(preset)
    }

    /// ユーザープリセットを削除
    func deleteUserPreset(
        _ preset: AUAudioUnitPreset,
        from audioUnit: AUAudioUnit
    ) throws {
        try audioUnit.deleteUserPreset(preset)
    }

    // MARK: - Parameter Tree Access

    /// パラメータツリーからすべてのパラメータを取得
    func allParameters(
        for audioUnit: AUAudioUnit
    ) -> [AUParameter] {
        guard let tree = audioUnit.parameterTree else { return [] }
        return collectParameters(from: tree)
    }

    /// パラメータ変更のオブザーバーを登録
    func observeParameters(
        of audioUnit: AUAudioUnit,
        handler: @escaping (AUParameterAddress, AUValue) -> Void
    ) -> AUParameterObserverToken? {
        audioUnit.parameterTree?.token(byAddingParameterObserver: { address, value in
            handler(address, value)
        })
    }

    // MARK: - Private

    private func collectParameters(from tree: AUParameterTree) -> [AUParameter] {
        var result: [AUParameter] = []
        func collect(_ node: AUParameterNode) {
            if let param = node as? AUParameter {
                result.append(param)
            } else if let group = node as? AUParameterGroup {
                group.children.forEach { collect($0) }
            }
        }
        tree.children.forEach { collect($0) }
        return result
    }
}

// MARK: - AUv3PluginInfo（プラグイン情報）

struct AUv3PluginInfo: Identifiable, Sendable {
    let id: UUID
    let name: String
    let manufacturerName: String
    let audioComponentDescription: AudioComponentDescription
    let category: PluginCategory
    let version: UInt32
    let hasCustomView: Bool
    let tags: [String]

    init(component: AVAudioUnitComponent, category: PluginCategory) {
        self.id = UUID()
        self.name = component.name
        self.manufacturerName = component.manufacturerName
        self.audioComponentDescription = component.audioComponentDescription
        self.category = category
        self.version = component.version
        self.hasCustomView = component.hasCustomView
        self.tags = component.tags ?? []
    }

    var displayName: String {
        // "Manufacturer: PluginName" 形式から PluginName を抽出
        if let colonIndex = name.firstIndex(of: ":") {
            return String(name[name.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
        }
        return name
    }

    var versionString: String {
        let major = (version >> 16) & 0xFF
        let minor = (version >> 8) & 0xFF
        let patch = version & 0xFF
        return "\(major).\(minor).\(patch)"
    }
}

// MARK: - PluginCategory

enum PluginCategory: String, Sendable, CaseIterable {
    case effect = "エフェクト"
    case instrument = "インストゥルメント"

    var systemImage: String {
        switch self {
        case .effect: "waveform.badge.plus"
        case .instrument: "pianokeys"
        }
    }
}
