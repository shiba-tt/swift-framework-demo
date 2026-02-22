import Foundation

/// オーディオエフェクトのパラメータ値
struct VoiceParameters: Sendable, Equatable {
    /// ピッチ変更 (セント) -2400 〜 +2400
    var pitch: Float
    /// 再生速度 0.25 〜 2.0
    var rate: Float
    /// リバーブ (ウェットミックス %) 0 〜 100
    var reverb: Float
    /// ディレイ (ウェットミックス %) 0 〜 100
    var delay: Float
    /// ディストーション (ウェットミックス %) 0 〜 100
    var distortion: Float
    /// 低音 EQ ゲイン (dB) -20 〜 +20
    var eqLow: Float
    /// 中音 EQ ゲイン (dB) -20 〜 +20
    var eqMid: Float
    /// 高音 EQ ゲイン (dB) -20 〜 +20
    var eqHigh: Float

    static let `default` = VoiceParameters(
        pitch: 0, rate: 1.0, reverb: 0, delay: 0,
        distortion: 0, eqLow: 0, eqMid: 0, eqHigh: 0
    )

    static let pitchRange: ClosedRange<Float> = -2400...2400
    static let rateRange: ClosedRange<Float> = 0.25...2.0
    static let mixRange: ClosedRange<Float> = 0...100
    static let eqRange: ClosedRange<Float> = -20...20
}
