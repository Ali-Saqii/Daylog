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
        listenerTask = Task {
            do {
                let authDataResult = try AuthenticationManager.shared.getUser()
                HabitDataManager.shared.addListernerForAllHabits(userId: authDataResult.uid) {[weak self] habits in
                    self?.habits = habits
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func refreshTodayStatus(userId: String, habits: [Habit]) async {
       
    }

    func toggleCompletion(_ habit: Habit) {
//        Task {
//            do {
//                let authDataResult = try AuthenticationManager.shared.getUser()
//                try await HabitDataManager.shared.(userId: authDataResult.uid, habitId: habit.id)
//            }catch {
//                errorMessage = error.localizedDescription
//            }
//        }
    }

    func addHabit(title: String, emoji: String?) async throws {
   
                let authDataResult = try AuthenticationManager.shared.getUser()
                try await HabitDataManager.shared.createHabit(userId: authDataResult.uid, title: title, emoji: emoji ?? "")
      
    }

    func deleteHabit(_ habit: Habit) {
        Task {
            do {
                let authDataResult = try AuthenticationManager.shared.getUser()
                try await HabitDataManager.shared.deleteHabit(userId: authDataResult.uid, habitId: habit.id)
            }catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    deinit {
        listenerTask?.cancel()
    }
}


//    func getHabites() {
//            Task {
//                do {
//                    let authDataResult = try AuthenticationManager.shared.getUser()
//                    self.habits = try await HabitDataManager.shared.getHabits(userId: authDataResult.uid)
//                } catch {
//                    print("Error:\(error)")
//                    self.errorMessage = error.localizedDescription
//                }
//            }
//    }
