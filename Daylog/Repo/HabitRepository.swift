//
//  HabitRepository.swift
//  Daylog
//
//  Repo/HabitRepository.swift
//

import Foundation
import FirebaseFirestore

protocol HabitRepositoryProtocol {
    func getHabits(userId: String) async throws -> [Habit]
    func createHabit(userId: String, habit: Habit) async throws
    func updateHabit(userId: String, habit: Habit) async throws
    func deleteHabit(userId: String, habitId: String) async throws
    func toggleHabitLog(userId: String, habitId: String, date: Date) async throws
}

final class HabitRepository: HabitRepositoryProtocol {
    static let shared = HabitRepository()
    private let dataManager: HabitDataManager

    init(dataManager: HabitDataManager = .shared) {
        self.dataManager = dataManager
    }

    func getHabits(userId: String) async throws -> [Habit] {
        try await dataManager.getHabits(userId: userId)
    }

    func createHabit(userId: String, habit: Habit) async throws {
        try await dataManager.createHabit(userId: userId, habit: habit)
    }

    func updateHabit(userId: String, habit: Habit) async throws {
        try await dataManager.updateHabit(userId: userId, habit: habit)
    }

    func deleteHabit(userId: String, habitId: String) async throws {
        try await dataManager.deleteHabit(userId: userId, habitId: habitId)
    }

    func toggleHabitLog(userId: String, habitId: String, date: Date = Date()) async throws {
        try await dataManager.toggleHabitLog(userId: userId, habitId: habitId, date: date)
    }
}
