//
//  AuthDataManager.swift
//  Daylog
//
//  Created by Mac mini on 18/08/2026.
//

import Foundation
import Firebase
import FirebaseAuth


class AuthenticationManager {
    
    static let shared = AuthenticationManager()
}
//MARK: signIn With email
extension AuthenticationManager {
    func CreateUser(email:String, Password:String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: Password)
        let result = AuthDataResultModel(user: authDataResult.user)
        return result
    }
    func getUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    @discardableResult
    func sigInUser(email:String, Password:String) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: Password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async  throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    func updateEmail(email: String) async throws {
        guard let user  = Auth.auth().currentUser else {
            print("User Not found")
            return
        }
        
        try await user.updatePassword(to:email )
    }
    
    func updatePassword(password: String)async throws {
        guard let user  = Auth.auth().currentUser else {
            print("User Not found")
            return
        }
        
        try await user.updatePassword(to:password )
    }
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
//MARK: SignIn with Google

extension AuthenticationManager {
    @discardableResult
    func signInWithGoogle(tokens:GIDSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        print(credential.provider)
        return try await signIn(crediential: credential)
    }
    private func signIn(crediential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: crediential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
