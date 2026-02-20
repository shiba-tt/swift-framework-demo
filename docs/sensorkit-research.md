# SensorKit フレームワーク 調査レポート

## 1. SensorKit とは

SensorKit は Apple が iOS 14（WWDC20）で導入したフレームワークで、iPhone および Apple Watch のセンサーから**詳細な行動・環境データ**を取得できる。一般のアプリ開発者には開放されておらず、**Apple が承認した研究目的のアプリのみ**が利用可能な特殊なフレームワークである。

「デジタルフェノタイピング（Digital Phenotyping）」— スマートフォンのセンサーデータから人の行動パターンを分析する手法 — を iOS 上で実現するための Apple 公式ツール。

**核心コンセプト:** 「研究者向けに、iPhone/Apple Watch のセンサーから行動・環境データを高精度で収集し、メンタルヘルスや神経疾患等の研究に活用」

### 他のセンサー関連フレームワークとの比較

| フレームワーク | 目的 | アクセス制限 | データの種類 |
|---|---|---|---|
| **SensorKit** | 研究用データ収集 | Apple 承認 + IRB 必須 | 行動パターン、環境、デバイス使用状況 |
| **CoreMotion** | 一般アプリの動作検出 | なし（パーミッション要） | 加速度、ジャイロ、歩数、高度 |
| **HealthKit** | 健康データの読み書き | なし（パーミッション要） | 心拍数、睡眠、歩数等 |
| **CoreLocation** | 位置情報 | なし（パーミッション要） | GPS座標、ジオフェンス |
| **ARKit** | AR 体験 | なし | カメラ、深度、モーション |

**SensorKit の特異性:** CoreMotion や HealthKit では取得できない**キーボード入力パターン**、**メッセージ使用量**、**デバイス使用レポート**、**訪問場所カテゴリ**等の「行動メタデータ」にアクセスできる点が最大の差別化要素。

---

## 2. アクセス要件（厳格な承認プロセス）

SensorKit は一般のアプリ開発者が自由に使えるフレームワークではない。以下の多段階承認が必須。

### 2.1 承認フロー

```
┌─────────────────────────┐
│  1. 研究プロポーザル作成    │
│     研究目的・対象データ等  │
└─────────┬───────────────┘
          ↓
┌─────────────────────────┐
│  2. Apple に申請           │
│  sensorkitrequest@apple.com│
│  → Apple がレビュー        │
└─────────┬───────────────┘
          ↓
┌─────────────────────────┐
│  3. 開発用エンタイトルメント取得│
│  com.apple.developer.     │
│  sensorkit.reader.allow    │
└─────────┬───────────────┘
          ↓
┌─────────────────────────┐
│  4. IRB（倫理審査委員会）承認 │
│  研究倫理の審査              │
└─────────┬───────────────┘
          ↓
┌─────────────────────────┐
│  5. 配布用エンタイトルメント取得│
│  → App Store 配布可能に     │
└─────────┬───────────────┘
          ↓
┌─────────────────────────┐
│  6. App Store レビュー      │
│  通常の審査プロセス          │
└─────────────────────────┘
```

### 2.2 必要な要件まとめ

| 要件 | 詳細 |
|---|---|
| **研究プロポーザル** | Apple に研究目的・データ収集計画を提出 |
| **Apple 承認** | sensorkitrequest@apple.com に申請。標準基準でレビュー |
| **開発用エンタイトルメント** | 承認後に取得。開発・テスト用 |
| **IRB（倫理審査）承認** | 研究機関の倫理審査委員会の承認が必須 |
| **配布用エンタイトルメント** | IRB 承認後に取得。参加者への配布用 |
| **参加者の同意** | 各センサーに対する個別の同意が必要 |
| **App Store レビュー** | 通常の審査プロセスも通過が必要 |
| **Info.plist 記載** | `NSSensorKitUsageDetail` に収集データの詳細を記載 |

