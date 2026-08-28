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
    @Published var errorMessage : String? = ""
    @Published var isSingOut = false
    @Published var user: AuthDataResultModel? = nil
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
    func getAuthenticatedUser()  throws {
        self.user = try AuthenticationManager.shared.getUser()
    }
    
    func deleteUser() async throws {
        try await AuthenticationManager.shared.deleteAccount()
    }
    //get auth Provider
    
    func getAuthProvider() throws {
        self.authProvider = try AuthenticationManager.shared.getProvider()
    }
}
