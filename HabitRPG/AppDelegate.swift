//
//  AppDelegate.swift
//  Habitica
//
//  Created by Phillip on 11.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Amplitude
import Habitica_API_Client
import Habitica_Models
import RealmSwift
import ReactiveSwift
import Firebase
#if !targetEnvironment(macCatalyst)
import FirebaseAnalytics
#endif
import SwiftyStoreKit
import StoreKit
import UserNotifications
import FirebaseMessaging
import Down
import WidgetKit
import FBSDKCoreKit
import AppAuth
import FBSDKLoginKit
import AdServices
import iAd

class HabiticaAppDelegate: UIResponder, MessagingDelegate, UIApplicationDelegate {
    var window: UIWindow?
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var isBeingTested = false
        
    var application: UIApplication?
    
    private let userRepository = UserRepository()
    private let contentRepository = ContentRepository()
    let taskRepository = TaskRepository()
    private let socialRepository = SocialRepository()
    private let configRepository = ConfigRepository.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        logger = RemoteLogger()
        self.application = application
        
        FBSDKCoreKit.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        setupRouter()
        handleLaunchArgs()
        if !isBeingTested {
            setupLogging()
            setupAnalytics()
            setupPurchaseHandling()
            setupFirebase()
        }
        setupNetworkClient()
        setupDatabase()
        configureNotifications()
        
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            handlePushnotification(identifier: nil, userInfo: userInfo)
        }
        
        handleInitialLaunch()
        applySearchAdAttribution()
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url) == true {
            currentAuthorizationFlow = nil
            return true
        }
        let wasHandled = ApplicationDelegate.shared.application(app, open: url, options: options)
        if !wasHandled {
            return RouterHandler.shared.handle(url: url)
        }
        return wasHandled
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach { context in
            RouterHandler.shared.handle(url: context.url)
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "com.habitrpg.habitica.ios.newhabit" {
            RouterHandler.shared.handle(urlString: "/user/tasks/habit/add")
        } else if shortcutItem.type == "com.habitrpg.habitica.ios.newdaily" {
            RouterHandler.shared.handle(urlString: "/user/tasks/daily/add")
        } else if shortcutItem.type == "com.habitrpg.habitica.ios.newtodo" {
            RouterHandler.shared.handle(urlString: "/user/tasks/todo/add")
        }
        completionHandler(true)
    }

    @objc
    func handleLaunchArgs() {
        if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
            isBeingTested = true
            contentRepository.retrieveContent(force: true).observeCompleted {
            }
            UIView.setAnimationsEnabled(false)
            self.window?.layer.speed = 100
            AuthenticationManager.shared.initialize(withStorage: MemoryAuthenticationStorage())
        } else {
            AuthenticationManager.shared.initialize(withStorage: KeychainAuthenticationStorage())
        }
        let launchEnvironment = ProcessInfo.processInfo.environment
        if let userID = launchEnvironment["userid"] {
            AuthenticationManager.shared.currentUserId = userID
        }
        if let apiKey = launchEnvironment["apikey"] {
            AuthenticationManager.shared.currentUserKey = apiKey
        }
        
        if let stubs = launchEnvironment["STUB_DATA"]?.data(using: .utf8) {
            // swiftlint:disable:next force_try
            HabiticaServerConfig.stubs = try! JSONDecoder().decode([String: CallStub].self, from: stubs)
        }
    }
    
    @objc
    func setupFirebase() {
        Messaging.messaging().delegate = self
        
        let userDefaults = UserDefaults.standard
        #if !targetEnvironment(macCatalyst)
        Crashlytics.crashlytics().setCustomValue(-(NSTimeZone.local.secondsFromGMT() / 60), forKey: "timesoze_offset")
        Crashlytics.crashlytics().setCustomValue(LanguageHandler.getAppLanguage().code, forKey: "app_language")
        Analytics.setUserProperty(LanguageHandler.getAppLanguage().code, forName: "app_language")
        Analytics.setUserProperty(UIApplication.shared.alternateIconName, forName: "app_icon")
        Analytics.setUserProperty(userDefaults.string(forKey: "initialScreenURL"), forName: "launch_screen")
        #endif
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
    }
    
    @objc
    func saveDeviceToken(_ deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(token, forKey: "PushNotificationDeviceToken")
    }
    
    @objc
    func setupLogging() {
        let userID = AuthenticationManager.shared.currentUserId
        FirebaseApp.configure()
        (logger as? RemoteLogger)?.setUserID(userID)
        logger.isProduction = HabiticaAppDelegate.isRunningLive()
    }
    
    @objc
    func setupAnalytics() {
        Amplitude.instance().initializeApiKey(Secrets.amplitudeApiKey)
        Amplitude.instance().setUserId(AuthenticationManager.shared.currentUserId)
        let userDefaults = UserDefaults.standard
        Amplitude.instance().setUserProperties(["iosTimezoneOffset": -(NSTimeZone.local.secondsFromGMT() / 60),
                                                 "launch_screen": userDefaults.string(forKey: "initialScreenURL") ?? ""
        ])
    }
    
    @objc
    func setupPurchaseHandling() {
        #if !targetEnvironment(simulator)
            PurchaseHandler.shared.completionHandler()
        #endif
    }
    
    @objc
    func setupNetworkClient() {
        NetworkAuthenticationManager.shared.currentUserId = AuthenticationManager.shared.currentUserId
        NetworkAuthenticationManager.shared.currentUserKey = AuthenticationManager.shared.currentUserKey
        updateServer()
        AuthenticatedCall.errorHandler = HabiticaNetworkErrorHandler()
        AuthenticatedCall.notificationListener = {[weak self] notifications in
            guard let notifications = notifications else {
                return
            }
            let unshownNotifications = NotificationManager.handle(notifications: notifications)
            self?.userRepository.saveNotifications(unshownNotifications)
        }
        let configuration = URLSessionConfiguration.default
        AuthenticatedCall.defaultConfiguration.urlConfiguration = configuration
        AuthenticatedCall.indicatorController = IOSNetworkIndicatorController()
        
        let userDefaults = UserDefaults.standard
        for (key, etag) in userDefaults.dictionaryRepresentation().filter({ (key, _) -> Bool in
            return key.starts(with: "etag")
        }) {
            HabiticaServerConfig.etags[String(key.dropFirst(4))] = etag as? String
        }
    }
    
    func updateServer() {
        if isBeingTested {
            AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.stub
            return
        }
        if let chosenServer = UserDefaults().string(forKey: "chosenServer") {
            switch chosenServer {
            case "production":
                let configRepository = ConfigRepository.shared
                if let host = configRepository.string(variable: .prodHost), let apiVersion = configRepository.string(variable: .apiVersion) {
                    let config = ServerConfiguration(scheme: "https", host: host, apiRoute: "api/\(apiVersion)")
                    AuthenticatedCall.defaultConfiguration = config
                } else {
                    AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.production
                }
            case "staging":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.staging
            case "beta":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.beta
            case "gamma":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.gamma
            case "delta":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.delta
            default:
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.localhost
            }
        } else {
            let configRepository = ConfigRepository.shared
            if let host = configRepository.string(variable: .prodHost), let apiVersion = configRepository.string(variable: .apiVersion), !host.isEmpty, !apiVersion.isEmpty {
                let config = ServerConfiguration(scheme: "https", host: host, apiRoute: "api/\(apiVersion)")
                AuthenticatedCall.defaultConfiguration = config
            } else {
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.production
            }
        }
    }
    
    @objc
    func setupDatabase() {
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true
        if isBeingTested {
            // when running tests use a fresh in-memory database on each launch
            config.inMemoryIdentifier = String(Date().timeIntervalSince1970)
        } else {
            let fileUrl = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.habitrpg.habitica")?
                .appendingPathComponent("habitica.realm")
            if let url = fileUrl {
                config.fileURL = url
            }
            logger.log("Realm stored at: \(config.fileURL?.absoluteString ?? "")")
        }
        Realm.Configuration.defaultConfiguration = config
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
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            rescheduleDailyReminder()
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
        UINotificationFeedbackGenerator.oneShotNotificationOccurred(.success)
    }
    
    @objc
    func displayNotificationInApp(title: String, text: String) {
        ToastManager.show(text: "\(title)\n\(text)", color: .purple)
        UINotificationFeedbackGenerator.oneShotNotificationOccurred(.success)
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
    
    func applySearchAdAttribution() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "userWasAttributed") {
            return
        }
        if #available(iOS 14.5, *) {
            Analytics.logEvent("attribution_begin", parameters: nil)
            DispatchQueue.global(qos: .default).async {
                Analytics.logEvent("attribution_attempt", parameters: nil)
                do {
                let attributionToken = try AAAttribution.attributionToken()
                Analytics.logEvent("attribution_token_collected", parameters: nil)
                if let url = URL(string: "https://api-adservices.apple.com/api/v1/") {
                    let request = NSMutableURLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
                    request.httpBody = Data(attributionToken.utf8)
                    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
                        Analytics.logEvent("attribution_data_collected", parameters: nil)
                        if let error = error {
                            logger.log(error)
                            Analytics.logEvent("attribution_failed", parameters: ["point": error.localizedDescription])
                            return
                        }
                        guard let data = data else {
                            Analytics.logEvent("attribution_failed_no_data", parameters: ["point": "no data"])
                            return
                        }
                        do {
                            guard let data = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                                Analytics.logEvent("attribution_failed_json", parameters: ["point": "no data"])
                                return
                            }
                            if let campaignId = data["campaignId"] as? Int {
                                var analyticsData = [String: Any]()
                                analyticsData["attribution"] = data["iad-attribution"]
                                analyticsData["campaignID"] = campaignId
                                analyticsData["campaignName"] = data["iad-campaign-name"]
                                analyticsData["purchaseDate"] = data["iad-purchase-date"]
                                analyticsData["conversionDate"] = data["iad-conversion-date"]
                                analyticsData["conversionType"] = data["iad-conversion-type"]
                                analyticsData["clickDate"] = data["iad-click-date"]
                                analyticsData["keyword"] = data["iad-keyword"]
                                analyticsData["keywordMatchtype"] = data["iad-keyword-matchtype"]
                                defaults.set(true, forKey: "userWasAttributed")
                                HabiticaAnalytics.shared.log("adAttribution", withEventProperties: analyticsData)
                                Amplitude.instance().setUserProperties([
                                    "clickedSearchAd": data["iad-attribution"] ?? "",
                                    "searchAdName": data["iad-campaign-name"] ?? "",
                                    "searchAdConversionDate": data["iad-conversion-date"] ?? ""
                                ])
                            } else {
                                Analytics.logEvent("attribution_failed_cid", parameters: ["point": "no campaignId"])
                            }
                        } catch {
                            logger.log(error)
                            Analytics.logEvent("attribution_failed", parameters: ["point": error.localizedDescription])
                        }
                    }
                    task.resume()
                } else {
                    Analytics.logEvent("attribution_failed_no_token", parameters: ["point": "No token"])
                }
                } catch {
                    Analytics.logEvent("attribution_failed", parameters: ["error": error.localizedDescription])
                }
            }
        } else {
            ADClient.shared().requestAttributionDetails({ (attributionDetails, _) in
                guard let attributionDetails = attributionDetails else {
                    return
                }
                for (_, adDictionary) in attributionDetails {
                    if let data = adDictionary as? [String: Any] {
                        if let campaignId = data["iad-campaign-id"] as? String {
                            defaults.set(true, forKey: "userWasAttributed")
                            var analyticsData = [String: Any]()
                            analyticsData["attribution"] = data["iad-attribution"]
                            if analyticsData["attribution"] as? String != "true" {
                                return
                            }
                            analyticsData["campaignID"] = campaignId
                            analyticsData["campaignName"] = data["iad-campaign-name"]
                            analyticsData["purchaseDate"] = data["iad-purchase-date"]
                            analyticsData["conversionDate"] = data["iad-conversion-date"]
                            analyticsData["conversionType"] = data["iad-conversion-type"]
                            analyticsData["clickDate"] = data["iad-click-date"]
                            analyticsData["keyword"] = data["iad-keyword"]
                            analyticsData["keywordMatchtype"] = data["iad-keyword-matchtype"]
                            HabiticaAnalytics.shared.log("adAttribution", withEventProperties: analyticsData)
                            Amplitude.instance().setUserProperties([
                                "clickedSearchAd": data["iad-attribution"] ?? "",
                                "searchAdName": data["iad-campaign-name"] ?? "",
                                "searchAdConversionDate": data["iad-conversion-date"] ?? ""
                            ])
                        }
                    }
                }
            })
        }
    }
    
    @objc
    static func isRunningScreenshots() -> Bool {
        #if !targetEnvironment(simulator)
        return false
        #else
        return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
        #endif
    }
    
    func messaging(_ messaging: MessagingDelegate, didReceiveRegistrationToken fcmToken: String) {
        logger.log("Firebase registration token: \(fcmToken)")
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    @objc
    func displayInAppNotification(taskID: String, text: String) {
        let alertController = HabiticaAlertController(title: text)
        alertController.addAction(title: L10n.complete, style: .default, isMainAction: true, closeOnTap: true, identifier: nil) {[weak self] _ in
            self?.scoreTask(taskID, direction: "up") {}
        }
        alertController.addCloseAction()
        alertController.enqueue()
        UINotificationFeedbackGenerator.oneShotNotificationOccurred(.warning)
    }
}