### 2.3 Apple Investigator Support Program

Apple は研究者支援プログラムを提供しており、研究に使用する Apple デバイスの提供やアプリ開発リソースへのアクセスが可能。

---

## 3. 利用可能なセンサー一覧

### 3.1 全センサータイプ

| SRSensor | データタイプ | 対応デバイス | 追加 OS |
|---|---|---|---|
| `.accelerometer` | 3 軸加速度 | iPhone / Apple Watch | iOS 14+ |
| `.rotationRate` | 3 軸回転速度（ジャイロ） | iPhone / Apple Watch | iOS 14+ |
| `.ambientLightSensor` | 環境光（照度・色温度） | iPhone | iOS 14+ |
| `.keyboardMetrics` | キーボード入力パターン | iPhone | iOS 14+ |
| `.deviceUsageReport` | デバイス使用レポート | iPhone | iOS 14+ |
| `.phoneUsageReport` | 電話使用レポート | iPhone | iOS 14+ |
| `.messagesUsageReport` | メッセージ使用レポート | iPhone | iOS 14+ |
| `.visits` | 訪問場所情報 | iPhone | iOS 14+ |
| `.pedometerData` | 歩数データ | iPhone / Apple Watch | iOS 14+ |
| `.onWristState` | 手首装着状態 | Apple Watch | iOS 14+ |
| `.mediaEvents` | メディア再生イベント | iPhone | iOS 16.4+ |

### 3.2 各センサーの詳細

#### 環境光センサー (`.ambientLightSensor`) — `SRAmbientLightSample`

ユーザーの周囲の光環境を計測。

| プロパティ | 型 | 説明 |
|---|---|---|
| `lux` | `Measurement<UnitIlluminance>` | 照度（ルクス値） |
| `chromaticity` | `SRAmbientLightSample.Chromaticity` | 色度座標（光の色味・明るさ） |
| `placement` | `SRAmbientLightSample.SensorPlacement` | センサーに対する光源の位置 |

**研究での活用:** 睡眠環境の光量評価、昼夜リズムの分析、季節性感情障害（SAD）との相関研究

---

#### キーボードメトリクス (`.keyboardMetrics`) — `SRKeyboardMetrics`

ユーザーのタイピングパターンを詳細に記録。**SensorKit の最もユニークなデータソース**の一つ。

| プロパティカテゴリ | 説明 |
|---|---|
| **タイピング速度** | キーストローク間の時間間隔 |
| **単語長** | 入力された単語の長さ分布 |
| **エラー率** | タイピング中の誤入力・修正の頻度 |
| **感情分析** | `SRKeyboardMetrics.SentimentCategory` — 入力テキストから推定されるムード |
| **タッチパターン** | キー押下の力・タイミング |

**研究での活用:**
- **うつ病検出:** タイピング速度の低下、エラー率の増加がうつ症状と相関
- **パーキンソン病早期発見:** 微細な振戦がキーストロークパターンに現れる
- **ストレスレベル推定:** キーストロークのタイミング特徴からストレスを推定
- **認知機能低下の検出:** アルツハイマー病、認知症の早期兆候

---

#### デバイス使用レポート (`.deviceUsageReport`) — `SRDeviceUsageReport`

iPhone の使用パターンを包括的に記録。

| プロパティ | 型 | 説明 |
|---|---|---|
| `duration` | `TimeInterval` | レポート対象期間 |
| `totalScreenWakes` | `Int` | 画面起動回数 |
| `totalUnlocks` | `Int` | デバイスアンロック回数 |
| `totalUnlockDuration` | `TimeInterval` | アンロック状態の合計時間 |
| `applicationUsageByCategory` | `[SRDeviceUsageReport.CategoryKey: [SRDeviceUsageReport.ApplicationUsage]]` | アプリカテゴリ別使用状況 |
| `notificationUsage` | `[SRDeviceUsageReport.NotificationUsage]` | 通知インタラクション |
| `webUsageByCategory` | `[SRDeviceUsageReport.CategoryKey: [SRDeviceUsageReport.WebUsage]]` | ウェブ閲覧カテゴリ別使用状況 |

