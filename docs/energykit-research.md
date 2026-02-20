# EnergyKit フレームワーク 調査レポート

## 1. EnergyKit とは

EnergyKit は Apple が **WWDC25**（iOS 26）で発表した**新しいフレームワーク**で、サードパーティアプリにローカルの**電力グリッド予測**と**電力料金情報**を提供し、ユーザーが**よりクリーンで安価な時間帯に電力を使用する**ことを支援する。

これまで Apple の Home アプリ内の「Grid Forecast」や iPhone の「クリーンエネルギー充電」機能として Apple 純正の中に閉じていたグリッドデータが、ついにサードパーティ開発者にも開放された。

**核心コンセプト:** 「電力網のクリーン度とコストを可視化し、家庭の二大電力消費（HVAC と EV 充電）を最適な時間帯にシフトする」

### 従来のアプローチとの決定的な違い

| 項目 | EnergyKit (iOS 26+) | 従来の独自実装 |
|---|---|---|
| **グリッド予測データ** | Apple が提供（環境・グリッド入力に基づく） | 自前で外部 API を調達・管理 |
| **パーソナライズ** | ユーザーの Home 所在地に自動最適化 | 位置情報を手動で設定 |
| **電力料金** | Home アプリの電力会社連携（TOU レート） | 料金プランを手動入力 |
| **プライバシー** | エンドツーエンド暗号化・Apple も読めない | アプリ開発者がデータ管理 |
| **バックグラウンド更新** | AsyncSequence でリアルタイム | 独自 Background Task が必要 |
| **インサイト（使用実績）** | LoadEvent → ElectricityInsight で自動生成 | 自前で集計・分析 |
| **HomeKit 統合** | EnergyVenue が Home と自動連携 | 独自の場所管理 |
| **対応地域** | 米国本土のみ（v1.0） | API 提供元に依存 |

---

## 2. 動作の仕組み

EnergyKit は Apple の Home アプリが持つ電力グリッドデータを基盤とし、3 つの主要機能（**ガイダンス**・**フィードバック**・**インサイト**）を提供する。

```
┌─────────────────────────────────────────────────────────────┐
│  外部データソース                                              │
│  ├── 再生可能エネルギー発電予測                                 │
│  ├── カーテイルメント（出力抑制）データ                          │
│  ├── グリッド需要変動に対応する発電源情報                        │
│  └── 電力会社の料金プラン（TOU: Time-of-Use）                  │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────────────┐
│  Apple Home / EnergyKit プラットフォーム                        │
│                                                              │
│  ① ガイダンス (Guidance)                                      │
│     グリッドの「クリーン度」と「コスト」の時間帯別予測を配信         │
│     → AsyncSequence でリアルタイム更新                          │
│                                                              │
│  ② フィードバック (LoadEvent)                                  │
│     アプリからデバイスの電力消費イベントを報告                     │
│     → 15分間隔 + 重要イベント発生時に送信                       │
│                                                              │
│  ③ インサイト (ElectricityInsight)                             │
│     ①と②を組み合わせた使用実績の環境影響分析                     │
│     → カーボンインテンシティ・コスト分析を自動生成                │
└──────────────────────┬──────────────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────────────┐
│  サードパーティアプリ                                           │
│                                                              │
│  ├── EV 充電アプリ: クリーンな時間帯に充電をシフト               │
│  ├── スマートサーモスタット: ピーク料金を避けて空調を制御          │
│  └── ユーザーへの表示: 電力消費のインサイト・サマリー             │
│                                                              │
│  表示先                                                       │
│  ├── アプリ内 UI: ガイダンスとインサイトの視覚化                  │
│  ├── ウィジェット: リアルタイムのグリッド状態表示                  │
│  └── Home アプリ: EnergyVenue 共有メンバーへのデータ連携         │
└──────────────────────────────────────────────────────────────┘
```

### グリッド予測の仕組み

EnergyKit は以下の要素を組み合わせて「クリーンな時間帯」を特定する:

1. **再生可能エネルギーのピーク発電予測** — 太陽光・風力の発電量が多い時間帯
2. **カーテイルメントデータ** — 再生可能エネルギーの出力抑制が発生する時間帯（= 余剰電力がある）
3. **限界発電源（Marginal Generator）** — 需要変動に応答する発電源がクリーンかどうか
4. **電力料金プラン** — ユーザーが Home アプリで電力会社アカウントを連携している場合、Time-of-Use（TOU）料金を反映

