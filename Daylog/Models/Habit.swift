//
//  Habit.swift
//  DayLog
//
//  Models/Habit.swift
//

import Foundation

struct Habit: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var emoji: String
    let createdAt: Date
    var currentStreak: Int
    var longestStreak: Int
    var isArchived: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case emoji
        case createdAt = "created_at"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case isArchived = "is_archived"
    }
}
