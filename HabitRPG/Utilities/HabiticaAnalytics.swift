//
//  HabiticaAnalytics.swift
//  Shared
//
//  Created by Phillip Thelen on 25.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Amplitude
import FirebaseAnalytics

public class HabiticaAnalytics {
    public static let shared = HabiticaAnalytics()
    
    public func initialize() {
        Amplitude.instance().initializeApiKey(Secrets.amplitudeApiKey)
        Amplitude.instance().setUserId(AuthenticationManager.shared.currentUserId)
        Amplitude.instance().optOut = true
        
        let userDefaults = UserDefaults.standard
        Amplitude.instance().setUserProperties(["iosTimezoneOffset": -(NSTimeZone.local.secondsFromGMT() / 60),
                                                 "launch_screen": userDefaults.string(forKey: "initialScreenURL") ?? ""
        ])
        
        Analytics.setAnalyticsCollectionEnabled(false)
    }
    
    public func setUserID(_ userID: String?) {
        Amplitude.instance().setUserId(userID)
    }
    
    public func setUserProperty(key: String, value: String?) {
        Analytics.setUserProperty(value, forName: key)
    }
    
    public func logNavigationEvent(_ pageName: String) {
        let properties = [
            "eventAction": "navigated",
            "eventCategory": "navigation",
            "hitType": "pageview",
        ]
        Amplitude.instance().logEvent(pageName, withEventProperties: properties)
    }
    
    public func log(_ eventName: String, withEventProperties properties: [AnyHashable: Any] = [:]) {
        Amplitude.instance().logEvent(eventName, withEventProperties: properties)
    }
    
    public func setAnalyticsConsents(_ consented: Bool) {
        let enable = consented == true
        Amplitude.instance().optOut = !enable
        Analytics.setAnalyticsCollectionEnabled(enable)
    }
}
