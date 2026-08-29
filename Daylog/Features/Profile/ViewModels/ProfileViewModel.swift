//
//  ProfileViewModel.swift
//  Daylog
//
//  Created by Mac mini on 17/08/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: AppUser? = nil
    @Published var errorMessage : String? = ""
    @Published var isSingOut = false
    @Published var authProvider: [AuthProviderOption]? = nil
    var onDismiss: (() -> Void)?
    func signOut() {
        do {
            try AuthenticationManager.shared.signOut()
            self.isSingOut = true
        } catch {
            self.isSingOut = false
            self.errorMessage = "Unable to logOut!"
        }
    }
    
    func upDatePassword(password: String)async throws {
                try await AuthenticationManager.shared.updatePassword(password: password)
            }
     func upDateEmail(email: String)async throws {
                try await AuthenticationManager.shared.updateEmail(email: email)
    }
    func reAuthenticateUser(email:String, password: String) async throws {
        try await AuthenticationManager.shared.sigInUser(email: email, Password: password)
    }
    func getAuthenticatedUser()  throws -> AuthDataResultModel {
        return try AuthenticationManager.shared.getUser()
    }
    
    func deleteUser() async throws {
        try await AuthenticationManager.shared.deleteAccount()
    }
    //get auth Provider
    
    func getAuthProvider() throws {
        self.authProvider = try AuthenticationManager.shared.getProvider()
    }
    // get Db user
    
    func getUser() {
        Task {
            do{
                let user = try getAuthenticatedUser()
                self.user = try await UserDataManager.shared.getDBUser(userId: user.uid)
            }catch let error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    //update display Name
    
    func updateUserName(displayName: String) {
        guard let user else {return}
        Task {
            do{
                try await UserDataManager.shared.upDateUserNamr(userID: user.id, displayName: displayName)
                getUser()
            }catch let error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
