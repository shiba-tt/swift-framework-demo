# CoreAudioKit フレームワーク 調査レポート

## 1. CoreAudioKit とは

CoreAudioKit は Apple が提供する**Audio Unit（AUv3）プラグインの UI を構築するためのフレームワーク**である。Audio Unit Extension（AUv3）にカスタム UI を持たせたり、ホストアプリが Audio Unit のパラメータを汎用 UI で表示したりするための基盤クラスを提供する。

iOS 9.0 / macOS 10.11 で導入され、Audio Unit v3（AUv3）アーキテクチャの「UI レイヤー」を担う。

**核心コンセプト:** 「Audio Unit プラグインに標準化された UI の仕組みを提供し、ホストアプリとプラグイン間の UI 連携を可能にする」

### CoreAudioKit の位置づけ

```
┌──────────────────────────────────────────────────────────────┐
│  ホストアプリ（DAW / 音楽アプリ）                                │
│                                                               │
│  ┌─ CoreAudioKit（UI レイヤー）──────────────────────────────┐ │
│  │ AUViewController (カスタム UI の基底クラス)                  │ │
│  │ AUGenericViewController (汎用パラメータ UI — iOS)           │ │
│  │ AUGenericView (汎用パラメータ UI — macOS)                   │ │
│  │ AUAudioUnitViewConfiguration (ビュー構成)                   │ │
│  └───────────────┬──────────────────────────────────────────┘ │
│                   ↕                                            │
│  ┌─ AudioToolbox / AVFAudio（オーディオエンジン）──────────────┐ │
│  │ AUAudioUnit / AUAudioUnitV2Bridge                          │ │
│  │ AUParameter / AUParameterTree / AUParameterGroup            │ │
│  │ AudioComponentDescription / AudioComponentInstantiationOptions│ │
│  │ AVAudioEngine / AVAudioUnitEffect / AVAudioUnitGenerator    │ │
│  └───────────────┬──────────────────────────────────────────┘ │
│                   ↕                                            │
│  ┌─ Core Audio（低レベルオーディオ）─────────────────────────┐ │
│  │ AudioUnit / AudioComponent / AudioBuffer                    │ │
│  │ AURenderCallback / AudioBufferList                          │ │
│  └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

| レイヤー | 役割 | 主要クラス |
|---|---|---|
| **CoreAudioKit** | Audio Unit の UI 提供 | `AUViewController`, `AUGenericViewController`, `AUGenericView`, `AUAudioUnitViewConfiguration` |
| **AudioToolbox** | Audio Unit エンジン | `AUAudioUnit`, `AUParameterTree`, `AUParameter`, `AudioComponentDescription` |
| **AVFAudio** | 高レベルオーディオ API | `AVAudioEngine`, `AVAudioUnitEffect`, `AVAudioUnitGenerator`, `AVAudioUnitMIDIInstrument` |
| **Core Audio** | 低レベルオーディオ処理 | `AudioUnit`, `AudioComponent`, `AudioBufferList`, `AURenderCallback` |

---

## 2. CoreAudioKit の主要クラス

### 2.1 AUViewController — カスタム UI の基底クラス

Audio Unit Extension にカスタム UI を持たせるための基底クラス。iOS では `UIViewController`、macOS では `NSViewController` のサブクラス。

```swift
import CoreAudioKit
import AudioToolbox

class MyEffectViewController: AUViewController {
    // Audio Unit への参照
    var audioUnit: AUAudioUnit? {
        didSet {
            // Audio Unit が設定されたら UI とパラメータを接続
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.connectViewToAU()
                }
            }
        }
    }

    // パラメータへの参照
    private var cutoffParameter: AUParameter?
    private var resonanceParameter: AUParameter?
    private var parameterObserverToken: AUParameterObserverToken?

    // UI 要素
    @IBOutlet weak var cutoffSlider: UISlider!
    @IBOutlet weak var resonanceSlider: UISlider!
    @IBOutlet weak var cutoffLabel: UILabel!
    @IBOutlet weak var resonanceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Audio Unit が既に設定されていたら接続
        if audioUnit != nil {
            connectViewToAU()
        }
    }

    private func connectViewToAU() {
        guard let paramTree = audioUnit?.parameterTree else { return }

        // パラメータを取得
        cutoffParameter = paramTree.value(forKey: "cutoff") as? AUParameter
        resonanceParameter = paramTree.value(forKey: "resonance") as? AUParameter

        // UI を初期値で更新
        cutoffSlider.value = cutoffParameter?.value ?? 0
        resonanceSlider.value = resonanceParameter?.value ?? 0

        // パラメータ変更を監視（ホスト側からの変更を UI に反映）
        parameterObserverToken = paramTree.token(byAddingParameterObserver: {
            [weak self] address, value in
            DispatchQueue.main.async {
                self?.updateUI(address: address, value: value)
            }
        })
    }

    private func updateUI(address: AUParameterAddress, value: AUValue) {
        if address == cutoffParameter?.address {
            cutoffSlider.value = value
            cutoffLabel.text = String(format: "%.1f Hz", value)
        } else if address == resonanceParameter?.address {
            resonanceSlider.value = value
            resonanceLabel.text = String(format: "%.1f dB", value)
        }
    }

    // UI 操作 → パラメータ変更
    @IBAction func cutoffChanged(_ sender: UISlider) {
        cutoffParameter?.value = sender.value
    }

    @IBAction func resonanceChanged(_ sender: UISlider) {
        resonanceParameter?.value = sender.value
    }
}
```

**重要な設計ポイント:**

| ポイント | 説明 |
|---|---|
| **ロード順序の不確定性** | Audio Unit と ViewController のどちらが先にロードされるか保証されない。両方のタイミングで接続を試みる |
| **スレッド安全性** | パラメータ変更通知はワーカースレッドから届く。UI 更新は必ず `DispatchQueue.main` で行う |
| **双方向バインディング** | UI → パラメータ と パラメータ → UI の双方向同期が必要 |
| **Extension プロセス** | AUViewController は別プロセス（App Extension）で動作し、ホストアプリに埋め込まれる |

### 2.2 AUGenericViewController — 汎用パラメータ UI（iOS）

Audio Unit がカスタム UI を提供しない場合に、パラメータツリーから自動的にスライダーやラベルを生成する汎用ビューコントローラー。

```swift
import CoreAudioKit
import AudioToolbox

