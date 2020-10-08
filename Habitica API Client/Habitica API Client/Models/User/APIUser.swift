//
//  APIUser.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models


public class APIUser: UserProtocol, Decodable {
    public var party: UserPartyProtocol?
    
    public var id: String?
    public var stats: StatsProtocol?
    public var flags: FlagsProtocol?
    public var preferences: PreferencesProtocol?
    public var profile: ProfileProtocol?
    public var contributor: ContributorProtocol?
    public var backer: BackerProtocol?
    public var items: UserItemsProtocol?
    public var balance: Float = 0
    public var tasksOrder: [String: [String]]
    public var tags: [TagProtocol]
    public var needsCron: Bool = false
    public var lastCron: Date?
    public var inbox: InboxProtocol?
    public var authentication: AuthenticationProtocol?
    public var purchased: PurchasedProtocol?
    public var challenges: [ChallengeMembershipProtocol]
    public var hasNewMessages: [UserNewMessagesProtocol]
    public var invitations: [GroupInvitationProtocol]
    public var pushDevices: [PushDeviceProtocol]
    public var isValid: Bool { return true }
    public var achievements: UserAchievementsProtocol?
    
    enum CodingKeys: String, CodingKey {
        case id
        case stats
        case flags
        case preferences
        case profile
        case contributor
        case backer
        case items
        case balance
        case tasksOrder
        case tags
        case needsCron
        case lastCron
        case inbox
        case authentication = "auth"
        case purchased
        case party
        case challenges
        case hasNewMessages = "newMessages"
        case invitations
        case pushDevices
        case achievements
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String.self, forKey: .id)
        stats = (try? values.decode(APIStats.self, forKey: .stats))
        flags = (try? values.decode(APIFlags.self, forKey: .flags))
        preferences = (try? values.decode(APIPreferences.self, forKey: .preferences))
        profile = (try? values.decode(APIProfile.self, forKey: .profile))
        contributor = (try? values.decode(APIContributor.self, forKey: .contributor))
        backer = (try? values.decode(APIBacker.self, forKey: .backer))
        items = (try? values.decode(APIUserItems.self, forKey: .items))
        balance = (try? values.decode(Float.self, forKey: .balance)) ?? -1
        tasksOrder = (try? values.decode([String: [String]].self, forKey: .tasksOrder)) ?? [:]
        tags = (try? values.decode([APITag].self, forKey: .tags)) ?? []
        tags.enumerated().forEach { (arg) in
            arg.element.order = arg.offset
        }
        needsCron = (try? values.decode(Bool.self, forKey: .needsCron)) ?? false
        lastCron = try? values.decode(Date.self, forKey: .lastCron)
        inbox = try? values.decode(APIInbox.self, forKey: .inbox)
        authentication = try? values.decode(APIAuthentication.self, forKey: .authentication)
        purchased = try? values.decode(APIPurchased.self, forKey: .purchased)
        party = try? values.decode(APIUserParty.self, forKey: .party)
        let challengeList = (try? values.decode([String].self, forKey: .challenges)) ?? []
        challenges = challengeList.map { challengeID in
            return APIChallengeMembership(challengeID: challengeID)
        }
        
        hasNewMessages = (try? values.decode([String: APIUserNewMessages].self, forKey: .hasNewMessages).map({ (key, value) in
            value.id = key
            return value
        })) ?? []
        
        let invitationsHelper = try? values.decode(APIGroupInvitationHelper.self, forKey: .invitations)
        invitationsHelper?.parties?.forEach({ (invitation) in
            invitation.isPartyInvitation = true
        })
        invitations = (invitationsHelper?.guilds ?? []) + (invitationsHelper?.parties ?? [])
        pushDevices = (try? values.decode([APIPushDevice].self, forKey: .pushDevices)) ?? []
        achievements = try? values.decode(APIUserAchievements.self, forKey: .achievements)
    }
}
