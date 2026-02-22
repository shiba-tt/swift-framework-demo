import AVFoundation
import Foundation

/// カメラのセットアップと管理
@MainActor
@Observable
final class CameraManager {
    /// カメラが利用可能かどうか
    private(set) var isAvailable = false

    /// カメラ認可状態
    private(set) var authorizationStatus: AVAuthorizationStatus = .notDetermined

    /// カメラセッション
    let captureSession = AVCaptureSession()

    init() {
        checkAuthorization()
    }

    /// カメラの認可状態を確認
    func checkAuthorization() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        isAvailable = authorizationStatus == .authorized
    }

    /// カメラの認可をリクエスト
    func requestAuthorization() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        authorizationStatus = granted ? .authorized : .denied
        isAvailable = granted
    }

    /// カメラセッションを設定
    func setupSession() {
        guard isAvailable else { return }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera)
        else {
            captureSession.commitConfiguration()
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        captureSession.commitConfiguration()
    }
}
