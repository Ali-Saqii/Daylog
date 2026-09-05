//
//  AuthRepository.swift
//  Daylog
//
//  Repo/AuthRepository.swift
//

import Foundation
import FirebaseAuth

protocol AuthRepositoryProtocol {
    func getUser() throws -> AuthDataResultModel
    func signOut() throws
    func deleteAccount() async throws
    func getProvider() throws -> [AuthProviderOption]
}

final class AuthRepository: AuthRepositoryProtocol {
    static let shared = AuthRepository()
    private let authManager: AuthenticationManager

    init(authManager: AuthenticationManager = .shared) {
        self.authManager = authManager
    }

    func getUser() throws -> AuthDataResultModel {
        try authManager.getUser()
    }

    func signOut() throws {
        try authManager.signOut()
    }

    func deleteAccount() async throws {
        try await authManager.deleteAccount()
    }

    func getProvider() throws -> [AuthProviderOption] {
        try authManager.getProvider()
    }
}
