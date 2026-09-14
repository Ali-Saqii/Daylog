//
//  AuthDataManager.swift
//  Daylog
//
//  Created by Mac mini on 18/08/2026.
//

import Foundation
import Firebase
import FirebaseAuth


enum AuthenticationError: LocalizedError {
    case userNotAuthenticated

    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "No authenticated user found. Please sign in again."
        }
    }
}

class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    
    // get Auth Provider
    func getProvider() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw AuthenticationError.userNotAuthenticated
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            }else{
                assertionFailure("Provider Option Not Found: \(provider.providerID)")
            }
        }
        return providers

    }
}
// MARK: - Sign In with Email
extension AuthenticationManager {
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

    func getUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotAuthenticated
        }
        return AuthDataResultModel(user: user)
    }

    @discardableResult
    func signInWithEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async  throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotAuthenticated
        }
        // Uses Firebase's secure flow: sends a verification link to the new address
        // before the change is committed.
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotAuthenticated
        }
        try await user.updatePassword(to: password)
    }
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            return
        }
        try await user.delete()
        
    }
}
//MARK: SignIn with Google

extension AuthenticationManager {
    @discardableResult
    func signInWithGoogle(tokens:GIDSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        print(credential.provider)
        return try await signIn(credential: credential)
    }
    private func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
//MARK: SignIn with Facebook

extension AuthenticationManager {
    @discardableResult
    func signInWithFacebook(tokenString: String) async throws -> AuthDataResultModel {
        let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
        return try await signIn(credential: credential)
    }
}

// Link Accounts
extension AuthenticationManager {
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let credentials = EmailAuthProvider.credential(withEmail: email, password: password)
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotAuthenticated
        }
        let authDataResult = try await user.link(with: credentials)
        return AuthDataResultModel(user: authDataResult.user)
    }

    func linkFacebook(tokens: FacebookAuthResultModel) async throws -> AuthDataResultModel {
        let credentials = FacebookAuthProvider.credential(withAccessToken: tokens.accessToken)
        return try await linkCredentials(credentials)
    }

    func linkGoogle(tokens: GIDSignInResultModel) async throws -> AuthDataResultModel {
        let credentials = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await linkCredentials(credentials)
    }

    private func linkCredentials(_ credentials: AuthCredential) async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotAuthenticated
        }
        let authDataResult = try await user.link(with: credentials)
        return AuthDataResultModel(user: authDataResult.user)
    }
}


