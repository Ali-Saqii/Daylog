//
//  FCMService.swift
//  Daylog
//
//  Services/Notifications/FCMService.swift
//
//  Handles Firebase Cloud Messaging token registration and updates.
//

import Foundation
import FirebaseMessaging
import UserNotifications
import UIKit

final class FCMService: NSObject, MessagingDelegate {

    static let shared = FCMService()
    private override init() {}

    // MARK: - Setup

    /// Call this once from AppDelegate after FirebaseApp.configure().
    func setup() {
        Messaging.messaging().delegate = self
    }

    // MARK: - MessagingDelegate

    /// Called whenever FCM issues a new registration token.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("[FCM] Registration token: \(token)")
        saveFCMToken(token)
    }

    // MARK: - Remote notification registration

    /// Pass the APNs device token to FCM so it can map it to an FCM token.
    func setAPNSToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // MARK: - Persist token

    private func saveFCMToken(_ token: String) {
        Task {
            guard let uid = try? AuthenticationManager.shared.getUser().uid else { return }
            try? await UserDataManager.shared.updateFCMToken(userID: uid, token: token)
        }
    }
}