---

## 3. API の詳細

### 3.1 主要クラス・構造体

| クラス / 構造体 | 役割 |
|---|---|
| `EnergyVenue` | 電力を消費する物理的な場所（Home アプリの Home に紐づく） |
| `EnergyVenueSelector` | オンボーディング UI で EnergyVenue を選択する SwiftUI ビュー |
| `ElectricityGuidance` | 電力グリッドのガイダンス（クリーン度・コスト予測）を表すモデル |
| `ElectricityGuidance.Query` | ガイダンスの取得条件（suggestedAction: .shift 等） |
| `ElectricityGuidance.sharedService` | ガイダンスストリームを提供する共有サービス |
| `ElectricityGuidanceValue` | ガイダンスの個別時間帯の値（クリーン度・コスト） |
| `LoadEvent` | デバイスの電力消費イベント（EnergyKit へのフィードバック） |
| `ElectricityInsightQuery` | インサイト（使用実績の環境影響）を取得するクエリ |
| `ElectricityInsightRecord` | インサイトの結果レコード（カーボンインテンシティ等） |

### 3.2 オンボーディング（EnergyVenue のセットアップ）

EnergyKit を利用するには、まずユーザーにクリーンエネルギー充電への**オプトイン**を求め、充電場所ごとに **EnergyVenue** を選択してもらう必要がある。

```swift
import EnergyKit
import SwiftUI

struct ChargingLocationSettingsView: View {
    @State private var isCleanEnergyEnabled = false
    @State private var selectedVenueID: UUID?

    var body: some View {
        Form {
            // ユーザーにクリーンエネルギー充電のオプトインを求めるトグル
            Toggle("クリーンエネルギー充電", isOn: $isCleanEnergyEnabled)

            if isCleanEnergyEnabled {
                // EnergyKit 提供のオンボーディング UI
                // ユーザーの位置情報近くの EnergyVenue を一覧表示し選択
                EnergyVenueSelector(selectedVenueID: $selectedVenueID)
            }
        }
        .onChange(of: selectedVenueID) { _, newVenueID in
            if let venueID = newVenueID {
                // 選択された EnergyVenue と充電場所のマッピングを永続化
                persistVenueMapping(venueID: venueID)
            }
        }
    }

    func persistVenueMapping(venueID: UUID) {
        // ユーザーがオプトアウトするまでマッピングを保持
        UserDefaults.standard.set(venueID.uuidString, forKey: "selectedEnergyVenueID")
    }
}
```

**オンボーディングフロー:**
1. ユーザーがクリーンエネルギー充電をトグルで有効化
2. `EnergyVenueSelector` が近隣の EnergyVenue 一覧を表示
3. ユーザーが EnergyVenue を選択
4. アプリが EnergyVenue ID と充電場所のマッピングを永続化
5. ユーザーがオプトアウトするまでマッピングを保持

### 3.3 ガイダンスの取得（ElectricityGuidance）

```swift
import EnergyKit
import Foundation

@Observable
final class EnergyVenueManager {
    var guidance: ElectricityGuidance?
    private var streamGuidanceTask: Task<Void, Never>?

    let venueID: UUID

    init(venueID: UUID) {
        self.venueID = venueID
    }

    // ガイダンスのストリーミングを開始
    func startGuidanceMonitoring() {
        streamGuidanceTask = Task {
            await streamGuidance(venueID: venueID) { [weak self] updatedGuidance in
                self?.guidance = updatedGuidance
            }
        }
    }

    // ガイダンスをストリームで受信（AsyncSequence）
    func streamGuidance(
        venueID: UUID,
        update: @escaping (ElectricityGuidance) -> Void
    ) async {
        // EV の場合、suggestedAction は .shift（電力使用のシフト）
        let query = ElectricityGuidance.Query(suggestedAction: .shift)

        // sharedService からガイダンスの AsyncSequence を取得
        for await updatedGuidance in ElectricityGuidance.sharedService.guidance(
            using: query,
            at: venueID
        ) {
            update(updatedGuidance)
        }
        // 注: 1 回だけ取得する場合は、最初の値取得後に break する
    }

    // ガイダンスの時間帯別の値を走査して最適な充電時間を判定
    func findBestChargingWindows() -> [ElectricityGuidanceValue] {
        guard let guidance = guidance else { return [] }

        // ガイダンスの各時間帯を走査し、クリーン度が高い時間帯を抽出
        return guidance.values.filter { value in
            value.isCleanerPeriod
        }.sorted { $0.startDate < $1.startDate }
    }

    func stopMonitoring() {
        streamGuidanceTask?.cancel()
        streamGuidanceTask = nil
    }
}
```

