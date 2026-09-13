//
//  CrashlyticsService.swift
//  Daylog
//
//  Services/Firebase/CrashlyticsService.swift
//  Handles Firebase Crashlytics logging, non-fatal error reporting, and user tracking.
//

import Foundation
import FirebaseCrashlytics

final class CrashlyticsService {
    static let shared = CrashlyticsService()
    
    private init() {}
    
    /// Sets the user identifier for Crashlytics reports
    func setUserID(_ userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
    
    /// Logs a custom message to Crashlytics
    func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    /// Sets custom keys for additional context in crash reports
    func setCustomKey(_ key: String, value: Any) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    /// Records non-fatal errors to Crashlytics dashboard
    func recordError(_ error: Error, additionalInfo: [String: Any]? = nil) {
        if let info = additionalInfo {
            for (key, value) in info {
                Crashlytics.crashlytics().setCustomValue(value, forKey: key)
            }
        }
        Crashlytics.crashlytics().record(error: error)
    }
}
