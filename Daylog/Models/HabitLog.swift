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

struct HabitLog: Codable, Equatable {
    let dayKey: String
    let completed: Bool
    let completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case dayKey = "day_key"
        case completed = "completed"
        case completedAt = "completed_at"
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.dayKey, forKey: .dayKey)
        try container.encode(self.completed, forKey: .completed)
        try container.encodeIfPresent(self.completedAt, forKey: .completedAt)
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dayKey = try container.decode(String.self, forKey: .dayKey)
        self.completed = try container.decode(Bool.self, forKey: .completed)
        self.completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
    }
    static func == (lhs: HabitLog, rhs: HabitLog) -> Bool {
        return lhs.dayKey == rhs.dayKey
    }
}