**ポイント:**
- `ElectricityGuidance.sharedService` がストリームの起点
- `AsyncSequence` で EnergyKit がガイダンスを更新するたびに新しい値を受信
- 継続的に更新を受け取る必要がない場合はループから `break` 可能
- バックグラウンド更新が必要な場合は `BGAppRefreshTask` ハンドラから呼び出す
- インタラクティブなウィジェットがある場合、ウィジェットからも更新を維持可能

### 3.4 フィードバック（LoadEvent の送信）

```swift
import EnergyKit

final class ChargingSessionManager {
    let venueID: UUID

    init(venueID: UUID) {
        self.venueID = venueID
    }

    /// 充電セッション開始時にイベントを作成
    func startChargingSession(
        vehicleID: String,
        initialStateOfCharge: Double,
        powerConsumption: Double
    ) async throws {
        // 初期状態の LoadEvent を作成
        let event = LoadEvent(
            deviceIdentifier: vehicleID,
            stateOfCharge: initialStateOfCharge,
            powerConsumption: powerConsumption,
            timestamp: Date()
        )

        // EnergyKit にフィードバックとして送信
        try await EnergyKit.submitLoadEvent(event, at: venueID)
    }

    /// 定期的な LoadEvent 送信（推奨: 15 分間隔）
    /// 以下のタイミングでも追加送信:
    ///   - 充電の一時停止 / 再開
    ///   - 新しいガイダンスによる充電スケジュール変更
    ///   - 消費電力の急激な変化
    func reportPeriodicUpdate(
        vehicleID: String,
        currentStateOfCharge: Double,
        powerConsumption: Double
    ) async throws {
        let event = LoadEvent(
            deviceIdentifier: vehicleID,
            stateOfCharge: currentStateOfCharge,
            powerConsumption: powerConsumption,
            timestamp: Date()
        )

        try await EnergyKit.submitLoadEvent(event, at: venueID)
    }
}
```

**LoadEvent 送信のベストプラクティス:**

| タイミング | 説明 |
|---|---|
| セッション開始時 | 初期状態（充電率、消費電力）を報告 |
| **15 分間隔** | 安定した充電中の定期報告（推奨） |
| 一時停止 / 再開 | 充電セッションの状態変化 |
| スケジュール変更 | 新しいガイダンスに基づくスケジュール変更 |
| 消費電力の急変 | 充電速度の変化など |

**注:** LoadEvent で送信されたデータは、EnergyVenue に関連付けられた HomeKit Home の共有メンバー全員に共有される。

### 3.5 インサイトの取得（ElectricityInsightQuery）

```swift
import EnergyKit

final class InsightManager {
    /// 特定日の充電インサイトを取得
    func fetchChargingInsights(
        vehicleID: String,
        venueID: UUID,
        date: Date
    ) async throws -> ElectricityInsightRecord? {
        // クリーン度と相対コストのインサイトを要求するクエリを作成
        let query = ElectricityInsightQuery(
            interests: [.cleanliness, .relativeCost]
        )

        // 指定した車両と EnergyVenue のインサイトを取得（AsyncStream）
        for await insight in query.insights(
            for: vehicleID,
            at: venueID
        ) {
            // 特定日のインサイトをフィルタリング
            if Calendar.current.isDate(insight.date, inSameDayAs: date) {
                return insight
            }
        }

        return nil
    }

    /// インサイトからサマリーを生成
    func createSummary(from insight: ElectricityInsightRecord) -> String {
        var summary = "充電サマリー\n"
        summary += "日付: \(insight.date)\n"

        // クリーンエネルギー使用率
        if let cleanliness = insight.cleanlinessScore {
            summary += "クリーンエネルギー率: \(Int(cleanliness * 100))%\n"
        }

        // 相対コスト
        if let cost = insight.relativeCost {
            summary += "相対コスト: \(cost)\n"
        }

        return summary
    }
}
```

---

## 4. プライバシーとセキュリティ

EnergyKit は Apple のプライバシーファーストの原則に基づいて設計されている:

