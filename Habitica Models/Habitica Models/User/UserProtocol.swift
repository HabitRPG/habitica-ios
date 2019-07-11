//
//  UserProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public enum HabiticaClass: String {
    case warrior
    case mage = "wizard"
    case healer
    case rogue
}

@objc
public protocol UserProtocol: AvatarProtocol {
    
    var id: String? { get set }
    var flags: FlagsProtocol? { get set }
    var profile: ProfileProtocol? { get set }
    var contributor: ContributorProtocol? { get set }
    var balance: Float { get set }
    var tasksOrder: [String: [String]] { get set }
    var tags: [TagProtocol] { get set }
    var needsCron: Bool { get set }
    var lastCron: Date? { get set }
    var inbox: InboxProtocol? { get set }
    var authentication: AuthenticationProtocol? { get set }
    var purchased: PurchasedProtocol? { get set }
    var party: UserPartyProtocol? { get set }
    var challenges: [ChallengeMembershipProtocol] { get set }
    var hasNewMessages: [UserNewMessagesProtocol] { get set }
    var invitations: [GroupInvitationProtocol] { get set }
    var pushDevices: [PushDeviceProtocol] { get set }
}

public extension UserProtocol {
    
    var username: String? {
        return authentication?.local?.username
    }
    
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
    
    var canChooseClassForFree: Bool {
        if preferences?.disableClasses == true {
            return true
        }
        return stats?.level ?? 0 >= 10 && flags?.classSelected == false
    }
    
    var isModerator: Bool {
        return (contributor?.level ?? 0) >= 8
    }
    
    var isSubscribed: Bool {
        return purchased?.subscriptionPlan?.isActive == true
    }
}
