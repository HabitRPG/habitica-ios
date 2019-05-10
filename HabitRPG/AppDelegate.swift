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
import Habitica_API_Client
import Habitica_Models
import RealmSwift
import ReactiveSwift
import Firebase
import SwiftyStoreKit
import StoreKit
import UserNotifications
import FirebaseMessaging

//This will eventually replace the old ObjC AppDelegate once that code is ported to swift.
//Reason for adding this class now is mostly, to configure PopupDialogs dim color.
class HabiticaAppDelegate: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    static let possibleLaunchArgs = ["userid", "apikey"]
    
    private let application: UIApplication
    
    private let userRepository = UserRepository()
    private let contentRepository = ContentRepository()
    private let taskRepository = TaskRepository()
    private let socialRepository = SocialRepository()
    
    @objc
    init(application: UIApplication) {
        self.application = application
        super.init()
    }
    
    @objc
    func handleLaunchArgs() {
        let launchArgs = ProcessInfo.processInfo.environment
        if (launchArgs["userid"] != nil) {
            AuthenticationManager.shared.currentUserId = launchArgs["userid"]
        }
        if (launchArgs["apikey"] != nil) {
            AuthenticationManager.shared.currentUserKey = launchArgs["apikey"]
        }
    }
    
    @objc
    func setupPopups() {
        let appearance = PopupDialogOverlayView.appearance()
        appearance.opacity = 0.6
        appearance.blurEnabled = false
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.cornerRadius = 12
    }
    
    @objc
    func setupFirebase() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        Analytics.setUserProperty(LanguageHandler.getAppLanguage().code, forName: "app_language")
        if #available(iOS 10.3, *) {
            Analytics.setUserProperty(UIApplication.shared.alternateIconName, forName: "app_icon")
        }
    }
    
    @objc
    func setupLogging() {
        let userID = AuthenticationManager.shared.currentUserId
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        Crashlytics.sharedInstance().setUserIdentifier(userID)
        Crashlytics.sharedInstance().setUserName(userID)
    }
    
    @objc
    func setupAnalytics() {
        let keys = HabiticaKeys()
        Amplitude.instance().initializeApiKey(keys.amplitudeApiKey)
        Amplitude.instance().setUserId(AuthenticationManager.shared.currentUserId)
        Amplitude.instance()?.setUserProperties(["iosTimezoneOffset": -(NSTimeZone.local.secondsFromGMT() / 60)])
    }
    
    @objc
    func setupPurchaseHandling() {
        if HabiticaAppDelegate.isRunningLive() {
            PurchaseHandler.shared.completionHandler()
        }
    }
    
    @objc
    func setupTheme() {
        let defaults = UserDefaults.standard
        let themeName = ThemeName(rawValue: defaults.string(forKey: "theme") ?? "") ?? ThemeName.defaultTheme
        ThemeService.shared.theme = themeName.themeClass
        Analytics.setUserProperty(themeName.rawValue, forName: "theme")
    }
    
    @objc
    func setupNetworkClient() {
        NetworkAuthenticationManager.shared.currentUserId = AuthenticationManager.shared.currentUserId
        NetworkAuthenticationManager.shared.currentUserKey = AuthenticationManager.shared.currentUserKey
        updateServer()
        AuthenticatedCall.errorHandler = HabiticaNetworkErrorHandler()
        let configuration = URLSessionConfiguration.default
        AuthenticatedCall.defaultConfiguration.urlConfiguration = configuration
    }
    
    func updateServer() {
        if let chosenServer = UserDefaults().string(forKey: "chosenServer") {
            switch chosenServer {
            case "staging":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.staging
            case "beta":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.beta
            case "gamma":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.gamma
            case "delta":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.delta
            default:
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.production
            }
        }
    }
    
    @objc
    func setupDatabase() {
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true
        let fileUrl = try? FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("habitica.realm")
        if let url = fileUrl {
            config.fileURL = url
        }
        print("Realm stored at:", config.fileURL ?? "")
        Realm.Configuration.defaultConfiguration = config
    }
    
    @objc
    func setupUserManager() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UserManager.shared.beginListening()
        }
        
    }
    
    @objc
    func setupRouter() {
        RouterHandler.shared.register()
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
            
            rescheduleDailyReminder()
        }
    }
    
    @objc
    func rescheduleDailyReminder() {
        let defaults = UserDefaults.standard
        
        let sharedApplication = UIApplication.shared
        for localNotification in sharedApplication.scheduledLocalNotifications ?? [] {
            if (localNotification.userInfo?["id"] as? String ?? "").isEmpty || (localNotification.userInfo?["isDailyNotification"] as? Bool) == true {
                sharedApplication.cancelLocalNotification(localNotification)
            }
        }
        
        if defaults.bool(forKey: "dailyReminderActive"), let date = defaults.value(forKey: "dailyReminderTime") as? Date {
            let localNotification = UILocalNotification()
            localNotification.fireDate = date
            localNotification.repeatInterval = .day
            localNotification.alertBody = L10n.rememberCheckOffDailies
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.timeZone = NSTimeZone.default
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }

    @objc
    func handleMaintenanceScreen() {
        let call = RetrieveMaintenanceInfoCall()
        call.fire()
        call.jsonSignal.map({ json -> [String: Any]? in
            let jsonDict = json as? [String: Any]
            return jsonDict
        })
            .skipNil()
            .on(value: {[weak self]json in
                if let activeMaintenance = json["activeMaintenance"] as? Bool, activeMaintenance {
                    self?.displayMaintenanceScreen(data: json, isDeprecated: false)
                } else {
                    self?.hideMaintenanceScreen()
                }
            })
            .filter { (json) -> Bool in
                guard let buildNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? NSString else {
                    return false
                }
                if let minVersion = json["minVersion"] as? Int, minVersion > buildNumber.integerValue {
                    return true
                }
                return false
            }
            .flatMap(.latest) { (_) -> Signal<Any, Never> in
                let call = RetrieveDeprecationInfoCall()
                call.fire()
                return call.jsonSignal
            }
            .map({ (jsonObject) in
                return jsonObject as? [AnyHashable: Any]
            })
            .skipNil()
            .observeValues { (json) in
                self.displayMaintenanceScreen(data: json, isDeprecated: true)
        }
    }
    
    @objc
    func displayMaintenanceScreen(data: [AnyHashable: Any], isDeprecated: Bool) {
        if let presentedController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentedViewController {
        if !(presentedController is HRPGMaintenanceViewController) {
            let maintenanceController = HRPGMaintenanceViewController()
            maintenanceController.setMaintenanceData(data)
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
    
    @objc
    func retrieveContent() {
        let defaults = UserDefaults.standard
        let lastContentFetch = defaults.object(forKey: "lastContentFetch") as? NSDate
        let lastContentFetchVersion = defaults.object(forKey: "lastContentFetchVersion") as? String
        let currentBuildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        if lastContentFetch == nil || (lastContentFetch?.timeIntervalSinceNow ?? 0) < 1 || lastContentFetchVersion != currentBuildNumber {
            contentRepository.retrieveContent()
                .flatMap(.latest, {[weak self] (_) -> Signal<WorldStateProtocol?, Never> in
                    return self?.contentRepository.retrieveWorldState() ?? Signal.empty
                })
                .observeCompleted {
                defaults.setValue(Date(), forKey: "lastContentFetch")
                defaults.setValue(currentBuildNumber, forKey: "lastContentFetchVersion")
            }
        }
    }
    
    @objc
    func retrieveTasks(_ completed: @escaping ((Bool) -> Void)) {
        taskRepository.retrieveTasks().observeResult { (result) in
            switch result {
            case .success:
                completed(true)
            case .failure:
                completed(false)
            }
        }
    }
    
    @objc
    func scoreTask(_ taskId: String, direction: String, completed: @escaping (() -> Void)) {
        if let task = taskRepository.getEditableTask(id: taskId), let scoringDirection = TaskScoringDirection(rawValue: direction) {
            taskRepository.score(task: task, direction: scoringDirection).observeCompleted {
                completed()
            }
        } else {
            completed()
        }
    }
    
    @objc
    func acceptQuestInvitation(_ completed: @escaping ((Bool) -> Void)) {
        userRepository.getUser().take(first: 1)
            .map({ (user) -> String? in
                return user.party?.id
            })
            .skipNil()
            .flatMap(.latest) {[weak self] (partyID) in
                return self?.socialRepository.acceptQuestInvitation(groupID: partyID) ?? Signal.empty
            }.on(failed: { _ in
                completed(false)
            }, value: { _ in
                completed(true)
            }).start()
    }
    
    @objc
    func rejectQuestInvitation(_ completed: @escaping ((Bool) -> Void)) {
        userRepository.getUser().take(first: 1)
            .map({ (user) -> String? in
                return user.party?.id
            })
            .skipNil()
            .flatMap(.latest) {[weak self] (partyID) in
                return self?.socialRepository.rejectQuestInvitation(groupID: partyID) ?? Signal.empty
            }.on(failed: { _ in
                completed(false)
            }, value: { _ in
                completed(true)
            }).start()
    }
    
    @objc
    func sendPrivateMessage(toUserID: String, message: String, completed: @escaping ((Bool) -> Void)) {
        socialRepository.post(inboxMessage: message, toUserID: toUserID).observeResult({ (result) in
            switch result {
            case .success:
                completed(true)
            case .failure:
                completed(false)
            }
        })
    }
    
    @objc
    func displayNotificationInApp(text: String) {
       ToastManager.show(text: text, color: .purple)
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator.oneShotNotificationOccurred(.success)
        }
    }
    
    @objc
    static func isRunningLive() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let isRunningTestFlightBeta  = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        let hasEmbeddedMobileProvision = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
        if isRunningTestFlightBeta || hasEmbeddedMobileProvision {
            return false
        } else {
            return true
        }
        #endif
    }
    
    @objc
    static func isRunningScreenshots() -> Bool {
        #if !targetEnvironment(simulator)
        return false
        #else
        return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
        #endif
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    @objc
    func displayInAppNotification(taskID: String, text: String) {
        let alertController = HabiticaAlertController(title: L10n.reminder, message: text)
        alertController.addCloseAction()
        alertController.addAction(title: L10n.complete, style: .default, isMainAction: true, closeOnTap: true, identifier: nil) { _ in
            self.scoreTask(taskID, direction: "up") {}
        }
        alertController.show()
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator.oneShotNotificationOccurred(.warning)
        }
    }
}