| 項目 | 詳細 |
|---|---|
| **暗号化** | Home アプリのデータはエンドツーエンド暗号化で保存・同期 |
| **Apple の関与** | Apple はユーザーデータを読めない |
| **データ削除** | ユーザーはいつでも EnergyKit データを削除可能 |
| **オプトイン** | ユーザーが明示的にクリーンエネルギー充電を有効化する必要あり |
| **LoadEvent の共有** | EnergyVenue に関連する HomeKit Home の共有メンバーに限定 |
| **Entitlement** | Xcode で専用の Entitlement を有効にする必要あり |

---

## 5. プラットフォーム要件と制限

| 項目 | 詳細 |
|---|---|
| **対応 OS** | iOS 26 以降、iPadOS 26 以降 |
| **対象デバイス** | iPhone、iPad |
| **対応地域** | 米国本土（Contiguous United States）のみ — アラスカ・ハワイ・米国領土は対象外 |
| **対応電力会社** | 現時点では PG&E のみ（TOU 料金プラン連携） |
| **ビルド環境** | Xcode 26 以降 |
| **Entitlement** | EnergyKit 専用 Entitlement が必要 |
| **配布** | 現時点は開発ビルドと Ad Hoc テストのみ。TestFlight と App Store 提出は 2025 年後半に対応予定 |
| **対象アプリ** | EV 充電アプリ、スマートサーモスタットアプリ（v1.0） |

### 現時点の制限事項

1. **地域限定:** 米国本土のみ（グローバル展開は未定）
2. **電力会社限定:** PG&E のみ（他の電力会社は今後対応予定）
3. **デバイスカテゴリ限定:** EV 充電と HVAC が主対象
4. **ベータ段階:** API が変更される可能性あり
5. **App Store 未対応:** 2025 年後半に対応予定

---

## 6. 他フレームワークとの関係

```
┌─────────────────────────────────────────────────────────┐
│                    EnergyKit                             │
│         グリッド予測 / ガイダンス / インサイト               │
└──────┬─────────┬──────────┬──────────┬──────────────────┘
       ↓         ↓          ↓          ↓
  ┌─────────┐ ┌────────┐ ┌─────────┐ ┌──────────────┐
  │ HomeKit │ │ SwiftUI│ │WidgetKit│ │BackgroundTasks│
  │         │ │        │ │         │ │              │
  │ Home    │ │ UI 表示 │ │ウィジェット│ │ BG 更新      │
  │ 連携    │ │        │ │ 表示    │ │              │
  └─────────┘ └────────┘ └─────────┘ └──────────────┘
       ↕                      ↕
  ┌─────────┐           ┌─────────┐
  │  Matter │           │  AppIn- │
  │ スマート │           │  tents  │
  │ ホーム   │           │  Siri   │
  └─────────┘           └─────────┘
```

| フレームワーク | EnergyKit との関係 |
|---|---|
| **HomeKit** | EnergyVenue が HomeKit の Home に紐づく。Home の共有メンバーとデータ共有 |
| **Matter** | 将来的にエネルギーモニタリング対応デバイスとの統合が期待される |
| **WidgetKit** | インタラクティブウィジェットでグリッド状態をリアルタイム表示し、ガイダンス更新を維持 |
| **BackgroundTasks** | BGAppRefreshTask でバックグラウンドでのガイダンス更新を実現 |
| **AppIntents** | Siri 連携で「今充電していい？」等の音声クエリに対応可能 |
| **SwiftUI** | EnergyVenueSelector 等のオンボーディング UI を提供 |

---

## 7. 面白いアプリアイデア 5 選

### アイデア 1: 「GreenCharge — EV 充電最適化 × ゲーミフィケーション」

**コンセプト:** EnergyKit のグリッド予測を活用した EV 充電最適化アプリ。単なる最適化にとどまらず、クリーンエネルギーでの充電を**ゲーミフィケーション**で「楽しみ」に変える。ユーザー同士でクリーンエネルギー充電率を競い合い、地域コミュニティ全体の CO2 削減に貢献する。

