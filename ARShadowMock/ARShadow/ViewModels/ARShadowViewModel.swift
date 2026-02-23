import Foundation
import SwiftUI

// MARK: - ARShadowViewModel

@MainActor
@Observable
final class ARShadowViewModel {

    // MARK: - State

    var stages: [PuzzleStage] = PuzzleStage.samples
    var selectedStage: PuzzleStage?
    var isPlaying = false
    var isPaused = false
    var isARActive = false
    var isScanningRoom = false
    var roomMeshInfo: RoomMeshInfo?

    // Light
    var lightSource = LightSource()

    // Objects
    var placedObjects: [VirtualObject] = []
    var selectedObjectShape: ObjectShape = .cube

    // Game State
    var currentAccuracy: Double = 0.0
    var elapsedTime: TimeInterval = 0
    var gameResults: [GameResult] = []
    var showingResult = false
    var lastResult: GameResult?

    // Coop
    var showingCoop = false
    var showingJoinSession = false
    var joinCode = ""

    // MARK: - Dependencies

    private let shadowEngine = ShadowEngine.shared
    let coopManager = CoopManager.shared

    // MARK: - Computed

    var totalStars: Int {
        stages.reduce(0) { $0 + $1.starRating }
    }

    var maxStars: Int {
        stages.count * 3
    }

    var completedStages: Int {
        stages.filter { $0.bestScore != nil }.count
    }

    var currentStageAllowedObjects: Int {
        selectedStage?.allowedObjects ?? 3
    }

    var canPlaceMoreObjects: Bool {
        placedObjects.count < currentStageAllowedObjects
    }

    var remainingTime: TimeInterval? {
        guard let timeLimit = selectedStage?.timeLimit else { return nil }
        return max(timeLimit - elapsedTime, 0)
    }

    var isTimeUp: Bool {
        guard let remaining = remainingTime else { return false }
        return remaining <= 0
    }

    // MARK: - Stage Actions

    func selectStage(_ stage: PuzzleStage) {
        guard stage.isUnlocked else { return }
        selectedStage = stage
    }

    func startGame() {
        guard selectedStage != nil else { return }
        isPlaying = true
        isPaused = false
        isARActive = true
        elapsedTime = 0
        currentAccuracy = 0
        placedObjects = []
        lightSource = LightSource()
    }

    func pauseGame() {
        isPaused = true
    }

    func resumeGame() {
        isPaused = false
    }

    func endGame() {
        guard let stage = selectedStage else { return }

        let result = GameResult(
            stage: stage,
            accuracy: currentAccuracy,
            timeElapsed: elapsedTime
        )
        gameResults.append(result)
        lastResult = result

        // ベストスコア更新
        if let index = stages.firstIndex(where: { $0.id == stage.id }) {
            let newScore = result.score
            if stages[index].bestScore == nil || newScore > (stages[index].bestScore ?? 0) {
                stages[index].bestScore = newScore
            }

            // 次のステージをアンロック
            if newScore >= Int(stage.requiredAccuracy * 100), index + 1 < stages.count {
                stages[index + 1].isUnlocked = true
            }
        }

        isPlaying = false
        isARActive = false
        showingResult = true
    }

    func returnToStageSelect() {
        selectedStage = nil
        showingResult = false
        lastResult = nil
    }

    // MARK: - AR / Room Scan

    func scanRoom() async {
        isScanningRoom = true
        roomMeshInfo = await shadowEngine.analyzeRoomMesh()
        isScanningRoom = false
    }

    // MARK: - Light Actions

    func moveLightSource(to position: CGPoint) {
        lightSource.position = position
        updateAccuracy()
    }

    func setLightIntensity(_ intensity: Double) {
        lightSource.intensity = intensity
        updateAccuracy()
    }

    func setLightColor(_ color: Color) {
        lightSource.color = color
    }

    // MARK: - Object Actions

    func placeObject() {
        guard canPlaceMoreObjects else { return }
        let object = VirtualObject(
            shape: selectedObjectShape,
            position: CGPoint(
                x: Double.random(in: 0.3...0.7),
                y: Double.random(in: 0.4...0.7)
            )
        )
        placedObjects.append(object)
        updateAccuracy()
    }

    func moveObject(_ objectID: UUID, to position: CGPoint) {
        guard let index = placedObjects.firstIndex(where: { $0.id == objectID }) else { return }
        placedObjects[index].position = position
        updateAccuracy()
    }

    func rotateObject(_ objectID: UUID, angle: Double) {
        guard let index = placedObjects.firstIndex(where: { $0.id == objectID }) else { return }
        placedObjects[index].rotation = angle
        updateAccuracy()
    }

    func scaleObject(_ objectID: UUID, scale: Double) {
        guard let index = placedObjects.firstIndex(where: { $0.id == objectID }) else { return }
        placedObjects[index].scale = scale
        updateAccuracy()
    }

    func removeObject(_ objectID: UUID) {
        placedObjects.removeAll { $0.id == objectID }
        updateAccuracy()
    }

    // MARK: - Timer

    func tick() {
        guard isPlaying, !isPaused else { return }
        elapsedTime += 1

        if isTimeUp {
            endGame()
        }
    }

    // MARK: - Coop

    func hostCoopSession() async {
        await coopManager.hostSession()
    }

    func joinCoopSession() async {
        _ = await coopManager.joinSession(code: joinCode)
    }

    func disconnectCoop() {
        coopManager.disconnect()
    }

    // MARK: - Private

    private func updateAccuracy() {
        guard let stage = selectedStage else { return }
        currentAccuracy = shadowEngine.calculateMatchAccuracy(
            lightSource: lightSource,
            objects: placedObjects,
            targetShape: stage.targetShape
        )
    }
}
