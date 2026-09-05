//
//  UserDataManager.swift
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
    
    // update userName
    func upDateUserNamr(userID:String,displayName: String) async throws {
        let data :[String: Any] = [
            AppUser.CodingKeys.displayName.rawValue : displayName
        ]
        try await userDocument(userID: userID).updateData(data)
    }

    // update photoUrl
    func updateUserPhotoUrl(userID: String, photoUrl: String) async throws {
        let data: [String: Any] = [
            AppUser.CodingKeys.photoUrl.rawValue : photoUrl
        ]
        try await userDocument(userID: userID).updateData(data)
    }
}
