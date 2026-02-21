import Foundation
import CoreLocation
import SwiftUI

/// AmeNige のメインビューモデル
@MainActor
@Observable
final class AmeNigeViewModel {
    // MARK: - State

    /// 分単位降水予報
    private(set) var minuteForecasts: [PrecipitationForecast] = []

    /// 時間別降水予報
    private(set) var hourlyForecasts: [HourlyPrecipitation] = []

    /// 晴れ間ウィンドウ
    private(set) var dryWindows: [DryWindow] = []

    /// 外出判定
    private(set) var verdict: OutdoorVerdict = .unavailable

    /// 現在の降水状況
    private(set) var currentPrecipitation: PrecipitationForecast?

    /// 気象アラート
    private(set) var alerts: [WeatherAlertInfo] = []

    /// 読み込み中フラグ
    private(set) var isLoading = false

    /// エラーメッセージ
    private(set) var errorMessage: String?

    /// 最終更新日時
    private(set) var lastUpdated: Date?

    /// 分単位予報が利用可能かどうか
    var isMinuteForecastAvailable: Bool {
        !minuteForecasts.isEmpty
    }

    /// 現在降水中かどうか
    var isCurrentlyRaining: Bool {
        currentPrecipitation?.isRaining ?? false
    }

    /// 次に雨が降り始める時刻
    var nextRainTime: Date? {
        guard !isCurrentlyRaining else { return nil }
        return minuteForecasts.first { $0.isRaining && $0.date > Date() }?.date
    }

    /// 次に雨が降り始めるまでの残り分数
    var minutesUntilRain: Int? {
        guard let rainTime = nextRainTime else { return nil }
        return max(0, Int(rainTime.timeIntervalSinceNow / 60))
    }

    /// 雨が止む時刻（現在降水中の場合）
    var rainStopTime: Date? {
        guard isCurrentlyRaining else { return nil }
        return minuteForecasts.first { !$0.isRaining && $0.date > Date() }?.date
    }

    /// 最終更新のテキスト
    var lastUpdatedText: String {
        guard let lastUpdated else { return "未更新" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: lastUpdated)) 更新"
    }

    // MARK: - Dependencies

    let locationManager = LocationManager()
    private let weatherKitManager = WeatherKitManager.shared

    // MARK: - Actions

    /// 位置情報の認可をリクエスト
    func requestLocationAccess() {
        locationManager.requestAuthorization()
    }

    /// 天気データをリフレッシュ
    func refresh() async {
        guard let location = locationManager.currentLocation else {
            locationManager.requestLocation()
            // ロケーション取得後に再度呼ばれるのを待つ
            return
        }

        await fetchWeatherData(for: location)
    }

    /// 指定位置の天気データを取得
    func fetchWeatherData(for location: CLLocation) async {
        isLoading = true
        errorMessage = nil

        do {
            // 並行で取得
            async let minuteTask = weatherKitManager.fetchMinuteForecast(for: location)
            async let hourlyTask = weatherKitManager.fetchHourlyForecast(for: location)
            async let currentTask = weatherKitManager.fetchCurrentPrecipitation(for: location)
            async let alertsTask = weatherKitManager.fetchAlerts(for: location)

            let (minutes, hourly, current, fetchedAlerts) = try await (
                minuteTask, hourlyTask, currentTask, alertsTask
            )

            minuteForecasts = minutes
            hourlyForecasts = hourly
            currentPrecipitation = current
            alerts = fetchedAlerts

            // 晴れ間ウィンドウを計算
            dryWindows = weatherKitManager.findDryWindows(in: minutes)

            // 外出判定
            verdict = weatherKitManager.judgeOutdoor(
                currentForecast: current,
                minuteForecasts: minutes
            )

            lastUpdated = Date()
        } catch {
            errorMessage = "天気データの取得に失敗しました: \(error.localizedDescription)"
            print("[AmeNigeVM] データ取得失敗: \(error)")
        }

        isLoading = false
    }
}
