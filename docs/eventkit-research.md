# EventKit 調査レポート

## 1. EventKit とは

EventKit は Apple が提供する iOS / macOS / watchOS 向けフレームワークで、**カレンダーイベント**と**リマインダー**のデータにプログラムからアクセスし、作成・読み取り・更新・削除（CRUD）を行うための API を提供する。

ユーザーの端末にあるカレンダーアプリ・リマインダーアプリと同じデータベースを共有しており、アプリから追加したイベントは即座にシステムのカレンダーに反映される。

**対応プラットフォーム:** iOS 4.0+ / macOS 10.8+ / Mac Catalyst 13.0+ / watchOS 2.0+ / visionOS 1.0+

---

## 2. 基本アーキテクチャ

### コアクラス一覧

| クラス | 役割 |
|---|---|
| **EKEventStore** | カレンダーデータベースへのゲートウェイ。アプリ内で1インスタンスを使い回すことが推奨される |
| **EKEvent** | カレンダーイベント（予定）を表すクラス |
| **EKReminder** | リマインダー（タスク）を表すクラス |
| **EKCalendar** | カレンダー（イベントやリマインダーのコンテナ）を表す |
| **EKSource** | カレンダーアカウント（iCloud、Exchange、ローカル等）を表す |
| **EKAlarm** | アラーム（通知）を設定するクラス |
| **EKRecurrenceRule** | 繰り返しルールを定義するクラス |
| **EKRecurrenceEnd** | 繰り返しの終了条件（日付 or 回数） |
| **EKRecurrenceDayOfWeek** | 繰り返しの曜日指定 |
| **EKParticipant** | イベントの参加者（読み取り専用） |
| **EKStructuredLocation** | 位置情報付きのロケーション（ジオフェンス対応） |
| **EKVirtualConferenceProvider** | バーチャル会議プロバイダー（iOS 15+） |
| **EKVirtualConferenceDescriptor** | バーチャル会議の詳細情報 |

### クラス階層

```
EKObject (基底クラス)
├── EKCalendarItem (抽象クラス)
│   ├── EKEvent (カレンダーイベント)
│   └── EKReminder (リマインダー)
├── EKCalendar
├── EKSource
├── EKAlarm
├── EKRecurrenceRule
├── EKParticipant
└── EKStructuredLocation
```

### EventKitUI クラス一覧（iOS / Mac Catalyst のみ）

| クラス | 役割 |
|---|---|
| **EKEventEditViewController** | イベント作成・編集画面をシステム UI で表示 |
| **EKEventViewController** | イベント詳細画面をシステム UI で表示 |
| **EKCalendarChooser** | カレンダー選択画面（単一選択 / 複数選択） |

---

## 3. できること（機能詳細）

### 3.1 カレンダーイベントの CRUD

#### イベントの作成

```swift
import EventKit

let store = EKEventStore()

let event = EKEvent(eventStore: store)
event.title = "チームミーティング"
event.startDate = Date()
event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
event.calendar = store.defaultCalendarForNewEvents
event.location = "会議室 A"
event.notes = "プロジェクト進捗の確認"
event.url = URL(string: "https://example.com/meeting")
event.timeZone = TimeZone(identifier: "Asia/Tokyo")

// 保存
try store.save(event, span: .thisEvent, commit: true)
```

#### イベントの取得

```swift
// 日付範囲でイベントを検索
let startDate = Calendar.current.startOfDay(for: Date())
let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!

let predicate = store.predicateForEvents(
    withStart: startDate,
    end: endDate,
    calendars: nil  // nil = 全カレンダー対象
)

let events = store.events(matching: predicate)
let sorted = events.sorted { $0.compareStartDate(with: $1) == .orderedAscending }
```

#### イベントの更新

```swift
event.title = "更新後のタイトル"
try store.save(event, span: .thisEvent, commit: true)
```

#### イベントの削除

```swift
try store.remove(event, span: .thisEvent, commit: true)
// span: .thisEvent = この1件だけ
// span: .futureEvents = これ以降の繰り返しイベントも削除
```