**研究での活用:**
- 画面使用時間とメンタルヘルスの関係分析
- SNS 使用量と不安レベルの相関
- 通知への反応パターンから注意力の評価
- 既存のデジタルフェノタイピングアプリをはるかに超える詳細度

---

#### 電話使用レポート (`.phoneUsageReport`) — `SRPhoneUsageReport`

| プロパティ | 型 | 説明 |
|---|---|---|
| `duration` | `TimeInterval` | レポート対象期間 |
| `totalOutgoingCalls` | `Int` | 発信回数 |
| `totalIncomingCalls` | `Int` | 着信回数 |
| `totalPhoneCallDuration` | `TimeInterval` | 通話合計時間 |

---

#### メッセージ使用レポート (`.messagesUsageReport`) — `SRMessagesUsageReport`

| プロパティ | 型 | 説明 |
|---|---|---|
| `duration` | `TimeInterval` | レポート対象期間 |
| `totalIncomingMessages` | `Int` | 受信メッセージ数 |
| `totalOutgoingMessages` | `Int` | 送信メッセージ数 |

**プライバシー:** メッセージの内容は取得されない。送受信数と送信者/受信者の匿名化された一意識別子のみ。

---

#### 訪問場所 (`.visits`) — `SRVisit`

| プロパティ | 型 | 説明 |
|---|---|---|
| `distanceFromHome` | `CLLocationDistance` | 自宅からの距離 |
| `arrivalDateInterval` | `DateInterval` | 到着日時 |
| `departureDateInterval` | `DateInterval` | 出発日時 |
| `locationCategory` | `SRVisit.LocationCategory` | 場所のカテゴリ |

**LocationCategory の値:**
- `.home` — 自宅
- `.work` — 職場
- `.school` — 学校
- `.gym` — ジム
- その他のカテゴリ

**プライバシー重視設計:** GPS 座標は一切含まれない。各場所にはランダム識別子が割り当てられ、自宅からの距離と場所カテゴリのみ提供される。

---

#### 加速度計 (`.accelerometer`) / 回転速度 (`.rotationRate`)

CoreMotion で取得可能なデータと同等だが、SensorKit ではバックグラウンドでの長時間連続記録が可能。

---

#### 手首装着状態 (`.onWristState`) — Apple Watch

Apple Watch が手首に装着されている時間と向きを記録。睡眠パターンやデバイス使用習慣の研究に活用。

---

#### メディアイベント (`.mediaEvents`) — iOS 16.4+

音楽やポッドキャスト等のメディア再生イベントを記録。

---

## 4. API の詳細

### 4.1 SRSensorReader（中心的な API）

