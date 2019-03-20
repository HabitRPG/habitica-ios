//
//  TestUser.swift
//  Habitica ModelsTests
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
@testable import Habitica_Models

class TestUser: UserProtocol {
    var id: String?
    var stats: StatsProtocol?
    var flags: FlagsProtocol?
    var preferences: PreferencesProtocol?
    var profile: ProfileProtocol?
    var contributor: ContributorProtocol?
    var items: UserItemsProtocol?
    var balance: Float = 0
    var tasksOrder: [String: [String]] = [String: [String]]()
    var tags: [TagProtocol] = [TagProtocol]()
}