class HostViewController: UIViewController {

    func showGenericUI(for audioUnit: AUAudioUnit) {
        // カスタム UI がない場合、汎用 UI を表示
        audioUnit.requestViewController { [weak self] viewController in
            DispatchQueue.main.async {
                if let customVC = viewController {
                    // カスタム UI が提供された
                    self?.embedViewController(customVC)
                } else {
                    // カスタム UI なし → 汎用 UI を生成
                    let genericVC = AUGenericViewController()
                    genericVC.auAudioUnit = audioUnit
                    self?.embedViewController(genericVC)
                }
            }
        }
    }

    private func embedViewController(_ vc: UIViewController) {
        addChild(vc)
        vc.view.frame = containerView.bounds
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
}
```

**AUGenericViewController の自動生成 UI:**
```
┌─ AUGenericViewController ──────────────────────────┐
│                                                      │
│  Cutoff Frequency                                    │
│  ◀── ──────────●──────── ▶  12000 Hz                │
│                                                      │
│  Resonance                                           │
│  ◀── ────●──────────── ▶  5.0 dB                    │
│                                                      │
│  Mix                                                 │
│  ◀── ──────────────●── ▶  80%                       │
│                                                      │
│  Bypass                                              │
│  [OFF] ████ [ON]                                     │
│                                                      │
│  (AUParameterTree から自動生成)                       │
└──────────────────────────────────────────────────────┘
```

### 2.3 AUGenericView — 汎用パラメータ UI（macOS）

macOS 向けの汎用パラメータ UI。`NSView` のサブクラス。

```swift
import CoreAudioKit  // macOS
import AudioToolbox

// macOS でのみ利用可能
let genericView = AUGenericView(audioUnit: audioUnitRef)
genericView.showsExpertParameters = true
```

| プロパティ | 説明 |
|---|---|
| `showsExpertParameters` | 通常は非表示の「エキスパート」パラメータも表示するか |
| `audioUnit` | 表示対象の AudioUnit |

### 2.4 AUAudioUnitViewConfiguration — ビュー構成の定義

Audio Unit がサポートするビューのサイズ・レイアウトをホストに伝えるための構成オブジェクト。

```swift
import CoreAudioKit

// Audio Unit 側: サポートするビュー構成を宣言
extension MyAudioUnit: AUAudioUnit {
    override var supportedViewConfigurations: [AUAudioUnitViewConfiguration] {
        return [
            // コンパクト表示（幅 400, 高さ 100）
            AUAudioUnitViewConfiguration(width: 400, height: 100,
                                          hostHasController: false),
            // フル表示（幅 800, 高さ 500）
            AUAudioUnitViewConfiguration(width: 800, height: 500,
                                          hostHasController: false),
            // ホストがコントローラーを持つ場合の最小表示
            AUAudioUnitViewConfiguration(width: 0, height: 0,
                                          hostHasController: true),
        ]
    }
}

// ホスト側: 最適なビュー構成を選択
func selectViewConfiguration(for audioUnit: AUAudioUnit,
                              containerSize: CGSize) {
    let configs = audioUnit.supportedViewConfigurations
    let best = configs.first { config in
        config.width <= containerSize.width &&
        config.height <= containerSize.height
    }
    if let selected = best {
        audioUnit.select(selected)
    }
}
```

**ビュー構成の使い分け:**
```
┌─ フル表示 (800x500) ─────────────────────────────────┐
│  ┌─────────────────────────────────────────────────┐  │
│  │         カスタム UI（ノブ、グラフ、波形等）         │  │
│  │                                                  │  │
│  │    🎛️ Cutoff    🎛️ Resonance    🎛️ Mix          │  │
│  │    ┌───────────────────────────────────────┐    │  │
│  │    │   周波数応答グラフ                       │    │  │
│  │    └───────────────────────────────────────┘    │  │
│  └─────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┘

┌─ コンパクト表示 (400x100) ──────────────────┐
│  Cutoff [────●────] Reso [──●──] Mix [───●] │
└─────────────────────────────────────────────┘

┌─ ホスト制御 (0x0) ───────────┐
│  (ホスト側の UI で制御)        │
│  ホストがスライダー等を提供    │
└──────────────────────────────┘
```

---

## 3. Audio Unit v3（AUv3）Extension アーキテクチャ

CoreAudioKit は AUv3 Extension の UI 部分を担う。AUv3 Extension の全体像を理解することが重要。

### 3.1 AUv3 Extension の構成要素

```
┌─ 配布アプリ (.app) ─────────────────────────────────────────┐
│                                                               │
│  メインアプリ (スタンドアロン動作 / 設定 UI)                     │
│                                                               │
│  ┌─ Audio Unit Extension (.appex) ─────────────────────────┐ │
│  │                                                          │ │
│  │  ┌─ AUViewController サブクラス ──────────────────────┐ │ │
│  │  │  (CoreAudioKit)                                     │ │ │
│  │  │  カスタム UI — ノブ、スライダー、グラフ等             │ │ │
│  │  │  ← import CoreAudioKit                              │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │                                                          │ │
│  │  ┌─ AUAudioUnit サブクラス ───────────────────────────┐ │ │
│  │  │  (AudioToolbox)                                      │ │ │
│  │  │  DSP 処理 / パラメータ定義 / プリセット管理            │ │ │
│  │  │  ← import AudioToolbox                               │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │                                                          │ │
│  │  Info.plist (AudioComponents 記述)                        │ │
│  │  MainInterface.storyboard (UI レイアウト)                  │ │
│  └──────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 Audio Unit Extension の作成（完全な例）

**Step 1: AUAudioUnit サブクラス（DSP 処理）**

```swift
import AudioToolbox

class SimpleDelayAudioUnit: AUAudioUnit {
    // パラメータ定義
    private let delayTimeParam = AUParameterTree.createParameter(
        withIdentifier: "delayTime",
        name: "Delay Time",
        address: 0,
        min: 0.0, max: 2.0,
        unit: .seconds,
        unitName: "sec",
        flags: [.flag_IsReadable, .flag_IsWritable],
        valueStrings: nil,
        dependentParameters: nil
    )

    private let feedbackParam = AUParameterTree.createParameter(
        withIdentifier: "feedback",
        name: "Feedback",
        address: 1,
        min: 0.0, max: 0.95,
        unit: .generic,
        unitName: nil,
        flags: [.flag_IsReadable, .flag_IsWritable],
        valueStrings: nil,
        dependentParameters: nil
    )

    private let mixParam = AUParameterTree.createParameter(
        withIdentifier: "mix",
        name: "Dry/Wet Mix",
        address: 2,
        min: 0.0, max: 1.0,
        unit: .generic,
        unitName: nil,
        flags: [.flag_IsReadable, .flag_IsWritable],
        valueStrings: nil,
        dependentParameters: nil
    )

    // 内部バッファ
    private var delayBuffer: [Float] = []
    private var writeIndex: Int = 0

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        // パラメータツリーの構築
        parameterTree = AUParameterTree.createTree(
            withChildren: [delayTimeParam, feedbackParam, mixParam]
        )

        // デフォルト値
        delayTimeParam.value = 0.5
        feedbackParam.value = 0.3
        mixParam.value = 0.5
    }

    override var internalRenderBlock: AUInternalRenderBlock {
        // ⚠️ render block 内では self をキャプチャしない
        // ⚠️ Objective-C / Swift の呼び出し禁止
        // ⚠️ I/O 禁止、ロック禁止
        let delayTime = delayTimeParam
        let feedback = feedbackParam
        let mix = mixParam

        return { actionFlags, timestamp, frameCount, outputBusNumber,
                 outputData, realtimeEventListHead, pullInputBlock in

            // 入力を取得
            guard let pullInputBlock = pullInputBlock else {
                return kAudioUnitErr_NoConnection
            }
            var pullFlags: AudioUnitRenderActionFlags = []
            let status = pullInputBlock(&pullFlags, timestamp,
                                         frameCount, 0, outputData)
            guard status == noErr else { return status }

            // DSP 処理（ディレイ）はここで実行
            // C/C++ で実装するのが推奨
            return noErr
        }
    }
}
```

**Step 2: AUViewController サブクラス（UI）**

```swift
import CoreAudioKit

class SimpleDelayViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: SimpleDelayAudioUnit?

    // AUAudioUnitFactory プロトコル
    func createAudioUnit(
        with componentDescription: AudioComponentDescription
    ) throws -> AUAudioUnit {
        let au = try SimpleDelayAudioUnit(
            componentDescription: componentDescription)
        audioUnit = au
        DispatchQueue.main.async { self.connectUI() }
        return au
    }

    @IBOutlet weak var delayTimeKnob: UISlider!
    @IBOutlet weak var feedbackKnob: UISlider!
    @IBOutlet weak var mixKnob: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectUI()
    }

    private func connectUI() {
        guard isViewLoaded, let au = audioUnit else { return }
        let paramTree = au.parameterTree!

        // スライダー初期値の設定
        delayTimeKnob.value = paramTree.parameter(
            withAddress: 0)?.value ?? 0.5
        feedbackKnob.value = paramTree.parameter(
            withAddress: 1)?.value ?? 0.3
        mixKnob.value = paramTree.parameter(
            withAddress: 2)?.value ?? 0.5

        // パラメータ変更の監視
        paramTree.token(byAddingParameterObserver: {
            [weak self] address, value in
            DispatchQueue.main.async {
                switch address {
                case 0: self?.delayTimeKnob.value = value
                case 1: self?.feedbackKnob.value = value
                case 2: self?.mixKnob.value = value
                default: break
                }
            }
        })
    }

    @IBAction func delayTimeChanged(_ sender: UISlider) {
        audioUnit?.parameterTree?.parameter(
            withAddress: 0)?.value = sender.value
    }

    @IBAction func feedbackChanged(_ sender: UISlider) {
        audioUnit?.parameterTree?.parameter(
            withAddress: 1)?.value = sender.value
    }

    @IBAction func mixChanged(_ sender: UISlider) {
        audioUnit?.parameterTree?.parameter(
            withAddress: 2)?.value = sender.value
    }
}
```

**Step 3: Info.plist 設定**

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>AudioComponents</key>
        <array>
            <dict>
                <key>type</key>
                <string>aufx</string>        <!-- エフェクト -->
                <key>subtype</key>
                <string>dely</string>        <!-- サブタイプ（4文字） -->
                <key>manufacturer</key>
                <string>Demo</string>        <!-- メーカーコード（4文字） -->
                <key>name</key>
                <string>Demo: SimpleDelay</string>
                <key>version</key>
                <integer>1</integer>
                <key>sandboxSafe</key>
                <true/>
                <key>tags</key>
                <array>
                    <string>Effects</string>
                </array>
            </dict>
        </array>
    </dict>
    <key>NSExtensionMainStoryboard</key>
    <string>MainInterface</string>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.AudioUnit-UI</string>
</dict>
```

### 3.3 Audio Unit のタイプ

| タイプコード | 名称 | 説明 | 例 |
|---|---|---|---|
| `aufx` | Effect | オーディオエフェクト | リバーブ、ディレイ、EQ、コンプレッサー |
| `aumu` | Music Instrument | MIDI 入力 → オーディオ出力 | シンセサイザー、サンプラー |
| `aumf` | Music Effect | オーディオ + MIDI 入力 → オーディオ出力 | ボコーダー、MIDI 制御エフェクト |
| `auou` | Output | オーディオ出力先 | スピーカー、ファイル書き出し |
| `augn` | Generator | オーディオ生成（入力なし） | トーンジェネレーター、ノイズ |
| `aumi` | MIDI Processor | MIDI 処理 | アルペジエーター、トランスポーザー |

### 3.4 ホストアプリから Audio Unit を利用する

```swift
import AVFoundation
import AudioToolbox
import CoreAudioKit

class AudioUnitHostManager {
    let audioEngine = AVAudioEngine()

