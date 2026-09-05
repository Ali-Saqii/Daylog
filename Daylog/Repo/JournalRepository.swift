//
//  JournalRepository.swift
//  Daylog
//
//  Repo/JournalRepository.swift
//

import Foundation
import FirebaseFirestore

protocol JournalRepositoryProtocol {
    func getEntries(userId: String) async throws -> [JournalEntry]
    func createEntry(userId: String, text: String, mood: Mood?) async throws
    func updateEntry(userId: String, entryId: String, text: String, mood: Mood?) async throws
    func saveEntry(userId: String, entry: JournalEntry) async throws
    func updateEntry(userId: String, entry: JournalEntry) async throws
    func deleteEntry(userId: String, entryId: String) async throws
}

final class JournalRepository: JournalRepositoryProtocol {
    static let shared = JournalRepository()
    private let dataManager: JournalDataManager

    init(dataManager: JournalDataManager = .shared) {
        self.dataManager = dataManager
    }

    func getEntries(userId: String) async throws -> [JournalEntry] {
        try await dataManager.getEntries(userId: userId)
    }

    func createEntry(userId: String, text: String, mood: Mood?) async throws {
        try await dataManager.createEntry(userId: userId, text: text, mood: mood)
    }

    func updateEntry(userId: String, entryId: String, text: String, mood: Mood?) async throws {
        try await dataManager.updateEntry(userId: userId, entryId: entryId, text: text, mood: mood)
    }

    func saveEntry(userId: String, entry: JournalEntry) async throws {
        try await dataManager.createEntry(userId: userId, text: entry.text, mood: entry.mood)
    }

    func updateEntry(userId: String, entry: JournalEntry) async throws {
        try await dataManager.updateEntry(userId: userId, entryId: entry.id, text: entry.text, mood: entry.mood)
    }

    func deleteEntry(userId: String, entryId: String) async throws {
        try await dataManager.deleteEntry(userId: userId, entryId: entryId)
    }
}
