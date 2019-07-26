//
//  RealmUser.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

@objc
class RealmUser: Object, UserProtocol {

    @objc dynamic var id: String?
    @objc dynamic var balance: Float = 0
    var tasksOrder: [String: [String]] = [:]
    var stats: StatsProtocol? {
        get {
            return realmStats
        }
        set {
            if let newStats = newValue as? RealmStats {
                realmStats = newStats
                return
            }
            if let stats = newValue {
                realmStats = RealmStats(id: id, stats: stats)
            }
        }
    }
    @objc dynamic var realmStats: RealmStats?
    
    var flags: FlagsProtocol? {
        get {
            return realmFlags
        }
        set {
            if let newFlags = newValue as? RealmFlags {
                realmFlags = newFlags
                return
            }
            if let newFlags = newValue {
                realmFlags = RealmFlags(id: id, flags: newFlags)
            }
        }
    }
    @objc dynamic var realmFlags: RealmFlags?
    
    var preferences: PreferencesProtocol? {
        get {
            return realmPreferences
        }
        set {
            if let newPreferences = newValue as? RealmPreferences {
                realmPreferences = newPreferences
                return
            }
            if let newPreferences = newValue {
                realmPreferences = RealmPreferences(id: id, preferences: newPreferences)
            }
        }
    }
    @objc dynamic var realmPreferences: RealmPreferences?
    
    var profile: ProfileProtocol? {
        get {
            return realmProfile
        }
        set {
            if let newProfile = newValue as? RealmProfile {
                realmProfile = newProfile
                return
            }
            if let profile = newValue {
                realmProfile = RealmProfile(id: id, profile: profile)
            }
        }
    }
    @objc dynamic var realmProfile: RealmProfile?
    
    var contributor: ContributorProtocol? {
        get {
            return realmContributor
        }
        set {
            if let newContributor = newValue as? RealmContributor {
                realmContributor = newContributor
                return
            }
            if let newContributor = newValue {
                realmContributor = RealmContributor(id: id, contributor: newContributor)
            }
        }
    }
    @objc dynamic var realmContributor: RealmContributor?
    var items: UserItemsProtocol? {
        get {
            return realmItems
        }
        set {
            if let newItems = newValue as? RealmUserItems {
                realmItems = newItems
                return
            }
            if let newItems = newValue {
                realmItems = RealmUserItems(id: id, userItems: newItems)
            }
        }
    }
    @objc dynamic var realmItems: RealmUserItems?
    var tags: [TagProtocol] {
        get {
            return realmTags.map({ (tag) -> TagProtocol in
                return tag
            })
        }
        set {
            realmTags.removeAll()
            newValue.forEach { (tag) in
                if let realmTag = tag as? RealmTag {
                    realmTags.append(realmTag)
                } else {
                    realmTags.append(RealmTag(userID: id, tagProtocol: tag))
                }
            }
        }
    }
    var inbox: InboxProtocol? {
        get {
            return realmInbox
        }
        set {
            if let newItems = newValue as? RealmInbox {
                realmInbox = newItems
                return
            }
            if let newItems = newValue {
                realmInbox = RealmInbox(id: id, inboxProtocol: newItems)
            }
        }
    }
    @objc dynamic var realmInbox: RealmInbox?
    var authentication: AuthenticationProtocol? {
        get {
            return realmAuthentication
        }
        set {
            if let value = newValue as? RealmAuthentication {
                realmAuthentication = value
                return
            }
            if let value = newValue {
                realmAuthentication = RealmAuthentication(userID: id, protocolObject: value)
            }
        }
    }
    @objc dynamic var realmAuthentication: RealmAuthentication?
    var purchased: PurchasedProtocol? {
        get {
            return realmPurchased
        }
        set {
            if let value = newValue as? RealmPurchased {
                realmPurchased = value
                return
            }
            if let value = newValue {
                realmPurchased = RealmPurchased(userID: id, protocolObject: value)
            }
        }
    }
    @objc dynamic var realmPurchased: RealmPurchased?
    var party: UserPartyProtocol? {
        get {
            return realmParty
        }
        set {
            if let value = newValue as? RealmUserParty {
                realmParty = value
                return
            }
            if let value = newValue {
                realmParty = RealmUserParty(userID: id, protocolObject: value)
            }
        }
    }
    @objc dynamic var realmParty: RealmUserParty?
    
