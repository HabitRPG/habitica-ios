//
//  UserProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol UserProtocol {
    
    var id: String? { get set }
    var stats: StatsProtocol? { get set }
    var flags: FlagsProtocol? { get set }
    var preferences: PreferencesProtocol? { get set }
    var profile: ProfileProtocol? { get set }
    var contributor: ContributorProtocol? { get set }
    var items: UserItemsProtocol? { get set }
    var balance: Float { get set }
    var tasksOrder: [String: [String]] { get set }
    var tags: [TagProtocol] { get set }
    var needsCron: Bool { get set }
    var lastCron: Date? { get set }
}

public extension UserProtocol {
    
    var gemCount: Int {
        return Int(balance * 4.0)
    }
    
    var canUseSkills: Bool {
        if preferences?.disableClasses == true {
            return false
        }
        if stats?.level ?? 0 < 10 || flags?.classSelected == false {
            return false
        }
        return true
    }
    
    var needsToChooseClass: Bool {
        if preferences?.disableClasses == true {
            return false
        }
        return stats?.level ?? 0 >= 10 && flags?.classSelected == false
    }
}
