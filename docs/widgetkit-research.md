# WidgetKit フレームワーク 調査レポート

## 1. WidgetKit とは

WidgetKit は Apple が WWDC20（iOS 14）で発表したフレームワークで、ホーム画面・ロック画面・コントロールセンター・StandBy に表示される**ウィジェット**を SwiftUI で構築するための仕組み。

iOS 14 のシンプルなホーム画面ウィジェットから始まり、iOS 16 でロック画面ウィジェット、iOS 17 でインタラクティブウィジェットと Live Activities、iOS 18 でコントロールセンターウィジェット（Controls）へと大幅に進化している。

**核心コンセプト:** 「アプリを開かずに、一目で情報を確認し、簡単な操作を実行できるミニ UI をシステム全体に展開」

---

## 2. フレームワークの進化

| 年 | バージョン | 主な追加機能 |
|---|---|---|
| **WWDC20** | iOS 14 | 初リリース。SwiftUI ベースのホーム画面ウィジェット。Small / Medium / Large の 3 サイズ |
| **WWDC21** | iOS 15 | iPadOS に `systemExtraLarge` 追加。IntentTimelineProvider による動的設定 |
| **WWDC22** | iOS 16 | ロック画面ウィジェット（`accessoryCircular` / `accessoryRectangular` / `accessoryInline`）。watchOS 対応コード統一 |
| **WWDC23** | iOS 17 | **インタラクティブウィジェット**（Button / Toggle + AppIntents）。**Live Activities** 拡張。StandBy モード対応。アニメーション対応 |
| **WWDC24** | iOS 18 | **コントロールセンターウィジェット（Controls）**。**Widget Push Updates**（APNs 経由）。ティントカラー対応。Action ボタン連携 |

---

## 3. ウィジェットファミリー（サイズ・形状）

### 3.1 ホーム画面ウィジェット

| ファミリー | サイズ | 対応 OS | 用途 |
|---|---|---|---|
| `systemSmall` | 正方形（小） | iOS 14+ | 単一情報の一目確認 |
| `systemMedium` | 横長（中） | iOS 14+ | 複数項目のリスト・グラフ |
| `systemLarge` | 正方形（大） | iOS 14+ | 詳細情報・複合レイアウト |
| `systemExtraLarge` | 横長（特大） | iPadOS 15+ | iPad 専用の大画面表示 |

### 3.2 ロック画面 / Apple Watch ウィジェット（iOS 16+）

| ファミリー | 形状 | 用途 |
|---|---|---|
| `accessoryCircular` | 円形 | 簡潔な情報、ゲージ、プログレス |
| `accessoryRectangular` | 長方形 | 複数行テキスト、小グラフ |
| `accessoryInline` | テキスト 1 行 | 時刻の上に表示されるインライン情報 |

### 3.3 レンダリングモード

ウィジェットは表示場所によって 3 つのレンダリングモードで描画される:

| モード | 説明 | 使用場所 |
|---|---|---|
| **fullColor** | フルカラー表示。色の加工なし | ホーム画面 |
| **accented** | ウィジェットをアクセントグループとデフォルトグループに分割し色を適用 | iOS 18 ティント付きホーム画面 |
| **vibrant** | 彩度を落としモノクロ化。背景に合わせた色付け | ロック画面、StandBy |

```swift
struct MyWidgetView: View {
    @Environment(\.widgetRenderingMode) var renderingMode

    var body: some View {
        switch renderingMode {
        case .fullColor:
            FullColorView()
        case .accented:
            AccentedView()
        case .vibrant:
            VibrantView()
        @unknown default:
            FullColorView()
        }
    }
}
```

**ティント対応（iOS 18）:**
```swift
// 重要な情報をアクセントカラーでハイライト
Text("重要")
    .widgetAccentable()

// 画像のティント制御
Image("icon")
    .widgetAccentedRenderingMode(.accentedDesaturated)
```

---

## 4. アーキテクチャ

### 4.1 全体構成

