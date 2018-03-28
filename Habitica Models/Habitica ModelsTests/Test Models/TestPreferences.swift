//
//  TestPreferences.swift
//  Habitica ModelsTests
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
@testable import Habitica_Models

class TestPreferences: PreferencesProtocol {
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
}
