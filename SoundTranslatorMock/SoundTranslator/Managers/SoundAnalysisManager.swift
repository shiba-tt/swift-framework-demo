import Foundation
import SwiftUI

// MARK: - SoundAnalysisManager

/// SoundAnalysis フレームワーク + カスタム Core ML モデルによる環境音分類（モック）
/// 実際のアプリでは SNAudioStreamAnalyzer と SNClassifySoundRequest を使用
@MainActor
@Observable
final class SoundAnalysisManager {

    static let shared = SoundAnalysisManager()

    // MARK: - State

    var isListening = false
    var audioLevel: Double = 0.0
    var detectedSounds: [SoundEvent] = []
    var currentSummary: SituationSummary?

    // MARK: - Mock Sound Generation

    private var simulationTask: Task<Void, Never>?

    private let mockSounds: [(SoundCategory, String, AlertLevel, SoundDirection?)] = [
        (.vehicle, "自動車のエンジン音", .safe, .front),
        (.vehicle, "救急車のサイレン", .danger, .right),
        (.vehicle, "自転車のベル", .caution, .back),
        (.vehicle, "クラクション", .danger, .front),
        (.alarm, "ドアベル", .caution, .back),
        (.alarm, "火災報知器", .danger, nil),
        (.alarm, "目覚まし時計", .caution, .left),
        (.animal, "犬の鳴き声", .safe, .right),
        (.animal, "猫の鳴き声", .safe, .left),
        (.animal, "鳥のさえずり", .safe, .above),
        (.human, "笑い声", .safe, .left),
        (.human, "会話（2人以上）", .safe, .front),
        (.human, "拍手", .safe, .front),
        (.human, "子供の泣き声", .caution, .back),
        (.nature, "雨音", .safe, .above),
        (.nature, "風の音", .safe, nil),
        (.nature, "雷", .caution, nil),
        (.music, "BGM（ジャズ）", .safe, .front),
        (.music, "BGM（ポップ）", .safe, .left),
        (.household, "電子レンジ", .caution, .back),
        (.household, "掃除機", .safe, .right),
        (.household, "食洗機", .safe, .back),
        (.machinery, "工事の音", .caution, .front),
    ]

    private let mockSummaries: [(String, AlertLevel)] = [
        ("カフェの店内にいます。ジャズの BGM が流れており、左のテーブルで会話が聞こえます。穏やかな環境です。", .safe),
        ("右方向から救急車が接近中。周囲の人が道を空けています。注意してください。", .danger),
        ("住宅街を歩いています。鳥のさえずりが聞こえ、遠くで犬が吠えています。安全な環境です。", .safe),
        ("自宅のキッチンにいます。電子レンジが動作中です。完了音にご注意ください。", .caution),
        ("雨が降り始めました。遠くで雷の音が聞こえます。屋内への移動を検討してください。", .caution),
        ("オフィス内にいます。周囲で会話が行われており、エアコンの動作音が聞こえます。", .safe),
    ]

    // MARK: - Actions

    func startListening() {
        isListening = true
        detectedSounds = []
        startSimulation()
    }

    func stopListening() {
        isListening = false
        simulationTask?.cancel()
        simulationTask = nil
    }

    // MARK: - Private

    private func startSimulation() {
        simulationTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }

                // ランダムなインターバルで音を検出
                let interval = Double.random(in: 2...5)
                try? await Task.sleep(for: .seconds(interval))

                guard !Task.isCancelled else { return }

                // オーディオレベルの更新
                self.audioLevel = Double.random(in: 0.1...0.9)

                // ランダムな音イベントを生成
                if let mockSound = self.mockSounds.randomElement() {
                    let event = SoundEvent(
                        category: mockSound.0,
                        label: mockSound.1,
                        confidence: Double.random(in: 0.7...0.99),
                        direction: mockSound.3,
                        alertLevel: mockSound.2
                    )
                    self.detectedSounds.insert(event, at: 0)

                    // 最大50件保持
                    if self.detectedSounds.count > 50 {
                        self.detectedSounds = Array(self.detectedSounds.prefix(50))
                    }
                }

                // 5回に1回、状況要約を更新
                if Int.random(in: 0...4) == 0 {
                    if let mockSummary = self.mockSummaries.randomElement() {
                        let recentSounds = Array(self.detectedSounds.prefix(3))
                        self.currentSummary = SituationSummary(
                            description: mockSummary.0,
                            alertLevel: mockSummary.1,
                            soundEvents: recentSounds
                        )
                    }
                }
            }
        }
    }

    private init() {}
}