### 3.2 リマインダーの管理

#### リマインダーの作成

```swift
let reminder = EKReminder(eventStore: store)
reminder.title = "買い物リスト"
reminder.calendar = store.defaultCalendarForNewReminders()
reminder.priority = 1  // 1-4: 高, 5: 中, 6-9: 低

// 期日の設定
var dueDateComponents = DateComponents()
dueDateComponents.year = 2026
dueDateComponents.month = 3
dueDateComponents.day = 1
dueDateComponents.hour = 10
reminder.dueDateComponents = dueDateComponents

try store.save(reminder, commit: true)
```

#### リマインダーの取得

```swift
// 全リマインダー
let predicate = store.predicateForReminders(in: nil)
let reminders = try await store.reminders(matching: predicate)

// 未完了リマインダー
let incompletePredicate = store.predicateForIncompleteReminders(
    withDueDateStarting: startDate,
    ending: endDate,
    calendars: nil
)

// 完了済みリマインダー
let completedPredicate = store.predicateForCompletedReminders(
    withCompletionDateStarting: startDate,
    ending: endDate,
    calendars: nil
)
```

#### リマインダーの完了

```swift
reminder.isCompleted = true
reminder.completionDate = Date()
try store.save(reminder, commit: true)
```

### 3.3 アラーム（通知）

```swift
// 絶対時刻アラーム
let absoluteAlarm = EKAlarm(absoluteDate: alarmDate)

// 相対時刻アラーム（イベント開始の15分前）
let relativeAlarm = EKAlarm(relativeOffset: -15 * 60) // 秒単位

event.addAlarm(relativeAlarm)
```

#### 位置ベースアラーム（ジオフェンス）

```swift
let alarm = EKAlarm()

let location = EKStructuredLocation(title: "東京駅")
location.geoLocation = CLLocation(latitude: 35.6812, longitude: 139.7671)
location.radius = 500  // メートル単位

alarm.structuredLocation = location
alarm.proximity = .enter  // .enter = 到着時, .leave = 出発時

reminder.addAlarm(alarm)
```

### 3.4 繰り返しルール

```swift
// 毎週繰り返し（10回まで）
let weeklyRule = EKRecurrenceRule(
    recurrenceWith: .weekly,
    interval: 1,
    end: EKRecurrenceEnd(occurrenceCount: 10)
)

// 毎月第1月曜日に繰り返し
let complexRule = EKRecurrenceRule(
    recurrenceWith: .monthly,
    interval: 1,
    daysOfTheWeek: [EKRecurrenceDayOfWeek(.monday, weekNumber: 1)],
    daysOfTheMonth: nil,
    monthsOfTheYear: nil,
    weeksOfTheYear: nil,
    daysOfTheYear: nil,
    setPositions: nil,
    end: nil  // 無期限
)

// 毎年3月15日に繰り返し
let yearlyRule = EKRecurrenceRule(
    recurrenceWith: .yearly,
    interval: 1,
    daysOfTheWeek: nil,
    daysOfTheMonth: [15],
    monthsOfTheYear: [3],
    weeksOfTheYear: nil,
    daysOfTheYear: nil,
    setPositions: nil,
    end: nil
)

event.addRecurrenceRule(weeklyRule)
```

**対応頻度:**
- `.daily` — 毎日
- `.weekly` — 毎週
- `.monthly` — 毎月
- `.yearly` — 毎年

### 3.5 カレンダーの管理

```swift
// 全カレンダーの取得
let eventCalendars = store.calendars(for: .event)
let reminderCalendars = store.calendars(for: .reminder)

// ソース（アカウント）の確認
for source in store.sources {
    print("\(source.title) - \(source.sourceType.rawValue)")
}

// 新規カレンダーの作成
let newCalendar = EKCalendar(for: .event, eventStore: store)
newCalendar.title = "仕事"
newCalendar.cgColor = UIColor.blue.cgColor
newCalendar.source = store.sources.first { $0.sourceType == .calDAV }
                   ?? store.defaultCalendarForNewEvents?.source

try store.saveCalendar(newCalendar, commit: true)
```

