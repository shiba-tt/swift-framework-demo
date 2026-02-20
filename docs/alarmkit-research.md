# AlarmKit フレームワーク 調査レポート

## 1. AlarmKit とは

AlarmKit は Apple が **WWDC25**（iOS 26）で発表した**新しいフレームワーク**で、サードパーティアプリから**システムレベルのアラーム・カウントダウンタイマー**をスケジュールできる。

これまで Apple の純正「時計」アプリだけが持っていた特権 —— サイレントモードや集中モードを貫通する目覚ましアラーム —— が、ついにサードパーティ開発者にも開放された。

**核心コンセプト:** 「サードパーティアプリでも、純正時計アプリと同等のアラーム・タイマー機能をシステムレベルで実現」

### ローカル通知との決定的な違い

| 項目 | AlarmKit (iOS 26+) | UserNotifications |
|---|---|---|
| **サイレントモード** | 貫通する（音が鳴る） | 鳴らない |
| **集中モード / DND** | 貫通する | 抑制される（Time Sensitive でも限定的） |
| **ロック画面** | フルスクリーン表示 | バナー通知のみ |
| **Dynamic Island** | 対応（カウントダウン表示） | 非対応 |
| **StandBy** | 対応 | 非対応 |
| **Apple Watch** | 対応（連動表示） | 限定的 |
| **スヌーズ** | ネイティブ対応 | 独自実装が必要 |
| **カスタムアクション** | AppIntents で実行 | Notification Action（限定的） |
| **アラーム数制限** | 実質無制限 | スケジュール制限あり |
| **バックグラウンド動作** | デーモン駆動（アプリ不要） | アプリ起動が必要な場合あり |

---

## 2. 動作の仕組み

AlarmKit はシステムデーモンによって駆動される。iOS のアラームはデーモン（バックグラウンドで動作するシステムプログラム）が管理しており、SpringBoard、タッチ＆モーションイベント、オーディオ＆ビデオ再生、位置情報サービスと同等のシステムレベルで動作する。

```
┌─────────────────────────────────────────────┐
│  サードパーティアプリ                          │
│  ┌───────────────────────────────────────┐  │
│  │ AlarmManager.shared.schedule(...)      │  │
│  └───────────────┬───────────────────────┘  │
└──────────────────┼──────────────────────────┘
                   ↓
┌──────────────────────────────────────────────┐
│  iOS システムデーモン（アラーム管理）            │
│                                              │
│  アプリが閉じていても、バックグラウンドに         │
│  いなくても、デーモンがアラームを管理・発火        │
│                                              │
│  サイレントモード → 貫通 ✓                     │
│  集中モード → 貫通 ✓                          │
│  アプリ終了 → 動作継続 ✓                       │
└──────────────────┬───────────────────────────┘
                   ↓ アラーム発火時
┌──────────────────────────────────────────────┐
│  表示先                                       │
│  ├── ロック画面: フルスクリーンアラート           │
│  ├── Dynamic Island: カウントダウン / アラート    │
│  ├── StandBy: 大画面表示                       │
│  └── Apple Watch: 連動表示                     │
│                                              │
│  ユーザー操作                                  │
│  ├── Stop ボタン → AppIntent 実行（オプション）  │
│  ├── Snooze ボタン → カウントダウン再開          │
│  └── カスタムボタン → AppIntent 実行            │
└──────────────────────────────────────────────┘
```

---

## 3. API の詳細

### 3.1 主要クラス・構造体

| クラス / 構造体 | 役割 |
|---|---|
| `AlarmManager` | アラームの認可・スケジュール・管理を行う中央コーディネーター |
| `AlarmManager.AlarmConfiguration` | アラームの動作と表示を定義（スケジュール、カウントダウン、属性） |
| `Alarm` | スケジュール済みアラームのインスタンス（ID、状態、カウントダウン時間） |
| `Alarm.Schedule` | アラームのトリガータイミング（固定 / 相対 / 繰り返し） |
| `Alarm.CountdownDuration` | プリアラート・ポストアラートのカウントダウン時間 |
| `AlarmAttributes` | ActivityAttributes のラッパー。Live Activity でのアラーム UI を定義 |
| `AlarmPresentation` | アラートの表示設定（タイトル、ボタン、色） |
| `AlarmPresentation.Alert` | アラート発火時の表示（Stop / Snooze ボタン等） |
| `AlarmButton` | アラート上のボタン（テキスト、色、アイコン） |