```
┌─────────────────────────────────────────────────┐
│                  ホストアプリ                      │
│  ┌──────────────────────────────────────────┐    │
│  │  データ更新 → UserDefaults / CoreData     │    │
│  │  WidgetCenter.shared.reloadAllTimelines() │    │
│  └──────────────────────────────────────────┘    │
└──────────────┬──────────────────────────────────┘
               │ App Group（共有コンテナ）
┌──────────────▼──────────────────────────────────┐
│              Widget Extension（別プロセス）        │
│  ┌──────────────────────────────────────────┐    │
│  │  TimelineProvider                         │    │
│  │  ├── placeholder() → 即座にプレースホルダ    │    │
│  │  ├── getSnapshot() → 現在のスナップショット   │    │
│  │  └── getTimeline() → タイムラインエントリ配列 │    │
│  └──────────────────────────────────────────┘    │
│  ┌──────────────────────────────────────────┐    │
│  │  Widget View (SwiftUI)                    │    │
│  │  → TimelineEntry のデータで描画             │    │
│  └──────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

### 4.2 Widget 定義の基本構造

```swift
import WidgetKit
import SwiftUI

// 1. TimelineEntry: ウィジェットに表示するデータ
struct MyEntry: TimelineEntry {
    let date: Date
    let title: String
    let value: Int
}

// 2. TimelineProvider: データ供給
struct MyProvider: TimelineProvider {
    // プレースホルダー（データロード前の表示）
    func placeholder(in context: Context) -> MyEntry {
        MyEntry(date: Date(), title: "読み込み中...", value: 0)
    }

    // スナップショット（ウィジェットギャラリー等で使用）
    func getSnapshot(in context: Context,
                     completion: @escaping (MyEntry) -> Void) {
        let entry = MyEntry(date: Date(), title: "サンプル", value: 42)
        completion(entry)
    }

    // タイムライン（更新スケジュール付きのエントリ配列）
    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<MyEntry>) -> Void) {
        // App Group 経由でデータ取得
        let defaults = UserDefaults(suiteName: "group.com.example.app")
        let title = defaults?.string(forKey: "title") ?? "デフォルト"
        let value = defaults?.integer(forKey: "value") ?? 0

        let entry = MyEntry(date: Date(), title: title, value: value)

        // 1 時間後に再取得
        let timeline = Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(3600))
        )
        completion(timeline)
    }
}

// 3. Widget View（SwiftUI）
struct MyWidgetView: View {
    var entry: MyEntry