### 3.6 参加者（読み取り専用）

```swift
// イベントの参加者情報を取得
if let attendees = event.attendees {
    for attendee in attendees {
        print("名前: \(attendee.name ?? "不明")")
        print("ステータス: \(attendee.participantStatus)")
        print("役割: \(attendee.participantRole)")
        print("タイプ: \(attendee.participantType)")
    }
}

// 主催者
if let organizer = event.organizer {
    print("主催者: \(organizer.name ?? "不明")")
}
```

> **注意:** 参加者の追加・変更はプログラムからは**不可能**。CalDAV / Exchange サーバーとの同期経由でのみ設定される。

### 3.7 バーチャル会議プロバイダー（iOS 15+）

ビデオ会議アプリがカレンダーのロケーションピッカーに統合できる。

```swift
class MyConferenceProvider: EKVirtualConferenceProvider {
    override func fetchAvailableRoomTypes() async throws
        -> [EKVirtualConferenceRoomTypeDescriptor] {
        return [
            EKVirtualConferenceRoomTypeDescriptor(
                title: "スタンダードルーム",
                identifier: "standard"
            )
        ]
    }

    override func fetchVirtualConference(
        identifier: EKVirtualConferenceRoomTypeIdentifier
    ) async throws -> EKVirtualConferenceDescriptor {
        let url = EKVirtualConferenceURLDescriptor(
            title: "会議に参加",
            url: URL(string: "https://example.com/join/12345")!
        )
        return EKVirtualConferenceDescriptor(
            title: "My App ミーティング",
            urlDescriptors: [url],
            conferenceDetails: "会議コード: 12345"
        )
    }
}
```

### 3.8 データベース変更の監視

```swift
// カレンダーデータベースの変更通知を監視
NotificationCenter.default.addObserver(
    self,
    selector: #selector(storeChanged),
    name: .EKEventStoreChanged,
    object: store
)

@objc func storeChanged() {
    // 保持しているイベント/リマインダーの情報が無効になった可能性がある
    // refresh() で再取得するか、データを再読み込みする
    event.refresh()
}
```

---

## 4. プライバシーとアクセス許可

### iOS 17+ のアクセスレベル体系

iOS 17 でアクセス許可モデルが大幅に改定された。

| レベル | 説明 | Info.plist キー |
|---|---|---|
| **アクセスなし** | EventKitUI を通じてイベント追加のみ。権限不要 | なし |
| **書き込み専用（Write-Only）** | イベントの追加・変更のみ。既存イベントの読み取り不可 | `NSCalendarsWriteOnlyAccessUsageDescription` |
| **フルアクセス** | 読み書き・削除・カレンダー管理すべて可能 | `NSCalendarsFullAccessUsageDescription` |

#### リマインダーのアクセス

| レベル | Info.plist キー |
|---|---|
| **フルアクセス** | `NSRemindersFullAccessUsageDescription` |

#### 認可フロー（iOS 17+）

```swift
let store = EKEventStore()

// カレンダー：フルアクセス
do {
    let granted = try await store.requestFullAccessToEvents()
    if granted {
        // アクセス許可済み
    }
} catch {
    // エラー処理
}

// カレンダー：書き込み専用
do {
    let granted = try await store.requestWriteOnlyAccessToEvents()
    if granted {
        // 書き込みのみ許可
    }
} catch {
    // エラー処理
}

// リマインダー：フルアクセス
do {
    let granted = try await store.requestFullAccessToReminders()
    if granted {
        // アクセス許可済み
    }
} catch {
    // エラー処理
}
```

#### 認可ステータスの確認

```swift
let status = EKEventStore.authorizationStatus(for: .event)
switch status {
case .notDetermined:
    // まだ権限リクエストしていない
    break
case .restricted:
    // システムにより制限されている（ペアレンタルコントロール等）
    break
case .denied:
    // ユーザーが拒否した
    break
case .fullAccess:
    // フルアクセス許可済み（iOS 17+）
    break
case .writeOnly:
    // 書き込み専用アクセス（iOS 17+）
    break
case .authorized:
    // レガシー：フルアクセス許可（iOS 16以前）
    break
@unknown default:
    break
}
```

