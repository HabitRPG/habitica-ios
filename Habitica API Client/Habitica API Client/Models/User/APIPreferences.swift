//
//  APIPreferences.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIPreferences: PreferencesProtocol, Decodable {
    var skin: String?
    var language: String?
    var automaticAllocation: Bool = false
    var dayStart: Int = 0
    var allocationMode: String?
    var background: String?
    var useCostume: Bool = false
    var dailyDueDefaultView: Bool = false
    var shirt: String?
    var size: String?
    var disableClasses: Bool = false
    var chair: String?
    var sleep: Bool = false
    var timezoneOffset: Int = 0
    var sound: String?
    var autoEquip: Bool = false
    var pushNotifications: PushNotificationsProtocol?
    var hair: HairProtocol?
    var searchableUsername: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case skin
        case language
        case automaticAllocation
        case dayStart
        case allocationMode
        case background
        case costume
        case dailyDueDefaultView
        case shirt
        case size
        case disableClasses
        case chair
        case sleep
        case timezoneOffset
        case sound
        case autoEquip
        case pushNotifications
        case hair
        case searchableUsername
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        skin = try? values.decode(String.self, forKey: .skin)
        language = try? values.decode(String.self, forKey: .language)
        automaticAllocation = (try? values.decode(Bool.self, forKey: .automaticAllocation)) ?? false
        dayStart = (try? values.decode(Int.self, forKey: .dayStart)) ?? 0
        allocationMode = try? values.decode(String.self, forKey: .allocationMode)
        background = (try? values.decode(String.self, forKey: .background))
        useCostume = (try? values.decode(Bool.self, forKey: .costume)) ?? false
        dailyDueDefaultView = (try? values.decode(Bool.self, forKey: .dailyDueDefaultView)) ?? false
        shirt = try? values.decode(String.self, forKey: .shirt)
        size = try? values.decode(String.self, forKey: .size)
        disableClasses = (try? values.decode(Bool.self, forKey: .disableClasses)) ?? false
        chair = try? values.decode(String.self, forKey: .chair)
        sleep = (try? values.decode(Bool.self, forKey: .sleep)) ?? false
        timezoneOffset = (try? values.decode(Int.self, forKey: .timezoneOffset)) ?? 0
        sound = try? values.decode(String.self, forKey: .sound)
        autoEquip = (try? values.decode(Bool.self, forKey: .autoEquip)) ?? false
        pushNotifications = try? values.decode(APIPushNotifications.self, forKey: .pushNotifications)
        hair = try? values.decode(APIHair.self, forKey: .hair)
        searchableUsername = (try? values.decode(Bool.self, forKey: .searchableUsername)) ?? false
    }
}
