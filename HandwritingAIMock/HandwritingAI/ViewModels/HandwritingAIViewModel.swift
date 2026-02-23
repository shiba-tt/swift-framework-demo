import Foundation
import SwiftUI

// MARK: - HandwritingAIViewModel

@MainActor
@Observable
final class HandwritingAIViewModel {

    // MARK: - State

    private(set) var notes: [Note] = Note.samples
    var selectedNote: Note?
    var showingCapture = false
    var showingNoteDetail = false
    var showingExport = false
    var searchText = ""
    var selectedNoteTypeFilter: NoteType?

    // OCR 処理中の状態
    var isCapturing = false
    var capturedOCRResult: OCRResult?
    var showingOCRResult = false

    // MARK: - Dependencies

    let ocrManager = OCRManager.shared
    private let analysisManager = NoteAnalysisManager.shared

    // MARK: - Computed

    var filteredNotes: [Note] {
        var result = notes
        if let filter = selectedNoteTypeFilter {
            result = result.filter { $0.noteType == filter }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.recognizedText.localizedCaseInsensitiveContains(searchText)
                || $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        return result.sorted { $0.capturedDate > $1.capturedDate }
    }

    var totalNotes: Int { notes.count }
    var processedNotes: Int { notes.filter(\.isProcessed).count }

    var noteTypeStats: [(NoteType, Int)] {
        NoteType.allCases.compactMap { type in
            let count = notes.filter { $0.noteType == type }.count
            return count > 0 ? (type, count) : nil
        }
    }

    // MARK: - OCR Actions

    func captureAndRecognize() async {
        isCapturing = true
        let result = await ocrManager.recognizeText()
        capturedOCRResult = result
        isCapturing = false
        showingOCRResult = true
    }

    func saveRecognizedNote(title: String, editedText: String) async {
        guard let ocrResult = capturedOCRResult else { return }

        let noteType = analysisManager.suggestNoteType(from: editedText)
        let tags = analysisManager.suggestTags(from: editedText)

        // Foundation Models で分析
        let summary = await analysisManager.analyzeNote(
            text: editedText,
            layoutType: ocrResult.layoutType
        )

        let note = Note(
            title: title.isEmpty ? "無題のノート" : title,
            recognizedText: editedText,
            layoutType: ocrResult.layoutType,
            noteType: noteType,
            tags: tags,
            capturedDate: Date(),
            isProcessed: true,
            summary: summary
        )

        notes.insert(note, at: 0)
        capturedOCRResult = nil
        showingOCRResult = false
        showingCapture = false
    }

    // MARK: - Note Actions

    func selectNote(_ note: Note) {
        selectedNote = note
        showingNoteDetail = true
    }

    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        if selectedNote?.id == note.id {
            selectedNote = nil
            showingNoteDetail = false
        }
    }

    func toggleActionItem(noteID: UUID, actionItemID: UUID) {
        guard let noteIndex = notes.firstIndex(where: { $0.id == noteID }),
              var summary = notes[noteIndex].summary,
              let itemIndex = summary.actionItems.firstIndex(where: { $0.id == actionItemID }) else {
            return
        }
        summary.actionItems[itemIndex].isCompleted.toggle()
        notes[noteIndex].summary = summary

        if selectedNote?.id == noteID {
            selectedNote = notes[noteIndex]
        }
    }

    // MARK: - Export

    func exportMarkdown(for note: Note) -> String {
        analysisManager.exportAsMarkdown(note: note)
    }
}