#### レガシー対応（iOS 16 以前との互換性）

```swift
if #available(iOS 17.0, *) {
    let granted = try await store.requestFullAccessToEvents()
} else {
    let granted = try await store.requestAccess(to: .event)
}
```

**Info.plist に追加すべきキー（前方・後方互換性）:**
- `NSCalendarsFullAccessUsageDescription` — iOS 17+
- `NSCalendarsUsageDescription` — iOS 16 以前のフォールバック
- `NSRemindersFullAccessUsageDescription` — iOS 17+
- `NSRemindersUsageDescription` — iOS 16 以前のフォールバック
- `NSContactsUsageDescription` — EventKitUI が連絡先アクセスを要求するため

### iOS 17+ : EventKitUI は別プロセスで実行

`EKEventEditViewController` は iOS 17 以降、**別プロセス（out-of-process）** で実行される。これにより：
- **カレンダーアクセス権限なしで** イベント作成 UI を表示可能
- ユーザーのプライバシー保護が大幅に向上
- 推奨パターン：まず EventKitUI を試み、カスタム UI が必要な場合のみ直接 API を使用

---

## 5. EventKitUI の詳細

### EKEventEditViewController（イベント編集画面）

```swift
import EventKitUI

let store = EKEventStore()

// 事前にイベント情報を埋めておくことで、ユーザーの入力を軽減
let event = EKEvent(eventStore: store)
event.title = "WWDC 2026 キーノート"
event.startDate = keynoteDate
event.endDate = Calendar.current.date(byAdding: .hour, value: 2, to: keynoteDate)!
event.timeZone = TimeZone(identifier: "America/Los_Angeles")
event.location = "1 Apple Park Way, Cupertino, CA"
event.notes = "Apple の年次開発者カンファレンス"

let editVC = EKEventEditViewController()
editVC.event = event
editVC.eventStore = store
editVC.editViewDelegate = self

present(editVC, animated: true)
```

```swift
// デリゲート
extension ViewController: EKEventEditViewDelegate {
    func eventEditViewController(
        _ controller: EKEventEditViewController,
        didCompleteWith action: EKEventEditViewAction
    ) {
        switch action {
        case .saved:
            print("イベントが保存されました")
        case .canceled:
            print("キャンセルされました")
        case .deleted:
            print("イベントが削除されました")
        @unknown default:
            break
        }
        dismiss(animated: true)
    }
}
```

### EKEventViewController（イベント詳細表示）

```swift
let eventVC = EKEventViewController()
eventVC.event = event
eventVC.allowsEditing = true
eventVC.allowsCalendarPreview = true

navigationController?.pushViewController(eventVC, animated: true)
```

### EKCalendarChooser（カレンダー選択画面）

```swift
let chooser = EKCalendarChooser(
    selectionStyle: .multiple,  // .single or .multiple
    displayStyle: .allCalendars, // .allCalendars or .writableCalendarsOnly
    entityType: .event,
    eventStore: store
)
chooser.showsDoneButton = true
chooser.showsCancelButton = true
chooser.delegate = self

let navController = UINavigationController(rootViewController: chooser)
present(navController, animated: true)
```

### Siri Event Suggestions（権限不要）

予約系のイベント（レストラン、フライト、ホテル等）は Siri Event Suggestions を使ってカレンダーに提案できる。ユーザーのカレンダーに直接書き込まず、受信ボックスに招待として表示される。

```swift
import Intents

let reservationReference = INSpeakableString(
    vocabularyIdentifier: "unique-reservation-id",
    spokenPhrase: "カフェ Macs でのランチ"
)

let reservation = INRestaurantReservation(
    itemReference: reservationReference,
    reservationStatus: .confirmed,
    reservationHolderName: "田中太郎",
    reservationDuration: INDateComponentsRange(
        start: startComponents,
        end: endComponents
    ),
    restaurantLocation: restaurantLocation
)

let intent = INGetReservationDetailsIntent(
    reservationContainerReference: reservationReference
)
let response = INGetReservationDetailsIntentResponse(
    code: .success,
    userActivity: nil
)
response.reservations = [reservation]

let interaction = INInteraction(intent: intent, response: response)
interaction.donate()
```