```swift
import SensorKit

class SensorManager: NSObject, SRSensorReaderDelegate {
    let ambientLightReader = SRSensorReader(sensor: .ambientLightSensor)
    let keyboardReader = SRSensorReader(sensor: .keyboardMetrics)
    let deviceUsageReader = SRSensorReader(sensor: .deviceUsageReport)

    func setup() {
        ambientLightReader.delegate = self
        keyboardReader.delegate = self
        deviceUsageReader.delegate = self
    }

    // 1. 認可リクエスト
    func requestAuthorization() {
        SRSensorReader.requestAuthorization(sensors: [
            .ambientLightSensor,
            .keyboardMetrics,
            .deviceUsageReport,
            .phoneUsageReport,
            .messagesUsageReport,
            .visits,
            .accelerometer
        ]) { error in
            if let error = error {
                print("認可エラー: \(error)")
            }
            // → Apple Research Permissions 画面がユーザーに表示される
        }
    }

    // 2. 記録開始
    func startRecording() {
        ambientLightReader.startRecording()
        keyboardReader.startRecording()
        deviceUsageReader.startRecording()
    }

    // 3. データ取得
    func fetchData() {
        let now = Date()
        let yesterday = now.addingTimeInterval(-86400)
        let request = SRFetchRequest()
        request.from = SRAbsoluteTime(yesterday.timeIntervalSinceReferenceDate)
        request.to = SRAbsoluteTime(now.timeIntervalSinceReferenceDate)

        ambientLightReader.fetch(request)
    }

    // 4. Delegate — データ受信
    func sensorReader(_ reader: SRSensorReader,
                      fetching fetchRequest: SRFetchRequest,
                      didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        switch reader.sensor {
        case .ambientLightSensor:
            if let sample = result.sample as? SRAmbientLightSample {
                let lux = sample.lux.converted(to: .lux).value
                print("照度: \(lux) lux")
            }
        case .keyboardMetrics:
            if let metrics = result.sample as? SRKeyboardMetrics {
                // キーボードメトリクスの処理
                print("キーボードデータ取得")
            }
        default:
            break
        }
        return true // true = 次の結果も受信する
    }

    // 5. 認可状態変更
    func sensorReader(_ reader: SRSensorReader,
                      didChange authorizationStatus: SRAuthorizationStatus) {
        switch authorizationStatus {
        case .authorized:
            print("\(reader.sensor) が認可されました")
        case .notDetermined:
            print("未決定")
        case .denied:
            print("拒否されました")
        @unknown default:
            break
        }
    }
}
```

### 4.2 セッションワークフロー

```
1. SRSensorReader 作成（各センサーごとに 1 つ）
      ↓
2. SRSensorReader.requestAuthorization() で認可リクエスト
   → Apple Research Permissions 画面がユーザーに表示
   → ユーザーが各センサーを個別に許可/拒否
      ↓
3. startRecording() で記録開始
      ↓
4. データは端末上に蓄積される（24 時間のホールディング期間あり）
      ↓
5. SRFetchRequest でデータ取得
      ↓
6. SRSensorReaderDelegate でデータ処理
```

### 4.3 重要な制約

| 制約 | 詳細 |
|---|---|
| **24 時間ホールディング期間** | 収集されたデータは 24 時間経過後に初めてアクセス可能 |
| **スレッドセーフではない** | 複数の SRSensorReader を同時に並行読み取りしてはいけない |
| **過去データ取得不可** | SensorKit は遡及的なデータ収集をサポートしない。記録開始後のデータのみ |
| **大量データ** | 1 参加者あたり 1 日数 GB の非圧縮データが生成される場合がある |
| **デバイス互換性** | SensorKit dylib がインストールされていないデバイスではクラッシュする |

### 4.4 バックグラウンド処理（iOS 17.1+）

```swift
// BGHealthResearchTask エンタイトルメント
// → バックグラウンドで HealthKit / SensorKit / Bluetooth デバイスデータの処理が可能
```

`BGHealthResearchTask` エンタイトルメントにより、アプリがバックグラウンドでも SensorKit データの処理を実行可能（iOS 17.1 以降）。

---

## 5. プライバシーとデータ設計

SensorKit は Apple のプライバシーファーストの思想に基づいて設計されている。

### 5.1 プライバシー保護メカニズム

| メカニズム | 詳細 |
|---|---|
| **Opt-in のみ** | ユーザーが各センサーを個別に許可する必要がある |
| **GPS 座標なし** | Visits データは GPS 座標を含まない。自宅からの距離とカテゴリのみ |
| **メッセージ内容なし** | メッセージの本文は取得されない。送受信数と匿名 ID のみ |
| **通話内容なし** | 通話の内容は取得されない。回数と時間のみ |
| **アプリ名の匿名化** | デバイス使用レポートではアプリカテゴリのみ。個別アプリ名は含まれない場合がある |
| **端末上処理** | 訪問場所の分類はデバイス上で行われ、生の位置データは送信されない |
| **24 時間遅延** | ホールディング期間によりリアルタイム監視を防止 |

