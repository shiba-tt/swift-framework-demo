import Foundation
import Speech
import AVFoundation

// MARK: - SpeechRecognitionManager（音声文字起こし）

@MainActor
@Observable
final class SpeechRecognitionManager {
    static let shared = SpeechRecognitionManager()

    private(set) var isRecording = false
    private(set) var isAuthorized = false
    private(set) var transcription = ""
    private(set) var recordingDuration: TimeInterval = 0
    private(set) var audioLevel: Float = 0

    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recordingTimer: Timer?

    private init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja_JP"))
    }

    // MARK: - 権限リクエスト

    func requestAuthorization() async -> Bool {
        // 音声認識の権限
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        guard speechStatus == .authorized else {
            isAuthorized = false
            return false
        }

        // マイクの権限
        let audioStatus: Bool
        if #available(iOS 17.0, *) {
            audioStatus = await AVAudioApplication.requestRecordPermission()
        } else {
            audioStatus = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }

        isAuthorized = audioStatus
        return audioStatus
    }

    // MARK: - 録音開始

    func startRecording() async throws {
        guard isAuthorized else {
            throw SpeechRecognitionError.notAuthorized
        }

        guard let speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerUnavailable
        }

        // 既存のタスクをキャンセル
        stopRecording()

        transcription = ""
        recordingDuration = 0

        // AVAudioSession の設定
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // 音声認識リクエストの作成
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        recognitionRequest = request

        // AudioEngine の起動
        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            // オーディオレベルの更新
            self?.updateAudioLevel(buffer: buffer)
        }

        engine.prepare()
        try engine.start()
        audioEngine = engine

        // 認識タスクの開始
        recognitionTask = speechRecognizer.recognitionTask(with: request) {
            [weak self] result, error in
            Task { @MainActor in
                if let result {
                    self?.transcription = result.bestTranscription.formattedString
                }
                if error != nil || (result?.isFinal ?? false) {
                    self?.finalizeRecording()
                }
            }
        }

        isRecording = true

        // 録音時間のタイマー
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
            [weak self] _ in
            Task { @MainActor in
                self?.recordingDuration += 0.1
            }
        }
    }

    // MARK: - 録音停止

    func stopRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        audioLevel = 0
    }

    // MARK: - Private

    private func finalizeRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    private nonisolated func updateAudioLevel(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let channelDataValue = channelData.pointee
        let frames = Int(buffer.frameLength)

        var sum: Float = 0
        for i in 0..<frames {
            sum += abs(channelDataValue[i])
        }
        let average = sum / Float(frames)
        let level = min(max(average * 10, 0), 1)

        Task { @MainActor in
            self.audioLevel = level
        }
    }

    var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - SpeechRecognitionError

enum SpeechRecognitionError: Error, LocalizedError {
    case notAuthorized
    case recognizerUnavailable

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            "音声認識の権限が許可されていません。設定アプリから許可してください。"
        case .recognizerUnavailable:
            "音声認識が利用できません。ネットワーク接続を確認してください。"
        }
    }
}