---

## 6. 制限事項と注意点

### 技術的制限

| 制限 | 詳細 |
|---|---|
| **参加者の追加不可** | `EKParticipant` は読み取り専用。プログラムから招待者を追加することはできない |
| **繰り返しルールは1つのみ** | 1つのイベントに設定できる `EKRecurrenceRule` は実質1つ。追加すると既存のルールが置き換わる |
| **EKEventStore の初期化コスト** | 初期化は重い処理。アプリ全体で1インスタンスを共有すべき |
| **日付範囲の制限** | イベント検索は最短の日付範囲を使うべき（パフォーマンス上の理由） |
| **バックグラウンド制限** | バックグラウンドでのカレンダーアクセスには制限がある |
| **書き込み専用の制限** | 書き込み専用アクセスでは、自アプリが追加したイベントすら読み取れない |

### iOS 18 の既知の問題

- iOS 18.4 以降、イベントのカレンダーを別アカウントのカレンダーに変更して保存すると "Access denied" エラーが発生するバグが報告されている
- iOS 18 アップデート後にカレンダーイベントが消える問題が一部で報告

### ベストプラクティス

1. **最小限のアクセス権限を要求する** — EventKitUI で済むならフルアクセスは不要
2. **`EKEventStoreChanged` 通知を監視する** — 外部でデータが変更される可能性がある
3. **DateComponents と Calendar を使う** — タイムゾーン安全な日付計算を行う
4. **エラーハンドリングを適切に行う** — 権限拒否やデータアクセスエラーに備える
5. **パフォーマンス** — イベント検索は最短の日付範囲で行い、必要なカレンダーのみ指定する

---

## 7. 他フレームワークとの連携

| 連携先 | 連携内容 |
|---|---|
| **EventKitUI** | システム標準のイベント編集・表示 UI を利用。iOS 17+ では権限不要で利用可能 |
| **SiriKit / Intents** | Siri Event Suggestions でカレンダーに予約を提案。音声でのイベント操作 |
| **App Intents** | iOS 16+ のショートカット・Siri・Spotlight 連携。カレンダー操作をシステム全体から呼び出し可能に |
| **WidgetKit** | 今日のスケジュールやリマインダーをウィジェットに表示 |
| **MapKit / CoreLocation** | 位置ベースのリマインダーやアラーム（ジオフェンス）の設定 |
| **CloudKit** | iCloud 経由でのカレンダーデータ同期（システムが自動管理） |
| **WatchKit** | Apple Watch でのカレンダー・リマインダー表示 |
| **UserNotifications** | EKAlarm はローカル通知としてシステムから配信される |
| **Universal Links** | バーチャル会議プロバイダーからのディープリンク |

---

## 8. iOS バージョン別の主要変更点

### iOS 6
- リマインダー API の追加（`EKReminder`）
- `EKEventStore` の権限モデル導入

### iOS 9
- `EKStructuredLocation` によるジオフェンスアラーム

### iOS 15
- `EKVirtualConferenceProvider` — バーチャル会議プロバイダー API の追加

### iOS 16
- EventKit / EventKitUI の一部変更
- Contacts アクセスの暗黙的要求が明示的になった

### iOS 17（大幅改定）
- **アクセスレベルの刷新**: フルアクセス / 書き込み専用 / アクセスなしの3段階
- **新しい認可メソッド**: `requestFullAccessToEvents()`, `requestWriteOnlyAccessToEvents()`, `requestFullAccessToReminders()`
- **EKEventEditViewController の別プロセス化**: 権限なしでイベント作成 UI を表示可能
- **新しい Info.plist キー**: `NSCalendarsFullAccessUsageDescription`, `NSCalendarsWriteOnlyAccessUsageDescription`, `NSRemindersFullAccessUsageDescription`
- **認可ステータスの追加**: `.fullAccess`, `.writeOnly`

