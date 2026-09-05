//
//  JournalDataManager.swift
//  Daylog
//
//  Services/Firebase/FireStore/JournalDataManager.swift
//

import Foundation
import FirebaseFirestore
import Firebase

class JournalDataManager {
    static let shared = JournalDataManager()
    private init() {}

    private func journalCollection(userId: String) -> CollectionReference {
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("journal")
    }

    private func journalDocument(userId: String, entryId: String) -> DocumentReference {
        journalCollection(userId: userId).document(entryId)
    }
}

// MARK: - CRUD

extension JournalDataManager {

    /// Creates a new journal entry for today. One entry per day (uses dayKey as the document ID).
    func createEntry(userId: String, text: String, mood: Mood?) async throws {
        let dayKey = Date().dayKey
        let doc = journalCollection(userId: userId).document(dayKey)

        var data: [String: Any] = [
            JournalEntry.CodingKeys.id.rawValue: dayKey,
            JournalEntry.CodingKeys.dayKey.rawValue: dayKey,
            JournalEntry.CodingKeys.text.rawValue: text,
            JournalEntry.CodingKeys.createdAt.rawValue: Timestamp()
        ]
        if let mood { data[JournalEntry.CodingKeys.mood.rawValue] = mood.rawValue }

        try await doc.setData(data, merge: false)
    }

    /// Updates the text and mood of an existing entry.
    func updateEntry(userId: String, entryId: String, text: String, mood: Mood?) async throws {
        var data: [String: Any] = [
            JournalEntry.CodingKeys.text.rawValue: text
        ]
        data[JournalEntry.CodingKeys.mood.rawValue] = mood?.rawValue as Any
        try await journalDocument(userId: userId, entryId: entryId).updateData(data)
    }

    /// Deletes a journal entry.
    func deleteEntry(userId: String, entryId: String) async throws {
        try await journalDocument(userId: userId, entryId: entryId).delete()
    }

    /// Real-time listener for all journal entries, sorted newest first.
    func addListener(userId: String, completion: @escaping ([JournalEntry]) -> Void) {
        journalCollection(userId: userId)
            .order(by: JournalEntry.CodingKeys.dayKey.rawValue, descending: true)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                let entries = docs.compactMap { try? $0.data(as: JournalEntry.self) }
                completion(entries)
            }
    }

    /// Server-side count of journal entries — used by profile stats.
    func getEntryCount(userId: String) async throws -> Int {
        return try await journalCollection(userId: userId).aggregateCount()
    }
}
