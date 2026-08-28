//
//  AuthDataResultModel.swift
//  Daylog
//
//  Created by Mac mini on 18/08/2026.
//

import Foundation
import FirebaseAuth


struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photourl: String?
    let isAnonymous: Bool
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photourl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}
enum AuthProviderOption: String {
    
    case email = "password"
    case google = "google.com"
    case faceBook = "facebook.com"
}
