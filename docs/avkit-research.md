# AVKit フレームワーク 調査レポート

## 1. AVKit とは

AVKit は Apple が提供する**メディア再生 UI フレームワーク**で、動画・音声コンテンツの再生インターフェースをシステム標準の外観と操作感で提供する。iOS / iPadOS / macOS / tvOS / visionOS の全プラットフォームに対応。

AVKit は内部で **AVFoundation**（メディア処理エンジン）を利用し、その上にプラットフォームに最適化された再生 UI（トランスポートコントロール、字幕、PiP、AirPlay 等）を提供する「UI レイヤー」の役割を担う。

**核心コンセプト:** 「メディア再生の UI を、各プラットフォームのデザインガイドラインに準拠した形で即座に提供する」

### AVKit と AVFoundation の関係

```
┌──────────────────────────────────────────────────────────┐
│  アプリケーション                                          │
│                                                           │
│  ┌─ AVKit（UI レイヤー）─────────────────────────────────┐│
│  │ VideoPlayer (SwiftUI) / AVPlayerViewController (UIKit) ││
│  │ トランスポートコントロール / 字幕 / PiP / AirPlay       ││
│  │ インライン再生 / フルスクリーン再生                       ││
│  └───────────────┬───────────────────────────────────────┘│
│                  ↕                                        │
│  ┌─ AVFoundation（メディアエンジン）──────────────────────┐│
│  │ AVPlayer / AVQueuePlayer / AVPlayerItem                ││
│  │ AVAsset / AVComposition / AVAssetExportSession          ││
│  │ AVCaptureSession / AVCaptureDevice                      ││
│  │ AVAudioEngine / AVAudioSession                          ││
│  │ HLS ストリーミング / FairPlay DRM                        ││
│  └───────────────┬───────────────────────────────────────┘│
│                  ↕                                        │
│  ┌─ 低レベルフレームワーク ───────────────────────────────┐│
│  │ Core Media / Core Audio / Core Video / VideoToolbox     ││
│  │ AudioToolbox / Metal / Accelerate                       ││
│  └───────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────┘
```

| レイヤー | 役割 | 主要クラス |
|---|---|---|
| **AVKit** | 再生 UI の提供 | `VideoPlayer`, `AVPlayerViewController`, `AVPlayerView`, `AVRoutePickerView` |
| **AVFoundation** | メディア処理エンジン | `AVPlayer`, `AVAsset`, `AVCaptureSession`, `AVAudioEngine`, `AVComposition` |
| **Core Media 等** | 低レベルメディア処理 | `CMTime`, `CMSampleBuffer`, `CVPixelBuffer`, `AudioBuffer` |

---

## 2. AVKit の主要機能

### 2.1 VideoPlayer（SwiftUI）

SwiftUI でのメディア再生を提供するビュー。`AVPlayer` を受け取り、システム標準の再生 UI を自動表示する。

```swift
import AVKit
import SwiftUI

// ローカルファイル再生
struct ContentView: View {
    let player = AVPlayer(url: Bundle.main.url(
        forResource: "sample", withExtension: "mp4"
    )!)

    var body: some View {
        VideoPlayer(player: player)
            .frame(height: 300)
            .onAppear { player.play() }
    }
}

// リモート URL 再生
struct StreamingView: View {
    let player = AVPlayer(url: URL(
        string: "https://example.com/video.mp4"
    )!)

    var body: some View {
        VideoPlayer(player: player)
    }
}

// オーバーレイ付き VideoPlayer
struct OverlayView: View {
    let player = AVPlayer(url: URL(string: "https://example.com/video.mp4")!)

    var body: some View {
        VideoPlayer(player: player) {
            VStack {
                Spacer()
                Text("ライブ配信中")
                    .padding(8)
                    .background(.red)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding()
        }
    }
}
```

**VideoPlayer の自動提供機能:**
| 機能 | 説明 |
|---|---|
| 再生 / 一時停止 | タップで切り替え |
| シークバー | ドラッグで再生位置を変更 |
| 音量調整 | スライダーで音量変更 |
| フルスクリーン | ボタンで全画面切り替え |
| AirPlay | Apple TV 等への出力ピッカー |
| 字幕 / クローズドキャプション | HLS で提供される字幕の選択 |
| 再生速度 | 速度変更 UI |

### 2.2 AVPlayerViewController（UIKit）

UIKit でのメディア再生コントローラー。VideoPlayer よりも高度なカスタマイズが可能。

```swift
import AVKit
import UIKit

class PlayerViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let url = URL(string: "https://example.com/stream.m3u8")!
        let player = AVPlayer(url: url)

        let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.allowsPictureInPicturePlayback = true
        playerVC.showsPlaybackControls = true
        playerVC.entersFullScreenWhenPlaybackBegins = true
        playerVC.exitsFullScreenWhenPlaybackEnds = true
        playerVC.canStartPictureInPictureAutomaticallyFromInline = true

        present(playerVC, animated: true) {
            player.play()
        }
    }
}
```