    // 利用可能な Audio Unit を検索
    func findAudioUnits() async -> [AVAudioUnitComponent] {
        let description = AudioComponentDescription(
            componentType: kAudioUnitType_Effect,  // エフェクトを検索
            componentSubType: 0,
            componentManufacturer: 0,
            componentFlags: 0,
            componentFlagsMask: 0
        )
        return AVAudioUnitComponentManager.shared()
            .components(matching: description)
    }

    // Audio Unit をインスタンス化して接続
    func loadAudioUnit(
        _ component: AVAudioUnitComponent
    ) async throws -> (AVAudioUnit, UIViewController?) {
        let audioUnit = try await AVAudioUnit.instantiate(
            with: component.audioComponentDescription)

        // AVAudioEngine に接続
        audioEngine.attach(audioUnit)
        audioEngine.connect(audioEngine.inputNode,
                           to: audioUnit, format: nil)
        audioEngine.connect(audioUnit,
                           to: audioEngine.mainMixerNode, format: nil)

        // UI を取得（CoreAudioKit の出番）
        let viewController = await withCheckedContinuation {
            continuation in
            audioUnit.auAudioUnit.requestViewController {
                vc in
                continuation.resume(returning: vc)
            }
        }

        return (audioUnit, viewController)
    }

    // UI がない場合は汎用 UI を使用
    func getGenericViewController(
        for audioUnit: AUAudioUnit
    ) -> AUGenericViewController {
        let genericVC = AUGenericViewController()
        genericVC.auAudioUnit = audioUnit
        return genericVC
    }

