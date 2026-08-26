//
//  AppUser.swift
//  DayLog
//
//  Models/AppUser.swift
//

import Foundation

struct AppUser: Identifiable, Codable, Equatable {
    let id: String          // Firebase Auth UID
    let email: String?
    let displayName: String?
    let createdAt: Date?
}