**AVPlayerViewController 固有機能:**
| 機能 | 説明 |
|---|---|
| `allowsPictureInPicturePlayback` | ピクチャ・イン・ピクチャ対応 |
| `canStartPictureInPictureAutomaticallyFromInline` | ホームに戻った時に自動 PiP |
| `entersFullScreenWhenPlaybackBegins` | 再生開始時に自動フルスクリーン |
| `exitsFullScreenWhenPlaybackEnds` | 再生完了時にフルスクリーン解除 |
| `showsTimecodes` | タイムコード表示 |
| `requiresLinearPlayback` | シーク禁止（広告再生等） |
| `contentOverlayView` | カスタムオーバーレイビュー |
| `updatesNowPlayingInfoCenter` | Now Playing 情報の自動更新 |

### 2.3 ピクチャ・イン・ピクチャ（PiP）

動画をフローティングウィンドウで表示し、他のアプリを使いながら視聴を継続する機能。

```swift
import AVKit

class PiPManager: NSObject, AVPictureInPictureControllerDelegate {
    var pipController: AVPictureInPictureController?

    func setupPiP(with playerLayer: AVPlayerLayer) {
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }

        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        pipController?.delegate = self
        pipController?.canStartPictureInPictureAutomaticallyFromInline = true
    }

    func startPiP() {
        pipController?.startPictureInPicture()
    }

    // デリゲートメソッド
    func pictureInPictureControllerWillStartPictureInPicture(
        _ controller: AVPictureInPictureController) {
        print("PiP 開始")
    }

    func pictureInPictureControllerDidStopPictureInPicture(
        _ controller: AVPictureInPictureController) {
        print("PiP 終了")
    }

    func pictureInPictureController(
        _ controller: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler
            completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
}
```

**PiP の動作:**
```
┌─ アプリ内インライン再生 ────────┐     ┌─ PiP フローティング ──┐
│  ┌──────────────────────────┐  │     │  ┌──────────┐         │
│  │       🎬 動画再生         │  │ →→→ │  │  🎬 動画  │ ← 小窓  │
│  │  ▶️ ──────●──────────── │  │     │  │  (ドラッグ│  で追従  │
│  └──────────────────────────┘  │     │  │   可能)   │         │
│  その他の UI                    │     │  └──────────┘         │
└────────────────────────────────┘     │  他のアプリを自由に操作  │
                                       └───────────────────────┘
```

**対応条件:**
- iPhone: iOS 14+
- iPad: iOS 9+
- `Audio, AirPlay, and Picture in Picture` バックグラウンドモードの有効化が必要

### 2.4 AirPlay

Apple TV やその他の AirPlay 対応デバイスにメディアをストリーミングする機能。

```swift
import AVKit

// AirPlay ルートピッカー（UIViewRepresentable でラップ）
struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.tintColor = .systemBlue
        picker.activeTintColor = .systemGreen
        return picker
    }
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}

// AVPlayer は AirPlay をデフォルトでサポート
let player = AVPlayer(url: streamURL)
player.allowsExternalPlayback = true
```

### 2.5 Now Playing 情報

ロック画面とコントロールセンターに再生中のメディア情報を表示。

```swift
import MediaPlayer

func updateNowPlayingInfo(title: String, artist: String,
                          duration: TimeInterval, currentTime: TimeInterval,
                          artwork: UIImage?) {
    var info = [String: Any]()
    info[MPMediaItemPropertyTitle] = title
    info[MPMediaItemPropertyArtist] = artist
    info[MPMediaItemPropertyPlaybackDuration] = duration
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
    info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0

    if let image = artwork {
        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
            boundsSize: image.size) { _ in image }
    }
    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
}

// リモートコマンド（ロック画面のコントロール）
func setupRemoteCommands() {
    let commandCenter = MPRemoteCommandCenter.shared()

    commandCenter.playCommand.addTarget { _ in
        self.player.play(); return .success
    }
    commandCenter.pauseCommand.addTarget { _ in
        self.player.pause(); return .success
    }
    commandCenter.skipForwardCommand.preferredIntervals = [15]
    commandCenter.skipForwardCommand.addTarget { event in
        guard let event = event as? MPSkipIntervalCommandEvent else { return .commandFailed }
        let currentTime = self.player.currentTime()
        self.player.seek(to: CMTime(
            seconds: currentTime.seconds + event.interval, preferredTimescale: 600))
        return .success
    }
}
```

**ロック画面 / コントロールセンター表示:**
```
┌─ ロック画面 ──────────────────────────────────┐
│  ┌─────┐  🎵 曲名 / 動画タイトル               │
│  │ 🖼️  │  アーティスト名                       │
│  │     │                                      │
│  └─────┘  ◀◀  ▶️/⏸️  ▶▶                      │
│           ──────●────────── 2:34 / 5:12       │
│           🔈 ──────●───── 🔊                  │
└───────────────────────────────────────────────┘
```

---

## 3. AVFoundation — メディアエンジン詳細

### 3.1 AVPlayer / AVQueuePlayer