    func start() throws {
        try audioEngine.start()
    }
}
```

**ホストアプリの Audio Unit 組み込みフロー:**
```
┌─ ホストアプリ ─────────────────────────────────────────┐
│                                                         │
│  1. Audio Unit を検索                                    │
│     AVAudioUnitComponentManager.components(matching:)   │
│              ↓                                          │
│  2. Audio Unit をインスタンス化                            │
│     AVAudioUnit.instantiate(with:)                      │
│              ↓                                          │
│  3. AVAudioEngine に接続                                 │
│     engine.attach() → engine.connect()                  │
│              ↓                                          │
│  4. UI を取得 (CoreAudioKit)                             │
│     auAudioUnit.requestViewController { vc in ... }     │
│              ↓                                          │
│  ┌─ vc が nil? ─────────────────────────────────────┐  │
│  │ YES → AUGenericViewController() を使用             │  │
│  │ NO  → カスタム AUViewController を埋め込み          │  │
│  └───────────────────────────────────────────────────┘  │
│              ↓                                          │
│  5. コンテナビューに埋め込み表示                           │
│     addChild(vc) → view.addSubview(vc.view)             │
│              ↓                                          │
│  6. engine.start() で処理開始                             │
└─────────────────────────────────────────────────────────┘
```

---

## 4. AUv3 プリセット管理

AUv3 は iOS 13 / macOS 10.15 以降でユーザープリセットをサポート。

```swift
import AudioToolbox

class PresetManager {
    let audioUnit: AUAudioUnit

    init(audioUnit: AUAudioUnit) {
        self.audioUnit = audioUnit
    }

    // ファクトリープリセット一覧
    var factoryPresets: [AUAudioUnitPreset] {
        return audioUnit.factoryPresets ?? []
    }

    // ユーザープリセット一覧
    var userPresets: [AUAudioUnitPreset] {
        return audioUnit.userPresets
    }

    // プリセット適用
    func selectPreset(_ preset: AUAudioUnitPreset) {
        audioUnit.currentPreset = preset
    }

    // 現在のパラメータをユーザープリセットとして保存
    func saveUserPreset(name: String) throws {
        let preset = AUAudioUnitPreset()
        preset.name = name
        preset.number = -1  // 負の値 = ユーザープリセット
        try audioUnit.saveUserPreset(preset)
    }

    // ユーザープリセットを削除
    func deleteUserPreset(_ preset: AUAudioUnitPreset) throws {
        try audioUnit.deleteUserPreset(preset)
    }

    // 全状態の保存（ホスト側でのセッション保存用）
    var fullState: [String: Any]? {
        get { audioUnit.fullState }
        set { audioUnit.fullState = newValue }
    }
}
```

---

## 5. SwiftUI との統合

### 5.1 AUViewController を SwiftUI で表示

```swift
import SwiftUI
import CoreAudioKit

// UIViewControllerRepresentable でラップ
struct AudioUnitView: UIViewControllerRepresentable {
    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController,
                                 context: Context) {}
}

// SwiftUI でのホスト画面
struct AudioUnitHostView: View {
    @StateObject private var host = AudioUnitHost()

    var body: some View {
        VStack {
            // Audio Unit 選択
            Picker("Audio Unit", selection: $host.selectedComponent) {
                ForEach(host.availableComponents, id: \.name) { comp in
                    Text(comp.name).tag(comp as AVAudioUnitComponent?)
                }
            }

            // Audio Unit の UI を埋め込み
            if let vc = host.audioUnitViewController {
                AudioUnitView(viewController: vc)
                    .frame(height: 300)
            }

            // プリセット選択
            Picker("Preset", selection: $host.selectedPreset) {
                ForEach(host.presets, id: \.number) { preset in
                    Text(preset.name).tag(preset as AUAudioUnitPreset?)
                }
            }
        }
    }
}
```

### 5.2 AUv3 Extension の UI を SwiftUI で構築

```swift
import CoreAudioKit
import SwiftUI

// AUViewController のサブクラスで SwiftUI を使用
class MySwiftUIAudioUnitViewController: AUViewController {
    var audioUnit: AUAudioUnit?

    override func viewDidLoad() {
        super.viewDidLoad()

        // SwiftUI ビューをホスティング
        let parameterState = ParameterState()
        let swiftUIView = AudioUnitControlView(state: parameterState)
        let hostingController = UIHostingController(rootView: swiftUIView)

        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        // パラメータ接続
        if let paramTree = audioUnit?.parameterTree {
            parameterState.connect(to: paramTree)
        }
    }
}

// パラメータ状態管理
class ParameterState: ObservableObject {
    @Published var cutoff: Float = 1000
    @Published var resonance: Float = 0.5
    @Published var mix: Float = 0.5

    private var paramTree: AUParameterTree?
    private var token: AUParameterObserverToken?

    func connect(to paramTree: AUParameterTree) {
        self.paramTree = paramTree
        token = paramTree.token(byAddingParameterObserver: {
            [weak self] address, value in
            DispatchQueue.main.async {
                switch address {
                case 0: self?.cutoff = value
                case 1: self?.resonance = value
                case 2: self?.mix = value
                default: break
                }
            }
        })
    }