```
ホーム画面:
┌─────────────────────────────────────────┐
│  ⚡ GreenCharge                          │
│                                         │
│  ┌─ 今日のグリッド予測 ───────────────┐  │
│  │                                    │  │
│  │  🟢🟢🟢🟡🟡🔴🔴🔴🟡🟢🟢🟢     │  │
│  │  6   8  10  12  14  16  18  20  22 │  │
│  │       ↑ 今 (10:00)                 │  │
│  │                                    │  │
│  │  次のクリーン窓: 18:00〜22:00       │  │
│  │  予測クリーン度: 87%                │  │
│  └────────────────────────────────────┘  │
│                                         │
│  ┌─ あなたのスコア ──────────────────┐  │
│  │  🌱 グリーンスコア: 2,450 pt       │  │
│  │  🏆 今月ランキング: #12 / 1,280人  │  │
│  │  📊 クリーン充電率: 78%            │  │
│  │  🌍 CO2 削減量: 42.3 kg           │  │
│  └────────────────────────────────────┘  │
│                                         │
│  ┌──────────────┐  ┌─────────────────┐  │
│  │ 🔋 今すぐ充電  │  │ 📅 スマート予約  │  │
│  └──────────────┘  └─────────────────┘  │
└─────────────────────────────────────────┘

スマート予約画面:
┌─────────────────────────────────────────┐
│  📅 スマート充電予約                      │
│                                         │
│  目標充電率: [━━━━━━━━░░] 80%           │
│  出発時刻:   明日 7:30                   │
│                                         │
│  ┌─ AI 最適化プラン ─────────────────┐  │
│  │                                    │  │
│  │  ⏸ 10:00-18:00  待機               │  │
│  │  ⚡ 18:00-20:30  充電 (クリーン 87%)│  │
│  │  ⏸ 20:30-02:00  待機               │  │
│  │  ⚡ 02:00-05:00  充電 (クリーン 72%)│  │
│  │                                    │  │
│  │  予測獲得ポイント: +180 pt          │  │
│  │  予測コスト削減: -$2.40             │  │
│  │  予測 CO2 削減: -1.8 kg            │  │
│  └────────────────────────────────────┘  │
│                                         │
│  ┌────────────────────────────────────┐  │
│  │       ✅ この予約を確定する           │  │
│  └────────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**面白い点:**
- **ゲーミフィケーション** — クリーンエネルギーで充電するほどポイント獲得。月間・年間ランキングで地域コミュニティと競争
- **コミュニティ CO2 ダッシュボード** — 地域全体の CO2 削減量をリアルタイム表示。「みんなで目標達成」の連帯感
- **AI スマート予約** — 出発時刻と目標充電率を設定するだけで、EnergyKit のガイダンスに基づき最適な充電スケジュールを自動生成
- LoadEvent の定期送信（15 分間隔）でインサイトを蓄積し、週次・月次のクリーンエネルギーレポートを自動生成
- WidgetKit でホーム画面にリアルタイムのグリッド状態と次のクリーン窓を表示

**技術構成:** EnergyKit（ガイダンス + LoadEvent + インサイト） + WidgetKit + AppIntents + Charts + CloudKit（ランキング）

---

### アイデア 2: 「GridPulse — 電力グリッドの鼓動を可視化するリビングアート」

**コンセプト:** EnergyKit のグリッド予測データを美しいジェネラティブアートとして可視化するアプリ。電力グリッドのクリーン度をリアルタイムに**色・波形・パーティクル**で表現し、StandBy モードやウィジェットで「エネルギーの鼓動」をリビングに飾る。実用情報とアートの融合。

```
メインビュー（StandBy / iPad 表示）:
┌─────────────────────────────────────────────┐
│                                             │
│     ～～～🌊～～～～～～～～～～🌊～～～      │
│   ～～🌊～～～～🌿～～～～～🌊～～～～～     │
│  ～🌊～～～🌿～～～🌿～～🌊～～～～～～～    │
│  ～～～～🌿～～～🌿～～～🌿～～～～～～～    │
│   ～～～～～～～～～～～～～～～～～～～～     │
│                                             │
│            87% クリーン                      │
│         「風と太陽の午後」                    │
│                                             │
│    ┌──────────────────────────────────┐     │
│    │ 6  8  10  12  14  16  18  20  22 │     │
│    │ 🟢🟢🟢🟢🟡🟡🔴🟡🟢🟢🟢🟢    │     │
│    └──────────────────────────────────┘     │
│                                             │
└─────────────────────────────────────────────┘

色の意味:
  🟢 緑 = 高クリーン度（再生可能エネルギー豊富）
  🟡 黄 = 中程度
  🔴 赤 = 低クリーン度（火力発電中心）