```swift
import AVFoundation

// 単一メディア再生
let player = AVPlayer(url: mediaURL)
player.play()

// 連続再生（プレイリスト）
let items = urls.map { AVPlayerItem(url: $0) }
let queuePlayer = AVQueuePlayer(items: items)
queuePlayer.play()

// 再生状態の監視
player.addPeriodicTimeObserver(
    forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
    queue: .main
) { time in
    print("再生位置: \(time.seconds)秒")
}

// ステータス監視（Combine）
playerItem.publisher(for: \.status)
    .sink { status in
        switch status {
        case .readyToPlay: print("再生準備完了")
        case .failed:      print("エラー")
        default: break
        }
    }
```

**AVPlayer の主要プロパティ:**
| 機能 | メソッド / プロパティ |
|---|---|
| 再生 / 一時停止 | `play()`, `pause()` |
| シーク | `seek(to:)`, `seek(to:toleranceBefore:toleranceAfter:)` |
| 再生速度 | `rate` (0.0 = 停止, 1.0 = 通常, 2.0 = 2 倍速) |
| 音量 | `volume` (0.0 〜 1.0) |
| ミュート | `isMuted` |
| AirPlay | `allowsExternalPlayback` |
| バッファリング | `automaticallyWaitsToMinimizeStalling` |

### 3.2 HLS ストリーミング（HTTP Live Streaming）

Apple 標準のアダプティブビットレートストリーミングプロトコル。

```swift
// HLS ストリームの再生（.m3u8 URL を指定するだけ）
let hlsURL = URL(string: "https://example.com/stream/master.m3u8")!
let player = AVPlayer(url: hlsURL)
player.play()
// AVPlayer が自動的にネットワーク状況に応じて最適なビットレートを選択
```

**HLS マスタープレイリスト構造:**
```
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
low/stream.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2000000,RESOLUTION=1280x720
mid/stream.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=1920x1080
high/stream.m3u8
```

| HLS 機能 | 説明 |
|---|---|
| **アダプティブビットレート** | ネットワーク状況に応じて自動品質切り替え |
| **ライブ / VOD** | ライブ配信・オンデマンド両対応 |
| **字幕 / オーディオトラック** | 複数言語の字幕・音声切り替え |
| **広告挿入** | プレロール / ミッドロール広告 |
| **FairPlay DRM** | コンテンツ保護 |
| **オフライン再生** | HLS コンテンツのダウンロード保存 |
| **低遅延 HLS** | ライブ配信の低遅延化 |

### 3.3 FairPlay Streaming（DRM）

Apple の DRM 技術。HLS コンテンツを暗号化し、正規ユーザーのみ再生可能にする。

```
FairPlay フロー:

  アプリ           Apple DRM         ライセンスサーバー
   │                │                    │
   │─ HLS 再生要求 →│                    │
   │                │─ 暗号化検出 →       │
   │← SPC 要求 ────│                    │
   │─ SPC 生成 ───→│───→ SPC 送信 ────→│
   │                │                    │─ SPC 検証
   │                │←── CKC 返却 ──────│← CKC 発行
   │← CKC 適用 ────│                    │
   │                │─ 復号・再生         │
```

### 3.4 AVCaptureSession（カメラ・マイク入力）

カメラとマイクからのリアルタイム入出力を管理する中心クラス。

```swift
import AVFoundation

class CameraManager: NSObject {
    let captureSession = AVCaptureSession()

    func setupSession() throws {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high

        // カメラ入力
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera, for: .video, position: .back
        ) else { throw CameraError.noCameraAvailable }
        let videoInput = try AVCaptureDeviceInput(device: camera)
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        // マイク入力
        guard let mic = AVCaptureDevice.default(for: .audio) else {
            throw CameraError.noMicrophoneAvailable
        }
        let audioInput = try AVCaptureDeviceInput(device: mic)
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }

        // 出力の追加（フレーム処理 / 写真 / 動画 / 深度 / メタデータ）
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        captureSession.commitConfiguration()
    }
}
```

**セッション構成図:**
```
┌─ AVCaptureSession ────────────────────────────────────┐
│                                                        │
│  入力 (Inputs)               出力 (Outputs)             │
│  ┌────────────────┐         ┌──────────────────────┐  │
│  │ 📷 背面カメラ    │────→───│ 🎬 MovieFileOutput   │  │
│  └────────────────┘    │    │    (動画ファイル保存)   │  │
│  ┌────────────────┐    │    └──────────────────────┘  │
│  │ 🤳 前面カメラ    │──┐ │   ┌──────────────────────┐  │
│  └────────────────┘  │ ├──│ 📸 PhotoOutput        │  │
│  ┌────────────────┐  │ │   └──────────────────────┘  │
│  │ 🎤 マイク       │──┴─┤   ┌──────────────────────┐  │
│  └────────────────┘    ├──│ 🖥️ VideoDataOutput     │  │
│                         │   │    (フレーム単位処理)    │  │
│                         │   └──────────────────────┘  │
│                         │   ┌──────────────────────┐  │
│                         ├──│ 📏 DepthDataOutput    │  │
│                         │   └──────────────────────┘  │
│                         │   ┌──────────────────────┐  │
│                         └──│ 📊 MetadataOutput     │  │
│                              │    (QR/バーコード等)   │  │
│                              └──────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

**カメラ機能一覧:**
| 機能 | API | 対応 |
|---|---|---|
| **写真撮影** | `AVCapturePhotoOutput` | 全機種 |
| **動画録画** | `AVCaptureMovieFileOutput` | 全機種 |
| **スローモーション** | 120fps / 240fps | iPhone 5s+ |
| **深度キャプチャ** | `AVCaptureDepthDataOutput` | デュアルカメラ / LiDAR |
| **4K 録画** | `.hd4K3840x2160` | iPhone 6s+ |
| **HDR ビデオ** | `videoHDREnabled` | iPhone 12+ |
| **手ブレ補正** | `preferredVideoStabilizationMode` | iPhone 6+ |
| **QR / バーコード** | `AVCaptureMetadataOutput` | 全機種 |
| **Zero Shutter Lag** | `zeroShutterLagEnabled` | iOS 17+ |

### 3.5 AVComposition（動画編集・合成）

複数のメディアトラックを合成して新しいメディアを生成。

```swift
import AVFoundation

