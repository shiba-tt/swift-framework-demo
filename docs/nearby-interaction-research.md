# Nearby Interaction フレームワーク 調査レポート

## 1. Nearby Interaction とは

Nearby Interaction は Apple が WWDC20 で発表したフレームワークで、U1 / U2 チップの **Ultra Wideband (UWB)** 技術を活用し、近くのデバイスやアクセサリとの**距離**と**方向**をセンチメートル精度でリアルタイムに取得できる。

Apple はこれを「リビングルームスケールの GPS」と表現している。

**核心コンセプト:** 「UWB による空間認識で、デバイス間の距離と方向をセンチメートル精度でリアルタイム計測」

### 他の近距離通信技術との比較

| 技術 | 精度 | 方向検出 | 範囲 | 消費電力 |
|---|---|---|---|---|
| **UWB (Nearby Interaction)** | ~10 cm | ○（3D ベクトル） | U1: ~5m / U2: ~20m+ | 中 |
| **Bluetooth (BLE)** | 1〜3 m | △（AoA で可能） | ~30 m | 低 |
| **Wi-Fi** | 3〜5 m | × | ~50 m | 高 |
| **GPS** | 3〜10 m（屋外） | × | 屋外のみ | 高 |
| **iBeacon** | 1〜3 m | × | ~30 m | 低 |
| **NFC** | ~5 cm | × | ~5 cm | 極低 |

---

## 2. UWB ハードウェア仕様

### 2.1 UWB の仕組み

UWB チップは 5〜9 GHz の広帯域にわたり極めて短い無線パルスを送信する。受信側がパルスの到着時刻を計測し、**Time of Flight (ToF)** から距離を、パルスの到着角度から方向を算出する。

```
送信デバイス              受信デバイス
┌──────────┐   UWB パルス   ┌──────────┐
│  U1/U2   │ ────────────→ │  U1/U2   │
│  チップ   │ ←────────────  │  チップ   │
└──────────┘   ToF 計測     └──────────┘
                 ↓
          距離: 2.34 m
          方向: (x: 0.5, y: 0.1, z: -0.8)
```

### 2.2 U1 vs U2 チップ

| 項目 | U1（第1世代） | U2（第2世代） |
|---|---|---|
| **プロセス** | 16nm | 7nm |
| **Precision Finding 範囲** | ~5 m（約16フィート） | ~20 m+（約70フィート） |
| **最大検出距離** | ~10 m | ~40 m+（広告材では132フィート） |
| **消費電力** | 標準 | 大幅改善（AirTag 電池寿命 1年 → 2〜3年） |
| **信号処理** | 標準 | 強化（ノイズフィルタリング改善） |
| **初搭載** | iPhone 11 (2019) | iPhone 15 (2023) |

### 2.3 対応デバイス

#### U1 チップ搭載デバイス
- **iPhone:** 11, 11 Pro, 11 Pro Max, 12 シリーズ, 13 シリーズ, 14 シリーズ
- **Apple Watch:** Series 6, Series 7, Series 8, SE (2nd gen)
- **その他:** HomePod mini, HomePod (2nd gen), AirTag, AirPods Pro 2 充電ケース

#### U2 チップ搭載デバイス
- **iPhone:** 15 シリーズ, 16 シリーズ, 17 シリーズ, iPhone Air
- **Apple Watch:** Series 9, Series 10, Series 11, Ultra 2, Ultra 3
- **その他:** AirPods Pro 3 充電ケース

#### 非対応
- iPhone SE（全世代）
- iPad（全モデル）※ 2025年時点

### 2.4 地域制限

UWB はすべての国・地域で利用可能ではない。日本では一部の UWB 周波数が規制により使用できず、Precision Finding の拡張範囲が制限される場合がある。

---

## 3. API の詳細

### 3.1 NISession（中心的な API）

`NISession` は 2 つのピアデバイス間のセッションを管理するオブジェクト。