### 5.2 研究倫理の要件

- 参加者の同意書に収集する全データタイプを明記する必要がある
- アプリがSensorKit データをどのように使用するかを参加者に明確に開示
- 各センサーは個別のパーミッションを要求するため、一部のセンサーのみ許可される場合がある

---

## 6. 実際の研究事例

### 6.1 メンタルヘルス研究（mindLAMP / Beth Israel Deaconess Medical Center）

オープンソースの mindLAMP アプリを使用し、うつ病患者から 1 週間の SensorKit データを収集した研究（2023年、Digital Biomarkers 誌）。

**使用センサー:** 電話使用、メッセージ使用、訪問場所、デバイス使用、環境光

**主な知見:**
- デバイス使用レポートは既存のデジタルフェノタイピングアプリをはるかに超える詳細度を提供
- ウェブサイトやアプリのカテゴリ情報が、スクリーンタイムに文脈的な豊かさを追加
- SNS 使用量と不安レベルの関係を調査可能
- メッセージ活動と時間的な不安レベルの関係を調査可能
- 環境光とメッセージ使用は完全に新しいセンサーデータ
- SensorKit メトリクスを機械学習モデルに組み込み、統合失調症の再発リスク予測に応用

### 6.2 Digital Mental Health Study（DMHS）— 大規模研究（2025年）

**規模:** 4,000人以上の参加者、最大 12 ヶ月間のデータ収集

**特徴:**
- HealthKit と SensorKit の両方を活用
- 年齢、性別、民族性、うつ症状の重症度で多様なサンプル
- プライバシー保護: 生の GPS 座標は送信されず、デバイス上で場所分類
- デジタルフェノタイピング分野で最大規模の研究の一つ

### 6.3 キーストロークダイナミクスによる疾患検出

**パーキンソン病:** ドーパミン欠乏による微細な振戦がタイピングパターンに影響。初期段階での微細な運動能力変化がキーストロークに反映される。

**うつ病:** 精神運動遅滞がタイピング速度の低下、エラー率の増加として現れる。300人以上を対象とした研究で有望な結果。

**ストレス:** 46 人の参加者からストレス/平穏の 2 状態を収集。タイピングリズムの変化からストレスレベルを推定。

---

## 7. iOS アプリ活用アイデア

> **注意:** SensorKit は研究目的のみに利用可能であり、以下のアイデアはすべて研究アプリとしての承認が前提です。

### アイデア 1: 「MindMirror — 日常行動からメンタルヘルスを見守る研究アプリ」

**コンセプト:** SensorKit の全センサーを統合的に活用し、ユーザーの日常行動パターンからメンタルヘルスの変化を検出する「デジタルメンタルヘルスミラー」。従来の自己申告式アンケートに頼らず、パッシブセンシングで客観的なメンタルヘルス指標を生成。