    var body: some View {
        VStack {
            Text(entry.title)
                .font(.headline)
            Text("\(entry.value)")
                .font(.largeTitle)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// 4. Widget 定義
struct MyWidget: Widget {
    let kind: String = "MyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MyProvider()) { entry in
            MyWidgetView(entry: entry)
        }
        .configurationDisplayName("マイウィジェット")
        .description("アプリの状態を表示します")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
```

### 4.3 WidgetBundle（複数ウィジェットの管理）

```swift
@main
struct MyWidgetBundle: WidgetBundle {
    var body: some Widget {
        MyWidget()           // ホーム画面ウィジェット
        StatsWidget()        // 統計ウィジェット
        TimerToggle()        // コントロール（iOS 18+）
    }
}
```

---

## 5. タイムラインとリロードポリシー

### 5.1 リロードポリシー

| ポリシー | 動作 |
|---|---|
| `.atEnd` | 最後のエントリ消費後にシステムが最適タイミングで再取得 |
| `.after(Date)` | 指定日時以降にシステムが再取得 |
| `.never` | 明示的に `reloadTimelines(ofKind:)` を呼ぶまで再取得しない |

### 5.2 更新バジェット

WidgetKit はシステムリソースとバッテリー節約のため、更新回数に**バジェット制限**を設けている:

- 通常 **1 日あたり 40〜70 回**のリロードが割り当てられる
- 約 **15〜60 分に 1 回**の更新頻度に相当
- ユーザーに頻繁に表示されるウィジェットほどバジェットが多く割り当てられる
- インタラクション（Button/Toggle）によるリロードはバジェット消費**なし**（保証される）
- 開発時は Settings > Developer > WidgetKit Developer Mode でバジェット制限を無視可能

### 5.3 更新トリガー方法の使い分け

| 方法 | 最適なユースケース |
|---|---|
| **Timeline（スケジュール）** | 定期的に変化するデータ（天気、カウントダウン等） |
| **`reloadAllTimelines()`** | アプリ内操作によるデータ変更 |
| **Widget Push Updates（APNs）** | サーバー側のデータ変更（iOS 18+） |
| **AppIntent 実行後の自動リロード** | インタラクティブウィジェットの操作後 |

---

## 6. インタラクティブウィジェット（iOS 17+）

### 6.1 概要

iOS 17 で Button と Toggle による**ウィジェット内インタラクション**が可能になった。AppIntents フレームワークと連携し、アプリを開かずにアクションを実行できる。

### 6.2 サポートされるコントロール

| コントロール | 用途 |
|---|---|
| `Button` | 離散的なアクション（タスク完了、お気に入り追加等） |
| `Toggle` | ON/OFF の状態切り替え（通知、ライト等） |

**制限:** Button と Toggle のみ。TextField、Slider、Picker、タップジェスチャー等は使用不可。State や Binding は動作しない。

### 6.3 実装例

```swift
import AppIntents
import WidgetKit
import SwiftUI

// AppIntent の定義
struct ToggleFavoriteIntent: AppIntent {
    static var title: LocalizedStringResource = "お気に入り切り替え"

    @Parameter(title: "Item ID")
    var itemID: String

    func perform() async throws -> some IntentResult {
        // App Group 経由でデータを更新
        let defaults = UserDefaults(suiteName: "group.com.example.app")
        let key = "favorite_\(itemID)"
        let current = defaults?.bool(forKey: key) ?? false
        defaults?.set(!current, forKey: key)

        // perform() の return 後、WidgetKit が自動的に Timeline を再取得
        return .result()
    }
}

// ウィジェット View
struct InteractiveWidgetView: View {
    var entry: MyEntry

    var body: some View {
        VStack {
            Text(entry.title)
            // AppIntent を使った Button
            Button(intent: ToggleFavoriteIntent(itemID: entry.id)) {
                Image(systemName: entry.isFavorite ? "star.fill" : "star")
            }
        }
    }
}
```

### 6.4 インタラクション時の動作フロー

```
ユーザーが Button をタップ
        ↓
AppIntent.perform() が Widget Extension プロセスで実行
        ↓
.result() を return
        ↓
WidgetKit が TimelineProvider.getTimeline() を呼び出し
        ↓
新しい Timeline でウィジェットを再描画
```

**重要:** インタラクションによるリロードはバジェット消費なしで**常に保証**される。

### 6.5 ロック画面での制限

ロック中のデバイスでは Button / Toggle は非アクティブ。ユーザーがデバイスをアンロックするまでアクションは実行されない。

---

## 7. コントロールセンターウィジェット — Controls（iOS 18+）

### 7.1 概要

iOS 18 で WidgetKit に新たに追加された「Controls」は、コントロールセンター・ロック画面・Action ボタンにアプリの機能を展開する仕組み。

### 7.2 Control の種類

| 種類 | 用途 | 例 |
|---|---|---|
| **ControlButton** | 離散的なアクション | タイマー開始、アプリ起動、録音開始 |
| **ControlToggle** | ON/OFF 切り替え | ライト、通知、モード切替 |

### 7.3 実装例

```swift
import WidgetKit
import AppIntents

struct CaffeineToggle: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "caffeine-toggle") {
            ControlToggle("カフェインモード",
                          isOn: CaffeineManager.shared.isEnabled,
                          action: ToggleCaffeineIntent()) { isOn in
                Label(isOn ? "ON" : "OFF",
                      systemImage: isOn ? "cup.and.saucer.fill" : "cup.and.saucer")
            }
        }
    }
}
```

### 7.4 配置場所

- **コントロールセンター:** リサイズ可能なコントロールとして配置
- **ロック画面:** クイックアクションとして配置
- **Action ボタン:** iPhone 15 Pro 以降の物理ボタンに割り当て可能

---

## 8. Live Activities（iOS 16.1+ / WidgetKit 連携）

### 8.1 概要

Live Activities は進行中のタスクやイベントの状態をロック画面と Dynamic Island にリアルタイム表示する仕組み。WidgetKit と ActivityKit が連携して動作する。

### 8.2 表示場所

| 場所 | 表示形式 |
|---|---|
| **ロック画面** | バナー形式の情報カード |
| **Dynamic Island（コンパクト）** | Leading / Trailing の 2 分割表示 |
| **Dynamic Island（展開）** | フル展開した詳細表示 |
| **StandBy** | ロック画面表示の 2x スケール |

### 8.3 更新方法

- **アプリ内から:** `Activity.update()` でローカル更新
- **Push 通知:** APNs 経由でバックグラウンド更新
- **インタラクティブ:** iOS 17+ で Button / Toggle による操作

### 8.4 制約

- 開始と終了が明確なイベントのみ（無期限は不可）
- 最大 8 時間アクティブ（その後 4 時間はロック画面に残る）
- 同時にアクティブにできる Live Activity は最大 5 個

---

## 9. データ共有（アプリ ↔ Widget Extension）

Widget Extension はホストアプリとは**別プロセス**で動作するため、データ共有に工夫が必要。

### 9.1 共有方法の比較

| 方法 | 最適なデータ | 実装難度 |
|---|---|---|
| **UserDefaults + App Group** | シンプルな Key-Value（設定値、フラグ等） | 低 |
| **CoreData + App Group** | 複雑なオブジェクトグラフ、リレーショナルデータ | 中 |
| **FileManager + 共有コンテナ** | バイナリファイル、画像、大容量データ | 中 |
| **SwiftData + App Group** | Swift ネイティブなモデル（iOS 17+） | 低〜中 |

### 9.2 App Group 設定（必須）

```
1. Project → Targets → ホストアプリ → Signing & Capabilities → App Groups 追加
2. Project → Targets → Widget Extension → Signing & Capabilities → App Groups 追加
   ※ 同じ App Group 名を選択すること