```swift
import NearbyInteraction

// 1. デバイスサポートの確認
guard NISession.deviceCapabilities.supportsPreciseDistanceMeasurement else {
    // UWB 非対応デバイス
    return
}

// 2. セッション作成
let session = NISession()
session.delegate = self

// 3. DiscoveryToken の取得と交換
// セッション作成時に自動生成される
guard let myToken = session.discoveryToken else { return }
// → このトークンを MultipeerConnectivity 等で相手に送信

// 4. 相手のトークンを受信したらセッション開始
let config = NINearbyPeerConfiguration(peerToken: peerToken)
session.run(config)
```

### 3.2 セッションワークフロー

```
1. NISession 作成
      ↓
2. discoveryToken を取得（自動生成）
      ↓
3. 通信チャネル（MultipeerConnectivity 等）でトークンを交換
      ↓
4. NINearbyPeerConfiguration を作成
      ↓
5. session.run(config) で開始
      ↓
6. delegate で距離・方向の更新を受信
      ↓
7. session.pause() / session.invalidate() で終了
```

**重要:** Nearby Interaction 自体にはデータ転送機能がない。トークン交換やアプリデータの送受信には MultipeerConnectivity、Bluetooth LE、iCloud 等の別の通信手段が必要。

### 3.3 NISessionDelegate（更新の受信）

```swift
extension MyController: NISessionDelegate {
    // 距離・方向の更新
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let object = nearbyObjects.first else { return }

        // 距離（メートル単位、Float 型）
        if let distance = object.distance {
            print("距離: \(distance) m")
        }

        // 方向（3D 単位ベクトル、simd_float3 型）
        if let direction = object.direction {
            print("方向: x=\(direction.x), y=\(direction.y), z=\(direction.z)")
        }

        // カメラアシスタンス有効時の追加プロパティ（iOS 16+）
        if let horizontalAngle = object.horizontalAngle {
            print("水平角度: \(horizontalAngle) rad")
        }

        // 垂直方向推定
        switch object.verticalDirectionEstimate {
        case .above: print("上方")
        case .below: print("下方")
        case .aboveOrBelow: print("上下不明")
        case .same: print("同じ高さ")
        @unknown default: break
        }
    }

    // セッション中断
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject],
                 reason: NINearbyObject.RemovalReason) {
        switch reason {
        case .peerEnded: print("相手がセッションを終了")
        case .timeout: print("タイムアウト")
        @unknown default: break
        }
    }

    // エラーハンドリング
    func session(_ session: NISession, didInvalidateWith error: Error) {
        print("セッション無効化: \(error.localizedDescription)")
    }
}
```

### 3.4 NINearbyObject の主要プロパティ

| プロパティ | 型 | 説明 |
|---|---|---|
| `distance` | `Float?` | 相手デバイスとの距離（メートル） |
| `direction` | `simd_float3?` | 相手デバイスへの 3D 方向ベクトル |
| `horizontalAngle` | `Float?` | 水平方向の角度（ラジアン）※ カメラアシスタンス時 |
| `verticalDirectionEstimate` | `VerticalDirectionEstimate` | 垂直方向の位置関係 ※ カメラアシスタンス時 |

**重要:** `distance` と `direction` は nullable。見通し線がない場合や視野角外では `nil` になる。

### 3.5 カメラアシスタンス（ARKit 統合、iOS 16+）

Precision Finding（AirTag の「探す」機能）と同じ技術を開発者に公開したもの。

```swift
let config = NINearbyPeerConfiguration(peerToken: peerToken)
config.isCameraAssistanceEnabled = true  // ARKit 統合を有効化
session.run(config)
```

- ARKit セッションは Nearby Interaction 内部で自動作成される（開発者が管理不要）
- 水平角度（`horizontalAngle`）と垂直方向推定が追加で取得可能
- Apple デバイス間 + サードパーティ UWB アクセサリで利用可能

### 3.6 サードパーティアクセサリ対応（iOS 15+）

```swift
// サードパーティ UWB アクセサリとのセッション
let accessoryConfig = NINearbyAccessoryConfiguration(
    data: accessoryConfigData  // Bluetooth GATT 経由で受信
)
session.run(accessoryConfig)
```

