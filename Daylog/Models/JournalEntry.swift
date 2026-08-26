//
//  JournalEntry.swift
//  DayLog
//
//  Models/JournalEntry.swift
//

import Foundation

enum Mood: String, Codable, CaseIterable {
    case great
    case okay
    case bad

    var emoji: String {
        switch self {
        case .great: return "😊"
        case .okay: return "😐"
        case .bad: return "😔"
        }
    }
}

struct JournalEntry: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let dayKey: String          // "yyyy-MM-dd"
    var text: String
    var photoURL: String?
    var mood: Mood?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case dayKey = "day_key"
        case text
        case photoURL = "photo_url"
        case mood
        case createdAt = "created_at"
    }
}