```
センサーデータ統合フロー:

┌─────────────────────────────────────────────────┐
│  iPhone 上でパッシブに収集                         │
│                                                   │
│  📱 デバイス使用 ──→ スクリーンタイム・SNS使用量    │
│  ⌨️ キーボード ────→ タイピング速度・エラー率・感情  │
│  📞 電話 ─────────→ 社会的つながりの頻度          │
│  💬 メッセージ ───→ コミュニケーション量の変化       │
│  📍 訪問場所 ────→ 行動範囲・外出頻度              │
│  💡 環境光 ──────→ 生活リズム（昼夜パターン）       │
│  🚶 加速度計 ────→ 身体活動量                     │
│  ⌚ 手首装着 ────→ 睡眠パターン                   │
└─────────────┬───────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────┐
│  統合分析エンジン                                   │
│                                                   │
│  行動パターン     正常          異常兆候            │
│  ────────────  ──────────  ──────────────         │
│  外出頻度        毎日 3 箇所    2 日間自宅のみ       │
│  タイピング速度   40 WPM       25 WPM（低下）       │
│  SNS 使用時間    1 時間/日     4 時間/日（増加）     │
│  メッセージ量     20 通/日      3 通/日（減少）       │
│  環境光パターン   規則的        不規則（昼夜逆転）     │
│  身体活動量      8,000 歩/日   2,000 歩/日（減少）   │
│                                                   │
│  → 複合指標: "メンタルヘルスリスクスコア" 算出        │
└─────────────┬───────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────┐
│  ユーザーへのフィードバック（アプリ内）               │
│                                                   │
│  📊 週間レポート: 行動パターンの可視化               │
│  ⚠️ 気づき通知:「外出頻度が普段より低下しています」   │
│  🩺 医療者連携: 研究チームへの匿名化データ共有        │
└─────────────────────────────────────────────────┘
```

**面白い点:**
- **6 つの独立したセンサー**を横断的に分析する「行動プロファイル」
- 1 つのセンサーだけでは見えない変化が、複数センサーの組み合わせで浮かび上がる
- キーボードの感情分析（`SentimentCategory`）と実際の行動変化の相関
- 24 時間ホールディング期間がプライバシーと同時に「非リアルタイム」の安全設計を提供
- 大規模研究（DMHS の 4,000 人級）への発展可能性

**技術構成:** SensorKit（全センサー） + HealthKit + CoreML（異常検知モデル） + ResearchKit

---

### アイデア 2: 「TypeGuard — タイピングで見つける神経疾患の兆候」

**コンセプト:** SRKeyboardMetrics に特化し、タイピングパターンの微細な変化からパーキンソン病や認知機能低下の早期兆候を検出する研究アプリ。ユーザーの「普段のタイピング」をベースラインとして学習し、変化を追跡。

```
タイピングバイオマーカー分析:

正常時:
  キー押下間隔:   ▁▂▁▂▁▂▁▂  (規則的)
  エラー率:       ▁▁▁▂▁▁▁▁  (低い)
  単語長分布:     ▃▇▅▃▁     (自然な分布)
  押下力分布:     ▃▆▇▆▃     (安定)

振戦の兆候:
  キー押下間隔:   ▁▅▂▇▁▆▂▄  (不規則)
  エラー率:       ▃▅▄▆▅▃▄▅  (増加)
  隣接キー誤入力: ▁▃▅▆▇▆▅▃  (増加)
  押下力分布:     ▁▆▂▇▁▅▃▇  (不安定)

認知機能低下の兆候:
  タイピング速度:  40 → 35 → 28 WPM（漸減）
  修正頻度:       増加傾向
  感情分析スコア:  変動の増大
```

**面白い点:**
- 毎日の自然なタイピング行為から受動的にデータ収集 — 追加の操作不要
- キーストロークダイナミクスによるパーキンソン病検出は学術的に実証されている
- SRKeyboardMetrics の `SentimentCategory` による感情変動も同時に追跡
- 長期間（数ヶ月〜年）のトレンド分析で緩やかな変化を検出
- 医師への「客観的データ」提供 — 「最近タイピングが遅くなった気がする」の数値化

**技術構成:** SensorKit（keyboardMetrics） + CoreML（時系列異常検知） + HealthKit + ResearchKit

---

### アイデア 3: 「LightLife — 光環境と生活リズムの関係を解明する研究」

**コンセプト:** 環境光センサー + 訪問場所 + デバイス使用を組み合わせ、ユーザーの光環境と生活リズム（概日リズム）の関係を研究するアプリ。季節性感情障害（SAD）や睡眠障害の予防研究に活用。

