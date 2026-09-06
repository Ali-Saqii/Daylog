//
//  StorageManager.swift
//  Daylog
//
//  Services/Firebase/Storage/StorageManager.swift
//
//  Handles all Firebase Storage operations for profile images.
//  Path convention: profileImages/{userId}/avatar.jpg
//

import Foundation
import FirebaseStorage

final class StorageManager {

    static let shared = StorageManager()
    private init() {}

    // MARK: - Reference helpers

    private func profileImageRef(userId: String) -> StorageReference {
        Storage.storage().reference()
            .child("profileImages/\(userId)/avatar.jpg")
    }

    // MARK: - Upload

    /// Uploads raw JPEG data to Storage and returns the public download URL string.
    func uploadProfileImage(userId: String, data: Data) async throws -> String {
        let ref = profileImageRef(userId: userId)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    // MARK: - Delete

    /// Deletes the stored avatar. Silently ignores "object not found" so callers
    /// don't need to guard against first-time uploads.
    func deleteProfileImage(userId: String) async throws {
        let ref = profileImageRef(userId: userId)
        do {
            try await ref.delete()
        } catch let nsErr as NSError {
            // StorageErrorCode.objectNotFound → file didn't exist yet, safe to swallow
            if let code = (nsErr.userInfo["FIRStorageErrorCode"] as? Int).map({ StorageErrorCode(rawValue: $0) }),
               code == .objectNotFound {
                return
            }
            throw nsErr
        }
    }

    // MARK: - Replace (delete old → upload new)

    /// Best-effort delete of the existing avatar, then uploads new JPEG data.
    /// Returns the download URL of the newly uploaded image.
    func replaceProfileImage(userId: String, data: Data) async throws -> String {
        try? await deleteProfileImage(userId: userId)   // ignore delete errors
        return try await uploadProfileImage(userId: userId, data: data)
    }
}
