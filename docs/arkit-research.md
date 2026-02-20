# ARKit フレームワーク 調査レポート

## 1. ARKit とは

ARKit は Apple が **WWDC17**（iOS 11）で初めて発表した**拡張現実（AR）フレームワーク**。iPhone / iPad のカメラ、モーションセンサー、LiDAR スキャナーを駆使して、現実世界にデジタルコンテンツを重ね合わせる体験を実現する。

2017 年の登場以降、毎年の WWDC で進化を続け、ARKit 6（iOS 16）まで到達。WWDC23 以降は visionOS（Apple Vision Pro）へのシフトも含め、Apple の空間コンピューティング戦略の中核を担う。

**核心コンセプト:** 「iPhone / iPad のカメラを通じて、現実世界とデジタルコンテンツをシームレスに融合する」

---

## 2. ARKit のバージョン進化

| バージョン | 年 | iOS | 主要な新機能 |
|---|---|---|---|
| **ARKit 1.0** | 2017 | iOS 11 | ワールドトラッキング、水平面検出、Face Tracking（iPhone X） |
| **ARKit 1.5** | 2018 | iOS 11.3 | 2D 画像検出、垂直面検出、不規則形状の面検出 |
| **ARKit 2** | 2018 | iOS 12 | 共有 AR 体験、永続化、3D オブジェクト検出、画像トラッキング |
| **ARKit 3** | 2019 | iOS 13 | People Occlusion、モーションキャプチャ、協調セッション、複数顔トラッキング |
| **ARKit 3.5** | 2020 | iOS 13.4 | LiDAR 対応、Scene Geometry、Instant AR |
| **ARKit 4** | 2020 | iOS 14 | Location Anchors（地理座標）、Depth API、拡張 Face Tracking |
| **ARKit 5** | 2021 | iOS 15 | Object Capture（フォトグラメトリ）、Location Anchors 都市拡大、App Clip Codes |
| **ARKit 6** | 2022 | iOS 16 | 4K HDR ビデオ、カメラ制御（露出/WB/フォーカス）、改良モーションキャプチャ |
| **visionOS ARKit** | 2023+ | visionOS | 空間コンピューティング、ハンドトラッキング、Vision Pro 向けシーン理解 |

---

## 3. ARKit の主要機能

### 3.1 ワールドトラッキング（World Tracking）

ARKit の根幹機能。デバイスの位置と向きを 6DoF（6 自由度）でリアルタイム追跡する。

```
6DoF = 3 軸の移動（X, Y, Z） + 3 軸の回転（Pitch, Yaw, Roll）

┌─────────────────────────────────────┐
│  現実世界                             │
│                                      │
│  ┌─ iPhone ─┐                        │
│  │ カメラ    │ → 映像フレーム解析       │
│  │ IMU      │ → 加速度・ジャイロ        │
│  │ LiDAR    │ → 深度マップ（対応機種）   │
│  └──────────┘                        │
│       ↓                              │
│  Visual-Inertial Odometry (VIO)      │
│  = カメラ映像 + モーションセンサー融合   │
│       ↓                              │
│  デバイスの位置・向きをリアルタイム推定  │
│  → 仮想オブジェクトを正確に配置可能     │
└─────────────────────────────────────┘
```

**対応デバイス:** A9 チップ以降の iPhone / iPad（iPhone 6s 以降）

### 3.2 平面検出（Plane Detection）

現実世界の水平面（床、テーブル）と垂直面（壁）を検出し、`ARPlaneAnchor` として追跡する。

```swift
import ARKit

let configuration = ARWorldTrackingConfiguration()
configuration.planeDetection = [.horizontal, .vertical]

// 検出された平面にオブジェクトを配置
func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

    // 平面の分類を取得
    switch planeAnchor.classification {
    case .floor:    print("床を検出")
    case .wall:     print("壁を検出")
    case .ceiling:  print("天井を検出")
    case .table:    print("テーブルを検出")
    case .seat:     print("座席を検出")
    case .door:     print("ドアを検出")
    case .window:   print("窓を検出")
    default:        print("その他の平面")
    }
}
```

**平面分類ラベル:**
| 分類 | 説明 |
|---|---|
| `.floor` | 床 |
| `.wall` | 壁 |
| `.ceiling` | 天井 |
| `.table` | テーブル |
| `.seat` | 座席 / 椅子 |
| `.door` | ドア |
| `.window` | 窓 |
| `.none` | 未分類 |

### 3.3 Face Tracking（顔追跡）

TrueDepth カメラ（フロントカメラ）を使用して、顔の 3D メッシュと 52 のブレンドシェイプ（表情パラメータ）をリアルタイム追跡。