func mergeVideos(urls: [URL]) async throws -> URL {
    let composition = AVMutableComposition()

    guard let videoTrack = composition.addMutableTrack(
        withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid
    ) else { throw CompositionError.cannotCreateTrack }

    guard let audioTrack = composition.addMutableTrack(
        withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid
    ) else { throw CompositionError.cannotCreateTrack }

    var currentTime = CMTime.zero
    for url in urls {
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        if let src = try await asset.loadTracks(withMediaType: .video).first {
            try videoTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: duration), of: src, at: currentTime)
        }
        if let src = try await asset.loadTracks(withMediaType: .audio).first {
            try audioTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: duration), of: src, at: currentTime)
        }
        currentTime = CMTimeAdd(currentTime, duration)
    }

    // エクスポート
    let outputURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("merged.mp4")
    guard let exportSession = AVAssetExportSession(
        asset: composition, presetName: AVAssetExportPresetHighestQuality
    ) else { throw CompositionError.cannotCreateExportSession }
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    await exportSession.export()
    return outputURL
}
```

**AVComposition でできること:**
| 機能 | 説明 |
|---|---|
| **動画結合** | 複数動画をシーケンシャルに連結 |
| **トリミング** | 動画の特定区間を切り出し |
| **オーディオミキシング** | BGM の追加、音量調整 |
| **ビデオレイヤー合成** | テキスト / 画像をオーバーレイ |
| **トランジション** | クロスディゾルブ等の効果 |
| **速度変更** | スローモーション / 早送り |
| **ウォーターマーク** | ロゴ / テキストの重ね合わせ |
| **フィルター** | CIFilter でリアルタイム映像加工 |

### 3.6 AVAudioEngine（オーディオ処理）

リアルタイムのオーディオ処理パイプライン。

```swift
import AVFoundation

class AudioProcessor {
    let audioEngine = AVAudioEngine()