### 3.2 認可（Authorization）

```swift
import AlarmKit

// 認可状態の確認とリクエスト
func checkAuthorization() async -> Bool {
    switch AlarmManager.shared.authorizationState {
    case .notDetermined:
        do {
            let state = try await AlarmManager.shared.requestAuthorization()
            return state == .authorized
        } catch {
            return false
        }
    case .authorized:
        return true
    case .denied:
        // ユーザーに Settings からの許可変更を案内
        return false
    @unknown default:
        return false
    }
}
```

**Info.plist 必須キー:**
```xml
<key>NSAlarmKitUsageDescription</key>
<string>このアプリはアラームとタイマーを使用して、あなたの予定を管理します。</string>
```

- ユーザーは各アプリごとにアラーム許可を設定可能
- 初回アラーム作成時に自動的にプロンプトが表示される（手動リクエストも可）
- Settings アプリからいつでも許可を変更可能

### 3.3 アラームのスケジュール

#### 固定スケジュール（1 回限り）

```swift
import AlarmKit

let alarmID = UUID()

// 固定スケジュール: 特定の未来の日時
let fixedDate = Calendar.current.date(
    bySettingHour: 7, minute: 30, second: 0, of: Date().addingTimeInterval(86400)
)!
let schedule = Alarm.Schedule.fixed(
    Alarm.Schedule.Fixed(date: fixedDate)
)

// アラート表示の設定
let alertPresentation = AlarmPresentation.Alert(
    title: "朝の目覚まし",
    stopButton: AlarmButton(
        text: "停止",
        textColor: .white,
        systemImageName: "stop.circle.fill"
    ),
    secondaryButton: AlarmButton(
        text: "スヌーズ",
        textColor: .white,
        systemImageName: "zzz"
    ),
    secondaryButtonBehavior: .countdown  // スヌーズ → カウントダウン再開
)

// カウントダウン設定（スヌーズ時間）
let countdownDuration = Alarm.CountdownDuration(
    preAlert: nil,
    postAlert: TimeInterval(5 * 60)  // 5 分スヌーズ
)

// メタデータ（カスタム属性）
let metadata = MyAlarmMetadata(category: .wakeUp)

// アラーム属性
let attributes = AlarmAttributes(metadata: metadata)

// 設定の組み立て
let configuration = AlarmManager.AlarmConfiguration(
    countdownDuration: countdownDuration,
    schedule: schedule,
    attributes: attributes,
    presentation: AlarmPresentation(alert: alertPresentation),
    sound: .default
)

// スケジュール実行
do {
    let alarm = try await AlarmManager.shared.schedule(
        id: alarmID,
        configuration: configuration
    )
    print("アラームをスケジュール: \(alarm.id)")
} catch {
    print("スケジュール失敗: \(error)")
}
```

#### 相対スケジュール（繰り返し）

```swift
// 相対スケジュール: 毎週月〜金 7:30
let relativeSchedule = Alarm.Schedule.relative(
    Alarm.Schedule.Relative(
        time: Alarm.Schedule.Relative.Time(hour: 7, minute: 30),
        repeats: .weekly([.monday, .tuesday, .wednesday, .thursday, .friday])
    )
)
```

**固定 vs 相対の違い:**

| 項目 | 固定 (Fixed) | 相対 (Relative) |
|---|---|---|
| **指定方法** | 絶対的な日時 | 時刻 + 繰り返しパターン |
| **タイムゾーン** | 変更の影響を受けない | タイムゾーン変更に追従 |
| **繰り返し** | 1 回限り | 毎日 / 毎週（曜日指定） |
| **ユースケース** | 特定日時のリマインダー | 目覚まし時計 |

#### カウントダウンタイマー

```swift
// スケジュールなし = 即時開始のカウントダウンタイマー
let timerDuration = Alarm.CountdownDuration(
    preAlert: TimeInterval(10 * 60),  // 10 分のカウントダウン
    postAlert: nil
)

let timerConfig = AlarmManager.AlarmConfiguration(
    countdownDuration: timerDuration,
    schedule: nil,  // nil = 即時開始
    attributes: attributes,
    presentation: AlarmPresentation(alert: alertPresentation)
)
```

