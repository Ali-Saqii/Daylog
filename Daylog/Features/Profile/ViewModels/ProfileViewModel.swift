//
//  ProfileViewModel.swift
//  Daylog
//
//  Created by Mac mini on 17/08/2026.
//

import Foundation
import Combine
import SwiftUI
import GoogleSignIn
import FacebookLogin
import FacebookCore

struct ProfileStats {
    var habitCount: Int = 0
    var bestStreak: Int = 0
    var journalEntries: Int = 0   // placeholder until Journal feature is built
}

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: AppUser? = nil
    @Published var stats: ProfileStats = ProfileStats()
    @Published var isLoadingStats = false
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
            self.errorMessage = AppError.format(error)
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
            } catch let error {
                self.errorMessage = AppError.format(error)
            }
        }
    }

    // MARK: - Profile Stats

    func loadStats() {
        Task {
            do {
                let authUser = try getAuthenticatedUser()
                isLoadingStats = true
                async let habitCount  = HabitDataManager.shared.getHabitCount(userId: authUser.uid)
                async let bestStreak  = HabitDataManager.shared.getBestStreak(userId: authUser.uid)
                async let entryCount  = JournalDataManager.shared.getEntryCount(userId: authUser.uid)
                let (count, streak, entries) = try await (habitCount, bestStreak, entryCount)
                self.stats = ProfileStats(
                    habitCount: count,
                    bestStreak: streak,
                    journalEntries: entries
                )
            } catch {
                self.errorMessage = AppError.format(error)
            }
            isLoadingStats = false
        }
    }

    //update display Name
    
    func updateUserName(displayName: String) {
        guard let user else {return}
        Task {
            do{
                try await UserDataManager.shared.upDateUserNamr(userID: user.id, displayName: displayName)
                getUser()
            } catch let error {
                self.errorMessage = AppError.format(error)
            }
        }
    }

    func updatePhotoUrl(photoUrl: String) {
        guard let user else { return }
        Task {
            do {
                try await UserDataManager.shared.updateUserPhotoUrl(userID: user.id, photoUrl: photoUrl)
                getUser()
            } catch {
                self.errorMessage = AppError.format(error)
            }
        }
    }
    
    //MARK: - Link Accounts
    func linkEmailAndPassword(email: String, password: String) {
        Task {
            do {
                let authDataResult = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
                let updatedUser = AppUser(auth: authDataResult)
                try await UserDataManager.shared.createUser(user: updatedUser)
                try getAuthProvider()
                getUser()
            } catch {
                self.errorMessage = AppError.format(error)
            }
        }
    }

    func linkGoogle() {
        Task {
            do {
                guard let topVC = Utilities.shared.topViewController() else {
                    throw URLError(.cannotFindHost)
                }
                let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
                guard let idToken = gidSignInResult.user.idToken?.tokenString else {
                    throw URLError(.badServerResponse)
                }
                let accessToken = gidSignInResult.user.accessToken.tokenString
                let tokens = GIDSignInResultModel(idToken: idToken, accessToken: accessToken)
                let authDataResult = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
                let updatedUser = AppUser(auth: authDataResult)
                try await UserDataManager.shared.createUser(user: updatedUser)
                try getAuthProvider()
                getUser()
            } catch {
                self.errorMessage = AppError.format(error)
            }
        }
    }

    func linkFacebook() {
        Task {
            do {
                let loginManager = LoginManager()
                let _: LoginManagerLoginResult = try await withCheckedThrowingContinuation { continuation in
                    loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        guard let result, !result.isCancelled else {
                            continuation.resume(throwing: URLError(.userCancelledAuthentication))
                            return
                        }
                        continuation.resume(returning: result)
                    }
                }
                guard let tokenString = AccessToken.current?.tokenString else {
                    self.errorMessage = "Could not retrieve Facebook access token."
                    return
                }
                let fbResult = FacebookAuthResultModel(accessToken: tokenString, name: nil, email: nil)
                let authDataResult = try await AuthenticationManager.shared.linkFacebook(tokens: fbResult)
                let updatedUser = AppUser(auth: authDataResult)
                try await UserDataManager.shared.createUser(user: updatedUser)
                try getAuthProvider()
                getUser()
            } catch {
                self.errorMessage = AppError.format(error)
            }
        }
    }

    func isProviderLinked(_ option: AuthProviderOption) -> Bool {
        authProvider?.contains(option) ?? false
    }
}
