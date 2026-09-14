//
//  AuthViewModel.swift
//  Daylog
//
//  Created by Mac mini on 15/08/2026.
//

import Foundation
import Combine
import GoogleSignIn
import FacebookLogin
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var password = ""
    @Published var email = ""
    @Published var errorMessage: String? = ""
    @Published var loginSuccessful = false
    @Published var signUpSuccessful = false

    func createAccount(email: String, password: String, name: String) {
        Task {
            guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
                  !password.isEmpty,
                  !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                self.errorMessage = "Please fill in all fields (name, email, password)."
                return
            }
            do {
                let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
                let user = AppUser(auth: authDataResult)
                try await UserDataManager.shared.createUser(user: user)
                self.signUpSuccessful = true
                NotificationManager.shared.notifySignUpSuccess()
            } catch {
                self.errorMessage = AppError.format(error)
            }
        }
    }

    func signIn(email: String, password: String) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else {
            self.errorMessage = "Please enter both email and password."
            return
        }
        Task {
            do {
                let _ = try await AuthenticationManager.shared.signInWithEmail(email: email, password: password)
                self.loginSuccessful = true
                NotificationManager.shared.notifyLoginSuccess()
            } catch {
                self.errorMessage = AppError.format(error)
            }
        }
    }

    func resetPassword(email: String) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.errorMessage = "Please enter your email address."
            return
        }
        Task {
            do {
                try await AuthenticationManager.shared.resetPassword(email: email)
            } catch {
                self.errorMessage = AppError.format(error)
            }
        }
    }
}

// MARK: - Sign In with Google
extension AuthViewModel {

    func signInGoogle() async throws {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        let tokens = GIDSignInResultModel(idToken: idToken, accessToken: accessToken)
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        NotificationManager.shared.notifyLoginSuccess()
        let user = AppUser(auth: authDataResult)
        try await UserDataManager.shared.createUser(user: user)
    }
}

// MARK: - Sign In with Facebook
extension AuthViewModel {

    /// Signs in via Facebook. Errors propagate to callers; do NOT wrap in a Task here
    /// so that structured concurrency is preserved.
    func signInFacebook() async {
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

            let authDataResult = try await AuthenticationManager.shared.signInWithFacebook(tokenString: tokenString)
            let user = AppUser(auth: authDataResult)
            try await UserDataManager.shared.createUser(user: user)
            self.loginSuccessful = true
            NotificationManager.shared.notifyLoginSuccess()

        } catch {
            self.errorMessage = AppError.format(error)
        }
    }

    func signOutFacebook() {
        LoginManager().logOut()
    }
}

enum FacebookAuthError: LocalizedError {
    case cancelled
    case missingToken
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Facebook sign-in was cancelled."
        case .missingToken:
            return "Could not retrieve Facebook access token."
        case .unknown(let message):
            return message
        }
    }
}