**preAlert vs postAlert:**

| 項目 | preAlert | postAlert |
|---|---|---|
| **タイミング** | アラート発火前のカウントダウン | アラート後のカウントダウン（スヌーズ） |
| **用途** | タイマー（「あと 10 分」） | スヌーズ（「5 分後にもう一度」） |
| **Live Activity** | カウントダウン表示に必須 | スヌーズ後の再カウントダウン |

### 3.4 Live Activity 統合（カウントダウン UI）

カウントダウン機能を持つアラームには **Live Activity の実装が必須**。

```swift
import ActivityKit
import AlarmKit
import WidgetKit
import SwiftUI

// カスタムメタデータ
struct MyAlarmMetadata: AlarmMetadata {
    // nonisolated が必要（Xcode 26 の MainActor デフォルトのため）
    nonisolated static var activityConfiguration: some AlarmActivityConfiguration {
        ActivityConfiguration(for: AlarmAttributes<MyAlarmMetadata>.self) { context in
            // ロック画面 / StandBy 表示
            VStack {
                Text(context.attributes.metadata.title)
                    .font(.headline)

                // カウントダウン中かアラート中かで表示を切り替え
                if context.state.isCountingDown {
                    Text("残り時間")
                    // カウントダウン表示
                } else {
                    Text("アラーム!")
                }
            }
        } dynamicIsland: { context in
            // Dynamic Island 表示
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "alarm.fill")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.metadata.title)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    // ボタン等
                }
            } compactLeading: {
                Image(systemName: "alarm.fill")
            } compactTrailing: {
                Text("⏰")
            } minimal: {
                Image(systemName: "alarm.fill")
            }
        }
    }
}
```

**表示場所と形式:**

| 表示場所 | 形式 | カウントダウン | アラート |
|---|---|---|---|
| **ロック画面** | バナー → フルスクリーン | カウントダウン表示 | Stop / Snooze ボタン |
| **Dynamic Island** | コンパクト → 展開 | 残り時間表示 | タイトル + ボタン |
| **StandBy** | 大画面 | 2x スケール表示 | フルスクリーン |
| **Apple Watch** | 連動表示 | 残り時間 | 振動 + 表示 |

### 3.5 AppIntents によるカスタムアクション

```swift
import AppIntents
import AlarmKit

// Stop ボタンのカスタムアクション
struct StopAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "アラーム停止"

    @Parameter(title: "Alarm ID")
    var alarmID: String

    func perform() async throws -> some IntentResult {
        // アラーム停止時のカスタム処理
        // 例: 起床記録の保存、ルーティン開始
        await RecordManager.shared.recordWakeUp(alarmID: alarmID)
        return .result()
    }
}

// Secondary ボタン（カスタムアクション）
struct OpenAppIntent: AppIntent {
    static var title: LocalizedStringResource = "アプリを開く"

    @Parameter(title: "Alarm ID")
    var alarmID: String

    func perform() async throws -> some IntentResult & OpensIntent {
        // アプリを開いて特定の画面に遷移
        return .result()
    }
}
```

**重要:** アプリが完全に終了していても、アラームボタンのタップで AppIntent が実行され、必要に応じてアプリが起動する。

### 3.6 アラームのライフサイクル管理

```swift
// スケジュール済みアラーム一覧の取得
let alarms = AlarmManager.shared.alarms  // AsyncSequence

for await alarm in alarms {
    print("ID: \(alarm.id), State: \(alarm.state)")
}

// アラームの停止
try await AlarmManager.shared.stop(id: alarmID)

// アラームのキャンセル（スケジュール取り消し）
try await AlarmManager.shared.cancel(id: alarmID)

// カウントダウンの一時停止・再開
try await AlarmManager.shared.pause(id: alarmID)
try await AlarmManager.shared.resume(id: alarmID)
```

**アラームの状態遷移:**

```
scheduled → countdown (preAlert) → alerting → countdown (postAlert/snooze) → stopped
                ↑         │                        │
                │         ↓                        │
              paused    stopped                  stopped
```

### 3.7 カスタムサウンド