    func setupAudioProcessing() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // エフェクトノード
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.cathedral)
        reverb.wetDryMix = 50

        let pitch = AVAudioUnitTimePitch()
        pitch.pitch = 400  // +400 セント

        let eq = AVAudioUnitEQ(numberOfBands: 3)
        eq.bands[0].frequency = 100;   eq.bands[0].gain = 5
        eq.bands[1].frequency = 1000;  eq.bands[1].gain = 0
        eq.bands[2].frequency = 10000; eq.bands[2].gain = 3

        // ノード接続
        audioEngine.attach(reverb)
        audioEngine.attach(pitch)
        audioEngine.attach(eq)
        audioEngine.connect(inputNode, to: pitch, format: format)
        audioEngine.connect(pitch, to: reverb, format: format)
        audioEngine.connect(reverb, to: eq, format: format)
        audioEngine.connect(eq, to: audioEngine.mainMixerNode, format: format)

        try? audioEngine.start()
    }
}
```

**オーディオ処理パイプライン:**
```
┌─ AVAudioEngine ─────────────────────────────────────────┐
│                                                          │
│  入力              エフェクトチェーン           出力       │
│  ┌──────────┐    ┌──────────────────┐    ┌──────────┐  │
│  │ 🎤 マイク │→→→│ TimePitch(ピッチ)  │→→→│ 🔊 出力   │  │
│  └──────────┘    │ Reverb(残響)      │    └──────────┘  │
│  ┌──────────┐    │ EQ(イコライザー)   │                  │
│  │ 🎵 ファイル│→→→│ Distortion(歪み)  │→→→ ...          │
│  └──────────┘    │ Delay(ディレイ)    │                  │
│                   └──────────────────┘                   │
└──────────────────────────────────────────────────────────┘
```

| エフェクトノード | 説明 |
|---|---|
| `AVAudioUnitTimePitch` | ピッチ変更 / 再生速度変更 |
| `AVAudioUnitReverb` | リバーブ（残響） |
| `AVAudioUnitEQ` | イコライザー |
| `AVAudioUnitDistortion` | ディストーション |
| `AVAudioUnitDelay` | ディレイ（エコー） |
| `AVAudioUnitVarispeed` | 可変速再生 |

### 3.7 Core ML / Vision 連携（リアルタイム映像解析）

AVCaptureSession のフレーム出力を Core ML / Vision にリアルタイムで渡す。

```swift
import AVFoundation
import Vision

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Vision: 顔検出
        let faceRequest = VNDetectFaceRectanglesRequest { request, _ in
            guard let results = request.results as? [VNFaceObservation] else { return }
            for face in results { print("顔検出: \(face.boundingBox)") }
        }

        // Vision: テキスト認識
        let textRequest = VNRecognizeTextRequest { request, _ in
            guard let results = request.results as? [VNRecognizedTextObservation] else { return }
            for obs in results {
                if let text = obs.topCandidates(1).first?.string {
                    print("テキスト: \(text)")
                }
            }
        }
        textRequest.recognitionLanguages = ["ja", "en"]

        // Core ML: カスタムモデル
        guard let model = try? VNCoreMLModel(for: MyClassifier().model) else { return }
        let mlRequest = VNCoreMLRequest(model: model) { request, _ in
            guard let results = request.results as? [VNClassificationObservation],
                  let top = results.first else { return }
            print("分類: \(top.identifier) (\(top.confidence * 100)%)")
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([faceRequest, textRequest, mlRequest])
    }
}
```

---

## 4. プラットフォーム別の AVKit 対応

| 機能 | iOS | iPadOS | macOS | tvOS | visionOS |
|---|---|---|---|---|---|
| **VideoPlayer (SwiftUI)** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **AVPlayerViewController** | ✅ | ✅ | ❌ | ✅ | ✅ |
| **PiP** | ✅ | ✅ | ✅ | ✅ | ❌ |
| **AirPlay** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **HLS** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **FairPlay DRM** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **4K ビデオ** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **空間オーディオ** | ✅ | ✅ | ✅ | ❌ | ✅ |
| **3D / 空間ビデオ** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **マルチビュー** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **AVCaptureSession** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **AVAudioEngine** | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## 5. 最新の WWDC アップデート

### WWDC 2022: 優れたビデオ再生体験

- `AVPlayerViewController` のインライン再生とフルスクリーン再生の最適化
- Visual Intelligence API との統合

### WWDC 2023: 空間再生体験

- **visionOS 対応:** `AVPlayerViewController` が visionOS でネイティブ動作
- **VideoPlayerComponent (RealityKit):** 3D 空間にビデオを配置
- **3D ビデオ:** MV-HEVC（Multiview HEVC）による立体映像再生
- **インライン再生の再設計:** visionOS 向けに最適化されたコントロール

### WWDC 2024: マルチビューと没入体験

- **マルチビュー:** 最大 5 画面の同時再生（visionOS）
- **カスタム環境:** 再生中の没入環境のカスタマイズ
- **ドッキング領域:** フルスクリーン時の配置カスタマイズ
- **LockedCamera Capture:** iOS 18 の新カメラ API

### WWDC 2025: 没入型ビデオとオーディオ強化

- **AVExperienceController:** 没入体験への遷移制御（visionOS 26）
- **APMP（Apple Projected Media Profile）:** 180° / 360° / 広角 FoV ビデオ
- **高モーション検出:** アクション映像での没入度自動調整
- **AVInputPickerInteraction:** マイク入力選択 UI（音量メーター + マイクモード選択）
- **空間スタイリング:** AVKit / RealityKit / Safari での空間ビデオサポート

---

## 6. 設計上の制約と注意点

### 6.1 技術的制約

| 制約 | 詳細 |
|---|---|
| **コーデック** | H.264 / HEVC / ProRes が主要対応。VP9 / AV1 は限定的 |
| **バックグラウンド再生** | バックグラウンドモードの有効化が必要 |
| **同時再生制限** | AVPlayer 同時インスタンスは推奨 4 以下 |
| **DRM 制約** | FairPlay はライセンスサーバー運用が必要 |
| **カメラアクセス** | `NSCameraUsageDescription` / `NSMicrophoneUsageDescription` 必須 |
| **バッテリー** | 4K / HDR 録画・再生は高負荷 |
| **ストレージ** | 4K 60fps: 約 400MB / 分 |

### 6.2 開発上の推奨事項

| 項目 | 推奨 |
|---|---|
| **新規開発** | SwiftUI `VideoPlayer` を第一候補。カスタムが必要なら `AVPlayerViewController` |
| **HLS** | アダプティブビットレート、字幕、DRM が必要なら HLS を推奨 |
| **PiP** | ユーザー体験向上のため積極的に実装 |
| **Now Playing** | ロック画面 / コントロールセンター対応は必須 |
| **エラーハンドリング** | ネットワーク断、バッファリング、DRM エラーを適切に処理 |

---

## 7. iOS アプリ活用アイデア

### アイデア 1: 「CineMagic — AI リアルタイム映画フィルター撮影」

**コンセプト:** AVCaptureSession のリアルタイムフレーム処理 + Core ML を組み合わせ、カメラ映像をリアルタイムで映画のような色調・質感に変換するアプリ。「ノーラン風」「ウェス・アンダーソン風」「ジブリ風」等の映画監督スタイルを AI が即時適用。

```
撮影画面:

  ┌─ カメラビュー ──────────────────────────────┐
  │  ┌──────────────────────────────────────┐   │
  │  │   リアルタイムで映画風フィルター適用     │   │
  │  │                                      │   │
  │  │   🎬 現在: "ウェス・アンダーソン風"     │   │
  │  │   パステルカラー + 左右対称構図ガイド   │   │
  │  └──────────────────────────────────────┘   │
  │                                              │
  │  フィルター選択:                               │
  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐       │
  │  │ノーラ│ │ウェス│ │ジブリ│ │タラン│ │リンチ │       │
  │  │ン   │ │    │ │    │ │ティ│ │    │       │
  │  └────┘ └────┘ └────┘ └────┘ └────┘       │
  │                                              │
  │  AI 構図アドバイス:                             │
  │  "少し右に寄ると黄金比に近づきます"              │
  │                                              │
  │        [📸 写真]    [🎬 動画]                 │
  └──────────────────────────────────────────────┘
