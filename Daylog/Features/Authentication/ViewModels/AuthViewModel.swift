//
//  AuthViewModel.swift
//  Daylog
//
//  Created by Mac mini on 15/08/2026.
//

import Foundation
import Combine
import GoogleSignIn

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
                let _ = try await  AuthenticationManager.shared.CreateUser(email: email, Password: password)
                self.SignUpsucessful = true
            }catch let error {
                print(error.localizedDescription)
                self.SignUpsucessful = true
                self.errorMessage = "Unable to create account"
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
                print(error.localizedDescription)
                self.logInsucessful = true
                self.errorMessage = "Unable to login account"

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
        try await AuthenticationManager.shared.signInWithGoogle(tokens:tokens)
    }
}