```
52 のブレンドシェイプ例:

  眉:    browDownLeft, browDownRight, browInnerUp, browOuterUpLeft, browOuterUpRight
  目:    eyeBlinkLeft, eyeBlinkRight, eyeLookDownLeft, eyeLookInLeft, ...
  口:    mouthSmileLeft, mouthSmileRight, mouthOpen, mouthFunnel, jawOpen, ...
  頬:    cheekPuff, cheekSquintLeft, cheekSquintRight
  舌:    tongueOut
  鼻:    noseSneerLeft, noseSneerRight
```

**用途:**
- Animoji / Memoji のような表情アニメーション
- バーチャルメイク / フィルター
- 顔認識ベースの UI 操作
- 表情を使ったゲーム入力

**対応:** iPhone X 以降（TrueDepth カメラ搭載機）/ A12 以降は前面カメラのみで対応

**同時追跡数:** 最大 3 顔（ARKit 3+、A12 以降）

### 3.4 画像検出・画像トラッキング（Image Detection / Tracking）

現実世界の 2D 画像（ポスター、絵画、本の表紙、QR コード等）を検出し、その位置と向きを追跡する。

```swift
// 参照画像の登録
guard let referenceImages = ARReferenceImage.referenceImages(
    inGroupNamed: "AR Resources", bundle: nil
) else { return }

let configuration = ARWorldTrackingConfiguration()
configuration.detectionImages = referenceImages
configuration.maximumNumberOfTrackedImages = 4  // 最大同時追跡数

// ARKit 6: 最大 100 画像を同時検出（自動サイズ推定付き）
```

**ユースケース:**
- 美術館のポスターにかざすと解説が表示
- 商品パッケージにかざすと 3D モデルが出現
- 本の表紙にかざすと動画が再生

### 3.5 3D オブジェクト検出（Object Detection）

事前にスキャンした 3D オブジェクトを現実世界で検出・追跡する。

```swift
guard let referenceObjects = ARReferenceObject.referenceObjects(
    inGroupNamed: "AR Objects", bundle: nil
) else { return }

let configuration = ARWorldTrackingConfiguration()
configuration.detectionObjects = referenceObjects
```

**用途:**
- 特定の玩具やフィギュアを検出して AR コンテンツを表示
- 機械部品を検出して修理手順を AR 表示
- 博物館の展示物を検出して情報をオーバーレイ

### 3.6 LiDAR スキャナー連携

LiDAR（Light Detection And Ranging）はパルスレーザーで周囲の物体までの距離を最大 5 メートルまでナノ秒単位で測定する。

#### Scene Reconstruction（シーン再構築）

LiDAR + カメラで環境の 3D メッシュをリアルタイム生成。

```swift
let configuration = ARWorldTrackingConfiguration()

// メッシュのみ（分類なし）
configuration.sceneReconstruction = .mesh

// メッシュ + 分類ラベル
configuration.sceneReconstruction = .meshWithClassification
```

**メッシュ分類ラベル:**
| 分類 | 説明 |
|---|---|
| `.wall` | 壁 |
| `.floor` | 床 |
| `.ceiling` | 天井 |
| `.table` | テーブル |
| `.seat` | 座席 |
| `.window` | 窓 |
| `.door` | ドア |
| `.none` | 未分類 |

```
シーン再構築の流れ:

  LiDAR パルス発射 → 反射光受信 → 距離計算（ナノ秒精度）
       ↓
  密なポイントクラウド生成
       ↓
  ARMeshAnchor として三角形メッシュに変換
       ↓
  各三角形に分類ラベルを付与（オプション）
       ↓
  リアルタイムで更新・拡張
```

#### Depth API（深度 API）

ピクセルごとの深度情報をリアルタイム取得。

```swift
let configuration = ARWorldTrackingConfiguration()
configuration.frameSemantics = .sceneDepth  // LiDAR 深度
// or
configuration.frameSemantics = .smoothedSceneDepth  // 平滑化深度

// フレームごとの深度マップ取得
func session(_ session: ARSession, didUpdate frame: ARFrame) {
    guard let depthMap = frame.sceneDepth?.depthMap else { return }
    // CVPixelBuffer (kCVPixelFormatType_DepthFloat32)
    // 各ピクセルがメートル単位の深度値
}
```

**LiDAR 対応デバイス:**
| デバイス | 搭載年 |
|---|---|
| iPad Pro (第 4 世代以降) | 2020〜 |
| iPhone 12 Pro / Pro Max | 2020 |
| iPhone 13 Pro / Pro Max | 2021 |
| iPhone 14 Pro / Pro Max | 2022 |
| iPhone 15 Pro / Pro Max | 2023 |
| iPhone 16 Pro / Pro Max | 2024 |

