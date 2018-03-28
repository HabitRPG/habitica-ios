//
//  TestFlags.swift
//  Habitica ModelsTests
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
@testable import Habitica_Models

class TestFlags: FlagsProtocol {
    var armoireEmpty: Bool = false
    var cronCount: Int = 0
    var rebirthEnabled: Bool = false
    var communityGuidelinesAccepted: Bool = false
    var hasNewStuff: Bool = false
    var armoireOpened: Bool = false
    var chatRevoked: Bool = false
    var classSelected: Bool = false
    var itemsEnabled: Bool = false
}
