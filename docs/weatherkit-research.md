# WeatherKit フレームワーク 調査レポート

## 1. WeatherKit とは

WeatherKit は Apple が WWDC22（iOS 16）で発表したフレームワークで、**Apple Weather サービス**が提供するハイパーローカルな気象データを Swift API（Apple プラットフォーム）または REST API（全プラットフォーム）経由でアプリに統合するための仕組み。

高解像度気象モデルと機械学習・予測アルゴリズムを組み合わせた Apple Weather サービスにより、世界中のあらゆる地点で精度の高い天気予報を取得できる。

**核心コンセプト:** 「プライバシーを保護しながら、タイムリーでハイパーローカルな気象情報をアプリに組み込む」

---

## 2. フレームワークの進化

| 年 | バージョン | 主な追加機能 |
|---|---|---|
| **WWDC22** | iOS 16 / macOS 13 | 初リリース。Swift API + REST API。現在の天気・時間別・日別予報・分単位降水・気象アラート |
| **WWDC23** | iOS 17 / macOS 14 | データセットの可用性チェック API。パフォーマンス改善 |
| **WWDC24** | iOS 18 / macOS 15 | **歴史的比較（HistoricalComparison）**。**天気の変化ハイライト（WeatherChanges）**。雲量の高度別データ。降雪量・みぞれ量・視程の最大/最小。昼間・夜間の個別予報。バイナリ転送フォーマット対応 |

---

## 3. 取得できるデータセット

WeatherKit は 6 つの主要データセットを提供する。`WeatherService.weather(for:including:)` メソッドで最大 5 つを一度にリクエスト可能。

### 3.1 データセット一覧

| データセット | WeatherQuery | 説明 |
|---|---|---|
| **現在の天気** | `.current` | 気温・体感温度・湿度・気圧・風速/風向・UV インデックス・雲量・視程・天候状態 |
| **時間別予報** | `.hourly` | 最大 240 時間（10 日間）の 1 時間ごとの予報 |
| **日別予報** | `.daily` | 最大 10 日間の日別予報（最高/最低気温・日の出/日の入り・降水確率） |
| **分単位降水** | `.minute` | 次の 1 時間の分単位降水予報（対応地域のみ） |
| **気象アラート** | `.alerts(countryCode:)` | 重大気象警報（暴風雨・洪水・熱波等） |
| **データ可用性** | `.availability` | 指定地域で利用可能なデータセットの確認 |

### 3.2 現在の天気（CurrentWeather）で取得できるプロパティ

| プロパティ | 型 | 説明 |
|---|---|---|
| `temperature` | `Measurement<UnitTemperature>` | 現在の気温 |
| `apparentTemperature` | `Measurement<UnitTemperature>` | 体感温度 |
| `humidity` | `Double` | 相対湿度（0〜1） |
| `pressure` | `Measurement<UnitPressure>` | 気圧 |
| `wind` | `Wind` | 風速・風向・突風 |
| `uvIndex` | `UVIndex` | UV インデックス（値とカテゴリ） |
| `visibility` | `Measurement<UnitLength>` | 視程 |
| `cloudCover` | `Double` | 雲量（0〜1） |
| `condition` | `WeatherCondition` | 天候状態（晴れ・曇り・雨など） |
| `isDaylight` | `Bool` | 昼間かどうか |
| `dewPoint` | `Measurement<UnitTemperature>` | 露点温度 |
| `precipitationIntensity` | `Measurement<UnitSpeed>` | 降水強度 |

### 3.3 日別予報（DayWeather）で取得できるプロパティ

| プロパティ | 説明 |
|---|---|
| `highTemperature` / `lowTemperature` | 最高気温 / 最低気温 |
| `precipitationChance` | 降水確率 |
| `precipitationAmount` | 降水量 |
| `snowfallAmount` | 降雪量（iOS 18+） |
| `sun.sunrise` / `sun.sunset` | 日の出 / 日の入り |
| `moon.moonrise` / `moon.phase` | 月の出 / 月相 |
| `wind` | 風速・風向 |
| `uvIndex` | UV インデックス |

### 3.4 iOS 18 で追加されたデータ

- **雲量の高度別内訳** — 低層・中層・高層それぞれの雲量
- **降雪量・みぞれ量** — 日別予報で詳細な降水種別を取得
- **視程の最大/最小** — 日別の視程範囲
- **昼間/夜間の個別予報** — 日中と夜間で異なる天候・気温を取得
- **歴史的比較（HistoricalComparison）** — 現在の気象と過去の統計平均との比較
- **天気の変化（WeatherChanges）** — 気温・降水の大きな変化を事前に検知