```
1日の光環境プロファイル:

時刻  0   3   6   9  12  15  18  21  24
      ┌─────────────────────────────────┐
 照度  │▁▁▁▁▁▃▅▇█▇▇▇█▇▅▃▁▁▃▂▁▁▁▁│ 正常
(lux) │▁▁▁▁▁▁▁▃▅▇▇▅▃▁▁▁▁▁▅▇▅▃▁▁│ 昼夜逆転
      └─────────────────────────────────┘

      ┌─────────────────────────────────┐
 場所  │🏠🏠🏠🏠🏠🚶🏢🏢🏢🏢🏢🏢🏢🏢🏢🚶🏋🚶🏠🏠🏠🏠🏠🏠│ 活動的
      │🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠🏠│ 引きこもり
      └─────────────────────────────────┘

      ┌─────────────────────────────────┐
 画面  │░░░░░░▓▓▓░░░▓▓▓░░░▓▓▓░░░│ 適度
使用  │▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ 過剰
      └─────────────────────────────────┘
```

**面白い点:**
- 環境光は SensorKit でしか取得できない完全に新しいデータストリーム
- 光量 × 訪問場所 × 画面使用の 3 軸で「生活の質」を多角的に評価
- 冬季の光量低下と行動パターン変化の相関を季節をまたいで追跡
- ウェアラブルデバイスなしで iPhone だけで環境光モニタリングが可能
- 色度（chromaticity）データでブルーライト曝露量も推定可能

**技術構成:** SensorKit（ambientLight + visits + deviceUsage） + HealthKit（睡眠データ） + SwiftUI Charts

---

### アイデア 4: 「SocialPulse — デジタル社会的つながりの健康指標」

**コンセプト:** 電話・メッセージ・訪問場所の 3 つのセンサーを組み合わせ、ユーザーの「社会的つながり」の量と質を定量化する研究アプリ。社会的孤立はうつ病・認知症の主要リスク因子であり、その客観的計測は医療上の大きな課題。

```
社会的つながりスコア:

┌─────────────────────────────────────────┐
│  📞 電話                                 │
│  発信: 3 回/日  着信: 5 回/日  通話: 45分  │
│  → 電話コミュニケーションスコア: 72/100    │
│                                          │
│  💬 メッセージ                             │
│  送信: 15 通/日  受信: 22 通/日            │
│  ユニーク相手数: 8 人                      │
│  → メッセージスコア: 85/100               │
│                                          │
│  📍 訪問場所                              │
│  外出場所数: 4 箇所  自宅外時間: 6.5 時間   │
│  カテゴリ: 職場, ジム, 買い物              │
│  → 行動範囲スコア: 68/100                 │
│                                          │
│  ─────────────────────                   │
│  総合 Social Pulse スコア: 75/100         │
│  先週比: +3 📈                            │
│  「社会的つながりは良好です」               │
└─────────────────────────────────────────┘
```

**面白い点:**
- 「社会的孤立」を客観的に計測できる — 本人の自覚がなくても変化を検出
- GPS 座標なしで「行動の多様性」を評価（プライバシー保護設計）
- 電話 + メッセージ + 訪問の 3 軸による「ソーシャルヘルス」の複合スコア
- 高齢者の見守り研究に直結（社会的孤立 → 認知症リスク）
- 縦断研究で個人のベースラインからの変化を追跡（個人内比較）

**技術構成:** SensorKit（phone + messages + visits） + HealthKit + ResearchKit + CareKit

---

### アイデア 5: 「ChronoSense — 24 時間の生体リズムを可視化する研究」

**コンセプト:** SensorKit の全センサーを 24 時間周期で統合分析し、ユーザーの概日リズム（サーカディアンリズム）を可視化する研究アプリ。各センサーデータを「時間の輪」として表現し、生活リズムの乱れを直感的に把握。