### 3.7 People Occlusion（人物オクルージョン）

現実世界の人物と仮想オブジェクトの前後関係（遮蔽）を正しく処理する。

```
従来:
  仮想オブジェクトが常に最前面 → 不自然

People Occlusion:
  人が仮想オブジェクトの前を通ると、人の部分が正しくオブジェクトを遮る
  → 仮想オブジェクトが本当にそこにあるかのような自然な表現

  ┌──────────────────┐
  │      🏠 (AR)      │
  │   🧑←人物が前を  │
  │   通ると遮蔽する   │
  │                    │
  └──────────────────┘
```

```swift
let configuration = ARWorldTrackingConfiguration()
configuration.frameSemantics.insert(.personSegmentationWithDepth)
```

**対応:** A12 チップ以降

### 3.8 モーションキャプチャ（Motion Capture）

人体の関節位置（2D / 3D）をリアルタイム追跡し、仮想キャラクターにマッピング可能。

```
追跡される関節（91 点 + 左右耳 = 93 点）:

         head
          |
    leftShoulder ── rightShoulder
         |                |
     leftElbow      rightElbow
         |                |
     leftWrist      rightWrist
         |                |
     leftHand        rightHand
         |                |
        ...              ...
         |                |
      leftHip         rightHip
         |                |
     leftKnee        rightKnee
         |                |
     leftAnkle      rightAnkle
         |                |
     leftFoot        rightFoot
```

```swift
let configuration = ARBodyTrackingConfiguration()

func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    for anchor in anchors {
        guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
        let skeleton = bodyAnchor.skeleton

        // 各関節の変換行列を取得
        let hipTransform = skeleton.modelTransform(for: .root)
        let leftHandTransform = skeleton.modelTransform(for: .leftHand)
        // ...
    }
}
```

**対応:** A12 チップ以降
**ARKit 6 改良:** 左右の耳のトラッキングが追加、全体的なポーズ検出が改善

### 3.9 Location Anchors（地理的アンカー）

GPS + Apple Maps データを使用して、特定の地理座標（緯度・経度・高度）に AR コンテンツを配置。

```swift
// ARKit 4+
let coordinate = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
let geoAnchor = ARGeoAnchor(coordinate: coordinate, altitude: 40.0)
session.add(anchor: geoAnchor)
```

**対応都市（ARKit 5〜6 で拡大）:**
- 米国: サンフランシスコ、ニューヨーク、シカゴ、マイアミ 等
- 英国: ロンドン
- カナダ: モントリオール、トロント、バンクーバー
- アジア: 東京、シンガポール
- オーストラリア: シドニー、メルボルン

**ユースケース:**
- 特定のランドマークに AR コンテンツを配置
- 地域限定の AR イベント / ゲーム
- AR ナビゲーション

### 3.10 Object Capture（フォトグラメトリ）

iPhone / iPad のカメラ（+ LiDAR）で現実の物体を撮影し、高品質な 3D モデル（USDZ）を自動生成。

```
撮影フロー:

  1. 物体の周囲を撮影（複数角度から 20〜200 枚）
     ┌───┐
     │ 📱│→ 📸📸📸📸📸
     └───┘  （様々な角度から撮影）

  2. PhotogrammetrySession で 3D モデル生成
     📸📸📸 → [Photogrammetry API] → 🧊 USDZ

  3. 生成された USDZ モデルを AR に配置
     🧊 → ARView / RealityKit で表示
```

```swift
import RealityKit

// フォトグラメトリセッション（macOS / iOS）
let session = try PhotogrammetrySession(
    input: inputFolder,    // 撮影画像フォルダ
    configuration: PhotogrammetrySession.Configuration()
)

try session.process(requests: [
    .modelFile(url: outputURL, detail: .medium)  // .preview / .reduced / .medium / .full / .raw
])
```

**品質レベル:**
| レベル | ポリゴン数 | テクスチャ | 用途 |
|---|---|---|---|
| `.preview` | 最小 | 低解像度 | プレビュー / AR Quick Look |
| `.reduced` | 少 | 中解像度 | モバイル AR |
| `.medium` | 中 | 高解像度 | 標準 AR 体験 |
| `.full` | 多 | 最高解像度 | プロ用途 |
| `.raw` | 最大 | RAW | 後処理前提 |

### 3.11 RoomPlan API

LiDAR 搭載デバイスで部屋をスキャンし、パラメトリックな 3D モデルを自動生成。

