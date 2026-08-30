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

import FirebaseAuth
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var password = ""
    @Published var email = ""
    @Published var errorMessage : String? = ""
    @Published var logInsucessful = false
    @Published var SignUpsucessful = false

    func createAccount(email: String, password: String,name:String) {
        Task {
            guard !email.isEmpty,!password.isEmpty ,!name.isEmpty else{
                self.errorMessage = "password or email is empty"
                return
            }
            do {
                let authDataresult = try await  AuthenticationManager.shared.CreateUser(email: email, Password: password)
                let user = AppUser(auth: authDataresult)
                try await UserDataManager.shared.createUser(user: user)
                self.SignUpsucessful = true
            }catch let error {
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
        }
    }
    func SignIn(email:String, password: String)   {
        guard !email.isEmpty,!password.isEmpty else{
            self.errorMessage = "password or email is empty"
            return
        }
        Task {
            do {
                let _ = try await AuthenticationManager.shared.sigInUser(email: email, Password: password)
                
                self.logInsucessful = true
            }catch let error {
                self.errorMessage = error.localizedDescription

            }
        }
    }
    
    func resetPassword(email:String) {
        guard  !email.isEmpty else {
            self.errorMessage = "Please enter valid email"
            return
        }
        Task {
            do {
               try await  AuthenticationManager.shared.resetPassword(email: email)
                
            }catch {
                self.errorMessage = "Un able to reset password"
            }
        }
    }
}
//MARK: SignIn With Goolgel

extension AuthViewModel {
    
    func signInGoogle() async throws {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else{
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GIDSignInResultModel(idToken: idToken, accessToken: accessToken)
        let authDataresult =  try await AuthenticationManager.shared.signInWithGoogle(tokens:tokens)
        let user = AppUser(auth: authDataresult)
        try await UserDataManager.shared.createUser(user: user)
    }
}
//MARK: SignIn With Facebook
extension AuthViewModel {

    func signInFacebook() async {
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
                    self.errorMessage = "Could not retrieve Facebook access token"
                    return
                }

                let authDataresult = try await AuthenticationManager.shared.signInWithFacebook(tokenString: tokenString)
                let user = AppUser(auth: authDataresult)
                try await UserDataManager.shared.createUser(user: user)
                self.logInsucessful = true

            } catch {
                print(error.localizedDescription)
                self.errorMessage = "Unable to sign in with Facebook"
            }
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
