import Foundation
import SwiftUI

/// GridPulse のメインビューモデル
@MainActor
@Observable
final class GridPulseViewModel {
    // MARK: - State

    /// 今日のグリッド状態一覧
    private(set) var gridStates: [GridState] = []

    /// 現在のグリッド状態
    private(set) var currentState: GridState?

    /// 日次サマリー
    private(set) var dailySummary: GridDailySummary?

    /// パーティクル群
    private(set) var particles: [EnergyParticle] = []

    /// 波形データ
    private(set) var waves: [WaveData] = []

    /// 選択中のアートテーマ
    var selectedTheme: ArtTheme = .wave

    /// アニメーションフェーズ
    var animationPhase: Double = 0

    /// 読み込み中フラグ
    private(set) var isLoading = false

    /// エラーメッセージ
    private(set) var errorMessage: String?

    /// 現在のクリーン度テキスト
    var currentCleanText: String {
        currentState?.cleanPercentText ?? "--"
    }

    /// 現在のテーマ名
    var currentThemeName: String {
        dailySummary?.themeName ?? "読み込み中..."
    }

    /// 現在のレベル
    var currentLevel: GridLevel {
        currentState?.level ?? .moderate
    }

    // MARK: - Dependencies

    let energyKitManager = GridEnergyKitManager.shared

    // MARK: - Init

    init() {
        generateDemoData()
    }

    // MARK: - Actions

    /// データの初回読み込み
    func initialize() async {
        isLoading = true
        await loadGridData()
        isLoading = false
    }

    /// グリッドデータを取得
    func loadGridData() async {
        errorMessage = nil

        do {
            gridStates = try await energyKitManager.fetchTodayGrid()
        } catch is GridEnergyKitError {
            generateDemoData()
        } catch {
            errorMessage = "グリッドデータの取得に失敗しました: \(error.localizedDescription)"
            generateDemoData()
        }

        updateCurrentState()
        updateArtElements()
    }

    /// アニメーションを更新
    func updateAnimation() {
        animationPhase += 0.02
        updateParticlePositions()
    }

    // MARK: - Private

    private func updateCurrentState() {
        currentState = gridStates.first {
            $0.date <= Date() && $0.date.addingTimeInterval(3600) > Date()
        } ?? gridStates.first

        if !gridStates.isEmpty {
            dailySummary = energyKitManager.generateDailySummary(from: gridStates)
        }
    }

    private func updateArtElements() {
        guard let state = currentState else { return }

        // 波形データを生成
        let cleanness = state.cleanEnergyFraction
        waves = [
            WaveData(
                amplitude: 30 * cleanness,
                frequency: 2,
                phase: 0,
                color: state.color.opacity(0.6)
            ),
            WaveData(
                amplitude: 20 * cleanness,
                frequency: 3,
                phase: .pi / 3,
                color: state.color.opacity(0.4)
            ),
            WaveData(
                amplitude: 15 * cleanness,
                frequency: 4,
                phase: .pi / 2,
                color: state.color.opacity(0.3)
            ),
        ]

        // パーティクルを生成
        generateParticles(for: state)
    }

    private func generateParticles(for state: GridState) {
        let count = Int(state.cleanEnergyFraction * 30) + 5
        let particleType: ParticleType = switch state.level {
        case .veryClean: .leaf
        case .clean: .wind
        case .moderate: .sun
        case .dirty: .smoke
        }

        particles = (0..<count).map { _ in
            EnergyParticle(
                x: Double.random(in: 0...1),
                y: Double.random(in: 0...1),
                size: Double.random(in: 8...24),
                opacity: Double.random(in: 0.3...0.8),
                color: state.color,
                type: particleType
            )
        }
    }

    private func updateParticlePositions() {
        guard let state = currentState else { return }

        let speed = state.level == .dirty ? 0.005 : 0.002

        for i in particles.indices {
            particles[i].x += Double.random(in: -speed...speed)
            particles[i].y -= speed
            particles[i].opacity = 0.3 + 0.5 * sin(animationPhase + Double(i))

            // 画面外に出たら下からリスポーン
            if particles[i].y < 0 {
                particles[i].y = 1.0
                particles[i].x = Double.random(in: 0...1)
            }
            if particles[i].x < 0 { particles[i].x = 1.0 }
            if particles[i].x > 1 { particles[i].x = 0.0 }
        }
    }

    // MARK: - Demo Data

    private func generateDemoData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let cleanPatterns: [(clean: Double, solar: Double, wind: Double)] = [
            (0.35, 0.00, 0.35), (0.32, 0.00, 0.32), (0.30, 0.00, 0.30),
            (0.28, 0.00, 0.28), (0.30, 0.00, 0.30), (0.35, 0.05, 0.30),
            (0.45, 0.15, 0.30), (0.55, 0.25, 0.30), (0.65, 0.35, 0.30),
            (0.75, 0.45, 0.30), (0.82, 0.52, 0.30), (0.88, 0.58, 0.30),
            (0.90, 0.60, 0.30), (0.85, 0.55, 0.30), (0.75, 0.45, 0.30),
            (0.60, 0.30, 0.30), (0.45, 0.15, 0.30), (0.38, 0.05, 0.33),
            (0.40, 0.00, 0.40), (0.55, 0.00, 0.55), (0.65, 0.00, 0.65),
            (0.60, 0.00, 0.60), (0.50, 0.00, 0.50), (0.42, 0.00, 0.42),
        ]

        gridStates = (0..<24).compactMap { hour in
            guard let date = calendar.date(byAdding: .hour, value: hour, to: today) else {
                return nil
            }
            let pattern = cleanPatterns[hour]
            return GridState(
                date: date,
                cleanEnergyFraction: pattern.clean,
                solarFraction: pattern.solar,
                windFraction: pattern.wind
            )
        }

        updateCurrentState()
        updateArtElements()
    }
}
