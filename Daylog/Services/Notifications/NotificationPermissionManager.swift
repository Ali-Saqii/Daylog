
//
//  NotificationManager.swift
//  Daylog
//
//  Services/Notifications/NotificationManager.swift
//

import Foundation
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()
    private init() { }

    private let reminderIdentifier = "dailyReminder"

    // MARK: - Permission
    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])
    }

    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: - Schedule daily reminder
    func scheduleDailyReminder(at hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()

        // Purana reminder hata dein agar pehle se koi schedule tha
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "DayLog"
        content.body = "Don't forget to check off your habits and write today's entry."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        // repeats: true → matlab ye har din isi waqt pe dubara trigger hoga, automatically
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                print("Failed to schedule reminder: \(error.localizedDescription)")
            } else {
                print("Daily reminder scheduled for \(hour):\(minute)")
            }
        }
    }
}
//MARK: Notification management

extension NotificationManager {

    func sendInstantNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to send instant notification: \(error.localizedDescription)")
            }
        }
    }
}
//MARK: Add Notification management

extension NotificationManager {

    func notifySignUpSuccess() {
        sendInstantNotification(
            title: "Welcome to DayLog 🎉",
            body: "Your account has been created successfully."
        )
    }

    func notifyLoginSuccess() {
        sendInstantNotification(
            title: "Welcome back 👋",
            body: "You're logged in to DayLog."
        )
    }

    func notifyAccountLinked(provider: String) {
        sendInstantNotification(
            title: "Account Linked",
            body: "Your account is now linked with \(provider)."
        )
    }

    func notifyHabitAdded(title: String) {
        sendInstantNotification(
            title: "Habit Added ✅",
            body: "\"\(title)\" has been added to your habits."
        )
    }

    func notifyJournalAdded() {
        sendInstantNotification(
            title: "Entry Saved 📝",
            body: "Today's journal entry has been saved."
        )
    }
}
//MARK: Badge management
extension NotificationManager {

    func clearBadgeCount() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error {
                print("Failed to clear badge count: \(error.localizedDescription)")
            }
        }
    }
}