```
24 時間クロノグラフ:

              12:00 (正午)
               ┃
         ╱──────────╲
       ╱  💡 高照度    ╲
     ╱  🏢 職場         ╲
   ╱  ⌨️ 高タイピング速度  ╲
  ╱  📱 中程度の画面使用    ╲
 ┃  🚶 高い身体活動量       ┃
09:00 ╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍ 15:00
 ┃                         ┃
  ╲  📞 電話活発            ╱
   ╲  💬 メッセージ活発     ╱
     ╲  🌙 照度低下       ╱
       ╲  🏠 帰宅       ╱
         ╲──────────╱
               ┃
              00:00 (深夜)
         💤 睡眠 / 無活動

リズム整合度スコア: 82/100
「生体リズムは安定しています」
```

**面白い点:**
- SensorKit の 8 種類以上のセンサーすべてを 1 つの「時間の輪」に統合
- 概日リズムの乱れ（シフトワーカー、時差ボケ等）を客観的に可視化
- 各センサーのピーク時間のずれから「リズムの同期度」を算出
- 週間・月間のリズム変動トレンドで季節変動も追跡
- 睡眠研究、交代勤務研究、時差適応研究に直接応用可能

**技術構成:** SensorKit（全センサー） + HealthKit + CoreML + SwiftUI（カスタムクロノグラフ） + ResearchKit

---

## 8. まとめ

| 観点 | 評価 |
|---|---|
| **データの独自性** | ★★★★★ — キーボードメトリクス・メッセージ使用・環境光等、他フレームワークでは取得不可能なデータ |
| **精度・詳細度** | ★★★★★ — デバイス使用レポートは既存ツールをはるかに超える詳細度 |
| **プライバシー設計** | ★★★★★ — GPS なし・内容なし・24 時間遅延・端末上処理 |
| **アクセス制限** | ★☆☆☆☆ — Apple 承認 + IRB 必須。一般アプリ開発者には利用不可 |
| **開発体験** | ★★★☆☆ — API 自体はシンプルだが、承認プロセスが複雑。非スレッドセーフ |
| **研究価値** | ★★★★★ — メンタルヘルス・神経疾患・睡眠研究に革命的な可能性 |

### SensorKit が最も輝くパターン

1. **デジタルフェノタイピング** — パッシブセンシングで行動パターンを客観的に計測
2. **メンタルヘルス研究** — うつ病、不安障害、統合失調症の行動バイオマーカー
3. **神経疾患の早期発見** — キーストロークダイナミクスによるパーキンソン病・認知症検出
4. **概日リズム研究** — 環境光 + 活動 + デバイス使用による生活リズム分析
5. **社会的つながりの定量化** — 電話・メッセージ・訪問による社会的孤立の検出

### 参考リンク

- [Apple Developer — SensorKit](https://developer.apple.com/documentation/sensorkit)
- [SRSensor](https://developer.apple.com/documentation/sensorkit/srsensor)
- [SRSensorReader](https://developer.apple.com/documentation/sensorkit/srsensorreader)
- [SRKeyboardMetrics](https://developer.apple.com/documentation/sensorkit/srkeyboardmetrics)
- [SRAmbientLightSample](https://developer.apple.com/documentation/sensorkit/srambientlightsample)
- [SRDeviceUsageReport](https://developer.apple.com/documentation/sensorkit/srdeviceusagereport)
- [SRVisit](https://developer.apple.com/documentation/sensorkit/srvisit)
- [SRPhoneUsageReport](https://developer.apple.com/documentation/sensorkit/srphoneusagereport)
- [Accessing SensorKit Data — ResearchKit & CareKit](https://www.researchandcare.org/resources/accessing-sensorkit-data/)
- [SensorKit Reader Entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.sensorkit.reader.allow)
- [Exploring the Potential of Apple SensorKit — Digital Biomarkers (2023)](https://karger.com/dib/article/7/1/104/861817/)
- [Using Apple's SensorKit for Ambient Light Monitoring](https://kylelukaszek.com/articles/Apple-Sensor-Kit/)
