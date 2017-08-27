//
//  AppDelegate.swift
//  Habitica
//
//  Created by Phillip on 11.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit
import PopupDialog
import Fabric
import Crashlytics
import Keys
import Amplitude_iOS

//This will eventually replace the old ObjC AppDelegate once that code is ported to swift.
//Reason for adding this class now is mostly, to configure PopupDialogs dim color.
class HabiticaAppDelegate: NSObject {
    
    func setupPopups() {
        let appearance = PopupDialogOverlayView.appearance()
        appearance.color = UIColor.purple50()
        appearance.opacity = 0.6
        appearance.blurEnabled = false
    }
    
    func setupLogging() {
        Fabric.with([Crashlytics.self])
    }
    
    func setupAnalytics() {
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
            return
        }
        gai.trackUncaughtExceptions = true
        
        let keys = HabiticaKeys()
        
        Amplitude.instance().initializeApiKey(keys.amplitudeApiKey)
    }
    
    func handleInitialLaunch() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "wasLaunchedBefore") {
            defaults.set(true, forKey: "wasLaunchedBefore")
            
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 19
            components.minute = 0
            let newDate = Calendar.current.date(from: components)
            
            defaults.set(true, forKey: "dailyReminderActive")
            defaults.set(newDate, forKey: "dailyReminderTime")
            defaults.set(true, forKey: "appBadgeActive")
            UIApplication.shared.cancelAllLocalNotifications()
            
            let localNotification = UILocalNotification()
            localNotification.fireDate = newDate
            localNotification.repeatInterval = .day
            localNotification.alertBody = NSLocalizedString("Remember to check off your Dailies!", comment: "")
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.timeZone = NSTimeZone.default
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }

}