```swift
import RoomPlan

// RoomPlan セッションの開始
let roomCaptureSession = RoomCaptureSession()
roomCaptureSession.delegate = self
roomCaptureSession.run(configuration: RoomCaptureSession.Configuration())

// スキャン結果の取得
func captureSession(_ session: RoomCaptureSession,
                    didUpdate room: CapturedRoom) {
    // CapturedRoom には以下が含まれる:
    // - walls: 壁
    // - doors: ドア
    // - windows: 窓
    // - openings: 開口部
    // - objects: 家具等（テーブル、椅子、ソファ、ベッド等）
    // - floors: 床
    // - sections: セクション

    for wall in room.walls {
        print("壁: \(wall.dimensions)")  // 幅 x 高さ
    }
    for object in room.objects {
        print("家具: \(object.category) at \(object.transform)")
    }
}

// USDZ / USD エクスポート
try room.export(to: fileURL, exportOptions: .model)
```

**検出可能なオブジェクト:**
壁 / 床 / 天井 / ドア / 窓 / 開口部 / テーブル / 椅子 / ソファ / ベッド / 暖炉 / テレビ / 収納家具 / 洗面台 / バスタブ / トイレ / 階段 / その他

### 3.12 4K HDR ビデオキャプチャ（ARKit 6）

ARKit セッション中に背面カメラから 4K ビデオフィードをキャプチャ。

```swift
let configuration = ARWorldTrackingConfiguration()

// 4K ビデオ（iPhone 11+）
if let hiResFormat = ARWorldTrackingConfiguration.supportedVideoFormats.first(
    where: { $0.captureDeviceType == .builtInWideAngleCamera &&
             $0.imageResolution.width >= 3840 }) {
    configuration.videoFormat = hiResFormat
}

// HDR ビデオ
configuration.videoHDRAllowed = true

// 高解像度背景画像キャプチャ
session.captureHighResolutionFrame { frame, error in
    // 高解像度フレームを取得
}

// カメラ制御（露出、ホワイトバランス、フォーカス）
// ARKit 6 でセッション中のカメラパラメータを直接制御可能
```

---

## 4. ARKit と連携する周辺フレームワーク

