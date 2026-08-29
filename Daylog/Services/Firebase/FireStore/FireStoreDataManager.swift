//
//  FireStoreDataManager.swift
//  Daylog
//
//  Created by Mac mini on 27/08/2026.
//

import Foundation
import FirebaseFirestore

class UserDataManager {
    static let shared  = UserDataManager()
    
    private init () {}
    
    private let userCollection = Firestore.firestore().collection("users")
    private func userDocument(userID: String) -> DocumentReference {
        userCollection.document(userID)
    }
    
    //MARK: Create DB user
    
    func createUser(user: AppUser) async throws {
        try userDocument(userID: user.id).setData(from: user,merge: false)
    }
    
    // get dbUser
    func getDBUser(userId:String) async throws -> AppUser{
        return try await userDocument(userID: userId).getDocument(as:AppUser.self)
    }
}
