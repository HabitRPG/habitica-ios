//
//  ObjcRemoteLogger.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Shared

@objc
class ObjcHabiticaAnalytics: NSObject {
    @objc
    static func logNavigationEvent(pageName: String) {
        HabiticaAnalytics.shared.logNavigationEvent(pageName)
    }
    
    @objc
    static func log(_ eventName: String, withEventProperties properties: [AnyHashable: Any]) {
        HabiticaAnalytics.shared.log(eventName, withEventProperties: properties)
    }
}