```
┌─────────────────────────────────────────────────┐
│                   ARKit 全体像                    │
│                                                   │
│  ┌─ ARKit (Core) ─────────────────────────────┐  │
│  │ World Tracking / Face Tracking              │  │
│  │ Plane Detection / Image Detection           │  │
│  │ Object Detection / Scene Reconstruction     │  │
│  │ Depth API / Location Anchors                │  │
│  │ People Occlusion / Motion Capture           │  │
│  └─────────────────────────────────────────────┘  │
│       ↕                                           │
│  ┌─ RealityKit ───────────────────────────────┐  │
│  │ 3D レンダリングエンジン                       │  │
│  │ PBR マテリアル / 物理シミュレーション          │  │
│  │ Object Capture (フォトグラメトリ)             │  │
│  │ Entity-Component System                      │  │
│  └─────────────────────────────────────────────┘  │
│       ↕                                           │
│  ┌─ SceneKit ─────────────────────────────────┐  │
│  │ 従来の 3D レンダリング（レガシー）             │  │
│  │ SCNNode ベースのシーングラフ                   │  │
│  └─────────────────────────────────────────────┘  │
│       ↕                                           │
│  ┌─ RoomPlan ─────────────────────────────────┐  │
│  │ 部屋スキャン・パラメトリック 3D モデル生成     │  │
│  │ 壁 / ドア / 窓 / 家具の自動検出              │  │
│  └─────────────────────────────────────────────┘  │
│       ↕                                           │
│  ┌─ SwiftUI / UIKit ──────────────────────────┐  │
│  │ ARView (RealityKit) / ARSCNView (SceneKit) │  │
│  │ AR Quick Look (USDZ ビューア)               │  │
│  └─────────────────────────────────────────────┘  │
│       ↕                                           │
│  ┌─ 連携フレームワーク ───────────────────────┐  │
│  │ Core ML: 機械学習モデル連携                   │  │
│  │ Vision: 画像認識・物体検出                    │  │
│  │ Metal: GPU レンダリング・カスタムシェーダー    │  │
│  │ MapKit / CoreLocation: 地理座標連携          │  │
│  │ MultipeerConnectivity: マルチユーザー AR     │  │
│  └─────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

| フレームワーク | 役割 | ARKit との関係 |
|---|---|---|
| **RealityKit** | 3D レンダリング + 物理エンジン | ARKit の推奨レンダラー。Entity-Component System |
| **SceneKit** | 3D レンダリング（レガシー） | ARKit 初期からの対応。SCNNode ベース |
| **RoomPlan** | 部屋スキャン | ARKit + LiDAR で部屋のパラメトリックモデル生成 |
| **Core ML** | 機械学習 | ARKit のカメラ映像に ML モデルを適用 |
| **Vision** | 画像認識 | ARKit フレームに対して物体検出・テキスト認識 |
| **Metal** | GPU レンダリング | カスタムシェーダー・ポストプロセッシング |
| **MultipeerConnectivity** | P2P 通信 | 協調 AR セッション（マルチユーザー） |

---

## 5. 設計上の制約と注意点

### 5.1 デバイス要件

| 機能 | 最低要件 |
|---|---|
| ワールドトラッキング | A9 チップ以降（iPhone 6s+） |
| Face Tracking（前面カメラ） | TrueDepth カメラ搭載機（iPhone X+） |
| Face Tracking（背面カメラ） | A12 チップ以降 |
| People Occlusion | A12 チップ以降 |
| モーションキャプチャ | A12 チップ以降 |
| LiDAR / Scene Reconstruction | LiDAR 搭載機（iPhone 12 Pro+, iPad Pro 4th+） |
| Depth API | LiDAR 搭載機 |
| Location Anchors | A12 + 対応都市のみ |
| Object Capture | LiDAR 搭載機（撮影）/ Apple Silicon Mac（処理） |
| RoomPlan | LiDAR 搭載機 |
| 4K ビデオ | iPhone 11 以降 |

### 5.2 技術的制約

| 制約 | 詳細 |
|---|---|
| **LiDAR 距離制限** | 最大 5 メートル。それ以上は精度が低下 |
| **暗所性能** | カメラベースのトラッキングは暗所で精度低下 |
| **反射面** | 鏡 / ガラス面は LiDAR メッシュ生成が困難 |
| **高天井** | RoomPlan は極端に高い天井のスキャンが苦手 |
| **非常に暗い面** | 黒い素材は LiDAR の反射率が低く検出困難 |
| **バッテリー消費** | AR セッションは CPU/GPU/カメラを集中使用 → 高消費 |
| **発熱** | 長時間使用で端末が発熱しパフォーマンス低下の可能性 |
| **屋外 AR** | 直射日光下ではカメラの露出調整が難しい場合あり |
| **Location Anchors** | 対応都市が限定的。Apple Maps データに依存 |
| **同時追跡制限** | 画像: 最大 100（ARKit 6）/ 顔: 最大 3（ARKit 3+） |

### 5.3 開発上の推奨事項

| 項目 | 推奨 |
|---|---|
| **レンダラー選択** | 新規開発は RealityKit を推奨（SceneKit はレガシー） |
| **LiDAR フォールバック** | LiDAR 非搭載機向けのフォールバック体験を用意 |
| **セッション管理** | バックグラウンド移行時はセッション一時停止 |
| **省電力設計** | AR セッションの自動タイムアウトを実装 |
| **ユーザーガイド** | 初回利用時にスキャン方法のオンボーディングを表示 |
| **アクセシビリティ** | VoiceOver 対応、振動フィードバックの追加 |

---

## 6. iOS アプリ活用アイデア

### アイデア 1: 「AR タイムマシン — 過去と未来の街並みを歩く」

**コンセプト:** Location Anchors + 画像検出 を活用して、今いる場所の「過去の姿」「未来の姿」を AR で重ね合わせるアプリ。観光地や歴史的建造物にかざすと、当時の姿が現実に浮かび上がる。

```
使用フロー:

  1. ユーザーが街を歩きながらカメラをかざす
  2. Location Anchors で現在地を特定
  3. その地点に紐付いた歴史データを取得

  ┌─ AR ビュー ─────────────────────────────────┐
  │                                              │
  │  ┌── 現在の建物 ──┐  ┌── AR 重ね合わせ ──┐   │
  │  │  東京駅（現在）  │  │  東京駅（1914年）  │   │
  │  │  近代的な外観    │→│  赤レンガの姿      │   │
  │  └────────────────┘  └──────────────────┘   │
  │                                              │
  │  タイムスライダー:                              │
  │  1914 ──●──────────────────────── 2026       │
  │         ↑                                    │
  │       現在の表示年                              │
  │                                              │
  │  [📸 AR 写真] [📖 歴史解説] [🗺️ 近くのスポット] │
  └──────────────────────────────────────────────┘
