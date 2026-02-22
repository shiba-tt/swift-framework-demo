import Foundation

// MARK: - SpeechRecognitionManager

/// Speech フレームワークによるリアルタイム音声認識を管理するマネージャー。
/// 実デバイスでは SFSpeechRecognizer + AVAudioEngine を使い、
/// モック環境ではシミュレーションデータを返す。

@MainActor
@Observable
final class SpeechRecognitionManager {
    static let shared = SpeechRecognitionManager()

    // MARK: - State

    private(set) var isRecording = false
    private(set) var isAuthorized = false
    private(set) var currentTranscription = ""
    private(set) var recordingDuration: TimeInterval = 0

    private var recordingTimer: Timer?
    private var simulationTask: Task<Void, Never>?

    private init() {
        checkAuthorization()
    }

    // MARK: - Authorization

    private func checkAuthorization() {
        // 実環境では SFSpeechRecognizer.requestAuthorization を呼び出す
        // モック環境では常に許可済みとする
        isAuthorized = true
    }

    // MARK: - Recording

    func startRecording() {
        guard !isRecording else { return }

        isRecording = true
        currentTranscription = ""
        recordingDuration = 0

        // タイマーで録音時間をカウント
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordingDuration += 1.0
            }
        }

        // シミュレーション: 段階的にテキストを追加
        simulationTask = Task {
            await simulateTranscription()
        }
    }

    func stopRecording() -> (transcription: String, duration: TimeInterval) {
        let result = (transcription: currentTranscription, duration: recordingDuration)

        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        simulationTask?.cancel()
        simulationTask = nil

        return result
    }

    // MARK: - Simulation

    private let sampleTranscriptions: [[String]] = [
        // 会議メモ
        [
            "えーと、",
            "今日の会議の内容をメモします。",
            "まず田中さんからQ3の売上報告がありました。",
            "目標に対して85%の達成率で、",
            "残り2ヶ月でキャッチアップが必要です。",
            "鈴木さんからは新機能のリリーススケジュールについて報告。",
            "来月15日にベータ版を出す予定。",
            "あと、佐藤さんがカスタマーサポートの人員が足りないと言っていたので、",
            "採用計画を来週までにまとめることになりました。"
        ],
        // 買い物リスト
        [
            "明日の買い物リストね。",
            "牛乳と卵、あとパンを買わないと。",
            "週末にパーティーがあるから、",
            "チーズとワインも必要だな。",
            "あ、洗剤も切れそうだった。",
            "スーパーに寄って全部まとめて買おう。"
        ],
        // アイデアメモ
        [
            "散歩してたら新しいアイデアを思いついた。",
            "位置情報に紐づくメモアプリなんだけど、",
            "特定の場所に行くとARで過去のメモが浮かび上がるの。",
            "友達ともスポットを共有できて、",
            "街歩きがもっと楽しくなると思う。",
            "まずは類似アプリを調べてみよう。"
        ]
    ]

    private func simulateTranscription() async {
        let phrases = sampleTranscriptions.randomElement() ?? sampleTranscriptions[0]

        for phrase in phrases {
            guard !Task.isCancelled else { return }
            try? await Task.sleep(for: .milliseconds(Int.random(in: 800...1500)))
            guard !Task.isCancelled else { return }
            currentTranscription += phrase
        }
    }
}
