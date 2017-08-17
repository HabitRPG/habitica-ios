//
//  HRPGAPI.swift
//  Habitica
//
//  Created by Craig Holliday on 8/7/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Crashlytics
import Google

class HRPGAPI {
    
}

//extension HRPGAPI {
//    // MARK: - Fetch Tasks
//    func fetchContent(_ successBlock: @escaping () -> Void, onError errorBlock: @escaping () -> Void) {
//        networkIndicatorController.beginNetworking()
//        var url: String = "content"
//        if user.preferences.language {
//            url = url + ("?language=\(user.preferences.language)")
//            defaults["contentLanguage"] = user.preferences.language
//            defaults.synchronize()
//        }
//        RKObjectManager.shared().getObjectsAtPath(url, parameters: nil, success: {(_ operation: RKObjectRequestOperation, _ mappingResult: RKMappingResult) -> Void in
//            var executeError: Error? = nil
//            for dict: [AnyHashable: Any] in mappingResult.dictionary()["backgrounds"] {
//                for background: Customization in dict["backgrounds"] {
//                    background.type = "background"
//                    background.set = dict["setName"]
//                    background.price = 7
//                    // TODO: Figure out why it is necessary to save each background individually
//                    background.managedObjectContext.save(toPersistentStore: executeError)
//                }
//            }
//            let textPath: String? = Bundle.main.path(forResource: "customizations", ofType: "json")
//            var error: Error?
//            let content = try? String(contentsOfFile: textPath!, encoding: String.Encoding.utf8)
//            let jsonData: Data? = content?.data(using: String.Encoding.utf8)
//            let customizations: [AnyHashable: Any]? = try? JSONSerialization.jsonObject(with: jsonData!, options: kNilOptions)["customizations"]
//            var identifiers = [Any]() /* capacity: 1 */
//            let fetchRequest = NSFetchRequest()
//            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Customization", in: self.getManagedObjectContext())
//            let existingCustomizations: [Any] = try? self.getManagedObjectContext().fetch(fetchRequest as? NSFetchRequest<NSFetchRequestResult> ?? NSFetchRequest<NSFetchRequestResult>())
//            for customization: Customization in existingCustomizations {
//                identifiers.append("\(customization?.type)\(customization?.name)")
//            }
//            for data: [AnyHashable: Any] in customizations {
//                if identifiers.contains("\(data["type"])\(data["name"])") {
//                    continue
//                }
//                let customization: Customization? = NSEntityDescription.insertNewObject(forEntityName: "Customization", into: self.getManagedObjectContext())
//                customization?.name = data["name"]
//                customization?.text = data["text"]
//                customization?.notes = data["notes"]
//                customization?.type = data["type"]
//                customization?.group = data["group"]
//                if data["set"] {
//                    customization?.set = data["set"]
//                }
//                customization?.price = data["price"]
//                customization?.purchasable = data["purchasable"]
//            }
//            self.getManagedObjectContext().save(toPersistentStore: executeError)
//            defaults["lastContentFetch"] = Date()
//            defaults.synchronize()
//            if successBlock {
//                successBlock()
//            }
//            networkIndicatorController.endNetworking()
//            return
//        }, failure: {(_ operation: RKObjectRequestOperation, _ error: Error?) -> Void in
//            if errorBlock {
//                errorBlock()
//            }
//            networkIndicatorController.endNetworking()
//            return
//        })
//    }
//    func fetchTasks(_ successBlock: @escaping () -> Void, onError errorBlock: @escaping () -> Void) {
//        fetchTasks(forDay: nil, onSuccess: successBlock, onError: errorBlock)
//    }
//    func fetchTasks(forDay dueDate: Date, onSuccess successBlock: @escaping () -> Void, onError errorBlock: @escaping () -> Void) {
//        networkIndicatorController.beginNetworking()
//        var url: String = "tasks/user"
//        if dueDate {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ssXXX"
//            url = url + ("?type=dailys&dueDate=")
//            url = url + (formatter.string(from: dueDate))
//        }
//        RKObjectManager.shared().getObjectsAtPath(url, parameters: nil, success: {(_ operation: RKObjectRequestOperation, _ mappingResult: RKMappingResult) -> Void in
//            var executeError: Error? = nil
//            self.getManagedObjectContext().save(toPersistentStore: executeError)
//            defaults["lastTaskFetch"] = Date()
//            defaults.synchronize()
//            if successBlock {
//                successBlock()
//            }
//            networkIndicatorController.endNetworking()
//            return
//        }, failure: {(_ operation: RKObjectRequestOperation, _ error: Error?) -> Void in
//            if errorBlock {
//                errorBlock()
//            }
//            networkIndicatorController.endNetworking()
//            return
//        })
//    }
//    func fetchCompletedTasks(_ successBlock: @escaping () -> Void, onError errorBlock: @escaping () -> Void) {
//        networkIndicatorController.beginNetworking()
//        RKObjectManager.shared().getObjectsAtPath("tasks/user?type=completedTodos", parameters: nil, success: {(_ operation: RKObjectRequestOperation, _ mappingResult: RKMappingResult) -> Void in
//            var executeError: Error? = nil
//            self.getManagedObjectContext().save(toPersistentStore: executeError)
//            defaults["lastTaskFetch"] = Date()
//            defaults.synchronize()
//            if successBlock {
//                successBlock()
//            }
//            networkIndicatorController.endNetworking()
//            return
//        }, failure: {(_ operation: RKObjectRequestOperation, _ error: Error?) -> Void in
//            if errorBlock {
//                errorBlock()
//            }
//            networkIndicatorController.endNetworking()
//            return
//        })
//    }
//}
//
//extension HRPGAPI {
//    // MARK: - Credentials and AUTH
//    func setCredentials() {
//        let keyChain = PDKeychainBindings.shared()
//        currentUser = keyChain.string(forKey: "id")
//        RKObjectManager.shared().httpClient.setDefaultHeader("x-api-user", value: currentUser)
//        RKObjectManager.shared().httpClient.setDefaultHeader("x-api-key", value: keyChain.string(forKey: "key"))
//        let tracker: GAITracker = GAI.sharedInstance().defaultTracker()
//        tracker.set("&uid", value: user.id)
//        Amplitude.instance().userId = currentUser
//        Crashlytics.sharedInstance().userIdentifier = currentUser
//        Crashlytics.sharedInstance().userName = currentUser
//    }
//    func hasAuthentication() -> Bool {
//        return (currentUser != nil && currentUser.length > 0)
//    }
//    func clearLoginCredentials() {
//        RKObjectManager.shared().httpClient.setDefaultHeader("x-api-user", value: "")
//        RKObjectManager.shared().httpClient.setDefaultHeader("x-api-key", value: "")
//    }
//    func setTimezoneOffset() {
//        let offset: Int = -NSTimeZone.local.secondsFromGMT / 60
//        if user.preferences {
//            if !user.preferences.timezoneOffset || offset != CInt(user.preferences.timezoneOffset) {
//                user.preferences.timezoneOffset = (offset)
//                updateUser(["preferences.timezoneOffset": (offset)], onSuccess: nil, onError: nil)
//            }
//        }
//    }
//}
//
//
