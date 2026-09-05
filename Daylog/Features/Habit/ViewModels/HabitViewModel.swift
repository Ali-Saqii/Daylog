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
                HabitDataManager.shared.addListernerForAllHabits(userId: authDataResult.uid) { [weak self] habits in
                    guard let self else { return }
                    self.habits = habits
                    // Refresh today's completion status every time the habits list changes
                    Task { await self.refreshTodayStatus(userId: authDataResult.uid, habits: habits) }
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// Fetches today's log for every habit concurrently and populates `completedToday`.
    private func refreshTodayStatus(userId: String, habits: [Habit]) async {
        await withTaskGroup(of: (String, Bool).self) { group in
            for habit in habits {
                group.addTask {
                    let log = try? await HabitDataManager.shared.getTodayLog(
                        userId: userId,
                        habitId: habit.id
                    )
                    return (habit.id, log?.completed ?? false)
                }
            }
            for await (habitId, isCompleted) in group {
                completedToday[habitId] = isCompleted
            }
        }
    }

    func toggleCompletion(_ habit: Habit) {
        Task {
            do {
                let authDataResult = try AuthenticationManager.shared.getUser()
                try await HabitDataManager.shared.toggleHabitLog(
                    userId: authDataResult.uid,
                    habitId: habit.id
                )
                // Refresh this habit's today status after toggle
                await refreshTodayStatus(userId: authDataResult.uid, habits: [habit])
            } catch {
                errorMessage = error.localizedDescription
            }
        }
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

    func updateHabit(_ habitID:String, _ habitTitle: String, _ HabitEmoji:String) async throws {
                let user = try AuthenticationManager.shared.getUser()
                try await HabitDataManager.shared.updateHabitFields(userId: user.uid, habitID: habitID, habitTitle: habitTitle, HabitEmoji: HabitEmoji)
           
        
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