```

### 9.3 UserDefaults でのデータ共有

```swift
// ── ホストアプリ側 ──
let shared = UserDefaults(suiteName: "group.com.example.app")
shared?.set("新しいタイトル", forKey: "widgetTitle")

// ウィジェットに更新通知
WidgetCenter.shared.reloadAllTimelines()

// ── Widget Extension 側（TimelineProvider 内） ──
func getTimeline(in context: Context,
                 completion: @escaping (Timeline<MyEntry>) -> Void) {
    let shared = UserDefaults(suiteName: "group.com.example.app")
    let title = shared?.string(forKey: "widgetTitle") ?? "デフォルト"
    // ...
}
```

### 9.4 CoreData でのデータ共有

```swift
// 共有コンテナの URL を指定
let container = NSPersistentContainer(name: "Model")
let storeURL = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.app")!
    .appendingPathComponent("Model.sqlite")
let description = NSPersistentStoreDescription(url: storeURL)
container.persistentStoreDescriptions = [description]
container.loadPersistentStores { _, error in
    // ...
}
```

**ベストプラクティス:** ウィジェットは軽量であるべき。重い CoreData 処理はホストアプリで行い、ウィジェットには最小限のデータを渡す。

---

## 10. Widget Push Updates（iOS 18+）

### 10.1 概要

サーバーから APNs 経由でウィジェットの更新を通知する仕組み。サーバー側のデータ変更をリアルタイムにウィジェットへ反映できる。

### 10.2 フロー

```
サーバー → APNs → iOS → WidgetKit → TimelineProvider.getTimeline()
                                              ↓
                                    新しいデータで再描画
```

### 10.3 注意点

- Push によるリロードも**バジェット消費**がある
- サーバー側でスロットリングを行い、過度な更新を避ける
- 全プラットフォーム（iOS / iPadOS / macOS / watchOS）で利用可能
- 開発時は WidgetKit Developer Mode でバジェット制限を無視可能

---

## 11. StandBy モード（iOS 17+）

### 11.1 概要

iPhone が充電中 + 横向き + ロック状態のとき自動的に有効になるモード。ウィジェットを大きく表示するスマートディスプレイ体験。

### 11.2 ウィジェットの表示

- ホーム画面ウィジェット（`systemSmall`）がスマートスタック形式で表示
- `vibrant` レンダリングモードで描画（モノクロ + 背景適応色）
- Night Mode 時は赤みがかった低輝度表示

### 11.3 Live Activities の表示

StandBy で Live Activities を表示するとき、ロック画面の表示が **2x スケール**で全画面に拡大される。

---

## 12. 設計上の制約と注意点

### 12.1 実行時制約

| 制約 | 詳細 |
|---|---|
| **別プロセス** | Widget Extension はホストアプリとは別プロセス。直接のメモリ共有不可 |
| **実行時間制限** | getTimeline() 等は短時間で完了する必要がある。長時間処理不可 |
| **バックグラウンド制限** | 独自のバックグラウンドタスクは実行不可 |
| **更新バジェット** | 1 日 40〜70 回。約 15〜60 分に 1 回 |
| **SwiftUI 限定** | UIKit は使用不可。SwiftUI のみ |

### 12.2 UI 制約

| 制約 | 詳細 |
|---|---|
| **限定的インタラクション** | Button と Toggle のみ（iOS 17+）。テキスト入力・スクロール不可 |
| **State / Binding 不可** | ウィジェット View は「アーカイブ」として描画される。ランタイムの状態管理不可 |
| **ジェスチャー不可** | onTapGesture 等のカスタムジェスチャーは動作しない |
| **タップ遷移** | widgetURL() または Link でアプリへのディープリンクのみ |
| **ロック中の制限** | ロック中は Button / Toggle 非アクティブ |

### 12.3 開発上の注意

| 項目 | 推奨事項 |
|---|---|
| **データ量** | ウィジェットには最小限のデータを渡す。重い処理はホストアプリで |
| **エラーハンドリング** | ネットワーク失敗時はキャッシュデータでフォールバック |
| **サイズ対応** | 各ファミリーごとに専用レイアウトを設計 |
| **レンダリングモード** | fullColor / accented / vibrant すべてに対応 |
| **プレビュー** | Xcode のウィジェットプレビューを活用 |

---

## 13. iOS アプリ活用アイデア

### アイデア 1: 「MoodBoard Widget — ホーム画面が日記になる」

**コンセプト:** ホーム画面ウィジェット自体が「感情日記」になるアプリ。毎日のウィジェットインタラクション（iOS 17+ の Button）で気分を記録し、ウィジェットの見た目が気分の推移に応じて変化する。

```
┌─────────────────────────┐
│  systemMedium            │
│                          │
│  今の気分は？              │
│  😊  😐  😔  🔥         │
│  [Button] [Button] ...   │
│                          │
│  ▁▃▅▇▅▃▁  ← 週間ムードグラフ│
│  月 火 水 木 金 土 日      │
└─────────────────────────┘