パーティクルの動き:
  - クリーン度が高い → 穏やかな波・葉のパーティクル
  - クリーン度が低い → 激しい波・煙のパーティクル
  - 変化の瞬間 → トランジションアニメーション
```

**面白い点:**
- **エネルギーデータをアートに変換** — 数字やグラフではなく、直感的に「今のグリッド状態」を感じ取れる
- StandBy モードで充電中の iPhone が「エネルギーアートフレーム」に変身
- 1 日の終わりに「今日のエネルギー風景」をタイムラプス動画として保存・共有
- ウィジェットで Lock Screen にもミニアートを表示 — 一目でグリッド状態を把握
- **環境教育ツール** として学校や家庭で活用可能

**技術構成:** EnergyKit（ガイダンス） + Metal / RealityKit（ジェネラティブアート） + WidgetKit + StandBy + SharePlay

---

### アイデア 3: 「WattWise — 家族で楽しむ節電チャレンジ」

**コンセプト:** EnergyKit のインサイト機能を活用し、家族全員で電力使用の最適化に取り組む「節電チャレンジ」アプリ。HomeKit Home の共有メンバー機能を活かし、家族間でリアルタイムにインサイトを共有。子供の環境教育にも最適。

```
ファミリーダッシュボード:
┌─────────────────────────────────────────┐
│  🏠 WattWise — 田中家                    │
│                                         │
│  ┌─ 今週のチャレンジ ────────────────┐  │
│  │  🎯「ピーク時間に電力 20% カット」   │  │
│  │                                    │  │
│  │  進捗: [━━━━━━━━░░░] 72%          │  │
│  │  残り 2 日!                         │  │
│  └────────────────────────────────────┘  │
│                                         │
│  ┌─ 家族メンバー ────────────────────┐  │
│  │  👨 パパ   ⚡ EV充電  クリーン率 85%│  │
│  │  👩 ママ   🌡 エアコン クリーン率 62%│  │
│  │  👦 太郎   📱 (学習中)  Quiz 正解 8 │  │
│  │  👧 花子   📱 (学習中)  Quiz 正解 12│  │
│  └────────────────────────────────────┘  │
│                                         │
│  ┌─ 今日のインサイト ────────────────┐  │
│  │  🌍 CO2 削減量:  2.1 kg           │  │
│  │  💰 コスト削減:  $1.80             │  │
│  │  🌱 クリーン率:  74%               │  │
│  │  📈 先週比:     +8%               │  │
│  └────────────────────────────────────┘  │
│                                         │
│  ┌──────────────┐  ┌─────────────────┐  │
│  │ 📊 詳細レポート│  │ 🎮 クイズに挑戦 │  │
│  └──────────────┘  └─────────────────┘  │
└─────────────────────────────────────────┘

