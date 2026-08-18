//
//  HabiticaAnalytics.swift
//  Shared
//
//  Created by Phillip Thelen on 25.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

public class HabiticaAnalytics {
    public static let shared = HabiticaAnalytics()
    
    private var analyticsConsented: Bool = false
    
    public func initialize() {
        setUserID(AuthenticationManager.shared.currentUserId)
    }
    
    public func setUserID(_ userID: String?) {
        if userID == nil {
            analyticsConsented = false
        }
    }
    
    public func setUserProperty(key: String, value: String?) {
        guard analyticsConsented else {
            return
        }
    }
    
    public func logNavigationEvent(_ pageName: String) {
        guard analyticsConsented else {
            return
        }
        let properties = [
            "eventAction": "navigated",
            "eventCategory": "navigation",
            "hitType": "pageview"
        ]
    }
    
    public func log(_ eventName: String, withEventProperties properties: [String: Any] = [:]) {
        guard analyticsConsented else {
            return
        }
    }
    
    public func resetAnalyticsOnLogout() {
        analyticsConsented = false
    }
    
    public func setAnalyticsConsents(_ consented: Bool) {
        analyticsConsented = consented
    }
}