    func setCutoff(_ value: Float) {
        paramTree?.parameter(withAddress: 0)?.value = value
    }

    func setResonance(_ value: Float) {
        paramTree?.parameter(withAddress: 1)?.value = value
    }

    func setMix(_ value: Float) {
        paramTree?.parameter(withAddress: 2)?.value = value
    }
}

// SwiftUI の Audio Unit コントロール画面
struct AudioUnitControlView: View {
    @ObservedObject var state: ParameterState

    var body: some View {
        VStack(spacing: 20) {
            ParameterSlider(label: "Cutoff", value: $state.cutoff,
                           range: 20...20000, unit: "Hz") {
                state.setCutoff($0)
            }
            ParameterSlider(label: "Resonance", value: $state.resonance,
                           range: 0...1, unit: "") {
                state.setResonance($0)
            }
            ParameterSlider(label: "Mix", value: $state.mix,
                           range: 0...1, unit: "") {
                state.setMix($0)
            }
        }
        .padding()
    }
}

struct ParameterSlider: View {
    let label: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let unit: String
    let onChange: (Float) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f %@", value, unit))
                    .foregroundColor(.secondary)
            }
            Slider(value: $value, in: range) { _ in
                onChange(value)
            }
        }
    }
}
```

---

## 6. MIDI 対応

### 6.1 MIDI Instrument Extension

```swift
import AudioToolbox
import CoreAudioKit

class SynthAudioUnit: AUAudioUnit {
    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        // タイプ: aumu (Music Instrument)
        try super.init(componentDescription: componentDescription,
                       options: options)
    }

    override var internalRenderBlock: AUInternalRenderBlock {
        return { actionFlags, timestamp, frameCount, outputBusNumber,
                 outputData, realtimeEventListHead, pullInputBlock in

            // MIDI イベントを処理
            var event = realtimeEventListHead?.pointee
            while event != nil {
                switch event!.head.eventType {
                case .MIDI:
                    let midiBytes = event!.MIDI.data
                    let status = midiBytes.0 & 0xF0
                    let note = midiBytes.1
                    let velocity = midiBytes.2

                    if status == 0x90 && velocity > 0 {
                        // Note On
                    } else if status == 0x80 || (status == 0x90 && velocity == 0) {
                        // Note Off
                    }
                default:
                    break
                }
                event = event?.head.next?.pointee
            }

            // オーディオバッファにシンセ出力を書き込み
            return noErr
        }
    }
}
```

### 6.2 MIDI Processor Extension（iOS 16+ / macOS 13+）

```swift
import AudioToolbox

class ArpeggiatorAudioUnit: AUAudioUnit {
    // タイプ: aumi (MIDI Processor)
    // MIDI 入力を受け取り、変換した MIDI を出力

    override var internalRenderBlock: AUInternalRenderBlock {
        return { actionFlags, timestamp, frameCount, outputBusNumber,
                 outputData, realtimeEventListHead, pullInputBlock in

            // 入力 MIDI を受け取ってアルペジオ化
            // 変換した MIDI イベントを出力
            return noErr
        }
    }
}
```

---

## 7. プラットフォーム別の CoreAudioKit 対応

| 機能 | iOS | iPadOS | macOS | visionOS |
|---|---|---|---|---|
| **AUViewController** | ✅ 9.0+ | ✅ 9.0+ | ✅ 10.11+ | ✅ 1.0+ |
| **AUGenericViewController** | ✅ | ✅ | ❌ | ✅ |
| **AUGenericView** | ❌ | ❌ | ✅ | ❌ |
| **AUAudioUnitViewConfiguration** | ✅ 11.0+ | ✅ 11.0+ | ✅ 10.13+ | ✅ 1.0+ |
| **AUv3 Extension** | ✅ 9.0+ | ✅ 9.0+ | ✅ 10.11+ | ✅ 1.0+ |
| **ユーザープリセット** | ✅ 13.0+ | ✅ 13.0+ | ✅ 10.15+ | ✅ 1.0+ |
| **MIDI Processor タイプ** | ✅ 16.0+ | ✅ 16.0+ | ✅ 13.0+ | ✅ 1.0+ |

---

## 8. WWDC 関連セッション

| 年 | セッション | 内容 |
|---|---|---|
| **WWDC 2015** | Session 508: Audio Unit Extensions | AUv3 アーキテクチャの初公開。App Extension としての Audio Unit |
| **WWDC 2017** | What's New in Audio | AUAudioUnitViewConfiguration の追加。複数ビューサイズ対応 |
| **WWDC 2019** | What's New in AVAudioEngine | ユーザープリセット API。AUv3 の改善 |

---

## 9. 設計上の制約と注意点

### 9.1 技術的制約

| 制約 | 詳細 |
|---|---|
| **Render Thread の制約** | render block 内で Swift/ObjC 呼び出し禁止、I/O 禁止、ロック禁止。C/C++ のみ安全 |
| **プロセス分離** | AUv3 Extension は別プロセスで動作。ホストアプリと直接メモリ共有不可 |
| **ロード順序の不確定** | AUViewController と AUAudioUnit のどちらが先にロードされるか不定 |
| **UI スレッド** | パラメータ変更通知はバックグラウンドスレッドから届く。UI 更新は main queue で |
| **サンドボックス** | Extension はサンドボックス内で動作。ファイルアクセス制限あり |
| **リソース制限** | Extension のメモリ上限あり。大容量サンプルの読み込みに注意 |

### 9.2 開発上の推奨事項

| 項目 | 推奨 |
|---|---|
| **DSP 処理** | C/C++ で実装し、Swift から呼び出す。render block 内は C/C++ のみ |
| **UI フレームワーク** | SwiftUI + UIHostingController が最新の推奨。UIKit も引き続きサポート |
| **複数ビューサイズ** | `AUAudioUnitViewConfiguration` で複数サイズを宣言し、ホスト環境に適応 |
| **プリセット** | ファクトリープリセットとユーザープリセットの両方をサポート |
| **テスト** | 自前のホストアプリでテスト + GarageBand / AUM 等の実環境でもテスト |
| **パフォーマンス** | リアルタイムオーディオはレイテンシーが命。メモリ確保やロックは init 時のみ |

---

## 10. iOS アプリ活用アイデア

### アイデア 1: 「SoundForge — モジュラーオーディオ・ワークステーション」

**コンセプト:** iPhone / iPad 上で AUv3 プラグインをドラッグ＆ドロップで自由に接続し、ビジュアルなノードグラフで音声処理パイプラインを構築するアプリ。CoreAudioKit でサードパーティ製 AUv3 の UI をシームレスに埋め込み、プロ品質の音作りをモバイルで実現。

```
メイン画面（ノードグラフ）:

  ┌─ SoundForge ─────────────────────────────────────────────┐
  │                                                            │
  │  ┌──────┐    ┌──────────┐    ┌──────────┐    ┌────────┐  │
  │  │ 🎤    │───→│ 🎛️ EQ    │───→│ 🌀 Reverb │───→│ 🔊 Out │  │
  │  │ Input │    │ (AUv3)   │    │ (AUv3)   │    │        │  │
  │  └──────┘    └────┬─────┘    └──────────┘    └────────┘  │
  │                    │                                       │
  │                    └──→ ┌──────────┐                       │
  │                         │ 📊 Meter  │ ← リアルタイム解析    │
  │                         └──────────┘                       │
  │                                                            │
  │  ┌──────┐    ┌──────────┐    ┌──────────┐                 │
  │  │ 🎹    │───→│ 🎵 Synth  │───→│ 🌊 Delay │───→ (Mix へ)   │
  │  │ MIDI  │    │ (AUv3)   │    │ (AUv3)   │                 │
  │  └──────┘    └──────────┘    └──────────┘                 │
  │                                                            │
  │  ノードをタップ → AUv3 カスタム UI がポップオーバーで表示      │
  │  ┌─────────────────────────────────────────┐              │
  │  │  🎛️ FabFilter Pro-Q (AUv3 UI)           │              │
  │  │  ┌───────────────────────────────────┐  │              │
  │  │  │  [周波数応答カーブ]                  │  │              │
  │  │  │  ← AUViewController の埋め込み表示  │  │              │
  │  │  └───────────────────────────────────┘  │              │
  │  └─────────────────────────────────────────┘              │
  └────────────────────────────────────────────────────────────┘