```swift
// デフォルトサウンド
let config = AlarmManager.AlarmConfiguration(
    // ...
    sound: .default
)

// カスタムサウンド（アプリバンドルまたは Library/Sounds フォルダ）
let config = AlarmManager.AlarmConfiguration(
    // ...
    sound: .named("morning_alarm.caf")
)
```

- サウンドファイルはアプリのメインバンドルまたは `Library/Sounds` フォルダに配置
- デフォルトサウンドは約 1 分間ループ再生
- カスタムサウンドは約 30 秒（ファイル長の制限）

---

## 4. 設計上の制約と注意点

### 4.1 現在の制限（v1.0）

| 制約 | 詳細 |
|---|---|
| **iOS 26+ 必須** | iOS 26.0 以降のみ対応。それ以前の iOS では使用不可 |
| **UI カスタマイズ限定** | システムレベルのアラート UI は大幅なカスタマイズ不可 |
| **スワイプ dismissal 検知不可** | ユーザーがアラームをスワイプで閉じた場合、Stop Intent が呼ばれない |
| **状態同期の手間** | アプリ内の DB とアラームの状態を手動で同期する必要がある |
| **タイムゾーン / DST** | 固定スケジュールはタイムゾーン変更の影響を受けない（意図的だが注意） |
| **ローカルサウンドのみ** | ネットワークからのサウンドストリーミングは不可 |
| **カスタムサウンド長** | カスタムサウンドは約 30 秒で停止する制限がある |

### 4.2 開発上の注意点

| 項目 | 推奨事項 |
|---|---|
| **認可ハンドリング** | denied 状態のユーザーに Settings への導線を提供 |
| **ID 管理** | アラーム ID とアプリ内 DB のレコードを一意 ID で紐付け |
| **Live Activity 必須** | カウントダウン機能にはLive Activity の実装が必須 |
| **nonisolated** | Xcode 26 の MainActor デフォルトのため、メタデータ型に nonisolated が必要 |
| **エラーハンドリング** | スケジュール失敗時のフォールバック（ローカル通知等） |

### 4.3 依存フレームワーク

AlarmKit は以下のフレームワークと密接に連携:

```
AlarmKit
  ├── ActivityKit（Live Activity / Dynamic Island / StandBy）
  ├── WidgetKit（カウントダウン UI）
  ├── AppIntents（カスタムアクション）
  └── SwiftUI（プレゼンテーション）
```

---

## 5. 従来の「アラームアプリ」問題の解決

### 5.1 iOS 25 以前の問題

| 問題 | 詳細 |
|---|---|
| **サイレントモードで鳴らない** | ローカル通知はサイレントモードで無音になる |
| **集中モードで抑制** | DND / Focus で通知が届かない |
| **Critical Alerts は取得困難** | Apple に特別なエンタイトルメントを申請する必要がある |
| **バックグラウンド制限** | アプリが終了するとアラームが機能しなくなる |
| **ロック画面の表示が貧弱** | バナー通知のみでフルスクリーン表示不可 |
| **スヌーズの信頼性** | 独自実装のスヌーズは信頼性が低い |

### 5.2 AlarmKit による解決

| 解決 | 詳細 |
|---|---|
| **サイレントモード貫通** | システムデーモンがサイレント・集中モードを貫通してアラートを表示 |
| **特別なエンタイトルメント不要** | NSAlarmKitUsageDescription + ユーザー認可のみ |
| **アプリ終了後も動作** | デーモン駆動のためアプリの状態に依存しない |
| **フルスクリーン表示** | ロック画面 / Dynamic Island / StandBy で本格的な表示 |
| **ネイティブスヌーズ** | システムレベルのスヌーズ機能 |

---

## 6. iOS アプリ活用アイデア

### アイデア 1: 「RitualAlarm — 朝のルーティンを段階的に導くアラーム」

**コンセプト:** 1 回の目覚まし → 起床 ではなく、朝のルーティン全体を「連鎖するアラーム」で段階的にガイドするアプリ。AlarmKit の相対スケジュール + AppIntents を組み合わせ、Stop ボタンのタップで次のルーティンアラームを自動スケジュール。

