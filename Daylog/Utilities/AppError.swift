//
//  AppError.swift
//  Daylog
//
//  Utilities/AppError.swift
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AppError {
    static func format(_ error: Error) -> String {
        let nsError = error as NSError
        
        // Handle FirebaseAuth errors
        if nsError.domain == AuthErrorDomain {
            if let code = AuthErrorCode(rawValue: nsError.code) {
                switch code {
                case .invalidEmail:
                    return "The email address format is invalid."
                case .wrongPassword:
                    return "Incorrect password. Please try again."
                case .userNotFound:
                    return "No account found with this email."
                case .emailAlreadyInUse:
                    return "An account with this email address already exists."
                case .weakPassword:
                    return "Password is too weak. Please use at least 6 characters."
                case .requiresRecentLogin:
                    return "Please log out and log back in to update credentials."
                case .networkError:
                    return "Network connection error. Please check your internet."
                case .userDisabled:
                    return "This account has been disabled."
                case .credentialAlreadyInUse:
                    return "This account is already linked to another user."
                case .providerAlreadyLinked:
                    return "This provider is already linked to your account."
                default:
                    break
                }
            }
        }

        // Handle Firestore errors
        if nsError.domain == FirestoreErrorDomain {
            if let code = FirestoreErrorCode(rawValue: nsError.code) {
                switch code {
                case .permissionDenied:
                    return "Permission denied. Check your permissions."
                case .unavailable:
                    return "Service is temporarily unavailable. Please try again."
                case .notFound:
                    return "Requested resource was not found."
                default:
                    break
                }
            }
        }

        let description = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        if !description.isEmpty && !description.contains("couldn’t be completed") {
            return description
        }

        return "An unexpected error occurred. Please try again."
    }
}
