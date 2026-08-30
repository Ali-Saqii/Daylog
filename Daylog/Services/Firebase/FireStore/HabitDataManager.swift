//
//  HabitDataManager.swift
//  Daylog
//
//  Created by Mac mini on 30/08/2026.
//

import Foundation
import FirebaseFirestore
import Firebase
class HabitDataManager {
    static let shared = HabitDataManager()
    private init() { }

    private func habitsCollection(userId: String) -> CollectionReference {
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("habits")
    }

    private func habitDocument(userId: String, habitId: String) -> DocumentReference {
        habitsCollection(userId: userId).document(habitId)
    }

    private func habitLogsCollection(userId: String, habitId: String) -> CollectionReference {
        habitDocument(userId: userId, habitId: habitId).collection("habitLogs")
    }
}
extension HabitDataManager {
    //Create habit
    
    func createHabit(userId:String,title: String,emoji:String,isArchived:Bool)async throws {
        let document = habitsCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data: [String: Any] = [
            Habit.CodingKeys.id.rawValue : documentId,
            Habit.CodingKeys.title.rawValue: title,
            Habit.CodingKeys.emoji.rawValue: emoji as Any,
            Habit.CodingKeys.createdAt.rawValue: Timestamp(),
            Habit.CodingKeys.currentStreak.rawValue: 0,
            Habit.CodingKeys.longestStreak.rawValue: 0,
            Habit.CodingKeys.isArchived.rawValue : isArchived
        ]
        try await document.setData(data, merge: false)
    }
    
    // Delete Habit
    func deleteHabit(userId: String, habitId: String) async throws {
        try await habitDocument(userId: userId, habitId: habitId).delete()
    }
    // Archived Habit
    func archiveHabit(userId: String, habitId: String) async throws {
        let data: [String: Any] = [
            Habit.CodingKeys.isArchived.rawValue: true
        ]
        try await habitDocument(userId: userId, habitId: habitId).updateData(data)
    }
    
    // update habitTitle
    func updateHabitTitle(userId: String, habitId: String, newTitle: String) async throws {
         let data: [String: Any] = [
             Habit.CodingKeys.title.rawValue: newTitle
         ]
         try await habitDocument(userId: userId, habitId: habitId).updateData(data)
     }
}