```
6:30  🔔 [起床アラーム]
      Stop: "起きた" → 次のアラームを自動スケジュール
      Snooze: 5分後に再アラーム
         ↓ Stop タップ
6:35  ⏱️ [ストレッチタイマー] (5分カウントダウン)
      Dynamic Island にカウントダウン表示
      完了 → 次を自動スケジュール
         ↓ 完了
6:40  🔔 [朝食準備アラーム]
      Stop: "準備完了" → 次をスケジュール
         ↓ Stop タップ
7:00  ⏱️ [出発準備タイマー] (20分カウントダウン)
      ロック画面にカウントダウン
         ↓ 完了
7:20  🔔 [出発アラーム]
      "家を出る時間です！"
      Custom Button: "天気を確認" → アプリ起動
```

**面白い点:**
- アラームが「点」ではなく「線」になる — 朝全体を設計
- 各 Stop ボタンの AppIntent で次のアラームを自動チェーンスケジュール
- Dynamic Island にカウントダウンが常に表示 → 時間意識の強化
- StandBy モードで充電中に大画面ルーティン表示
- Apple Watch 連動で手首にもリマインド
- サイレントモード貫通で「絶対に起きる」信頼性

**技術構成:** AlarmKit + AppIntents（チェーンスケジュール） + ActivityKit（Live Activity） + WeatherKit

---

### アイデア 2: 「CookMaster — マルチタイマー料理アシスタント」

**コンセプト:** 料理中に複数のタイマーを同時管理するアプリ。AlarmKit のカウントダウン機能で「パスタ茹で 8 分」「ソース煮込み 15 分」「オーブン 25 分」を同時に走らせ、すべてが Dynamic Island と ロック画面に表示される。

```
┌─ Dynamic Island ──────────────────────┐
│  🍝 パスタ 3:42  │  🍖 オーブン 18:30  │
└───────────────────────────────────────┘

┌─ ロック画面 ──────────────────────────┐
│  🍝 パスタ茹で       3:42 残り        │
│     [一時停止]  [キャンセル]           │
│                                       │
│  🥘 トマトソース     12:05 残り        │
│     [一時停止]  [キャンセル]           │
│                                       │
│  🍖 ローストチキン   18:30 残り        │
│     [一時停止]  [キャンセル]           │
└───────────────────────────────────────┘

アラート発火時（パスタ完了）:
┌─────────────────────────────────────┐
│         🍝 パスタが茹で上がりました!     │
│                                      │
│  ┌──────────┐   ┌──────────────┐    │
│  │  🛑 完了  │   │  ➕ 1分追加   │    │
│  └──────────┘   └──────────────┘    │
│                                      │
│  サイレントモードでも鳴ります 🔊        │
└─────────────────────────────────────┘
```

**仕組み:**
- 各食材・工程ごとに独立した AlarmKit タイマーをスケジュール
- preAlert カウントダウンで残り時間を Live Activity に表示
- アラート発火時の Secondary ボタンで「1 分追加」（postAlert で再カウントダウン）
- カスタムサウンドで食材ごとに異なるアラーム音
- 一時停止 / 再開でタイマーを柔軟に管理

**面白い点:**
- **サイレントモード貫通が料理に最適** — キッチンでサイレントにしていても必ず鳴る
- 複数タイマーが Dynamic Island にコンパクト表示 — 画面を見なくても確認可能
- StandBy で充電台に置けば「キッチンタイマーディスプレイ」に変身
- Apple Watch 連動で手首にタイマー通知 — 手が濡れていても確認可能

**技術構成:** AlarmKit（複数タイマー） + ActivityKit + SwiftUI + カスタムサウンド

---

### アイデア 3: 「FocusForge — ポモドーロ×アラームの集中力鍛錬」

**コンセプト:** ポモドーロ・テクニック（25 分集中 + 5 分休憩）を AlarmKit のシステムレベルアラームで実装。通常のポモドーロアプリと違い、サイレントモードや集中モードを貫通して「強制的に休憩を取らせる」。