┌────────────────┐
│ accessoryCircular │
│   ┌────┐        │
│   │ 😊 │ 3日連続 │
│   └────┘        │
└────────────────┘
```

**仕組み:**
- **Button（AppIntent）** で気分を 1 タップ記録 → アプリを開く必要なし
- 記録データは UserDefaults + App Group で共有
- Timeline で翌日 0:00 に自動リセット
- ロック画面ウィジェットに「今日の気分」と連続記録日数を表示
- Medium サイズには週間のムードグラフを Gauge / Chart で描画

**面白い点:**
- 「ウィジェットを使うこと自体」がアプリの体験そのもの
- ホーム画面を見るたびに自分の気分を意識するマインドフルネス効果
- ウィジェットの色やアイコンが気分データに応じて有機的に変化
- iOS 18 ティントカラーで「気分色」をホーム画面全体に反映

**技術構成:** WidgetKit + AppIntents + SwiftUI Charts + App Group (UserDefaults)

---

### アイデア 2: 「WidgetQuest — ウィジェットだけで遊べる RPG」

**コンセプト:** ホーム画面のウィジェットだけで完結するミニ RPG。Timeline ベースの時間経過でイベントが発生し、Button で選択肢を選んで冒険を進める。

```
┌──────────────────────────────────┐
│  systemLarge                      │
│                                   │
│  🏰 ドラゴンの洞窟 - Day 12        │
│  ──────────────────────           │
│  HP: ████████░░ 80/100            │
│  MP: ██████░░░░ 60/100            │
│  Gold: 1,250                      │
│                                   │
│  "洞窟の奥から唸り声が聞こえる..."    │
│                                   │
│  ┌─────────┐  ┌─────────┐        │
│  │ ⚔️ 戦う  │  │ 🏃 逃げる │        │
│  └─────────┘  └─────────┘        │
│                                   │
│  次のイベント: 2:30:00 後           │
└──────────────────────────────────┘