```

**仕組み:**
- **Location Anchors:** 対応都市で地理座標に歴史データをアンカリング
- **画像検出:** 建物のファサード / ランドマークを検出して適切な 3D モデルを表示
- **Scene Reconstruction（LiDAR）:** 現在の建物のメッシュを取得し、歴史的な建物の 3D モデルで「上書き」表示
- **タイムスライダー:** 年代を動かすと建物が年代ごとに変化するアニメーション
- **People Occlusion:** 通行人が歴史的建物の前を自然に通り過ぎる

**面白い点:**
- 「今ここにいる」感覚と「タイムトラベル」の感覚が同時に味わえる
- 観光 × 教育 × エンターテインメントの三重の価値
- UGC で過去の写真を投稿 → コミュニティで歴史を復元
- 学校の社会科授業での活用可能性

**技術構成:** ARKit（Location Anchors + Image Detection + Scene Reconstruction） + RealityKit + MapKit + CloudKit（歴史データ DB）

---

### アイデア 2: 「AR 生き物図鑑 — 部屋が水族館・動物園になる」

**コンセプト:** RoomPlan で部屋をスキャンし、部屋の構造（床・壁・天井・家具）を理解した上で、部屋全体を水族館や動物園に変換するアプリ。生き物が部屋の構造に合わせてリアルに行動する。

```
RoomPlan スキャン後:

  ┌─ あなたの部屋 ──────────────────────────────┐
  │                                              │
  │  天井 → 鳥 / 蝶が飛ぶ空間                     │
  │                                              │
  │  壁 → 水族館の水槽ビュー（半透明ガラス効果）    │
  │     🐠🐟🦈 魚が壁面を泳ぐ                     │
  │                                              │
  │  テーブル → 小動物の居場所                      │
  │     🐹 ハムスターがテーブル上を走り回る         │
  │                                              │
  │  床 → 大型動物が歩く地面                       │
  │     🦁 ライオンが床の上を歩く                   │
  │     → People Occlusion でソファの後ろに隠れる   │
  │                                              │
  │  ソファ → 猫が寝転ぶ場所                       │
  │     🐱 AR 猫がソファの上で丸くなる              │
  │                                              │
  └──────────────────────────────────────────────┘
```

**仕組み:**
- **RoomPlan:** 部屋をスキャンして壁・床・天井・家具の位置と種類を取得
- **Scene Reconstruction:** メッシュ分類で「テーブルの上」「床の上」「壁の前」を区別
- **People Occlusion:** ユーザーや家具の前後関係を正しく処理 → 動物が家具の後ろに隠れる
- **RealityKit 物理シミュレーション:** 動物がメッシュに沿って歩く・ジャンプする
- **Motion Capture:** ユーザーの動きに動物が反応（近づくと逃げる / 寄ってくる）

**面白い点:**
- 「自分の部屋」が水族館になる体験は子供に強烈なインパクト
- RoomPlan による空間理解で「テーブルの上にカエルが乗る」「本棚の上に猫が座る」等の自然な配置
- 生き物ごとの AI 行動パターン（ナマケモノは動かない、犬は走り回る等）
- 教育コンテンツ: 動物をタップすると解説が表示

**技術構成:** ARKit（Scene Reconstruction + People Occlusion + Motion Capture） + RealityKit（物理シミュレーション） + RoomPlan + Core ML（動物 AI 行動）

---

### アイデア 3: 「AR シャドウ — 光と影の物理パズルゲーム」

**コンセプト:** 現実の部屋の光源位置と家具配置を AR で認識し、その上で「影」を使ったパズルゲームをプレイするアプリ。仮想の光源を動かし、現実の家具が作る影を操作して、影絵でパズルを解く。

```
ゲーム画面:

  ┌─ AR ビュー ─────────────────────────────────┐
  │                                              │
  │  ☀️ ← 仮想光源（ドラッグで移動可能）           │
  │   \                                          │
  │    \  ┌─ テーブル（現実）─┐                    │
  │     \ │                  │                    │
  │      \└──────────────────┘                    │
  │       \                                      │
  │        ████████████████ ← テーブルの影（AR）   │
  │                                              │
  │  目標: 影の形を 🐕 の形に合わせよう！           │
  │                                              │
  │  ┌──────────────┐                             │
  │  │  🐕 目標の形  │  一致度: 73%               │
  │  └──────────────┘                             │
  │                                              │
  │  ヒント: 光源を右に動かし、                     │
  │          物体を追加して影を調整しよう            │
  └──────────────────────────────────────────────┘
