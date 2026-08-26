//
//  HabitLog.swift
//  DayLog
//
//  Models/HabitLog.swift
//
//  One document per (habit, day) — used to mark a habit complete/incomplete
//  for a specific date and to power streak calculations.
//

import Foundation

struct HabitLog: Identifiable, Codable, Equatable {
    let id: String
    let habitId: String
    let dayKey: String        // "yyyy-MM-dd", matches Date+Extensions.dayKey
    var completed: Bool
    var completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case habitId = "habit_id"
        case dayKey = "day_key"
        case completed
        case completedAt = "completed_at"
    }
}
