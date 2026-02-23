import Foundation
import SwiftUI

/// 環境音の分析・分類を管理するマネージャー
/// 実際のアプリでは AVAudioEngine + SoundAnalysis + Accelerate を使用
@MainActor
@Observable
final class SoundAnalysisManager {
    static let shared = SoundAnalysisManager()

    // MARK: - Observable State

    private(set) var isListening = false
    private(set) var currentDecibel: Double = 0
    private(set) var peakDecibel: Double = 0
    private(set) var currentClassifications: [SoundClassification] = []
    private(set) var spectrumHistory: [SpectrumData] = []
    private(set) var soundLog: [SoundLogEntry] = SoundLogEntry.samples
    private(set) var isRecording = false
    private(set) var sessionDuration: TimeInterval = 0

    var noiseLevel: NoiseLevel { NoiseLevel(decibel: currentDecibel) }

    // MARK: - Private

    private var mockTimer: Timer?
    private var sessionStartDate: Date?

    private init() {}

    // MARK: - Engine Control

    func startListening() {
        guard !isListening else { return }
        isListening = true
        sessionStartDate = Date()
        startMockAnalysis()
    }

    func stopListening() {
        isListening = false
        mockTimer?.invalidate()
        mockTimer = nil
        currentDecibel = 0
        peakDecibel = 0
        currentClassifications = []
        sessionDuration = 0
        sessionStartDate = nil
    }

    func toggleRecording() {
        isRecording.toggle()
    }

    // MARK: - Statistics

    var todayTotalListeningTime: TimeInterval {
        soundLog.reduce(0) { $0 + $1.duration }
    }

    var todayAverageDecibel: Double {
        guard !soundLog.isEmpty else { return 0 }
        return soundLog.reduce(0) { $0 + $1.averageDecibel } / Double(soundLog.count)
    }

    var todayPeakDecibel: Double {
        soundLog.map(\.peakDecibel).max() ?? 0
    }

    var categoryBreakdown: [(category: SoundCategory, totalDuration: TimeInterval)] {
        let grouped = Dictionary(grouping: soundLog, by: \.category)
        return grouped.map { category, entries in
            (category: category, totalDuration: entries.reduce(0) { $0 + $1.duration })
        }
        .sorted { $0.totalDuration > $1.totalDuration }
    }

    // MARK: - Mock Analysis

    private func startMockAnalysis() {
        mockTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateMockData()
            }
        }
    }

    private func updateMockData() {
        // デシベルのシミュレーション
        let baseDecibel = Double.random(in: 35...65)
        let spike = Double.random(in: 0...1) > 0.9 ? Double.random(in: 10...25) : 0
        currentDecibel = baseDecibel + spike
        peakDecibel = max(peakDecibel, currentDecibel)

        // セッション時間の更新
        if let start = sessionStartDate {
            sessionDuration = Date().timeIntervalSince(start)
        }

        // スペクトラムの更新
        let spectrum = SpectrumData.generateRandom()
        spectrumHistory.append(spectrum)
        if spectrumHistory.count > 60 {
            spectrumHistory.removeFirst()
        }

        // AI 分類のシミュレーション（ランダムに数カテゴリの信頼度を更新）
        let activeCategories = SoundCategory.allCases.shuffled().prefix(4)
        var totalConfidence = 0.0
        currentClassifications = activeCategories.enumerated().map { index, category in
            let confidence: Double
            if index == 0 {
                confidence = Double.random(in: 0.6...0.95)
            } else if index == 1 {
                confidence = Double.random(in: 0.3...0.65)
            } else {
                confidence = Double.random(in: 0.05...0.4)
            }
            totalConfidence += confidence
            return SoundClassification(
                category: category,
                confidence: min(confidence, 1.0 - totalConfidence + confidence)
            )
        }
        .sorted { $0.confidence > $1.confidence }
    }
}