---

## 4. Swift API の使い方

### 4.1 基本的な天気取得

```swift
import WeatherKit
import CoreLocation

let weatherService = WeatherService()

// 東京の位置
let tokyo = CLLocation(latitude: 35.6762, longitude: 139.6503)

// 全データを取得
let weather = try await weatherService.weather(for: tokyo)

// 現在の天気にアクセス
let currentTemp = weather.currentWeather.temperature
let condition = weather.currentWeather.condition
let uvIndex = weather.currentWeather.uvIndex
```

### 4.2 特定のデータセットのみ取得

```swift
// 現在の天気のみ
let current = try await weatherService.weather(
    for: tokyo,
    including: .current
)

// 複数データセットを同時に取得（最大 5 つ）
let (current, daily, hourly) = try await weatherService.weather(
    for: tokyo,
    including: .current, .daily, .hourly
)

// 気象アラートを含む取得
let (current, alerts) = try await weatherService.weather(
    for: tokyo,
    including: .current, .alerts(countryCode: "JP")
)
```

### 4.3 分単位降水予報

```swift
let minuteForecast = try await weatherService.weather(
    for: tokyo,
    including: .minute
)

// 分単位降水は対応地域のみ（nil の可能性あり）
if let minutes = minuteForecast {
    for minute in minutes {
        print("\(minute.date): 降水強度 \(minute.precipitationIntensity)")
    }
}
```

### 4.4 データセットの可用性チェック

```swift
let availability = try await weatherService.weather(
    for: tokyo,
    including: .availability
)

// 分単位降水が利用可能か確認
if availability.contains(.minuteWeather) {
    // 分単位データが利用可能
}
```

### 4.5 iOS 18: 歴史的比較と天気の変化

```swift
// 歴史的比較 — 現在の天気が過去の平均と比べてどうか
let weather = try await weatherService.weather(for: tokyo)
if let comparison = weather.currentWeather.historicalComparison {
    // 例: .warmerThanAverage, .coolerThanAverage など
    print("歴史的比較: \(comparison)")
}

// 天気の変化 — 大きな気温・降水変化の検出
// WeatherChanges クエリで翌日の重大な変化を事前に把握
```

### 4.6 単位変換とフォーマット

```swift
let temp = weather.currentWeather.temperature

// Measurement API で簡単に単位変換
let celsius = temp.converted(to: .celsius)
let fahrenheit = temp.converted(to: .fahrenheit)

// MeasurementFormatter で地域に応じた表示
let formatter = MeasurementFormatter()
formatter.unitStyle = .medium
print(formatter.string(from: temp)) // "25°C" or "77°F"
```

---

## 5. セットアップ要件

### 5.1 対応プラットフォーム

| プラットフォーム | 最低バージョン |
|---|---|
| iOS | 16.0+ |
| iPadOS | 16.0+ |
| macOS | 13.0+ |
| watchOS | 9.0+ |
| tvOS | 16.0+ |
| visionOS | 1.0+ |

### 5.2 開発要件

1. **Xcode 14 以降** — WeatherKit フレームワークが含まれる
2. **Apple Developer Program メンバーシップ** — API コール割り当てに必要
3. **Capability の追加** — Xcode プロジェクトで「WeatherKit」Capability を有効にする
4. **App ID の設定** — Apple Developer Portal で App ID に WeatherKit を追加

### 5.3 API コール制限と料金

| プラン | 月間コール数 | 料金 |
|---|---|---|
| 無料枠 | 500,000 回/月 | Apple Developer Program に含まれる |
| 追加枠 | 上限を超える場合 | Apple Developer アプリのアカウントタブから購入 |

---

## 6. プライバシーとアトリビューション

### 6.1 プライバシー保護

WeatherKit はプライバシーファーストで設計されている:

- 位置情報は天気予報の提供にのみ使用される
- ユーザーの位置情報は Apple のサーバーに保存されない
- リクエスト間でユーザーが追跡されることはない
- 位置データは個人を特定する情報と関連付けられない

### 6.2 アトリビューション要件

Apple Weather のデータを表示するアプリは以下を遵守する必要がある:

- **Apple Weather 商標の表示** — 「 Weather」の表示が必要
- **データソースへの法的リンク** — 他のデータソースへのリンクを明示
- **例外** — 気象アラートのみの表示、または付加価値サービスの場合は不要

```swift
// アトリビューションの取得
let attribution = try await weatherService.attribution

// attribution.legalPageURL — 法的ページへの URL
// attribution.squareMarkURL — Apple Weather ロゴ（正方形）
// attribution.combinedMarkDarkURL — ダークモード用ロゴ
// attribution.combinedMarkLightURL — ライトモード用ロゴ
```

---

## 7. REST API（クロスプラットフォーム）

WeatherKit は REST API も提供しており、Web アプリや Android など Apple 以外のプラットフォームでも利用可能。

### 7.1 エンドポイント例

```
GET https://weatherkit.apple.com/api/v1/weather/{language}/{latitude}/{longitude}
    ?dataSets=currentWeather,forecastDaily,forecastHourly
```

### 7.2 認証

- JSON Web Token（JWT）を使用
- Apple Developer Portal で生成した秘密鍵で署名
- Service ID の作成が必要

---

## 8. 他の天気 API との比較

| 特徴 | WeatherKit | OpenWeatherMap | Weather API |
|---|---|---|---|
| **無料枠** | 500,000 コール/月 | 1,000 コール/日 | 1,000,000 コール/月 |
| **データソース** | Apple Weather Service | 独自 | 独自 |
| **分単位降水** | ○（対応地域） | △（有料） | × |
| **気象アラート** | ○ | ○（有料） | ○ |
| **歴史データ** | ○（iOS 18+） | ○（有料） | ○（有料） |
| **プライバシー** | ◎（トラッキングなし） | △ | △ |
| **Apple 統合** | ◎（ネイティブ） | × | × |
| **クロスプラットフォーム** | ○（REST API） | ○ | ○ |

---

## 9. WeatherKit を活用した面白いアプリのアイデア

以下に、WeatherKit のユニークなデータを最大限に活用した創造的なアプリアイデアを提案する。

### 9.1 「SoraNavi（ソラナビ）」 — AI 写真撮影スポットアドバイザー

**コンセプト:** 雲量の高度別データ + 日の出/日の入り + UV インデックスを組み合わせて、最高の写真が撮れる瞬間と場所をリアルタイムに提案するアプリ。

**WeatherKit 活用ポイント:**
- **雲量（高度別）** — 高層雲が多く低層雲が少ない条件 = 美しい夕焼けの可能性が高い
- **日の出/日の入り時刻** — ゴールデンアワー・ブルーアワーの正確な計算
- **視程** — 遠景撮影に適した条件の判定
- **分単位降水** — 雨上がりの虹の可能性を予測

**技術的な特徴:**
```swift
// 夕焼け撮影スコアの計算例
func calculateSunsetScore(weather: Weather) -> Double {
    let daily = weather.dailyForecast.first!
    let highCloudCover = weather.currentWeather.cloudCoverByAltitude?.high ?? 0
    let lowCloudCover = weather.currentWeather.cloudCoverByAltitude?.low ?? 0
    let visibility = weather.currentWeather.visibility.converted(to: .kilometers).value

    // 高層雲が多く低層雲が少ない = 美しい夕焼け
    var score = highCloudCover * 0.4
    score += (1.0 - lowCloudCover) * 0.3
    score += min(visibility / 20.0, 1.0) * 0.3
    return score
}
```

---

### 9.2 「KiseKae（キセカエ）」 — 天気連動バーチャルコーディネーター

**コンセプト:** 気温・湿度・風速・UV インデックス・降水確率を総合的に分析し、「何を着るべきか」をリアルタイムに 3D アバターで提案。時間帯ごとの天気変化を考慮した「一日分のコーディネート」を提案する。

**WeatherKit 活用ポイント:**
- **時間別予報** — 朝は寒いが昼は暖かい場合、脱ぎ着しやすい服装を提案
- **天気の変化（iOS 18）** — 午後から急な気温低下がある場合、上着を追加提案
- **UV インデックス** — UV が高い日はサングラス・帽子・日焼け止めを推奨
- **降水確率 + 分単位降水** — 傘の必要性をきめ細かく判定
- **歴史的比較** — 「例年より暑い/寒い」という情報で季節感のある提案

**差別化:** 単なる天気アプリではなく、ファッション × 天気の掛け算。WidgetKit と組み合わせて朝のロック画面に今日のコーデをウィジェット表示。

