//
//  AnalyticsManager.swift
//  Daylog
//
//  Created by Mac mini on 14/09/2026.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    private init() {}
    
    func logEvent(name: String, params: [String:Any]? = nil) {
        
        Analytics.logEvent(name, parameters: params)
    }
    func setUserId(userId: String) {
        Analytics.setUserID(userId)
    }
    
    func setUserProperty(value: String?, property: String) {
        // AnalyticsEventAddPaymentInfo
        Analytics.setUserProperty(value, forName: property)
    }
}