### iOS 18
- リマインダーがカレンダーアプリ内にインライン表示されるようになった（ユーザー向け機能）
- EventKit API 自体への大きな変更はなし

---

## 9. EventKit を活用した面白い iOS アプリのアイデア

### アイデア 1: 「TimeMap」— 時空間スケジュールマップ

**コンセプト:** カレンダーイベントを地図上に時系列で可視化し、移動ルートと「空き時間 × 現在地周辺のスポット」を自動提案するアプリ。

**仕組み:**
- EventKit でユーザーの予定を取得し、各イベントの場所情報を MapKit で地図にプロット
- イベント間の移動時間を MapKit の経路検索で自動計算
- 空き時間と現在地から「カフェで30分休憩」「近くのジムで1時間トレーニング」等のアクティビティを提案
- 提案を選択すると EventKit で仮イベントをカレンダーに追加

**活用する EventKit 機能:**
- `EKEvent` の location / structuredLocation からの座標取得
- 日付範囲でのイベント検索
- イベントの自動作成

**差別化ポイント:** 既存のカレンダーアプリは時間軸のみでスケジュールを表示するが、「場所」という次元を加えることで移動のムダや空き時間の活用機会を直感的に把握できる。

---

### アイデア 2: 「HabitWeave」— 習慣をカレンダーに織り込むトラッカー

**コンセプト:** 習慣トラッキングとカレンダーを深く統合し、既存の予定の「隙間」に習慣タスクを自動配置するアプリ。

**仕組み:**
- ユーザーが「毎日30分読書」「週3回ジョギング」等の習慣目標を設定
- EventKit でカレンダーの空き時間を分析し、最適な時間枠を自動算出
- `EKReminder` として習慣タスクを作成し、位置ベースアラーム（ジオフェンス）と組み合わせ
  - 例: 「自宅に到着したらストレッチ」のリマインダー
- 繰り返しルール（`EKRecurrenceRule`）で定期タスクを設定
- 完了/未完了を `EKReminder.isCompleted` で追跡し、達成率を可視化

**活用する EventKit 機能:**
- カレンダーイベントの読み取りによる空き時間分析
- `EKReminder` の作成・完了追跡
- `EKRecurrenceRule` による繰り返し設定
- `EKStructuredLocation` + `EKAlarm` によるジオフェンストリガー

**差別化ポイント:** 一般的な習慣トラッカーは独自のスケジュール管理をするが、このアプリは既存のカレンダーデータを活用して「現実のスケジュールに基づいた実行可能な習慣計画」を自動生成する。

---

### アイデア 3: 「MeetingLens」— 会議コスト可視化＆最適化ツール

**コンセプト:** カレンダーの会議データを分析し、「会議のコスト」を金額換算で可視化。会議の最適化を提案するアプリ。

**仕組み:**
- EventKit で全会議イベントを取得し、以下を分析:
  - 週/月あたりの会議時間
  - 参加者数（`EKParticipant`）× 推定時給で「会議コスト」を算出
  - 繰り返し会議の累計コスト
  - 会議が集中している時間帯のヒートマップ
- 「ディープワーク可能な連続空き時間」をスコアリング
- 会議のパターン分析に基づき最適化提案:
  - 「この30分会議を15分に短縮すると月X時間節約」
  - 「火曜日午前を会議ゼロにすると3時間のディープワークブロックが生まれる」
- WidgetKit で「今日の会議コスト」「今週のディープワークスコア」を表示

**活用する EventKit 機能:**
- `EKEvent` の参加者情報（`attendees`）の読み取り
- 繰り返しイベントの検出と分析
- 日付範囲検索による大量イベントの集計

**差別化ポイント:** 「時間は有限のリソースである」という発想に基づき、会議を金銭的コストとして可視化することで、組織の会議文化改善を促す。

---

### アイデア 4: 「LifeRewind」— カレンダーベースのライフログ＆回顧録

**コンセプト:** 過去のカレンダーデータを「人生の振り返り」として美しく可視化するアプリ。

