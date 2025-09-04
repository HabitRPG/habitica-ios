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
    
    private var analyticsConsented: Bool = false
    
    public func initialize() {
        Amplitude.instance().initializeApiKey(Secrets.amplitudeApiKey)
        Amplitude.instance().setUserId(AuthenticationManager.shared.currentUserId)
        Amplitude.instance().optOut = true
        Analytics.setAnalyticsCollectionEnabled(false)
    }
    
    public func setUserID(_ userID: String?) {
        Amplitude.instance().setUserId(userID)
        if userID == nil {
            analyticsConsented = false
            Amplitude.instance().optOut = true
            Analytics.setAnalyticsCollectionEnabled(false)
        }
    }
    
    public func setUserProperty(key: String, value: String?) {
        guard analyticsConsented else { return }
        Analytics.setUserProperty(value, forName: key)
    }
    
    public func logNavigationEvent(_ pageName: String) {
        guard analyticsConsented else { return }
        let properties = [
            "eventAction": "navigated",
            "eventCategory": "navigation",
            "hitType": "pageview"
        ]
        Amplitude.instance().logEvent(pageName, withEventProperties: properties)
    }
    
    public func log(_ eventName: String, withEventProperties properties: [String: Any] = [:]) {
        guard analyticsConsented else { return }
        Amplitude.instance().logEvent(eventName, withEventProperties: properties)
        Analytics.logEvent(eventName, parameters: properties)
    }
    
    public func resetAnalyticsOnLogout() {
        analyticsConsented = false
        Amplitude.instance().optOut = true
        Analytics.setAnalyticsCollectionEnabled(false)
        Amplitude.instance().setUserId(nil)
    }
    
    public func setAnalyticsConsents(_ consented: Bool) {
        analyticsConsented = consented
        let enable = consented == true
        Amplitude.instance().optOut = !enable
        Analytics.setAnalyticsCollectionEnabled(enable)
        if enable {
            let userDefaults = UserDefaults.standard
            var properties: [String: Any] = [
                "iosTimezoneOffset": -(NSTimeZone.local.secondsFromGMT() / 60),
                "launch_screen": userDefaults.string(forKey: "initialScreenURL") ?? ""
            ]
            if userDefaults.bool(forKey: "userWasAttributed") {
                if let clickedAd = userDefaults.string(forKey: "pendingAttribution_clickedSearchAd") {
                    properties["clickedSearchAd"] = clickedAd
                    userDefaults.removeObject(forKey: "pendingAttribution_clickedSearchAd")
                }
                if let adName = userDefaults.string(forKey: "pendingAttribution_searchAdName") {
                    properties["searchAdName"] = adName
                    userDefaults.removeObject(forKey: "pendingAttribution_searchAdName")
                }
                if let conversionDate = userDefaults.string(forKey: "pendingAttribution_searchAdConversionDate") {
                    properties["searchAdConversionDate"] = conversionDate
                    userDefaults.removeObject(forKey: "pendingAttribution_searchAdConversionDate")
                }
            }
            Amplitude.instance().setUserProperties(properties)
        }
    }
}
