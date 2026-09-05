//
//  JournalViewModel.swift
//  Daylog
//
//  Features/Journal/ViewModels/JournalViewModel.swift
//

import Foundation
import Combine

@MainActor
final class JournalViewModel: ObservableObject {
    @Published private(set) var entries: [JournalEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Compose / edit state
    @Published var draftText = ""
    @Published var draftMood: Mood? = nil
    @Published var editingEntry: JournalEntry? = nil

    /// True when there is already an entry for today.
    var hasTodayEntry: Bool {
        entries.first?.dayKey == Date().dayKey
    }

    var todayEntry: JournalEntry? {
        entries.first(where: { $0.dayKey == Date().dayKey })
    }

    // MARK: - Listener

    func startListening() {
        guard let uid = try? AuthenticationManager.shared.getUser().uid else { return }
        isLoading = true
        JournalDataManager.shared.addListener(userId: uid) { [weak self] entries in
            guard let self else { return }
            self.entries = entries
            self.isLoading = false
        }
    }

    // MARK: - Save (create or update)

    func saveEntry() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        Task {
            do {
                let uid = try AuthenticationManager.shared.getUser().uid
                if let editing = editingEntry {
                    try await JournalDataManager.shared.updateEntry(
                        userId: uid,
                        entryId: editing.id,
                        text: text,
                        mood: draftMood
                    )
                } else {
                    try await JournalDataManager.shared.createEntry(
                        userId: uid,
                        text: text,
                        mood: draftMood
                    )
                }
                resetDraft()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Delete

    func deleteEntry(_ entry: JournalEntry) {
        Task {
            do {
                let uid = try AuthenticationManager.shared.getUser().uid
                try await JournalDataManager.shared.deleteEntry(userId: uid, entryId: entry.id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Draft helpers

    func beginEditing(_ entry: JournalEntry) {
        editingEntry = entry
        draftText = entry.text
        draftMood = entry.mood
    }

    func resetDraft() {
        draftText = ""
        draftMood = nil
        editingEntry = nil
    }
}
