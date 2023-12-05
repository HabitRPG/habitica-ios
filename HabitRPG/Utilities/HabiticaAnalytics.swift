//
//  HabiticaAnalytics.swift
//  Shared
//
//  Created by Phillip Thelen on 25.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Amplitude

public class HabiticaAnalytics {
    public static let shared = HabiticaAnalytics()
    
    public func setUserID(_ userID: String?) {
        Amplitude.instance().setUserId(userID)
    }
    
    public func logNavigationEvent(_ pageName: String) {
        let properties = [
            "eventAction": "navigated",
            "eventCategory": "navigation",
            "hitType": "pageview",
            "page": pageName
        ]
        Amplitude.instance().logEvent("navigated", withEventProperties: properties)
    }
    
    public func log(_ eventName: String, withEventProperties properties: [AnyHashable: Any] = [:]) {
        Amplitude.instance().logEvent(eventName, withEventProperties: properties)
    }
}