┌────────────────┐     ┌─────────────────────┐
│ accessoryCircular│     │  accessoryRectangular │
│   ┌────┐        │     │  HP: ████░░ 80       │
│   │ ⚔️ │        │     │  イベントまで 2:30    │
│   │Lv12│        │     │  🏰 ドラゴンの洞窟    │
│   └────┘        │     └─────────────────────┘
└────────────────┘
```

**仕組み:**
- **Timeline** で 2〜4 時間ごとにストーリーイベントが自動発生
- **Button（AppIntent）** で選択肢を選び、結果がステータスに反映
- 選択結果で分岐するストーリーライン（CoreData で状態管理）
- ロック画面ウィジェットにキャラクターレベルと次イベントまでのカウントダウン
- StandBy で大画面のゲーム画面を表示

**面白い点:**
- 「アプリを開かない」ゲーム体験 — ウィジェットだけで完結
- Timeline の自然な更新タイミング（15〜60 分間隔）がゲームデザインに合致
- 「次のイベントまであと○時間」がプレイヤーの再訪動機になる
- 更新バジェットの制限がゲームバランスとして機能（1 日 40〜70 回 = イベント回数）

**技術構成:** WidgetKit + AppIntents + CoreData + App Group + SwiftUI Animation

---

### アイデア 3: 「ControlDeck — iPhone をスマートホームリモコン化」

**コンセプト:** iOS 18 の Controls（コントロールセンターウィジェット）を最大限活用し、コントロールセンター・ロック画面・Action ボタンに家電操作を展開。iPhone 自体がスマートホームの統合リモコンになる。

```
┌─ コントロールセンター ─────────────┐
│                                   │
│  ┌───────┐ ┌───────┐ ┌───────┐  │
│  │ 💡    │ │ 🌡️    │ │ 🔒    │  │
│  │リビング│ │エアコン│ │玄関鍵  │  │
│  │ [ON]  │ │ 24°C  │ │ [施錠] │  │
│  └───────┘ └───────┘ └───────┘  │
│  ┌───────┐ ┌───────┐ ┌───────┐  │
│  │ 🎵    │ │ 🚪    │ │ 📹    │  │
│  │スピーカ│ │ガレージ│ │カメラ  │  │
│  │ [再生] │ │ [開く] │ │ [確認] │  │
│  └───────┘ └───────┘ └───────┘  │
│                                   │
│  ── ロック画面クイックアクション ──  │
│  🔒 施錠   💡 全消灯               │
│                                   │
│  ── Action ボタン ──               │
│  長押し → 「帰宅シーン」実行         │
└──────────────────────────────────┘
```

**仕組み:**
- **ControlToggle:** ライト ON/OFF、エアコン ON/OFF、鍵の施錠/解錠
- **ControlButton:** シーン実行（帰宅、外出、就寝等）、ガレージ開閉
- **Action ボタン連携:** 最も頻繁に使うアクションを物理ボタンに割り当て
- **Widget Push Updates:** サーバー（Home Hub）からデバイス状態変更を通知
- ホーム画面ウィジェットに部屋全体の状態サマリーを表示

**面白い点:**
- アプリを開かず、ロック画面からでもコントロールセンターからでも家電操作
- Action ボタンで「物理ボタン 1 押し」の操作感
- Controls + Widget + Live Activities の組み合わせで、エアコンの温度変化を Live Activity でリアルタイム表示

**技術構成:** WidgetKit Controls + AppIntents + HomeKit / Matter + Widget Push Updates + Live Activities

---

### アイデア 4: 「PixelPet — ウィジェットで育てるデジタルペット」

**コンセプト:** ホーム画面に住む仮想ペット。Timeline で時間経過とともにお腹が減り、Button でごはんを与え、ロック画面でいつでも様子を確認できる。

```
┌─────────────────────────┐
│  systemSmall             │
│                          │
│      ╭─────╮            │
│      │ ^ω^ │  ♪         │
│      ╰─┬─┬─╯            │
│        │ │               │
│  ────────────            │
│  ❤️ ████░░ 満腹度        │
│  ⭐ ████████ 機嫌        │
│                          │
│   [🍖 ごはん]             │
└─────────────────────────┘

時間経過で変化:
  満腹 → ╭─────╮    空腹 → ╭─────╮    瀕死 → ╭─────╮
         │ ^ω^ │           │ ;ω; │           │ x_x │
         ╰─────╯           ╰─────╯           ╰─────╯