**仕組み:**
- EventKit で過去数年のイベントデータを取得（ユーザー許可のもと）
- データを分析して以下を生成:
  - 年間サマリー:「2025年は 342 件のイベント、最も忙しかったのは7月」
  - カテゴリ別の時間配分（仕事/プライベート/健康 等、カレンダー色で分類）
  - よく訪れた場所のランキング（location データから）
  - 「人生のタイムライン」— 主要イベントを時系列で美しくレイアウト
- 過去の同じ日に何をしていたか「On This Day」通知
- 将来の目標に対して「このペースだと年間X時間を趣味に使える」等のインサイト

**活用する EventKit 機能:**
- 広範な日付範囲でのイベント取得
- カレンダー（`EKCalendar`）のカテゴリ・色情報の活用
- ロケーションデータの集計・分析

**差別化ポイント:** 写真アプリの「○年前の今日」機能のカレンダー版。自分の行動パターンを振り返ることで、時間の使い方への意識を高める。

---

### アイデア 5: 「SyncLife」— マルチカレンダー調整＆ファミリーコーディネーター

**コンセプト:** 家族やチームメンバーのカレンダーを統合分析し、全員の空き時間を自動検出してイベントを提案するアプリ。

**仕組み:**
- 各ユーザーが EventKit 経由で自分のカレンダーを共有（iCloud 共有カレンダー活用）
- 複数カレンダーの空き時間を重ね合わせて可視化
- 「家族全員が空いている週末の午後」を自動検出
- イベント提案を選択すると、EventKitUI の `EKEventEditViewController` で全員のカレンダーに追加
- リマインダー共有リスト（`EKCalendar` for reminders）で買い物リストや準備タスクを共有
- 位置ベースの通知:「お父さんが駅に到着」→「夕食の準備を始めましょう」

**活用する EventKit 機能:**
- 複数カレンダーの横断検索
- `EKCalendar` の共有設定の活用
- `EKEventEditViewController`（権限最小化）
- `EKReminder` の共有リスト
- `EKStructuredLocation` による位置ベーストリガー

**差別化ポイント:** 家族間のスケジュール調整という日常的な「面倒ごと」を自動化し、「一緒に過ごす時間」を最大化するアプローチ。

---

### アプリアイデア比較

| アイデア | 技術難易度 | EventKit 活用度 | 市場性 | ユニークさ |
|---|---|---|---|---|
| TimeMap（時空間マップ） | ★★★★ | ★★★★ | ★★★★ | ★★★★★ |
| HabitWeave（習慣織り込み） | ★★★ | ★★★★★ | ★★★★★ | ★★★★ |
| MeetingLens（会議コスト） | ★★★ | ★★★★ | ★★★★ | ★★★★ |
| LifeRewind（ライフログ） | ★★★ | ★★★ | ★★★★ | ★★★★★ |
| SyncLife（ファミリー調整） | ★★★★★ | ★★★★★ | ★★★★★ | ★★★ |

---

## 10. 参考資料

- [EventKit | Apple Developer Documentation](https://developer.apple.com/documentation/eventkit)
- [EventKit UI | Apple Developer Documentation](https://developer.apple.com/documentation/EventKitUI)
- [TN3152: Migrating to the latest Calendar access levels](https://developer.apple.com/documentation/technotes/tn3152-migrating-to-the-latest-calendar-access-levels)
- [TN3153: Adopting API changes for EventKit in iOS 17](https://developer.apple.com/documentation/technotes/tn3153-adopting-api-changes-for-eventkit-in-ios-macos-and-watchos)
- [WWDC23: Discover Calendar and EventKit](https://developer.apple.com/videos/play/wwdc2023/10052/)
- [Accessing Calendar using EventKit and EventKitUI](https://developer.apple.com/documentation/EventKit/accessing-calendar-using-eventkit-and-eventkitui)
- [Creating events and reminders](https://developer.apple.com/documentation/eventkit/creating-events-and-reminders)
- [Retrieving events and reminders](https://developer.apple.com/documentation/eventkit/retrieving-events-and-reminders)
