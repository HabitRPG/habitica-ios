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
    var permissions: (any Habitica_Models.PermissionsProtocol)?
    
    var backer: BackerProtocol?
    
    var needsCron: Bool = false
    
    var lastCron: Date?
    
    var inbox: InboxProtocol?
    
    var authentication: AuthenticationProtocol?
    
    var purchased: PurchasedProtocol?
    
    var party: UserPartyProtocol?
    
    var challenges: [ChallengeMembershipProtocol] = []
    
    var hasNewMessages: [UserNewMessagesProtocol] = []
    
    var invitations: [GroupInvitationProtocol] = []
    
    var pushDevices: [PushDeviceProtocol] = []
    
    var achievements: UserAchievementsProtocol?
    
    var loginIncentives: Int = 0
    
    var pinnedItemsOrder: [String] = []
    
    var isValid: Bool = true
    
    var isManaged: Bool = false
    
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
