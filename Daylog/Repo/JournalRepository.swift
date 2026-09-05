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

    func saveEntry(userId: String, entry: JournalEntry) async throws {
        try await dataManager.saveEntry(userId: userId, entry: entry)
    }

    func updateEntry(userId: String, entry: JournalEntry) async throws {
        try await dataManager.updateEntry(userId: userId, entry: entry)
    }

    func deleteEntry(userId: String, entryId: String) async throws {
        try await dataManager.deleteEntry(userId: userId, entryId: entryId)
    }
}
