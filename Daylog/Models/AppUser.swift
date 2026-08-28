//
//  AppUser.swift
//  DayLog
//
//  Models/AppUser.swift
//

import Foundation

struct AppUser: Identifiable, Codable, Equatable {
    let id: String          // Firebase Auth UID
    let email: String?
    let displayName: String?
    let photoUrl: String?
    let createdAt: Date?
    
    init(
        id: String  ,
        email: String?,
        displayName: String?,
        photoUrl: String?,
        createdAt: Date?,
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoUrl = photoUrl
        self.createdAt = createdAt
    }
    
    init(auth:AuthDataResultModel) {
        self.id = auth.uid
        self.email = auth.email
        self.displayName = ""
        self.photoUrl = auth.photourl
        self.createdAt = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email = "email"
        case displayName = "display_name"
        case photoUrl = "photo_url"
        case createdAt = "created_at"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.displayName, forKey: .displayName)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.createdAt, forKey: .createdAt)
    }
    

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }

}
