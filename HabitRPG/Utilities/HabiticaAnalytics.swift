//
//  HabiticaAnalytics.swift
//  Shared
//
//  Created by Phillip Thelen on 25.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import AmplitudeSwift

public class HabiticaAnalytics {
    public static let shared = HabiticaAnalytics()
    
    private var amplitude: Amplitude?
    private var analyticsConsented: Bool = false
    
    public func initialize() {
        amplitude = Amplitude(configuration: Configuration(apiKey: Secrets.amplitudeApiKey,
                                                           optOut: true))
        
        setUserID(AuthenticationManager.shared.currentUserId)
    }
    
    public func setUserID(_ userID: String?) {
        amplitude?.setUserId(userId: userID)
        if userID == nil {
            analyticsConsented = false
            amplitude?.optOut = true
        }
    }
    
    public func setUserProperty(key: String, value: String?) {
        guard analyticsConsented else {
            return
        }
        amplitude?.identify(userProperties: [key: value ?? ""])
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
        let event = BaseEvent(eventType: pageName, eventProperties: properties)
        amplitude?.track(event: event)
    }
    
    public func log(_ eventName: String, withEventProperties properties: [String: Any] = [:]) {
        guard analyticsConsented else {
            return
        }
        let event = BaseEvent(eventType: eventName, eventProperties: properties)
        amplitude?.track(event: event)
    }
    
    public func resetAnalyticsOnLogout() {
        analyticsConsented = false
        amplitude?.optOut = true
        amplitude?.setUserId(userId: nil)
    }
    
    public func setAnalyticsConsents(_ consented: Bool) {
        analyticsConsented = consented
        let enable = consented == true
        amplitude?.optOut = !enable
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
            amplitude?.identify(userProperties: properties)
        }
    }
}