```

**仕組み:**
- **AVCaptureSession:** カメラ入力をフレーム単位で取得
- **Core ML (Style Transfer):** 映画監督スタイルの Neural Style Transfer モデルをリアルタイム適用
- **CIFilter:** 色調補正、ビネット、グレインの映画的ポストプロセッシング
- **Metal:** GPU シェーダーで高速リアルタイム処理
- **Vision:** 構図分析（三分割法、黄金比）で撮影アドバイス
- **AVComposition:** 撮影後にトランジション、BGM、テロップで「ショートフィルム」化

**面白い点:**
- 「スマホで撮ったのに映画みたい」— SNS 映え + クリエイティブツール
- AI 構図アドバイスで映画的な画角を学べる
- 動画撮影後の自動編集で短編映画に仕上がる

**技術構成:** AVKit + AVFoundation（AVCaptureSession + AVComposition） + Core ML + Vision + Metal + CIFilter

---

### アイデア 2: 「VoiceMorph — リアルタイムボイスチェンジャー」

**コンセプト:** AVAudioEngine のリアルタイムオーディオパイプラインを活用した「ボイスチェンジャー」アプリ。マイク入力をリアルタイムで加工し、様々な声（ロボット、ヘリウム、低音、宇宙人等）に変換。録音・共有にも対応。

```
メイン画面:

  ┌─ VoiceMorph ──────────────────────────────┐
  │  🎤 マイク入力中...                           │
  │  ████████████░░░░░░░░░░░░ -12 dB            │
  │                                             │
  │  ┌─ ボイスプリセット ──────────────────────┐ │
  │  │  🤖 ロボット    🎈 ヘリウム   👹 デーモン │ │
  │  │  🌊 水中       👽 宇宙人    🎭 アナウンサー│ │
  │  └─────────────────────────────────────────┘ │
  │                                             │
  │  ┌─ カスタムパラメータ ──────────────────┐   │
  │  │ ピッチ:    ◀── ────●──────── ▶ +400   │   │
  │  │ リバーブ:  ◀── ──●────────── ▶ 30%    │   │
  │  │ ディレイ:  ◀── ●──────────── ▶ 10ms   │   │
  │  │ 歪み:     ◀── ─────────●─── ▶ 70%    │   │
  │  └──────────────────────────────────────┘   │
  │                                             │
  │  [🔴 録音] [📤 共有] [📞 通話モード]         │
  └─────────────────────────────────────────────┘

  パイプライン:
  マイク → TimePitch → Reverb → EQ → Distortion → Delay → 出力
```

**仕組み:**
- **AVAudioEngine:** マイク → エフェクトチェーン → スピーカーのリアルタイムパイプライン
- **AVAudioUnitTimePitch / Reverb / Distortion / Delay / EQ:** エフェクトの組み合わせ
- **installTap:** リアルタイム音量メーターとウェーブフォーム表示

**面白い点:**
- リアルタイム処理で「話しながら」声が変わる（遅延は数ミリ秒）
- プリセットですぐ使える + カスタムパラメータで細かく調整
- ゲーム実況、ポッドキャスト、匿名通話等に活用

**技術構成:** AVFoundation（AVAudioEngine + エフェクトノード） + Accelerate（FFT / ウェーブフォーム）

---

### アイデア 3: 「WatchParty — 離れた友人と同期視聴」

**コンセプト:** HLS ストリーミング + SharePlay を活用して、離れた友人と動画を完全同期再生するアプリ。再生・一時停止・シークが全員同時に同期し、音声チャット + リアクションが重なる。

```
視聴画面:

  ┌─ WatchParty ──────────────────────────────┐
  │  ┌───────────────────────────────────────┐ │
  │  │         🎬 動画再生エリア               │ │
  │  │         (HLS ストリーミング)             │ │
  │  │  ▶️ ─────●──────────── 23:45 / 1:42:30│ │
  │  └───────────────────────────────────────┘ │
  │                                             │
  │  ┌─ 同期中の参加者 ──────────────────────┐ │
  │  │ 👤 Aさん (ホスト)  🟢 同期中           │ │
  │  │ 👤 Bさん           🟢 同期中           │ │
  │  │ 👤 Cさん           🟡 バッファリング    │ │
  │  └───────────────────────────────────────┘ │
  │                                             │
  │  ┌─ リアクション ────────────────────┐     │
  │  │ 😂 → Aさん  🔥 → Bさん  😱 → Cさん │     │
  │  └──────────────────────────────────┘     │
  │                                             │
  │  [🎤 音声チャット ON] [😂😍🔥 リアクション]  │
  └─────────────────────────────────────────────┘