---

### 9.3 「TenKi Log（テンキログ）」 — 天気と人生のライフログ

**コンセプト:** 毎日の天気データを自動記録し、写真・日記・健康データと紐付けるライフログアプリ。「あの日の天気」を振り返ることで記憶がよみがえる。

**WeatherKit 活用ポイント:**
- **歴史的比較** — 「今日は例年より 5°C 暖かい」などの文脈を自動付与
- **全データセット** — 気温・天候・降水量・風速を日々自動記録
- **気象アラート** — 台風・大雪などの重大イベントも記録

**ユニークな機能:**
- **天気タイムライン** — カレンダーを天気アイコンで彩り、特定の天候条件の日を検索
- **HealthKit 連携** — 天気と体調・気分の相関を可視化（気圧と頭痛、日照時間と睡眠品質）
- **「1 年前の今日」** — 去年の同じ日の天気・写真・日記を通知
- **天気統計** — 「今年は晴れが○日、雨が○日」「最も暑かった日」などの年間サマリー

---

### 9.4 「AmeNige（アメニゲ）」 — 分単位リアルタイム雨よけナビ

**コンセプト:** 分単位降水予報を最大限活用し、「今から外出して雨に濡れずに帰れるか？」をリアルタイムで判定。外出タイミングと帰宅リミットを秒単位で提案。

**WeatherKit 活用ポイント:**
- **分単位降水（.minute）** — 次の 60 分間の降水を 1 分刻みで予測
- **時間別予報** — 1 時間以降の降水見通し
- **気象アラート** — ゲリラ豪雨・雷雨の警報を即時通知

**ユニークな機能:**
```swift
// 「雨が止む窓」を検出する例
func findDryWindows(minuteForecast: Forecast<MinuteWeather>) -> [DateInterval] {
    var dryWindows: [DateInterval] = []
    var windowStart: Date? = nil

    for minute in minuteForecast {
        let isRaining = minute.precipitationIntensity.converted(to: .millimetersPerHour).value > 0.1

        if !isRaining && windowStart == nil {
            windowStart = minute.date
        } else if isRaining, let start = windowStart {
            let interval = DateInterval(start: start, end: minute.date)
            if interval.duration >= 600 { // 10分以上の晴れ間
                dryWindows.append(interval)
            }
            windowStart = nil
        }
    }
    return dryWindows
}
```

- **Live Activity 連携** — Dynamic Island に「あと○分で雨が降ります」を表示
- **Apple Watch 対応** — 手首への Haptic 通知で「今すぐ出発！」
- **MapKit 統合** — 目的地までの移動時間と雨の降り始めを重ねて表示

---

### 9.5 「Hoshi-Zora（ホシゾラ）」 — 天体観測コンディションスコアラー

**コンセプト:** 天体観測に最適な夜を見つけるためのアプリ。雲量・視程・月相・湿度を総合スコアリングし、「今夜は星が見える度 ★★★★☆」と直感的に表示。

**WeatherKit 活用ポイント:**
- **雲量（高度別）** — 薄い高層雲 vs 厚い低層雲で星の見え方が大きく異なる
- **視程** — 空気の澄み具合を判定
- **月相（moon.phase）** — 新月に近いほど好条件
- **湿度** — 低湿度 = クリアな空
- **時間別予報** — 夜間の時間帯別に最適な観測タイミングを提案

**差別化:**
- **ARKit 連携** — カメラをかざすと星座を AR オーバーレイ表示（天気が良い夜のみ機能を促進）
- **10 日間星空予報** — 日別予報を使って「今週のベスト観測日」を提案
- **通知** — 「今夜は月のない快晴！絶好の天体観測日和です」

---

### 9.6 最もおすすめ: 「KiSeki（キセキ）」 — 気象 × 記憶 ジェネラティブアートアプリ

**コンセプト:** リアルタイムの天気データを入力として、その瞬間の天気を反映したユニークなジェネラティブアートを自動生成するアプリ。毎日、毎時間、天気が変わるたびに新しいアートが生まれる。「あなたの街の今の空」をアートにする。

**WeatherKit 活用ポイント（全データを活用）:**
- **気温** → 色温度（暖色〜寒色）のグラデーション
- **風速/風向** → パーティクルの流れと方向
- **雲量** → テクスチャの密度と透明度
- **湿度** → にじみ・ぼかしの強度
- **降水** → 水滴・雪結晶のエフェクト
- **UV インデックス** → 光の強さと彩度
- **気圧** → 構図の圧迫感・開放感
- **日の出/日の入り** → 時間帯に応じた全体の色調
- **歴史的比較** → 「異常に暑い日」は特別なビジュアルエフェクト

