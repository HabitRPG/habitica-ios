//
// Created by Phillip Thelen on 09.03.18.
// Copyright (c) 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol PreferencesProtocol: BaseModelProtocol {
    var skin: String? { get set }
    var language: String? { get set }
    var automaticAllocation: Bool { get set }
    var dayStart: Int { get set }
    var allocationMode: String? { get set }
    var background: String? { get set }
    var useCostume: Bool { get set }
    var dailyDueDefaultView: Bool { get set }
    var shirt: String? { get set }
    var size: String? { get set }
    var disableClasses: Bool { get set }
    var chair: String? { get set }
    var sleep: Bool { get set }
    var timezoneOffset: Int { get set }
    var sound: String? { get set }
    var autoEquip: Bool { get set }
    var pushNotifications: PushNotificationsProtocol? { get set }
    var emailNotifications: EmailNotificationsProtocol? { get set }
    var hair: HairProtocol? { get set }
    var searchableUsername: Bool { get set }
    var dateFormat: String? { get set }
}