```

**仕組み:**
- **Scene Reconstruction:** 部屋のメッシュを取得 → 影の投影面と遮蔽物を計算
- **Depth API:** ピクセル単位の深度で正確な影の形を計算
- **RealityKit:** リアルタイムのライティング + シャドウレンダリング
- **Metal カスタムシェーダー:** 影の形状をリアルタイム計算し、目標形状との一致度を算出
- **平面検出:** 床・壁を影の投影面として使用

**面白い点:**
- 「現実の家具」がパズルの要素になる → 部屋が変わるとパズルも変わる
- 物理的に光の性質（影の大きさは距離に反比例）を体験的に学べる
- 複数人で協力: 1 人が光源を持ち、もう 1 人が物体を配置（協調セッション）
- ステージが無限: ユーザーの部屋ごとに異なるパズルが生成される

**技術構成:** ARKit（Scene Reconstruction + Depth API） + RealityKit + Metal（カスタムシェーダー） + MultipeerConnectivity（協力プレイ）

---

### アイデア 4: 「AR ミュージアム — 自分だけの美術館を建築する」

**コンセプト:** Object Capture で現実の物体（自作の陶芸、子供の工作、コレクション等）を 3D スキャンし、RoomPlan でスキャンした自分の部屋に「バーチャル美術館」を構築するアプリ。作品を額縁に入れ、照明を当て、来場者（友人）を招待できる。

```
フロー:

  Step 1: 作品を 3D スキャン（Object Capture）
  ┌──────────────────────────────────────┐
  │  📱 → 📸📸📸 → 🧊 USDZ モデル生成   │
  │  自作の陶芸作品を 360° 撮影            │
  └──────────────────────────────────────┘

  Step 2: 部屋をスキャン（RoomPlan）
  ┌──────────────────────────────────────┐
  │  📱 → 🏠 部屋の 3D モデル生成          │
  │  壁・床・家具の位置を把握              │
  └──────────────────────────────────────┘

  Step 3: 美術館を設計（AR エディタ）
  ┌─ AR ビュー ─────────────────────────┐
  │                                      │
  │  壁面: 額縁付きの写真 / 絵画          │
  │  ┌─────────┐  ┌─────────┐           │
  │  │ 🖼️ 作品1 │  │ 🖼️ 作品2 │           │
  │  │ 💡 照明  │  │ 💡 照明  │           │
  │  └─────────┘  └─────────┘           │
  │                                      │
  │  台座: 3D スキャンした立体作品         │
  │     🏺 陶芸作品（Object Capture）     │
  │     💡 スポットライト                  │
  │     📝 「2024年制作 / 作者: ○○」      │
  │                                      │
  │  床面: ガイドライン（順路表示）         │
  │  ------→------→------→              │
  │                                      │
  │  [🎨 作品追加] [💡 照明編集] [🔗 共有]  │
  └──────────────────────────────────────┘

  Step 4: 友人を招待（協調セッション）
  ┌──────────────────────────────────────┐
  │  MultipeerConnectivity で             │
  │  同じ空間を共有 → 一緒に美術館を巡る   │
  └──────────────────────────────────────┘
```

**面白い点:**
- 「自分の作品が美術館に飾られる」体験 — 子供の工作が格調高い展示に
- Object Capture で実物を 3D 化 → 手元にない友人にも立体作品を見せられる
- 協調セッションで「バーチャル美術館ツアー」— 離れた友人も同じ空間で鑑賞
- 教育現場: 学校の作品展を AR で常設展示化
- SNS 共有: AR 美術館のスクリーンショット / 動画を共有

**技術構成:** ARKit + RealityKit + Object Capture + RoomPlan + MultipeerConnectivity + CloudKit（作品データ共有）

---

### アイデア 5: 「AR フィットネスコーチ — モーションキャプチャで完璧なフォーム」

**コンセプト:** モーションキャプチャ機能で、ユーザーの体の動き（関節位置）をリアルタイム追跡し、理想のフォームと比較してリアルタイムフィードバックを行うフィットネスアプリ。

```
トレーニング画面:

  ┌─ AR ビュー（フロントカメラ or ミラー使用）───┐
  │                                              │
  │     👤 ユーザー（実際の姿）                    │
  │     ┌──┐                                     │
  │     │頭│                                     │
  │  ┌──┼──┼──┐                                  │
  │  │左│胴│右│                                  │
  │  │腕│体│腕│  ← 🟢 正しい角度                  │
  │  └──┼──┼──┘                                  │
  │     │  │                                     │
  │     │膝│  ← 🔴 膝が前に出すぎ！ -15°          │
  │     └──┘                                     │
  │                                              │
  │  ┌─ リアルタイムフィードバック ──────────────┐ │
  │  │ スクワット: 8/12 回                       │ │
  │  │ フォーム精度: 82%                         │ │
  │  │ ⚠️ 膝が前に出すぎています。                │ │
  │  │    つま先より後ろに保ちましょう             │ │
  │  │                                          │ │
  │  │ 🟢 背筋: OK  🟢 足幅: OK  🔴 膝: NG     │ │
  │  └──────────────────────────────────────────┘ │
  │                                              │
  │  [⏸️ 一時停止] [📹 録画] [📊 統計]            │
  └──────────────────────────────────────────────┘

  半透明ガイドキャラクター（AR オーバーレイ）:
  ┌──────────────────────────────────────────────┐
  │  理想のフォームを半透明のキャラクターで表示       │
  │  ユーザーの体に重ね合わせて「ズレ」を可視化       │
  │                                              │
  │     👤（実際）  + 👻（理想ガイド）              │
  │     → ズレている部分が赤くハイライト             │
  └──────────────────────────────────────────────┘
