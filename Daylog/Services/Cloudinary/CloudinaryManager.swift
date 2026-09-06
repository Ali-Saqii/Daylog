//
//  CloudinaryManager.swift
//  Daylog
//
//  Services/Cloudinary/CloudinaryManager.swift
//
//  Handles all Cloudinary image storage operations for profile photos.
//  Uses unsigned uploads with preset, supports automatic overwrite/replacement,
//  and signed deletion if API credentials are provided.
//

import Foundation
import CryptoKit

enum CloudinaryError: LocalizedError {
    case invalidURL
    case invalidResponse
    case uploadFailed(String)
    case missingCredentials

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Cloudinary endpoint URL."
        case .invalidResponse:
            return "Invalid response received from Cloudinary."
        case .uploadFailed(let msg):
            return "Cloudinary Upload Failed: \(msg)"
        case .missingCredentials:
            return "Cloudinary cloudName or uploadPreset is missing. Please configure them in CloudinaryManager."
        }
    }
}

final class CloudinaryManager {

    static let shared = CloudinaryManager()
    private init() {}

    // MARK: - Configuration
    // Replace these values with your Cloudinary dashboard credentials:
    // 1. cloudName: Your Cloudinary Cloud Name
    // 2. uploadPreset: An unsigned upload preset (Settings -> Upload -> Upload presets -> Add preset -> Signing Mode: Unsigned)
    // 3. apiKey & apiSecret: (Optional) Needed only if making direct signed destroy API calls
    var cloudName: String = "YOUR_CLOUD_NAME"
    var uploadPreset: String = "daylog_preset"
    var apiKey: String = ""
    var apiSecret: String = ""

    private let folder: String = "daylog_profile_photos"

    // MARK: - Helper Public ID
    func publicIdForUser(userId: String) -> String {
        return "\(folder)/user_\(userId)"
    }

    // MARK: - Upload / Replace Profile Image
    /// Uploads the given image data to Cloudinary.
    /// Overwrites any existing photo for this user (deleting the old version on Cloudinary).
    /// Returns the secure HTTPS URL of the uploaded image.
    @discardableResult
    func replaceProfileImage(userId: String, data: Data) async throws -> String {
        guard !cloudName.isEmpty && cloudName != "YOUR_CLOUD_NAME" else {
            // If placeholder is still present, throw a descriptive error
            throw CloudinaryError.missingCredentials
        }

        let publicId = publicIdForUser(userId: userId)

        // Attempt signed deletion first if API Secret & Key are provided
        if !apiKey.isEmpty && !apiSecret.isEmpty {
            try? await deleteImage(publicId: publicId)
        }

        // Upload new image with overwrite=true and invalidate=true
        return try await uploadImage(data: data, publicId: publicId)
    }

    // MARK: - Upload Image (Unsigned REST API)
    func uploadImage(data: Data, publicId: String) async throws -> String {
        guard let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload") else {
            throw CloudinaryError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var parameters: [String: String] = [
            "upload_preset": uploadPreset,
            "public_id": publicId,
            "overwrite": "true",
            "invalidate": "true"
        ]

        let body = createMultipartBody(
            boundary: boundary,
            parameters: parameters,
            imageData: data,
            fieldName: "file",
            fileName: "avatar.jpg",
            mimeType: "image/jpeg"
        )

        request.httpBody = body

        let (responseData, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudinaryError.invalidResponse
        }

        if (200...299).contains(httpResponse.statusCode) {
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let secureUrl = json["secure_url"] as? String {
                return secureUrl
            } else {
                throw CloudinaryError.invalidResponse
            }
        } else {
            var errorMessage = "HTTP \(httpResponse.statusCode)"
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let errorObj = json["error"] as? [String: Any],
               let message = errorObj["message"] as? String {
                errorMessage = message
            }
            throw CloudinaryError.uploadFailed(errorMessage)
        }
    }

    // MARK: - Delete Image (Signed Destroy API)
    func deleteImage(publicId: String) async throws {
        guard !apiKey.isEmpty, !apiSecret.isEmpty, !cloudName.isEmpty else {
            return
        }

        guard let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/destroy") else {
            throw CloudinaryError.invalidURL
        }

        let timestamp = String(Int(Date().timeIntervalSince1970))
        let stringToSign = "public_id=\(publicId)&timestamp=\(timestamp)\(apiSecret)"
        let signature = sha1(stringToSign)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params: [String: String] = [
            "public_id": publicId,
            "timestamp": timestamp,
            "api_key": apiKey,
            "signature": signature,
            "invalidate": "true"
        ]

        let bodyString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            print("Cloudinary delete warning: HTTP \(httpResponse.statusCode)")
        }
    }

    // MARK: - Multipart Helper
    private func createMultipartBody(
        boundary: String,
        parameters: [String: String],
        imageData: Data,
        fieldName: String,
        fileName: String,
        mimeType: String
    ) -> Data {
        var body = Data()

        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }

    // MARK: - SHA1 Hash for Cloudinary Signature
    private func sha1(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = Insecure.SHA1.hash(data: inputData)
        return hashed.map { String(format: "%02hhx", $0) }.joined()
    }
}
