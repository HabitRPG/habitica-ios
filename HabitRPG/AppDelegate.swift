//
//  AppDelegate.swift
//  Habitica
//
//  Created by Phillip on 11.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import PopupDialog
import Fabric
import Crashlytics
import Keys
import Amplitude_iOS
import Alamofire

//This will eventually replace the old ObjC AppDelegate once that code is ported to swift.
//Reason for adding this class now is mostly, to configure PopupDialogs dim color.
class HabiticaAppDelegate: NSObject {
    
    @objc
    func setupPopups() {
        let appearance = PopupDialogOverlayView.appearance()
        appearance.color = UIColor.purple50()
        appearance.opacity = 0.6
        appearance.blurEnabled = false
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.cornerRadius = 12

    }
    
    @objc
    func setupLogging() {
        Fabric.with([Crashlytics.self])
    }
    
    @objc
    func setupAnalytics() {
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
            return
        }
        gai.trackUncaughtExceptions = true
        
        let keys = HabiticaKeys()
        
        Amplitude.instance().initializeApiKey(keys.amplitudeApiKey)
    }
    
    @objc
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

    @objc
    func handleMaintenanceScreen() {
        Alamofire.request("https://habitica-assets.s3.amazonaws.com/mobileApp/endpoint/maintenance-ios.json")
            .validate()
            .responseJSON {[weak self] response in
                if let json = response.result.value as? NSDictionary {
                    if let activeMaintenance = json["activeMaintenance"] as? NSNumber, activeMaintenance.boolValue {
                        self?.displayMaintenanceScreen(data: json, isDeprecated: false)
                    } else {
                        self?.hideMaintenanceScreen()
                    }
                    guard let buildNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? NSString else {
                        return
                    }
                    if let minVersion = json["minVersion"] as? NSNumber, minVersion.intValue > buildNumber.integerValue {
                        Alamofire.request("https://habitica-assets.s3.amazonaws.com/mobileApp/endpoint/deprecation-ios.json").validate().responseJSON {[weak self] response in
                            if let json = response.result.value as? NSDictionary {
                                self?.displayMaintenanceScreen(data: json, isDeprecated: true)
                            }
                        }
                    }
                }
        }
    }
    
    @objc
    func displayMaintenanceScreen(data: NSDictionary, isDeprecated: Bool) {
        if let presentedController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentedViewController {
        if !(presentedController is HRPGMaintenanceViewController) {
            let maintenanceController = HRPGMaintenanceViewController()
            if let maintenanceData = data as? [AnyHashable: Any] {
                maintenanceController.setMaintenanceData(maintenanceData)
            }
            maintenanceController.isDeprecatedApp = isDeprecated
            presentedController.present(maintenanceController, animated: true, completion: nil)
        }
        }
    }
    
    @objc
    func hideMaintenanceScreen() {
        if let presentedController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentedViewController {
            if presentedController is HRPGMaintenanceViewController {
                presentedController.dismiss(animated: true, completion: nil)
            }
        }
    }
}