    var realmTags = List<RealmTag>()
    
    var challenges: [ChallengeMembershipProtocol] {
        get {
            return realmChallenges.map({ (tag) -> ChallengeMembershipProtocol in
                return tag
            })
        }
        set {
            realmChallenges.removeAll()
            newValue.forEach { (challenge) in
                if let realmChallenge = challenge as? RealmChallengeMembership {
                    realmChallenges.append(realmChallenge)
                } else {
                    realmChallenges.append(RealmChallengeMembership(userID: id, protocolObject: challenge))
                }
            }
        }
    }
    var realmChallenges = List<RealmChallengeMembership>()
    
    var hasNewMessages: [UserNewMessagesProtocol] {
        get {
            return realmNewMessages.map({ (tag) -> UserNewMessagesProtocol in
                return tag
            })
        }
        set {
            realmNewMessages.removeAll()
            newValue.forEach { (newMessages) in
                if let realmNewMessage = newMessages as? RealmUserNewMessages {
                    realmNewMessages.append(realmNewMessage)
                } else {
                    realmNewMessages.append(RealmUserNewMessages(userID: id, protocolObject: newMessages))
                }
            }
        }
    }
    var realmNewMessages = List<RealmUserNewMessages>()
    
    var invitations: [GroupInvitationProtocol] {
        get {
            return realmInvitations.map({ (invitation) -> GroupInvitationProtocol in
                return invitation
            })
        }
        set {
            realmInvitations.removeAll()
            newValue.forEach { (invitation) in
                if let realmInvitation = invitation as? RealmGroupInvitation {
                    realmInvitations.append(realmInvitation)
                } else {
                    realmInvitations.append(RealmGroupInvitation(userID: id, protocolObject: invitation))
                }
            }
        }
    }
    var realmInvitations = List<RealmGroupInvitation>()
    
    var pushDevices: [PushDeviceProtocol] {
        get {
            return realmPushDevices.map({ (pushDevice) -> PushDeviceProtocol in
                return pushDevice
            })
        }
        set {
            realmPushDevices.removeAll()
            newValue.forEach { (pushDevice) in
                if let realmPushDevice = pushDevice as? RealmPushDevice {
                    realmPushDevices.append(realmPushDevice)
                } else {
                    realmPushDevices.append(RealmPushDevice(userID: id, protocolObject: pushDevice))
                }
            }
        }
    }
    var realmPushDevices = List<RealmPushDevice>()
    
    var questAchievements: [AchievementProtocol] {
        get {
            return realmAchievements.map({ (achievement) -> AchievementProtocol in
                return achievement
            })
        }
        set {
            realmAchievements.removeAll()
            newValue.forEach { (achievement) in
                if let realmAchievement = achievement as? RealmAchievement {
                    realmAchievements.append(realmAchievement)
                } else {
                    realmAchievements.append(RealmAchievement(userID: id, protocolObject: achievement))
                }
            }
        }
    }
    var realmAchievements = List<RealmAchievement>()
    var achievementStreak: Int = 0
    
    var needsCron: Bool = false
    var lastCron: Date?
    
    var isValid: Bool {
        return !isInvalidated
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["flags", "preferences", "stats", "profile", "contributor", "tasksOrder", "items", "tags", "inbox", "authentication", "purchased", "party", "invitations", "pushDevices", "questAchievements"]
    }
    
    convenience init(_ user: UserProtocol) {
        self.init()
        id = user.id
        stats = user.stats
        flags = user.flags
        preferences = user.preferences
        profile = user.profile
        contributor = user.contributor
        balance = user.balance
        items = user.items
        tags = user.tags
        needsCron = user.needsCron
        lastCron = user.lastCron
        inbox = user.inbox
        authentication = user.authentication
        purchased = user.purchased
        party = user.party
        challenges = user.challenges
        hasNewMessages = user.hasNewMessages
        invitations = user.invitations
        pushDevices = user.pushDevices
        questAchievements = user.questAchievements
        achievementStreak = user.achievementStreak
    }
}