```

**仕組み:**
- **AVAudioEngine:** ノード間のオーディオルーティングを管理
- **AVAudioUnitComponentManager:** インストール済み AUv3 プラグインを検索
- **CoreAudioKit (AUViewController / AUGenericViewController):** サードパーティ AUv3 の UI を埋め込み表示
- **AUAudioUnitViewConfiguration:** プラグイン UI のサイズをノードグラフ内に最適化
- **AUParameterTree:** パラメータの自動化 / タイムライン制御

**面白い点:**
- サードパーティ製プラグイン（FabFilter, iZotope 等）をモバイルで自由に組み合わせ
- ビジュアルノードグラフで「音の流れ」が直感的に見える
- ポッドキャスト収録 → エフェクト → マスタリングまで 1 アプリで完結
- iPad の大画面で本格的な DAW ワークフロー

**技術構成:** CoreAudioKit + AVFAudio (AVAudioEngine) + AudioToolbox + UIKit (ドラッグ&ドロップ)

---

### アイデア 2: 「PedalBoard — ギタリスト向け AUv3 エフェクトボード」

**コンセプト:** 実際のギターエフェクターボードを模したスキューモーフィック UI で、AUv3 エフェクトプラグインをペダルとして配置。CoreAudioKit で各 AUv3 のカスタム UI を「ペダル筐体」の中に埋め込み、iPhone をギターエフェクターに変える。

```
メイン画面（エフェクトボード）:

  ┌─ PedalBoard ──────────────────────────────────────────┐
  │                                                         │
  │  🎸 Input ──→──→──→──→──→──→──→──→──→ 🔊 Output       │
  │       │          │          │          │                │
  │  ┌────┴────┐ ┌───┴────┐ ┌──┴─────┐ ┌─┴──────┐        │
  │  │ OVERDRIVE│ │  DELAY │ │ REVERB │ │CHORUS  │        │
  │  │ ┌─────┐ │ │ ┌────┐ │ │ ┌────┐ │ │ ┌────┐ │        │
  │  │ │AUv3 │ │ │ │AUv3│ │ │ │AUv3│ │ │ │AUv3│ │        │
  │  │ │ UI  │ │ │ │ UI │ │ │ │ UI │ │ │ │ UI │ │        │
  │  │ └─────┘ │ │ └────┘ │ │ └────┘ │ │ └────┘ │        │
  │  │ [ON/OFF]│ │[ON/OFF]│ │[ON/OFF]│ │[ON/OFF]│        │
  │  └────────┘ └────────┘ └────────┘ └────────┘        │
  │                                                         │
  │  ペダルをタップ → フルサイズ UI がモーダル表示             │
  │  ペダルを長押し → 並べ替え / 削除                         │
  │  ＋ ボタン → AUv3 プラグイン一覧から追加                   │
  │                                                         │
  │  [🎚️ チューナー] [📱 セットリスト] [⏺️ 録音]              │
  └─────────────────────────────────────────────────────────┘