```

**仕組み:**
- **AVKit (VideoPlayer):** HLS ストリームの再生 UI
- **SharePlay (GroupActivities):** Apple 公式の同期再生フレームワーク
- **AVAudioEngine:** 音声チャットのリアルタイム処理
- **PiP:** バックグラウンドでも視聴継続

**面白い点:**
- 「映画館で友人と一緒に観る」体験を遠隔で再現
- SharePlay 連携で FaceTime からシームレスに視聴開始
- リアクションがタイムライン上に表示 → 同じシーンでの共感
- PiP でチャットしながら視聴継続

**技術構成:** AVKit（VideoPlayer + PiP） + AVFoundation（AVPlayer + AVAudioEngine） + GroupActivities (SharePlay)

---

### アイデア 4: 「SoundScape — 環境音 AI 分析・可視化」

**コンセプト:** AVAudioEngine のリアルタイム音声入力 + Core ML の Sound Analysis を組み合わせ、周囲の環境音をリアルタイムで分類・可視化するアプリ。鳥の声、車の音、人の話し声、楽器の音等を識別し、美しいビジュアライゼーションで表示。

```
メイン画面:

  ┌─ SoundScape ──────────────────────────────┐
  │  ┌─ リアルタイムスペクトログラム ──────────┐ │
  │  │  ▓▓░░▓▓▓░░░▓▓░░▓▓▓▓░░░▓▓░░▓▓▓░░░    │ │
  │  │  ▓▓▓░▓▓▓▓░░▓▓▓░▓▓▓▓▓░░▓▓▓░▓▓▓▓░░    │ │
  │  │  ▓▓▓▓▓▓▓▓░▓▓▓▓▓▓▓▓▓▓░▓▓▓▓▓▓▓▓▓▓░    │ │
  │  │  20Hz ─────────────── 20kHz            │ │
  │  └────────────────────────────────────────┘ │
  │                                             │
  │  ┌─ AI 音分類（リアルタイム）─────────────┐ │
  │  │  🐦 鳥の声         ████████░░ 82%       │ │
  │  │  🚗 車の走行音      ██████░░░░ 65%       │ │
  │  │  💨 風              ████░░░░░░ 41%       │ │
  │  │  🗣️ 人の話し声      ██░░░░░░░░ 23%       │ │
  │  └─────────────────────────────────────────┘ │
  │                                             │
  │  ┌─ 今日の環境音ログ ──────────────────┐   │
  │  │  08:00 🐦 朝の鳥の合唱 (15分)        │   │
  │  │  08:30 🚗 通勤の車両音 (20分)         │   │
  │  │  09:00 ⌨️ オフィス環境音 (2時間)       │   │
  │  └────────────────────────────────────────┘ │
  │                                             │
  │  [🔴 録音中] [📊 統計] [🗺️ 音マップ]        │
  └─────────────────────────────────────────────┘
```

**仕組み:**
- **AVAudioEngine (installTap):** マイク入力をリアルタイムでバッファリング
- **Accelerate (vDSP):** FFT でスペクトログラム生成
- **Core ML + SoundAnalysis:** 環境音を 300+ カテゴリに分類
- **Core Location:** 位置情報を付与 → 「音マップ」生成
- **HealthKit:** 騒音レベルを健康データとして記録
- **Metal:** スペクトログラムの GPU レンダリング

**面白い点:**
- 「目に見えない音の世界」を可視化する新しい体験
- 環境音ログが「1 日の音の日記」に
- 音マップ: 散歩コースの音の風景を地図上に可視化
- 騒音レベル記録で聴覚保護（HealthKit 連携）
- バードウォッチング / 自然観察のツール
- 物理（音波 / 周波数）の教育ツール

**技術構成:** AVFoundation（AVAudioEngine） + Core ML + SoundAnalysis + Accelerate + Metal + Core Location + HealthKit

---

### アイデア 5: 「ReelForge — AI ショートムービー自動生成」

**コンセプト:** カメラロールの動画・写真から AI が自動的にハイライトを検出し、BGM・トランジション・テロップ付きのショートムービー（15〜60 秒）を自動生成するアプリ。

```
生成フロー:

  Step 1: 素材選択
  📸📸📸🎬🎬📸🎬📸📸🎬
  AI が自動で「ベストショット」を選出

  Step 2: AI 分析
  ┌──────────────────────────────────────────┐
  │ Vision: 顔検出 → 笑顔シーン優先          │
  │ Core ML: シーン分類 → 景色/食事/人物      │
  │ AVAsset: 手ブレ少ない安定シーン優先       │
  │ 音声分析: 笑い声/歓声シーン優先           │
  └──────────────────────────────────────────┘

  Step 3: 自動編集（AVComposition）
  ┌────┐ ╲╱ ┌────┐ ╲╱ ┌────┐ ╲╱ ┌────┐
  │ S1 │→→→│ S2 │→→→│ S3 │→→→│ S4 │
  └────┘    └────┘    └────┘    └────┘
  トランジション + BGM + テロップ自動配置

  Step 4: プレビュー & 共有
  ┌───────────────────────────────────────┐
  │      🎬 "夏の思い出 2026"              │
  │      ▶️ ───●──────── 0:28 / 0:45     │
  │                                       │
  │  タイムライン:                          │
  │  [S1][S2][S3][S4][S5][S6][S7][S8]     │
  │  🎵 BGM: Summer Vibes                 │
  │                                       │
  │  [🔄 再生成] [✏️ 編集] [📤 SNS 共有]   │
  └───────────────────────────────────────┘