子供向けエネルギークイズ:
┌─────────────────────────────────────────┐
│  🎮 エネルギークイズ #42                  │
│                                         │
│  Q: 今日、一番クリーンな電力が使える       │
│     時間はいつでしょう？                   │
│                                         │
│  ┌────────────────────────────────────┐  │
│  │  A. 朝 8時                         │  │
│  │  B. 昼 12時                        │  │
│  │  C. 夕方 18時  ← 正解! 🎉          │  │
│  │  D. 夜 22時                        │  │
│  └────────────────────────────────────┘  │
│                                         │
│  💡 太陽光発電が多い夕方は、余った電力で   │
│     グリッドがクリーンになるよ!            │
│                                         │
│  +10 pt 獲得!  累計: 120 pt             │
└─────────────────────────────────────────┘
```

**面白い点:**
- **HomeKit Home の共有機能をフル活用** — LoadEvent で送信されたデータが家族全員に共有される仕組みを活かしたファミリーアプリ
- **子供向けエネルギークイズ** — EnergyKit のリアルデータに基づいた問題を自動生成。「今日のクリーンな時間はいつ？」で環境教育
- 週次チャレンジで家族の結束力アップ + 実際のコスト削減
- ElectricityInsightRecord のデータを月次レポートとして可視化 — 環境への貢献を実感
- 他の家族とのコミュニティ対抗戦で「ご近所対決」も可能

**技術構成:** EnergyKit（インサイト + ガイダンス） + HomeKit（Home 共有） + CloudKit（ファミリー同期） + WidgetKit + Charts

---

### アイデア 4: 「ThermoShift — AI サーモスタット × 快適度の予測最適化」

**コンセプト:** EnergyKit のガイダンスと電力料金データを活用し、スマートサーモスタットの運転を**ユーザーの快適度を損なわずに**最適化する AI サーモスタットアプリ。事前冷暖房（Pre-conditioning）により、ピーク料金時間帯の前に室温を調整し、ピーク時はパッシブに過ごす戦略を自動化。

```
メイン画面:
┌─────────────────────────────────────────┐
│  🌡 ThermoShift                          │
│                                         │
│           現在の室温                      │
│          ┌────────┐                     │
│          │ 23.5°C │                     │
│          └────────┘                     │
│        目標: 23°C  快適度: 😊 95%        │
│                                         │
│  ┌─ 今日の運転プラン ────────────────┐  │
│  │                                    │  │
│  │  06:00-08:00  🟢 事前暖房 → 24°C  │  │
│  │  08:00-12:00  ⏸ パッシブ維持       │  │
│  │  12:00-14:00  🔴 ピーク → OFF      │  │
│  │  14:00-16:00  🟢 事前冷房 → 22°C  │  │
│  │  16:00-19:00  🔴 ピーク → パッシブ  │  │
│  │  19:00-22:00  🟢 通常運転 23°C     │  │
│  │                                    │  │
│  │  予測節約額: $3.20 / 日             │  │
│  │  快適度スコア: 92% (許容範囲内)     │  │
│  └────────────────────────────────────┘  │
│                                         │
│  ┌─ 電力料金 × グリッド ─────────────┐  │
│  │  💰🟢  💰🟢  💰💰🟡  💲💲🔴     │  │
│  │   6    10    14     18    22      │  │
│  │  安+緑  安+緑  中+黄   高+赤       │  │
│  └────────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**面白い点:**
- **事前冷暖房（Pre-conditioning）** — ピーク料金の前に室温を目標より少し上下に調整。建物の断熱性を「蓄電池」として活用
- EnergyKit の TOU 料金データとグリッド予測の**二軸最適化** — コストとクリーン度の両方を考慮
- **快適度 AI** — 過去のユーザー行動（手動温度調整のパターン）を学習し、許容できる温度範囲を個人ごとに最適化
- 「快適度は 92% 以上をキープ」のように制約を設定すると、その範囲内で最大限コストを削減
- LoadEvent で HVAC の消費電力を報告し、月次の節約レポートを自動生成

**技術構成:** EnergyKit（ガイダンス + 料金 + LoadEvent） + HomeKit（サーモスタット制御） + Core ML（快適度予測） + WidgetKit + Charts

---

### アイデア 5: 「GridBeat — 電力市場リアルタイムトラッカー × パーソナルカーボンフットプリント」

**コンセプト:** EnergyKit のデータを基盤に、個人の「カーボンフットプリント」をリアルタイムで追跡する環境意識アプリ。EV 充電と HVAC の電力消費がカーボンに換算されてどれだけの環境影響を持つかを、直感的な UI で毎日トラッキング。年間サマリーで「あなたの 1 年」を振り返る。

