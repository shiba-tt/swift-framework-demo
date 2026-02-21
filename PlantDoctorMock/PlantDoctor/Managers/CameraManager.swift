import Foundation
import AVFoundation

/// カメラへのアクセスを管理するマネージャー
@MainActor
@Observable
final class CameraManager: NSObject {

    // MARK: - State

    private(set) var authorizationStatus: AVAuthorizationStatus = .notDetermined
    private(set) var isCameraAvailable = false

    /// カメラが利用可能かどうか
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    // MARK: - Initialization

    override init() {
        super.init()
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        isCameraAvailable = AVCaptureDevice.default(for: .video) != nil
    }

    // MARK: - Authorization

    /// カメラの使用許可をリクエストする
    func requestAuthorization() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        authorizationStatus = granted ? .authorized : .denied
    }

    /// 許可状態を更新する
    func updateAuthorizationStatus() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
}