**技術的な実装イメージ:**
```swift
struct WeatherArtGenerator {
    func generateArt(from weather: CurrentWeather) -> some View {
        Canvas { context, size in
            // 気温で背景色を決定
            let tempColor = colorForTemperature(weather.temperature)
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(tempColor))

            // 風でパーティクルの方向を決定
            let windAngle = weather.wind.direction.converted(to: .degrees).value
            let windSpeed = weather.wind.speed.converted(to: .metersPerSecond).value
            drawWindParticles(context: context, size: size,
                           angle: windAngle, speed: windSpeed)

            // 雲量でテクスチャを追加
            let cloudOpacity = weather.cloudCover
            drawCloudTexture(context: context, size: size, opacity: cloudOpacity)

            // 降水でエフェクトを追加
            if weather.precipitationIntensity.value > 0 {
                drawRainEffect(context: context, size: size,
                             intensity: weather.precipitationIntensity)
            }
        }
    }
}
```

**ユニークな機能:**
- **WidgetKit** — ホーム画面ウィジェットが天気に合わせてリアルタイムに変化するアート作品になる
- **Apple Watch 文字盤** — 天気アートが文字盤のコンプリケーションに
- **共有機能** — 「今日の東京の空」をアートとして SNS にシェア
- **コレクション** — 日々のアートが自動保存され、天気のアートギャラリーが形成される
- **年間レビュー** — 365 枚のアートで 1 年の天気を振り返るタイムラプス動画を生成

---

## 10. WeatherKit を使う際の注意点とベストプラクティス

### 10.1 エラーハンドリング

```swift
do {
    let weather = try await weatherService.weather(for: location)
    // 天気データを使用
} catch let error as WeatherError {
    switch error {
    case .networkError:
        // ネットワークエラーの処理
    case .permissionDenied:
        // 権限エラーの処理
    default:
        // その他のエラー
    }
} catch {
    // 一般的なエラーの処理
}
```

### 10.2 API コールの最適化

- 必要なデータセットのみリクエストする（`.current` のみで十分な場合は日別・時間別を含めない）
- キャッシュを活用して不要な API コールを削減する
- バックグラウンド更新は BGAppRefreshTask を使い、適切な間隔に設定する

### 10.3 位置情報のベストプラクティス

- `CLLocationManager` で位置情報の使用許可を適切に取得する
- 「使用中のみ」の許可で十分な場合は「常に許可」を求めない
- 位置情報の精度を必要最低限に設定する（天気予報には `kCLLocationAccuracyKilometer` で十分）

---

## 11. まとめ

WeatherKit は Apple エコシステムにネイティブ統合された強力な気象データフレームワークである。

**強み:**
- プライバシーファースト設計（トラッキングなし）
- 月 500,000 コールの無料枠
- Swift Concurrency との自然な統合
- iOS 18 での歴史的比較・天気変化検知などの高度な機能
- WidgetKit・Live Activities・Apple Watch との深い連携

**注意点:**
- Apple Developer Program メンバーシップが必須
- 分単位降水予報は対応地域が限定的
- アトリビューション表示の義務がある
- クロスプラットフォームは REST API 経由のみ

**活用の可能性:**
天気データは「天気アプリ」だけのものではない。ファッション・写真・ヘルスケア・アート・農業・旅行など、あらゆる領域で天気データを文脈情報として活用することで、ユーザー体験を大きく向上させることができる。iOS 18 で追加された歴史的比較や天気変化の検出により、さらに豊かなコンテキスト提供が可能になった。

---

## 参考資料

- [WeatherKit — Apple Developer](https://developer.apple.com/weatherkit/)
- [WeatherKit | Apple Developer Documentation](https://developer.apple.com/documentation/weatherkit/)
- [Meet WeatherKit — WWDC22](https://developer.apple.com/videos/play/wwdc2022/10003/)
- [Bring context to today's weather — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10067/)
- [Fetching Weather Forecasts with WeatherKit](https://developer.apple.com/documentation/weatherkit/fetching_weather_forecasts_with_weatherkit)
- [WeatherKit REST API | Apple Developer Documentation](https://developer.apple.com/documentation/weatherkitrestapi/)