- FiRa コンソーシアム標準に準拠した UWB チップ（Qorvo DWM3001C 等）と相互運用可能
- Bluetooth LE GATT サービスによるアクセサリ認証が必要
- バックグラウンドセッション対応（Bluetooth LE ペアリング済みアクセサリ）

### 3.7 マルチセッション

1 台のデバイスで複数の NISession を同時実行可能。各セッションは 1 つのピアとの接続を管理する。

```swift
// 複数のピアと同時にセッションを実行
let session1 = NISession()
let session2 = NISession()
// それぞれ異なるピアの discoveryToken で設定
```

### 3.8 バックグラウンドセッション（iOS 16+）

```swift
// Bluetooth LE ペアリング済みアクセサリとのバックグラウンドセッション
let config = NINearbyAccessoryConfiguration(
    accessoryData: data,
    bluetoothPeerIdentifier: peripheralIdentifier
)
session.run(config)
```

- Core Bluetooth のバックグラウンド動作を活用
- アクセサリが BLE ペアリング済みであることが条件
- アプリがバックグラウンドに長時間滞在するとセッション再開不可になる場合がある

---

## 4. 設計上の制約と注意点

### 4.1 物理的制約

| 制約 | 詳細 |
|---|---|
| **視野角 (FoV)** | デバイス背面から出る仮想的な円錐形の範囲内でのみ方向検出が可能。範囲外では距離のみ取得可能 |
| **見通し線 (LoS)** | 障害物があると `direction` が `nil` になる。iPhone のワイドカメラと同等の視野 |
| **デバイスの向き** | ポートレートモードで最適動作。一方がランドスケープだと信頼性低下 |
| **屋内限定** | UWB は屋内近距離向け。屋外の長距離測位には不向き |

### 4.2 API 上の制約

| 制約 | 詳細 |
|---|---|
| **データ転送不可** | NI 自体にデータ転送機能はない。MultipeerConnectivity 等が別途必要 |
| **nullable な値** | `distance` / `direction` は常に nil の可能性がある。フォールバック設計が必須 |
| **パーミッション** | 初回の `NISession.run()` 時にシステムがプロンプトを自動表示 |
| **iPad 非対応** | 2025年時点で iPad には UWB チップが搭載されていない |

---

## 5. フレームワークの進化

| 年 | バージョン | 主な追加機能 |
|---|---|---|
| **WWDC20** | iOS 14 | 初リリース。iPhone 間の距離・方向計測 |
| **WWDC21** | iOS 15 | Apple Watch 対応、サードパーティ UWB アクセサリ対応 |
| **WWDC22** | iOS 16 | ARKit 統合（カメラアシスタンス）、バックグラウンドセッション、`NIDeviceCapability` |

---

## 6. iOS アプリ活用アイデア

### アイデア 1: 「ProximityParty — 空間認識マルチプレイヤーゲーム」

**コンセプト:** 実際の物理空間をゲームフィールドとして使うパーティゲーム。プレイヤーの iPhone 間の距離と方向をリアルタイムで計測し、物理的な動きがゲームに直接反映される。

```
プレイヤー A の iPhone
     ↕ UWB (距離 + 方向)
プレイヤー B の iPhone
     ↕ UWB
プレイヤー C の iPhone
     ↕ MultipeerConnectivity (ゲームデータ同期)
     ↕ UWB
プレイヤー D の iPhone
```

**ゲームモード例:**

1. **空間鬼ごっこ:** 鬼の iPhone が他プレイヤーとの距離をリアルタイム表示。3m 以内に近づくとタッチ判定。逃げる側は鬼との距離・方向をレーダーで確認
2. **宝探し:** 1 台を「宝」として隠し、他プレイヤーが Precision Finding で探索。ARKit カメラアシスタンスで AR ガイド表示
3. **距離当てクイズ:** 2 人の距離を当てるクイズ。UWB のセンチメートル精度を活かした新感覚ゲーム

**面白い点:**
- 画面ではなく「身体を動かす」ゲーム体験
- マルチセッションで 4 人以上の同時プレイが可能
- ARKit 統合で AR オーバーレイを重ねた没入感

