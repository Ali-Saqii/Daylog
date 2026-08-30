//
//  Habit.swift
//  DayLog
//
//  Models/Habit.swift
//

import Foundation


struct Habit: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let emoji: String?
    let createdAt: Date
    var currentStreak: Int
    var longestStreak: Int
    var isArchived: Bool

    enum CodingKeys: String, CodingKey {
        case id  = "id"
        case title = "title"
        case emoji = "emoji"
        case createdAt = "created_at"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case isArchived = "is_archived"
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.emoji = try container.decodeIfPresent(String.self, forKey: .emoji)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        self.longestStreak = try container.decode(Int.self, forKey: .longestStreak)
        self.isArchived = try container.decode(Bool.self, forKey: .isArchived)
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.title, forKey: .title)
        try container.encodeIfPresent(self.emoji, forKey: .emoji)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encode(self.currentStreak, forKey: .currentStreak)
        try container.encode(self.longestStreak, forKey: .longestStreak)
        try container.encode(self.isArchived, forKey: .isArchived)
    }
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.id == rhs.id
    }
}
