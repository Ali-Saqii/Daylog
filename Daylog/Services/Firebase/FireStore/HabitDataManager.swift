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
    // Archive Habit
    func archiveHabit(userId: String, habitId: String) async throws {
        let data: [String: Any] = [Habit.CodingKeys.isArchived.rawValue: true]
        try await habitDocument(userId: userId, habitId: habitId).updateData(data)
    }

    // Unarchive Habit
    func unarchiveHabit(userId: String, habitId: String) async throws {
        let data: [String: Any] = [Habit.CodingKeys.isArchived.rawValue: false]
        try await habitDocument(userId: userId, habitId: habitId).updateData(data)
    }
    
    // update habitTitle
    func updateHabitFields(userId: String, habitID: String,habitTitle: String , HabitEmoji: String) async throws {
        guard  !userId.isEmpty  else { return  }
         let data: [String: Any] = [
            Habit.CodingKeys.title.rawValue: habitTitle,
            Habit.CodingKeys.emoji.rawValue: HabitEmoji
         ]
        try await habitDocument(userId: userId, habitId: habitID).updateData(data)
     }
    // Fetch Habits
    func getHabits(userId:String) async throws -> [Habit]{
        return try await habitsCollection(userId: userId).getAllHabits(as: Habit.self)
    }
    @discardableResult
    func addListernerForAllHabits(userId: String, completion: @escaping (_ habits: [Habit]) -> Void) -> ListenerRegistration {
        return habitsCollection(userId: userId).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("no documents")
                return
            }
            let habits: [Habit] = documents.compactMap({ try? $0.data(as: Habit.self) })
            completion(habits)
        }
    }

    // MARK: - Habit Logs (toggle completion)

    /// Fetches the log document for today. Returns nil if it doesn't exist yet.
    func getTodayLog(userId: String, habitId: String) async throws -> HabitLog? {
        let dayKey = Date().dayKey
        let doc = habitLogsCollection(userId: userId, habitId: habitId).document(dayKey)
        let snapshot = try await doc.getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: HabitLog.self)
    }

    /// Toggles today's completion for a habit and recalculates streaks.
    func toggleHabitLog(userId: String, habitId: String) async throws {
        let dayKey = Date().dayKey
        let logDoc = habitLogsCollection(userId: userId, habitId: habitId).document(dayKey)
        let snapshot = try await logDoc.getDocument()

        let newCompleted: Bool
        if snapshot.exists, let log = try? snapshot.data(as: HabitLog.self) {
            // Flip existing value
            newCompleted = !log.completed
        } else {
            // First time tapping today — mark complete
            newCompleted = true
        }

        let logData: [String: Any] = [
            HabitLog.CodingKeys.dayKey.rawValue: dayKey,
            HabitLog.CodingKeys.completed.rawValue: newCompleted,
            HabitLog.CodingKeys.completedAt.rawValue: newCompleted ? Timestamp() : NSNull()
        ]
        try await logDoc.setData(logData, merge: false)

        // Recalculate and persist streaks after every toggle
        try await recalculateAndSaveStreaks(userId: userId, habitId: habitId)
    }

    /// Fetches all logs for a habit, sorted ascending by dayKey, used for streak calculation.
    func getAllLogs(userId: String, habitId: String) async throws -> [HabitLog] {
        let snapshot = try await habitLogsCollection(userId: userId, habitId: habitId)
            .order(by: HabitLog.CodingKeys.dayKey.rawValue, descending: false)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: HabitLog.self) }
    }

    /// Calculates currentStreak and longestStreak from all logs and writes them back to the habit doc.
    private func recalculateAndSaveStreaks(userId: String, habitId: String) async throws {
        let logs = try await getAllLogs(userId: userId, habitId: habitId)
        let completedKeys = Set(logs.filter { $0.completed }.map { $0.dayKey })

        var currentStreak = 0
        var longestStreak = 0
        var runningStreak = 0

        // Walk backwards from today to count currentStreak
        var checkDate = Date()
        while completedKeys.contains(checkDate.dayKey) {
            currentStreak += 1
            checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        // Walk all completed days in order to find longestStreak
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let sortedKeys = completedKeys.sorted()
        var prevDate: Date? = nil
        for key in sortedKeys {
            guard let date = formatter.date(from: key) else { continue }
            if let prev = prevDate, date.daysSince(prev) == 1 {
                runningStreak += 1
            } else {
                runningStreak = 1
            }
            longestStreak = max(longestStreak, runningStreak)
            prevDate = date
        }

        let data: [String: Any] = [
            Habit.CodingKeys.currentStreak.rawValue: currentStreak,
            Habit.CodingKeys.longestStreak.rawValue: longestStreak
        ]
        try await habitDocument(userId: userId, habitId: habitId).updateData(data)
    }

    // MARK: - Profile Stats

    /// Server-side count of active (non-archived) habits for a user.
    func getHabitCount(userId: String) async throws -> Int {
        return try await habitsCollection(userId: userId)
            .whereField(Habit.CodingKeys.isArchived.rawValue, isEqualTo: false)
            .aggregateCount()
    }

    /// Highest `longestStreak` across all habits for a user.
    func getBestStreak(userId: String) async throws -> Int {
        let habits = try await getHabits(userId: userId)
        return habits.map { $0.longestStreak }.max() ?? 0
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
