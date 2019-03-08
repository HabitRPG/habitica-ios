//
//  RealmPreferences.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

@objc
class RealmPreferences: Object, PreferencesProtocol {
    @objc dynamic var id: String?
    @objc dynamic var skin: String?
    @objc dynamic var language: String?
    @objc dynamic var automaticAllocation: Bool = false
    @objc dynamic var dayStart: Int = 0
    @objc dynamic var allocationMode: String?
    @objc dynamic var background: String?
    @objc dynamic var useCostume: Bool = false
    @objc dynamic var dailyDueDefaultView: Bool = false
    @objc dynamic var shirt: String?
    @objc dynamic var size: String?
    @objc dynamic var disableClasses: Bool = false
    @objc dynamic var chair: String?
    @objc dynamic var sleep: Bool = false
    @objc dynamic var timezoneOffset: Int = 0
    @objc dynamic var sound: String?
    @objc dynamic var autoEquip: Bool = false
    @objc dynamic var searchableUsername: Bool = false
    var pushNotifications: PushNotificationsProtocol? {
        get {
            return realmPushNotifications
        }
        set {
            if let newItems = newValue as? RealmPushNotifications {
                realmPushNotifications = newItems
                return
            }
            if let newItems = newValue {
                realmPushNotifications = RealmPushNotifications(id: id, pnProtocol: newItems)
            }
        }
    }
    @objc dynamic var realmPushNotifications: RealmPushNotifications?
    var hair: HairProtocol? {
        get {
            return realmHair
        }
        set {
            if let newHair = newValue as? RealmHair {
                realmHair = newHair
                return
            }
            if let newHair = newValue {
                realmHair = RealmHair(userID: id, protocolObject: newHair)
            }
        }
    }
    @objc dynamic var realmHair: RealmHair?
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["pushNotifications"]
    }
    
    convenience init(id: String?, preferences: PreferencesProtocol) {
        self.init()
        self.id = id
        skin = preferences.skin
        language = preferences.language
        automaticAllocation = preferences.automaticAllocation
        dayStart = preferences.dayStart
        allocationMode = preferences.allocationMode
        background = preferences.background
        useCostume = preferences.useCostume
        dailyDueDefaultView = preferences.dailyDueDefaultView
        shirt = preferences.shirt
        size = preferences.size
        disableClasses = preferences.disableClasses
        chair = preferences.chair
        sleep = preferences.sleep
        timezoneOffset = preferences.timezoneOffset
        sound = preferences.sound
        autoEquip = preferences.autoEquip
        pushNotifications = preferences.pushNotifications
        hair = preferences.hair
        searchableUsername = preferences.searchableUsername
    }
}