```

**仕組み:**
- **AVAudioEngine:** エフェクトチェーンのシリアル / パラレル接続
- **CoreAudioKit (AUViewController):** 各ペダル内に AUv3 カスタム UI を縮小表示
- **AUAudioUnitViewConfiguration:** コンパクト表示（ペダル内）/ フル表示（モーダル）の切り替え
- **Core Audio (AudioUnit):** 超低レイテンシー処理（< 5ms）
- **AVAudioSession:** `.measurement` カテゴリで最小バッファサイズ

**面白い点:**
- リアルなペダルボードの見た目 → ギタリストが直感的に使える
- サードパーティ AUv3 で無限のエフェクト組み合わせ
- セットリスト機能: ライブで曲ごとにプリセット切り替え
- iPhone + オーディオインターフェースだけでライブ演奏可能
- チューナー / メトロノーム内蔵

**技術構成:** CoreAudioKit + AVFAudio (AVAudioEngine + AVAudioSession) + AudioToolbox + UIKit

---

### アイデア 3: 「SynthLab — ビジュアル・シンセサイザー学習アプリ」

**コンセプト:** シンセサイザーの仕組みを視覚的に学べる教育アプリ。オシレーター、フィルター、エンベロープ、LFO 等のモジュールを AUv3 として実装し、CoreAudioKit の UI で各モジュールの動作をリアルタイムに可視化しながら音作りを学ぶ。

```
学習画面:

  ┌─ SynthLab ──────────────────────────────────────────────┐
  │  📖 Lesson 3: フィルターを理解しよう                       │
  │                                                           │
  │  ┌─ シグナルフロー ──────────────────────────────────────┐│
  │  │                                                       ││
  │  │  ┌──────────┐    ┌──────────┐    ┌──────────┐       ││
  │  │  │ 🌊 OSC    │───→│ 🎛️ FILTER│───→│ 📈 AMP   │→ 🔊  ││
  │  │  │ (AUv3)   │    │ (AUv3)   │    │ (AUv3)   │       ││
  │  │  └────┬─────┘    └────┬─────┘    └────┬─────┘       ││
  │  │       │               │               │              ││
  │  │  ┌────┴─────┐    ┌────┴─────┐    ┌────┴─────┐       ││
  │  │  │ 波形表示   │    │周波数応答 │    │ エンベロープ│       ││
  │  │  │ ∿∿∿∿∿∿  │    │ ╱‾‾╲__  │    │ ╱╲___    │       ││
  │  │  │ リアルタイム│    │リアルタイム│    │ ADSR     │       ││
  │  │  └──────────┘    └──────────┘    └──────────┘       ││
  │  └───────────────────────────────────────────────────────┘│
  │                                                           │
  │  💡 ヒント: カットオフ周波数を下げると                       │
  │     高い倍音が削られ、音が「丸く」なります。                 │
  │     スライダーを動かしながら波形の変化を観察しましょう。       │
  │                                                           │
  │  ┌─ AUv3 パラメータ UI（CoreAudioKit）──────────────────┐│
  │  │  Cutoff:     [──────●──────────]  8000 Hz            ││
  │  │  Resonance:  [────●────────────]  0.3                ││
  │  │  Filter Type: [LPF] [HPF] [BPF] [Notch]             ││
  │  └──────────────────────────────────────────────────────┘│
  │                                                           │
  │  [◀ 前のレッスン]              [次のレッスン ▶]             │
  └───────────────────────────────────────────────────────────┘
```

**仕組み:**
- **自作 AUv3 Extension（CoreAudioKit + AudioToolbox）:** オシレーター、フィルター、エンベロープ、LFO を個別の AUv3 として実装
- **AUViewController:** 各モジュールにリアルタイム波形表示 / 周波数応答カーブ等のカスタム UI
- **AUParameterTree:** パラメータ変更のリアルタイム反映
- **AVAudioEngine:** モジュール間の接続管理
- **Metal / Core Graphics:** 波形 / スペクトラム / エンベロープのリアルタイム描画

**面白い点:**
- 「音が変わる理由」を視覚的に理解できる → 音楽教育の革新
- 各モジュールが独立した AUv3 → 他の DAW アプリでも使える
- チュートリアルモードとフリープレイモードの切り替え
- 作った音をプリセットとして保存・共有
- MIDI キーボード接続で実際に演奏しながら学べる

**技術構成:** CoreAudioKit (AUViewController) + AudioToolbox (AUAudioUnit) + AVFAudio (AVAudioEngine) + Metal + Core Graphics

---

### アイデア 4: 「VoiceStudio — ポッドキャスター向けリアルタイム音声加工ステーション」

**コンセプト:** ポッドキャスト収録に特化した音声処理アプリ。CoreAudioKit を活用して AUv3 プラグイン（ノイズゲート、コンプレッサー、EQ、ディエッサー等）をチェーン接続し、プロ品質の音声をリアルタイムで収録。録音後の編集も AUv3 エフェクトで非破壊処理。

```
収録画面:

  ┌─ VoiceStudio ──────────────────────────────────────────┐
  │  🔴 REC  00:15:32                          [⏸️] [⏹️]   │
  │                                                         │
  │  ┌─ エフェクトチェーン ──────────────────────────────┐   │
  │  │                                                    │   │
  │  │ 🎤 → [Gate] → [DeEss] → [Comp] → [EQ] → [Limiter]│   │
  │  │       AUv3    AUv3     AUv3    AUv3    AUv3       │   │
  │  │       ↓        ↓        ↓       ↓        ↓        │   │
  │  │      各ペダルに AUv3 カスタム UI を埋め込み表示      │   │
  │  └────────────────────────────────────────────────────┘   │
  │                                                         │
  │  ┌─ リアルタイムメーター ──────────────────┐              │
  │  │  Input:  ████████████░░░░░░░ -12 dB    │              │
  │  │  Output: ██████████████░░░░░ -6 dB     │              │
  │  │  GR:     ████░░░░░░░░░░░░░░ -4 dB     │              │
  │  │  LUFS:   -16.2 LUFS (Target: -16)      │              │
  │  └───────────────────────────────────────┘              │
  │                                                         │
  │  📋 プリセット: [ポッドキャスト標準] [ナレーション] [インタビュー]│
  └─────────────────────────────────────────────────────────┘
