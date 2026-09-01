//
//  HabitViewModel.swift
//  Daylog
//
//  Created by Mac mini on 30/08/2026.
//

import Foundation
import Combine


@MainActor
final class HabitViewModel: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    @Published private(set) var completedToday: [String: Bool] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var listenerTask: Task<Void, Never>?

    var completedTodayCount: Int {
        habits.filter { completedToday[$0.id] == true }.count
    }

    var bestStreak: Int {
        habits.map { $0.longestStreak }.max() ?? 0
    }

    func isCompletedToday(_ habit: Habit) -> Bool {
        completedToday[habit.id] ?? false
    }

    func startListening() {

    }

    private func refreshTodayStatus(userId: String, habits: [Habit]) async {
       
    }

    func toggleCompletion(_ habit: Habit) {
        
    }

    func addHabit(title: String, emoji: String?) async throws {
   
                let authDataResult = try AuthenticationManager.shared.getUser()
                try await HabitDataManager.shared.createHabit(userId: authDataResult.uid, title: title, emoji: emoji ?? "")
      
    }

    func deleteHabit(_ habit: Habit) {
        Task {
         
        }
    }

    deinit {
        listenerTask?.cancel()
    }
}