```

**仕組み:**
- **Motion Capture（背面カメラ）:** ユーザーの 93 関節をリアルタイム追跡
- **RealityKit:** 理想フォームの半透明キャラクターを AR オーバーレイ
- **Core ML:** 関節角度データから「正しいフォーム」との偏差を判定
- **People Occlusion:** ユーザーの体に自然にガイドキャラクターを重ねる
- **音声フィードバック:** リアルタイムで「もう少し腰を下げて」等の音声指示

**面白い点:**
- **パーソナルトレーナーが不要** — 高精度なフォームチェックが自宅で可能
- 関節角度のリアルタイム計算で「膝が何度ずれている」まで定量的にフィードバック
- 半透明ガイドキャラクターと自分の体を重ねる → 直感的にフォームを修正
- トレーニング録画 + 関節トラッキングデータを保存 → 成長の可視化
- HealthKit 連携でカロリー消費・ワークアウト記録を自動保存
- Apple Watch の心拍データとリアルタイム連携

**技術構成:** ARKit（Motion Capture + People Occlusion） + RealityKit + Core ML + HealthKit + AVFoundation（録画）

---

## 7. まとめ

| 観点 | 評価 |
|---|---|
| **機能の幅** | ★★★★★ — 平面検出 / 顔追跡 / LiDAR / モーキャプ / 位置アンカー等、AR の全領域をカバー |
| **エコシステム** | ★★★★★ — RealityKit / RoomPlan / Object Capture / Core ML / Vision と深く統合 |
| **デバイス互換性** | ★★★★☆ — A9 以降で基本機能使用可。LiDAR 機能は Pro 機種限定 |
| **開発体験** | ★★★★☆ — RealityKit + SwiftUI の組み合わせは直感的。ただし学習曲線あり |
| **パフォーマンス** | ★★★☆☆ — バッテリー消費・発熱が課題。長時間 AR セッションは設計上の工夫が必要 |
| **成熟度** | ★★★★★ — 2017 年から 6 世代の進化。API は安定し、豊富なドキュメントとサンプル |

### ARKit が最も輝くパターン

1. **空間理解 × コンテンツ配置** — 部屋の構造を理解して最適にデジタルコンテンツを配置
2. **LiDAR × 高精度メッシュ** — 現実世界の 3D メッシュをリアルタイム生成・活用
3. **人体追跡 × インタラクション** — モーキャプ / フェイストラッキングでユーザーの動きに反応
4. **マルチユーザー × 共有体験** — 協調セッションで同じ AR 空間を複数人が共有
5. **フォトグラメトリ × コンテンツ生成** — 現実の物体を 3D モデル化してアプリ内で活用

### 参考リンク

- [Apple Developer — ARKit](https://developer.apple.com/documentation/arkit)
- [Apple Developer — Augmented Reality](https://developer.apple.com/augmented-reality/arkit/)
- [WWDC17: Introducing ARKit](https://developer.apple.com/videos/play/wwdc2017/602/)
- [WWDC19: Introducing ARKit 3](https://developer.apple.com/videos/play/wwdc2019/604/)
- [WWDC20: Explore ARKit 4](https://developer.apple.com/videos/play/wwdc2020/10611/)
- [WWDC21: Explore ARKit 5](https://developer.apple.com/videos/play/wwdc2021/10073/)
- [WWDC22: Discover ARKit 6](https://developer.apple.com/videos/play/wwdc2022/10126/)
- [WWDC22: Create parametric 3D room scans with RoomPlan](https://developer.apple.com/videos/play/wwdc2022/10127/)
- [WWDC23: Evolve your ARKit app for spatial experiences](https://developer.apple.com/videos/play/wwdc2023/10091/)
- [Apple Developer — RealityKit](https://developer.apple.com/documentation/realitykit)
- [Apple Developer — RoomPlan](https://developer.apple.com/documentation/roomplan)
- [Awesome-ARKit (GitHub)](https://github.com/olucurious/Awesome-ARKit)
- [ARKitScenes Dataset (GitHub)](https://github.com/apple/ARKitScenes)
- [MobiDev — ARKit Guide 2026](https://mobidev.biz/blog/arkit-guide-augmented-reality-app-development-ios)
- [STRV — How Apple's ARKit Changed Reality](https://www.strv.com/blog/how-apples-arkit-changed-reality-engineering-product)
