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
    
    func createHabit(userId:String,title: String,emoji:String)async throws {
        let document = habitsCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data: [String: Any] = [
            Habit.CodingKeys.id.rawValue : documentId,
            Habit.CodingKeys.title.rawValue: title,
            Habit.CodingKeys.emoji.rawValue: emoji as Any,
            Habit.CodingKeys.createdAt.rawValue: Timestamp(),
            Habit.CodingKeys.currentStreak.rawValue: 0,
            Habit.CodingKeys.longestStreak.rawValue: 0,
            Habit.CodingKeys.isArchived.rawValue : false
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
    // Fetch Habits
    func getHabits(userId:String) async throws -> [Habit]{
        return try await habitsCollection(userId: userId).getAllHabits(as: Habit.self)
    }
    func addListernerForAllHabits(userId: String,completion: @escaping (_ habits: [Habit]) -> Void) {
        habitsCollection(userId: userId).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("no documents")
                return
            }
            
            let habits: [Habit] = documents.compactMap({ try? $0.data(as: Habit.self)})
            completion(habits)
        }
    }
}
    
extension Query {
    //    func getAllProducts2<T>(as: T.Type) async throws -> [T] where T : Decodable {
    //        let snapShot = try await self.getDocuments()
    //        return try snapShot.documents.map { document in
    //            try document.data(as: T.self)
    //        }
    //    }
    func getAllHabits<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getAllHabitsWithSnapshot(as: type).0
    }
    func getAllHabitsWithSnapshot<T>(as: T.Type) async throws -> ([T] , DocumentSnapshot?) where T : Decodable {
        let snapShot = try await self.getDocuments()
        let habits =  try snapShot.documents.map { document in
            try document.data(as: T.self)
        }
        return (habits, snapShot.documents.last)
    }
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return self.start(afterDocument: lastDocument)
    }
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
}