```

**仕組み:**
- **Timeline** で 30 分〜1 時間ごとにステータスが自然減少
- **Button** でごはん・遊ぶ・掃除等のアクション
- ペットの表情・アニメーション（SwiftUI Transitions）がステータスで変化
- ロック画面 `accessoryCircular` にペットの顔と機嫌ゲージ
- StandBy でペットが大画面で「寝ている」姿を表示（夜間）
- コントロールセンターに「緊急ごはんボタン」を Controls で配置

**面白い点:**
- たまごっち的な「放置すると状態が悪化する」緊張感
- Timeline の更新間隔がゲームメカニクスそのもの
- ホーム画面を見るたびにペットの様子が変わっている発見の楽しさ
- iOS 18 ティントカラーでペットの機嫌がホーム画面の「雰囲気」に反映
- 全ウィジェットファミリー + Controls + StandBy をフル活用

**技術構成:** WidgetKit（全ファミリー） + Controls + AppIntents + SwiftUI Animation + App Group

---

### アイデア 5: 「LiveBoard — リアルタイムコラボホワイトボード Widget」

**コンセプト:** チームメンバーがアプリで書いたメモ・ステータスがウィジェットにリアルタイム反映される「常に見えるチームダッシュボード」。Widget Push Updates でサーバー変更を即座に反映。

```
┌──────────────────────────────────┐
│  systemLarge                      │
│  🏢 チーム Alpha                   │
│  ──────────────────────           │
│  👤 田中: 「レビュー対応中」  🟢     │
│  👤 鈴木: 「ランチ中」       🟡     │
│  👤 佐藤: 「集中モード」     🔴     │
│  ──────────────────────           │
│  📌 今日のタスク                    │
│  ☑️ API 設計レビュー               │
│  ☐ UI テスト作成                   │
│  ☐ リリースノート                   │
│                                   │
│  [✅ 完了] [💬 コメント]            │
└──────────────────────────────────┘
```

**仕組み:**
- **Widget Push Updates（iOS 18+）** でサーバーからリアルタイム更新
- **Button** でタスクの完了/コメント追加をウィジェットから直接操作
- **Live Activities** でスプリント期限カウントダウンやデプロイ状況を表示
- チームメンバーのステータス変更がウィジェットに即座に反映
- ロック画面ウィジェットに未完了タスク数とチーム稼働状況

**面白い点:**
- Slack / Teams を開かずにホーム画面でチーム状況を常に把握
- Widget Push Updates で「ほぼリアルタイム」の同期
- インタラクティブウィジェットでタスク完了がワンタップ
- 朝の StandBy で今日のタスク一覧をスマートディスプレイ風に表示

**技術構成:** WidgetKit + Widget Push Updates + AppIntents + Live Activities + CloudKit / 独自サーバー

---

## 14. まとめ

| 観点 | 評価 |
|---|---|
| **展開範囲** | ★★★★★ — ホーム画面 / ロック画面 / コントロールセンター / StandBy / Dynamic Island / Apple Watch |
| **インタラクティブ性** | ★★★☆☆ — Button / Toggle のみ。本格的な操作は不可 |
| **リアルタイム性** | ★★★☆☆ — バジェット制限あり（40〜70回/日）。Push Updates で改善（iOS 18+） |
| **開発体験** | ★★★★☆ — SwiftUI ベースで統一的。ただし別プロセス + データ共有が複雑 |
| **ユーザーリーチ** | ★★★★★ — iOS 14+ で基本機能が使えるため広い対象 |
| **デザイン自由度** | ★★★★☆ — SwiftUI の表現力。ただし静的レンダリングの制約あり |

### WidgetKit が最も輝くパターン

1. **一目で確認 (Glanceable)** — ユーザーが頻繁に確認したい情報の常時表示
2. **ワンタップアクション** — アプリを開かず完了できる簡単な操作
3. **時間変化するコンテンツ** — カウントダウン、スケジュール、プログレス
4. **システム統合** — コントロールセンター / ロック画面 / Action ボタン / StandBy
5. **リアルタイム通知** — Live Activities + Widget Push Updates の組み合わせ

### 参考リンク

- [Apple Developer — WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [Developing a WidgetKit Strategy](https://developer.apple.com/documentation/widgetkit/developing-a-widgetkit-strategy)
- [Adding interactivity to widgets and Live Activities](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)
- [WidgetFamily](https://developer.apple.com/documentation/widgetkit/widgetfamily)
- [Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date)
- [WWDC20: Meet WidgetKit](https://developer.apple.com/videos/play/wwdc2020/10028/)
- [WWDC22: Complications and widgets: Reloaded](https://developer.apple.com/videos/play/wwdc2022/10050/)
- [WWDC23: Bring widgets to life](https://developer.apple.com/videos/play/wwdc2023/10028/)
- [WWDC23: Bring widgets to new places](https://developer.apple.com/videos/play/wwdc2023/10027/)
- [WWDC24: Extend your app's controls across the system](https://developer.apple.com/videos/play/wwdc2024/10157/)
- [Updating widgets with WidgetKit push notifications](https://developer.apple.com/documentation/widgetkit/updating-widgets-with-widgetkit-push-notifications)
- [Widget Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/widgets/)