```

**仕組み:**
- **AVAudioEngine + AUv3 チェーン:** マイク → ノイズゲート → ディエッサー → コンプレッサー → EQ → リミッター → 出力/録音
- **CoreAudioKit (AUViewController):** 各プラグインの UI をインラインで表示
- **AUGenericViewController:** UI を持たないプラグインには汎用 UI を自動生成
- **AVAudioFile / AVAudioPCMBuffer:** 録音データの書き出し
- **Accelerate (vDSP):** LUFS メーター / ピークメーターのリアルタイム計算

**面白い点:**
- ポッドキャスターが「プロの音質」をワンタップで実現
- AUv3 エコシステムを活用 → サードパーティ製プラグインも使える
- LUFS ターゲット表示で Apple Podcasts / Spotify の推奨音量を簡単に遵守
- 録音後の非破壊編集 → 元の音声を破壊せずにエフェクト調整可能
- セッション管理: エピソードごとにプロジェクトを保存

**技術構成:** CoreAudioKit + AVFAudio (AVAudioEngine + AVAudioSession + AVAudioFile) + AudioToolbox + Accelerate

---

### アイデア 5: 「AUBazaar — AUv3 プラグイン試聴・比較プラットフォーム」

**コンセプト:** App Store で配信されている AUv3 プラグインを試聴・比較できるアプリ。インストール済みの全 AUv3 プラグインを自動検出し、CoreAudioKit の UI で統一的に表示。同じ音源に複数のプラグインを適用して A/B 比較ができる。

```
メイン画面:

  ┌─ AUBazaar ──────────────────────────────────────────┐
  │  🔍 インストール済み AUv3 プラグイン (32個)              │
  │                                                       │
  │  ┌─ カテゴリ ───────────────────────────────────────┐│
  │  │ [全て] [EQ] [Comp] [Reverb] [Delay] [Synth]      ││
  │  └──────────────────────────────────────────────────┘│
  │                                                       │
  │  ┌─ プラグイン一覧 ────────────────────────────────┐  │
  │  │  🎛️ FabFilter Pro-Q 3        ★★★★★  EQ         │  │
  │  │  🎛️ Valhalla Shimmer         ★★★★★  Reverb     │  │
  │  │  🎛️ Eventide BlackHole       ★★★★☆  Delay      │  │
  │  │  🎛️ Moog Model 15            ★★★★★  Synth      │  │
  │  └─────────────────────────────────────────────────┘  │
  │                                                       │
  │  ┌─ A/B 比較モード ─────────────────────────────┐    │
  │  │  音源: 🎵 ボーカルサンプル ▶️                    │    │
  │  │                                               │    │
  │  │  A: FabFilter Pro-Q     B: TDR Nova           │    │
  │  │  ┌────────────────┐    ┌────────────────┐    │    │
  │  │  │  [AUv3 UI]     │    │  [AUv3 UI]     │    │    │
  │  │  │  (CoreAudioKit) │    │  (CoreAudioKit) │    │    │
  │  │  └────────────────┘    └────────────────┘    │    │
  │  │                                               │    │
  │  │  [A を聴く] [B を聴く] [A/B 切替]              │    │
  │  └───────────────────────────────────────────────┘    │
  └───────────────────────────────────────────────────────┘
```

**仕組み:**
- **AVAudioUnitComponentManager:** デバイスにインストール済みの全 AUv3 を検出・列挙
- **AVAudioUnit.instantiate:** 選択した AUv3 を動的にインスタンス化
- **CoreAudioKit (requestViewController):** 各 AUv3 のカスタム UI を取得・表示
- **AUGenericViewController:** カスタム UI を持たないプラグインは汎用 UI で表示
- **AVAudioEngine:** A/B 比較用のデュアル処理パス構築

**面白い点:**
- 「どのプラグインを買うべきか」を実際に聴いて比較できる
- 同じ音源で即座に A/B 切替 → 違いが明確に分かる
- 全プラグインの一元管理 → 「持っているのに忘れていた」を防止
- プラグインレビュー / レーティング機能でコミュニティ形成
- CoreAudioKit のホストアプリとしての模範的な実装

**技術構成:** CoreAudioKit + AVFAudio (AVAudioEngine) + AudioToolbox (AVAudioUnitComponentManager)

---

## 11. まとめ

| 観点 | 評価 |
|---|---|
| **機能の幅** | ★★★☆☆ — Audio Unit の UI に特化した狭いが深いフレームワーク |
| **エコシステム** | ★★★★★ — AUv3 プラグインエコシステム（GarageBand, Logic, 多数のサードパーティ）と直結 |
| **クロスプラットフォーム** | ★★★★☆ — iOS / macOS / visionOS 対応。クラス名がプラットフォームで異なる点に注意 |
| **開発体験** | ★★★☆☆ — render block の制約（C/C++ のみ）やプロセス間通信等、学習曲線あり |
| **カスタマイズ性** | ★★★★★ — カスタム UI は完全に自由。SwiftUI / UIKit / Metal 何でも使える |
| **成熟度** | ★★★★☆ — iOS 9 以降安定。API の変更頻度は低く、後方互換性が高い |

### CoreAudioKit が最も輝くパターン

1. **AUv3 プラグイン開発** — エフェクト / インストゥルメント / MIDI プロセッサーのカスタム UI
2. **DAW / ホストアプリ** — サードパーティ AUv3 の UI をシームレスに埋め込み
3. **音楽教育アプリ** — 各処理モジュールを AUv3 として可視化
4. **ポッドキャスト / 音声処理** — プロ品質のエフェクトチェーンをモバイルで構築
5. **ギター / 楽器エフェクト** — リアルタイム低レイテンシー処理 + カスタム UI

### 参考リンク

- [Apple Developer — CoreAudioKit](https://developer.apple.com/documentation/coreaudiokit)
- [Apple Developer — AUViewController](https://developer.apple.com/documentation/coreaudiokit/auviewcontroller)
- [Apple Developer — AUAudioUnitViewConfiguration](https://developer.apple.com/documentation/coreaudiokit/auaudiounitviewconfiguration)
- [Apple Developer — Audio Unit Extensions (App Extension Guide)](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/AudioUnit.html)
- [Apple Developer — Incorporating Audio Effects and Instruments](https://developer.apple.com/documentation/audiotoolbox/audio_unit_v3_plug-ins/incorporating_audio_effects_and_instruments)
- [Apple Developer — Migrating Your Audio Unit Host to AUv3](https://developer.apple.com/documentation/audiotoolbox/audio_unit_v3_plug-ins/migrating_your_audio_unit_host_to_the_auv3_api)
- [WWDC 2015 Session 508: Audio Unit Extensions](https://developer.apple.com/videos/play/wwdc2015/508/)
- [WWDC 2019: AUv3 Extensions User Presets](https://developer.apple.com/videos/play/wwdc2019/509/)
- [Soaky Audio — AUv3 & SwiftUI Multiplatform](https://soakyaudio.com/blog/multiplatform-audiounit/)
- [AudioKit Pro — AUv3 MIDI Tutorial](https://audiokitpro.com/auv3-midi-tutorial-part1/)
- [GitHub — Audio Unit V3 Templates](https://github.com/mhamilt/Audio-Unit-V3-Templates)
- [GitHub — AUv3Host (bradhowes)](https://github.com/bradhowes/AUv3Host)