**技術構成:** Nearby Interaction（マルチセッション） + MultipeerConnectivity + ARKit + SceneKit

---

### アイデア 2: 「SoundField — 空間オーディオ DJ」

**コンセプト:** 部屋の中での iPhone の位置に応じて音楽体験が変化する空間オーディオアプリ。ホスト iPhone が音源を再生し、リスナーの iPhone との距離・方向に応じて音量・パン・エフェクトをリアルタイム制御。

```
                    ┌─────────┐
                    │ HomePod │ (ホスト音源)
                    └────┬────┘
                 UWB     │     UWB
            ┌────────────┼────────────┐
            │            │            │
       ┌────▼────┐  ┌────▼────┐  ┌────▼────┐
       │ iPhone A │  │ iPhone B │  │ iPhone C │
       │ 近い:大音量│  │ 中間:通常│  │ 遠い:小音量│
       │ Bass強調  │  │ バランス │  │ Echo追加 │
       └─────────┘  └─────────┘  └─────────┘
```

**面白い点:**
- 部屋を歩き回ると音が変わる — 「音を探索する」体験
- 距離ゾーン別エフェクト: 近距離=低音強調、中距離=バランス、遠距離=リバーブ追加
- 複数人で異なる音体験を同時に楽しめる
- HomePod（U1 搭載）との連携で、既存の Apple エコシステムを活用

**技術構成:** Nearby Interaction + AVFoundation + Core Audio + MultipeerConnectivity

---

### アイデア 3: 「InvisibleWall — 見えない境界線セキュリティ」

**コンセプト:** UWB の精密な距離計測を活用した「見えないジオフェンス」。特定の UWB アクセサリ（または iPhone）からの距離に応じて、自動的にアクションをトリガーするスマートホーム / セキュリティアプリ。

```
距離ゾーン設計:
┌──────────────────────────────────────────────────┐
│  Zone 3: 遠距離 (10m+)                            │
│  → デバイスロック / アプリ非表示                       │
│  ┌──────────────────────────────────────────────┐ │
│  │  Zone 2: 中距離 (3〜10m)                      │ │
│  │  → 通知受信 / 限定機能のみ                      │ │
│  │  ┌──────────────────────────────────────────┐ │ │
│  │  │  Zone 1: 近距離 (0〜3m)                   │ │ │
│  │  │  → 全機能アンロック / 自動ログイン           │ │ │
│  │  └──────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────┘
```

**ユースケース:**
- **子供のデバイス管理:** 親の iPhone から 10m 離れると自動でアプリ制限
- **オフィスセキュリティ:** UWB タグから離れると機密アプリを自動ロック
- **展示物保護:** 美術館で作品に近づきすぎるとスタッフに通知
- **ペット見守り:** UWB タグ付きの首輪で、ペットが一定距離を超えたらアラート

**面白い点:**
- GPS ジオフェンスでは不可能なセンチメートル精度のゾーン制御
- バックグラウンドセッション（iOS 16+）で常時監視可能
- サードパーティ UWB アクセサリで iPhone 不要の設置が可能

**技術構成:** Nearby Interaction + Core Bluetooth（BLE ペアリング） + UserNotifications + ショートカット

---

### アイデア 4: 「BumpShare — 近づけて共有」

**コンセプト:** 2 台の iPhone を近づけるだけで、コンテンツを共有する次世代 AirDrop。UWB の方向検出を活用し、「iPhone を相手に向ける」というジェスチャーで共有先を特定。距離が近づくほど共有の意図が強まる UI。

```swift
func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
    guard let object = nearbyObjects.first,
          let distance = object.distance,
          let direction = object.direction else { return }

    // 方向が正面を向いている && 距離が近い → 共有意図あり
    let isFacingPeer = direction.z < -0.7  // Z軸が負 = 前方
    let isClose = distance < 0.5           // 50cm 以内

    if isFacingPeer && isClose {
        triggerShare()  // 共有実行
    }

    // 距離に応じた UI フィードバック
    updateProximityUI(distance: distance, direction: direction)
}
```