```
作業フェーズ (25分):
┌─ Dynamic Island ──────────┐
│  🧠 集中中  22:45 残り      │
└───────────────────────────┘

         ↓ 25分経過

休憩アラーム発火:
┌─────────────────────────────────────┐
│    🧘 休憩時間です！                    │
│    「25分間お疲れさまでした」             │
│                                      │
│  ┌──────────────┐  ┌────────────┐   │
│  │ 🏃 休憩開始   │  │ ⏭️ スキップ │   │
│  └──────────────┘  └────────────┘   │
│                                      │
│  ※ サイレントモードでも通知されます       │
└─────────────────────────────────────┘

         ↓ 休憩開始タップ

休憩フェーズ (5分):
┌─ Dynamic Island ──────────┐
│  ☕ 休憩中  4:30 残り        │
└───────────────────────────┘

         ↓ 5分経過

作業復帰アラーム:
┌─────────────────────────────────────┐
│    🔥 作業再開！                       │
│    「今日 3 ポモドーロ目です」            │
│                                      │
│  ┌──────────────┐  ┌────────────┐   │
│  │ 🧠 作業開始   │  │ 🛑 終了    │   │
│  └──────────────┘  └────────────┘   │
└─────────────────────────────────────┘
```

**面白い点:**
- 「集中モードを貫通する休憩通知」が逆説的だが実用的 — 過集中の防止
- AppIntents による自動チェーン: 作業 Stop → 休憩タイマー自動開始 → 休憩 Stop → 作業タイマー自動開始
- Dynamic Island にフェーズ（集中/休憩）とカウントダウンが常に表示
- ポモドーロ完了数の記録を AppIntents 内で自動蓄積
- ロック画面を見なくても Apple Watch で残り時間を確認可能

**技術構成:** AlarmKit + AppIntents（チェーンスケジュール） + ActivityKit + HealthKit（集中時間記録）

---

### アイデア 4: 「MedicineGuard — 絶対に飲み忘れない服薬アラーム」

**コンセプト:** 服薬管理に特化したアラームアプリ。従来の通知ベースの服薬アプリは「サイレントモードで聞こえない」「集中モードで届かない」という致命的問題があったが、AlarmKit で解決。

```
相対スケジュール例:

  朝の薬: 毎日 8:00
  ┌─────────────────────────────────────┐
  │  💊 朝の薬の時間です                    │
  │  「アムロジピン 5mg + ビタミン D」        │
  │                                      │
  │  ┌──────────────┐  ┌────────────┐   │
  │  │ ✅ 服用済み   │  │ ⏰ 30分後   │   │
  │  └──────────────┘  └────────────┘   │
  └─────────────────────────────────────┘

  昼の薬: 毎日 12:30
  夜の薬: 毎日 20:00
  週1回の薬: 毎週月曜 9:00

Stop → "服用済み" AppIntent:
  → 服薬記録を HealthKit に保存
  → アプリ内の服薬カレンダーに記録
  → 連続服薬日数を更新

Snooze → "30分後" :
  → 30分後に再アラーム
  → 未服薬フラグを設定
```

**面白い点:**
- **サイレントモード / 集中モード貫通が「命に関わる」レベルで重要** — 従来の通知アプリの最大の弱点を解消
- 相対スケジュールの繰り返しで「毎日・毎週」の服薬スケジュールを確実に管理
- Stop ボタンの AppIntents で HealthKit に自動記録 — タップ 1 つで記録完了
- Apple Watch 連動で手首に服薬リマインド
- 高齢者の服薬アドヒアランス向上に直結する社会的価値

**技術構成:** AlarmKit（相対スケジュール繰り返し） + AppIntents + HealthKit + CareKit

---

### アイデア 5: 「SleepCraft — 睡眠サイクルに合わせたスマートアラーム」

**コンセプト:** Apple Watch の睡眠データ（HealthKit）と AlarmKit を連携し、睡眠サイクル（レム睡眠 / ノンレム睡眠）の浅いタイミングでアラームを発火させる「スマートアラーム」。

```
設定:
  起床希望時間: 7:00
  アラームウィンドウ: 6:30 〜 7:00（30分幅）

動作:
  ┌────────────────────────────────────────────┐
  │  睡眠サイクル                                 │
  │                                              │
  │  深い ████░░░░████░░░░████░░░░███            │
  │  浅い ░░░░████░░░░████░░░░████░░░████        │
  │       22:00  0:00  2:00  4:00  6:00  7:00   │
  │                                    ↑         │
  │                               6:42 に浅い睡眠 │
  │                               → ここでアラーム │
  └────────────────────────────────────────────┘

  6:42 🔔 [スマートアラーム]
  ┌─────────────────────────────────────┐
  │  ☀️ おはようございます                  │
  │  「浅い睡眠のタイミングで起こしました」   │
  │  睡眠スコア: 82/100                   │
  │                                      │
  │  ┌──────────────┐  ┌────────────┐   │
  │  │ ☀️ 起きる     │  │ 💤 スヌーズ │   │
  │  └──────────────┘  └────────────┘   │
  │                                      │
  │  Custom: "今日の天気 ☀️ 22°C"         │
  └─────────────────────────────────────┘
```