```

**仕組み:**
- **Photos Framework:** カメラロールからの素材取得
- **Vision:** 顔検出（笑顔スコア）、シーン分類、テキスト認識
- **Core ML:** 「映え」スコアリング（色彩、構図、動きの面白さ）
- **AVComposition:** クリップの結合、トリミング、速度変更
- **AVVideoCompositionCoreAnimationTool:** テロップ、ウォーターマーク
- **AVAssetExportSession:** 最終書き出し（H.264 / HEVC）
- **AVAudioEngine:** BGM のビートに合わせたカット切り替えタイミング計算

**面白い点:**
- 「10 分の旅行動画」→「45 秒の映える Reel」を AI が自動生成
- BGM のビートに合わせてカットが切り替わる → プロっぽい仕上がり
- 笑顔シーン優先 + 手ブレ除外 = 質の高い自動選出
- ワンタップで SNS に共有

**技術構成:** AVKit + AVFoundation（AVComposition + AVAudioEngine） + Vision + Core ML + Photos Framework + Metal

---

## 8. まとめ

| 観点 | 評価 |
|---|---|
| **機能の幅** | ★★★★★ — 再生 / 撮影 / 編集 / オーディオ / ストリーミング / DRM まで全領域カバー |
| **エコシステム** | ★★★★★ — Core ML / Vision / Metal / HealthKit 等と深く統合 |
| **クロスプラットフォーム** | ★★★★★ — iOS / iPadOS / macOS / tvOS / visionOS 全対応 |
| **開発体験** | ★★★★☆ — SwiftUI VideoPlayer は簡単。低レベル API は学習曲線あり |
| **カスタマイズ性** | ★★★★★ — 低レベル API で完全なカスタマイズが可能 |
| **成熟度** | ★★★★★ — iOS 初期から存在する最も成熟したフレームワークの一つ |

### AVKit / AVFoundation が最も輝くパターン

1. **動画再生アプリ** — HLS + PiP + AirPlay + DRM で本格的な動画配信
2. **カメラアプリ** — AVCaptureSession でフル制御のカスタムカメラ
3. **動画編集** — AVComposition で非破壊のタイムライン編集
4. **リアルタイム映像解析** — カメラフレーム → Core ML / Vision
5. **オーディオ処理** — AVAudioEngine でリアルタイムエフェクト
6. **ショートムービー生成** — AI 解析 + 自動編集 + BGM 合成

### 参考リンク

- [Apple Developer — AVKit](https://developer.apple.com/documentation/avkit)
- [Apple Developer — AVFoundation](https://developer.apple.com/documentation/avfoundation)
- [Apple Developer — VideoPlayer (SwiftUI)](https://developer.apple.com/documentation/avkit/videoplayer)
- [Apple Developer — AVPlayerViewController](https://developer.apple.com/documentation/avkit/avplayerviewcontroller)
- [Apple Developer — AVCaptureSession](https://developer.apple.com/documentation/avfoundation/avcapturesession)
- [Apple Developer — AVAudioEngine](https://developer.apple.com/documentation/avfaudio/avaudioengine)
- [Apple Developer — AVComposition](https://developer.apple.com/documentation/avfoundation/avcomposition)
- [Apple Developer — HLS Authoring Specification](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices)
- [Apple Developer — FairPlay Streaming](https://developer.apple.com/streaming/fps/)
- [WWDC22: Create a great video playback experience](https://developer.apple.com/videos/play/wwdc2022/10147/)
- [WWDC23: Create a great spatial playback experience](https://developer.apple.com/videos/play/wwdc2023/10070/)
- [WWDC23: Create a more responsive camera experience](https://developer.apple.com/videos/play/wwdc2023/10105/)
- [WWDC24: Enhance the immersion of media viewing](https://developer.apple.com/videos/play/wwdc2024/10115/)
- [WWDC25: Support immersive video playback in visionOS](https://developer.apple.com/videos/play/wwdc2025/296/)
- [Create with Swift — HLS Streaming with AVKit and SwiftUI](https://www.createwithswift.com/hls-streaming-with-avkit-and-swiftui/)
- [Create with Swift — Custom Video Player with PiP](https://www.createwithswift.com/custom-video-player-with-avkit-and-swiftui-supporting-picture-in-picture/)