**共有できるもの:**
- 連絡先（NameDrop 風だがカスタマイズ可能）
- Wi-Fi パスワード
- アプリ固有データ（ゲームのフレンド申請、ポイントカード等）
- AR コンテンツ（3D モデルを「手渡す」ように共有）

**面白い点:**
- 「近づける」＋「向ける」の 2 段階ジェスチャーで誤操作防止
- 距離に連動したアニメーション（磁石のように引き寄せられる UI）
- 「引き離す」ことでキャンセル — 自然な身体動作でのインタラクション
- NFC より広い範囲（数メートル）で意図的な共有が可能

**技術構成:** Nearby Interaction + MultipeerConnectivity + UIKit アニメーション + Core Haptics

---

### アイデア 5: 「SpaceCanvas — 空間お絵描き AR」

**コンセプト:** 複数の iPhone の位置をリアルタイムで追跡し、空中にお絵描きする AR アプリ。各プレイヤーの iPhone が「空間上のペン」になり、移動軌跡が AR 空間に 3D の線として描画される。

```
  iPhone A (赤ペン)       iPhone B (青ペン)
       \                    /
        \    AR 空間       /
         \   ┌─────┐    /
          \  │ 3D  │   /
           → │ 描画 │ ←
             │ 結果 │
             └─────┘
               ↑
         iPhone C (観覧者)
         ARKit カメラで 3D 作品を閲覧
```

**面白い点:**
- 身体全体を使って描くダイナミックな体験
- UWB の精度でセンチメートル単位の精密な 3D 描画が可能
- カメラアシスタンス + ARKit で描画結果を AR で即座に確認
- 複数人で同じ空間に同時に描ける（マルチセッション）
- 描画結果を USDZ で書き出し、他の AR アプリで閲覧可能

**技術構成:** Nearby Interaction（カメラアシスタンス） + ARKit + RealityKit + MultipeerConnectivity + SceneKit

---

## 7. まとめ

| 観点 | 評価 |
|---|---|
| **精度** | ★★★★★ — センチメートル精度。BLE/Wi-Fi/GPS を大幅に上回る |
| **方向検出** | ★★★★☆ — 3D ベクトル + ARKit 統合で高精度。ただし FoV 制限あり |
| **範囲** | ★★★☆☆ — U1: ~5m / U2: ~20m。近距離に限定 |
| **デバイス対応** | ★★★☆☆ — iPhone 11 以降（iPad 非対応）。フォールバック必須 |
| **開発体験** | ★★★★☆ — API はシンプル。ただしトークン交換に別通信手段が必要 |
| **プライバシー** | ★★★★★ — Opt-in、ローカル処理、位置データはデバイス内に留まる |

### Nearby Interaction が最も輝くパターン

1. **物理空間を活用したインタラクション** — 距離・方向に応じた動的な体験
2. **Precision Finding 系の探索 UI** — ARKit 統合で「ここだよ」ガイド
3. **近接トリガー** — 近づく/離れるでアクションを自動実行
4. **マルチデバイス空間認識** — 複数デバイスの相対位置をリアルタイム把握
5. **サードパーティ UWB アクセサリ連携** — IoT / スマートホーム

### 参考リンク

- [Apple Developer — Nearby Interaction](https://developer.apple.com/nearby-interaction/)
- [Nearby Interaction Documentation](https://developer.apple.com/documentation/nearbyinteraction)
- [WWDC20: Meet Nearby Interaction](https://developer.apple.com/videos/play/wwdc2020/10668/)
- [WWDC21: Explore Nearby Interaction with third-party accessories](https://developer.apple.com/videos/play/wwdc2021/10165/)
- [WWDC22: What's new in Nearby Interaction](https://developer.apple.com/videos/play/wwdc2022/10008/)
- [WWDC21: Design for spatial interaction](https://developer.apple.com/videos/play/wwdc2021/10245/)
- [Apple Support — Ultra Wideband availability](https://support.apple.com/en-us/109512)