**仕組み:**
- 就寝前に AlarmKit でウィンドウ終了時刻（7:00）にフォールバックアラームをスケジュール
- バックグラウンドで HealthKit の睡眠ステージデータを監視
- 浅い睡眠を検知したら、既存アラームをキャンセルし、即時アラームを再スケジュール
- Stop ボタンの AppIntents で睡眠サマリーを表示
- Secondary ボタンで天気・予定を確認（WeatherKit / EventKit 連携）

**面白い点:**
- AlarmKit の「デーモン駆動でアプリ不要」+ HealthKit の睡眠データ = 最適な起床タイミング
- フォールバックアラーム（ウィンドウ終了時刻）で「絶対に起きる」保証
- サイレントモード貫通 + スマート起床 = 最高の起床体験
- 睡眠スコアとアラームの自然な連携
- StandBy モードで充電中に睡眠ステージをリアルタイム表示（Live Activity）

**技術構成:** AlarmKit + HealthKit（睡眠ステージ） + ActivityKit + WeatherKit + EventKit + BGHealthResearchTask

---

## 7. まとめ

| 観点 | 評価 |
|---|---|
| **信頼性** | ★★★★★ — システムデーモン駆動。サイレント / 集中モード貫通。アプリ終了後も動作 |
| **表示先** | ★★★★★ — ロック画面 / Dynamic Island / StandBy / Apple Watch の全面対応 |
| **カスタマイズ性** | ★★★☆☆ — AppIntents でアクションは柔軟だが、UI カスタマイズは限定的（v1.0） |
| **API 成熟度** | ★★☆☆☆ — v1.0 であり、スワイプ dismissal 検知不可等の制限あり |
| **互換性** | ★★☆☆☆ — iOS 26+ 必須。当面はフォールバック実装も必要 |
| **開発体験** | ★★★☆☆ — ActivityKit / AppIntents / WidgetKit の統合理解が必要。ネストが深い |

### AlarmKit が最も輝くパターン

1. **確実に届くアラーム** — サイレント / 集中モードを貫通する「絶対に見逃さない」通知
2. **カウントダウンタイマー** — Dynamic Island + ロック画面でリアルタイム表示
3. **繰り返しスケジュール** — 毎日 / 毎週の定期アラーム（目覚まし、服薬等）
4. **アクション連鎖** — AppIntents でStop → 次のアクション を自動チェーン
5. **マルチデバイス連携** — iPhone + Apple Watch + StandBy での統合体験

### 参考リンク

- [Apple Developer — AlarmKit](https://developer.apple.com/documentation/AlarmKit)
- [Scheduling an alarm with AlarmKit](https://developer.apple.com/documentation/AlarmKit/scheduling-an-alarm-with-alarmkit)
- [WWDC25: Wake up to the AlarmKit API](https://developer.apple.com/videos/play/wwdc2025/230/)
- [AlarmManager.AlarmConfiguration](https://developer.apple.com/documentation/alarmkit/alarmmanager/alarmconfiguration)
- [AlarmAttributes](https://developer.apple.com/documentation/alarmkit/alarmattributes)
- [NSAlarmKitUsageDescription](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAlarmKitUsageDescription)
- [Nil Coalescing — Schedule a countdown timer with AlarmKit](https://nilcoalescing.com/blog/CountdownTimerWithAlarmKit/)
- [SVP Digital Studio — AlarmKit API in Swift](https://www.svpdigitalstudio.com/blog/how-to-use-alarmkit-api-in-swift-ios-schedule-alarms-natively)
- [Create with Swift — Scheduling and Managing Alarms in SwiftUI with AlarmKit](https://www.createwithswift.com/scheduling-and-managing-alarms-in-swiftui-with-alarmkit/)
- [Jacob Bartlett — My ADHD vs. the AlarmKit API](https://blog.jacobstechtavern.com/p/adhd-vs-alarmkit)