// Maintenance
extension HabiticaAppDelegate {
    @objc
    func handleMaintenanceScreen() -> Bool {
        let maintenanceData = configRepository.dictionary(variable: .maintenanceData)
        if let title = maintenanceData["title"] as? String, let descriptionString = maintenanceData["description"] as? String {
            displayMaintenanceScreen(title: title, descriptionString: descriptionString)
            return true
        } else {
            hideMaintenanceScreen()
        }
        return false
    }
    
    @objc
    func displayMaintenanceScreen(title: String, descriptionString: String) {
        if findMaintenanceScreen() == nil {
            let maintenanceController = MaintenanceViewController()
            maintenanceController.configure(title: title, descriptionString: descriptionString, showAppstoreButton: false)
            maintenanceController.modalPresentationStyle = .fullScreen
            maintenanceController.modalTransitionStyle = .crossDissolve
            UIApplication.topViewController()?.present(maintenanceController, animated: true, completion: nil)
        }
    }
    
    @objc
    func hideMaintenanceScreen() {
        findMaintenanceScreen()?.dismiss(animated: true, completion: nil)
    }
    
    private func findMaintenanceScreen() -> MaintenanceViewController? {
        var viewController: UIViewController? = UIApplication.shared.findKeyWindow()?.rootViewController
        while viewController != nil {
            if let maintenanceController = viewController as? MaintenanceViewController {
                return maintenanceController
            } else {
                viewController = viewController?.presentedViewController
            }
        }
        return nil
    }
}