```
メイン画面:
┌─────────────────────────────────────────┐
│  🌍 GridBeat                             │
│                                         │
│  ┌─ 今日のカーボンフットプリント ─────┐  │
│  │                                    │  │
│  │      🌱 1.2 kg CO2                 │  │
│  │      (平均比 -45%)                  │  │
│  │                                    │  │
│  │  ┌────────────────────────────┐   │  │
│  │  │ 🔋 EV 充電:    0.4 kg     │   │  │
│  │  │ 🌡 エアコン:   0.6 kg     │   │  │
│  │  │ 🏠 その他:     0.2 kg     │   │  │
│  │  └────────────────────────────┘   │  │
│  └────────────────────────────────────┘  │
│                                         │
│  ┌─ カーボンカレンダー ──────────────┐  │
│  │  月 火 水 木 金 土 日              │  │
│  │  🟢 🟢 🟡 🟢 🟢 🟢 ⬜            │  │
│  │  🟡 🟢 🟢 🔴 🟢 🟡 🟢            │  │
│  │  🟢 🟢 📍                         │  │
│  │                                    │  │
│  │  🟢 20日  🟡 5日  🔴 1日          │  │
│  │  今月のグリーン日率: 77%            │  │
│  └────────────────────────────────────┘  │
│                                         │
│  ┌─ 今のアクション提案 ──────────────┐  │
│  │  💡 18:00 からクリーン度が上がります │  │
│  │     EV 充電を 18:00 に予約しますか？│  │
│  │  ┌──────────┐  ┌──────────┐       │  │
│  │  │ ✅ 予約   │  │ ⏭ 後で   │       │  │
│  │  └──────────┘  └──────────┘       │  │
│  └────────────────────────────────────┘  │
└─────────────────────────────────────────┘

年間サマリー（12 月末に自動生成）:
┌─────────────────────────────────────────┐
│  📊 2026 年 あなたの GridBeat             │
│                                         │
│  🌍 年間 CO2 削減量:   480 kg            │
│  🌳 植樹換算:          24 本分           │
│  💰 年間節約額:        $840              │
│  ⚡ クリーン充電率:    82%               │
│  📅 グリーン日数:      285 / 365 日      │
│                                         │
│  🏆 あなたの環境貢献度: 上位 8%           │
│                                         │
│  ┌────────────────────────────────────┐  │
│  │       🎉 シェアする                  │  │
│  └────────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**面白い点:**
- **ElectricityInsightRecord の「クリーン度 × 消費電力」でカーボンを自動計算** — ユーザーは何も入力しなくていい
- **カーボンカレンダー** — GitHub のコントリビューショングラフのように、毎日のカーボン影響を色で可視化
- Siri 連携（AppIntents）で「今日のカーボンは？」「今充電していい？」に音声で回答
- 年末の「年間サマリー」を Spotify Wrapped のようにデザイン — SNS でシェアして環境意識を広める
- プッシュ通知でリアルタイムに「今クリーンな時間が始まりました！」と行動を促す

**技術構成:** EnergyKit（インサイト + ガイダンス + LoadEvent） + AppIntents（Siri） + WidgetKit + Charts + CloudKit + ShareSheet

---

## 8. まとめ

| 観点 | 評価 |
|---|---|
| **データ品質** | ★★★★☆ — Apple のグリッド予測データは iPhone のクリーンエネルギー充電と同じソースで信頼性が高い |
| **プライバシー** | ★★★★★ — エンドツーエンド暗号化。Apple もデータを読めない |
| **API 設計** | ★★★★☆ — AsyncSequence ベースのモダンな Swift Concurrency 設計 |
| **対応範囲** | ★★☆☆☆ — 米国本土のみ、PG&E のみ（v1.0 の最大の制限） |
| **デバイスカテゴリ** | ★★☆☆☆ — EV 充電と HVAC のみ（蓄電池・太陽光等は未対応） |
| **API 成熟度** | ★★☆☆☆ — ベータ段階。App Store 提出未対応。API 変更の可能性あり |
| **将来性** | ★★★★★ — Apple Home の HEMS 化、Matter 統合、グローバル展開の可能性 |

### EnergyKit が最も輝くパターン

1. **EV 充電の最適化** — クリーンで安価な時間帯に充電をシフトする「スマート充電」
2. **HVAC の事前制御** — ピーク料金前の Pre-conditioning で快適度を維持しつつ節約
3. **カーボンフットプリントの可視化** — インサイトデータで環境影響をユーザーに伝える
4. **電力コストの削減** — TOU 料金データと連携したコスト最適化
5. **環境教育** — リアルなグリッドデータを使った子供・家族向けの教育コンテンツ

### 参考リンク

- [Apple Developer — EnergyKit](https://developer.apple.com/energykit/)
- [EnergyKit Documentation](https://developer.apple.com/documentation/energykit)
- [WWDC25: Optimize home electricity usage with EnergyKit](https://developer.apple.com/videos/play/wwdc2025/257/)
- [ElectricityInsightQuery](https://developer.apple.com/documentation/energykit/electricityinsightquery)
- [Optimizing home electricity usage](https://developer.apple.com/documentation/EnergyKit/optimizing-home-electricity-usage)
- [Apple Developer Forums — EnergyKit](https://developer.apple.com/forums/topics/energykit)
- [AppleInsider — Apple's new EnergyKit helps apps shift usage to cleaner, cheaper electricity](https://appleinsider.com/articles/25/06/12/apples-new-energykit-in-ios-26-help-homekit-users-shift-to-cleaner-cheaper-electricity)
- [9to5Mac — Apple enables smart home apps to cut your electricity bills](https://9to5mac.com/2025/06/12/apple-enables-smart-home-apps-to-cut-your-electricity-bills/)
