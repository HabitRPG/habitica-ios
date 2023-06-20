//
//  RealmMember.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 11.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

@objc
class RealmMember: BaseModel, MemberProtocol {
    
    @objc dynamic var id: String?
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
                realmStats = RealmStats(id: "m\(id ?? "")", stats: stats)
            }
        }
    }
    @objc dynamic var realmStats: RealmStats?
    
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
                realmPreferences = RealmPreferences(id: "m\(id ?? "")", preferences: newPreferences)
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
                realmProfile = RealmProfile(id: "m\(id ?? "")", profile: profile)
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
                realmContributor = RealmContributor(id: "m\(id ?? "")", contributor: newContributor)
            }
        }
    }
    @objc dynamic var realmContributor: RealmContributor?
    
    var backer: BackerProtocol? {
        get {
            return realmBacker
        }
        set {
            if let newBacker = newValue as? RealmBacker {
                realmBacker = newBacker
                return
            }
            if let newBacker = newValue {
                realmBacker = RealmBacker(id: id, backer: newBacker)
            }
        }
    }
    @objc dynamic var realmBacker: RealmBacker?
    
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
                realmItems = RealmUserItems(id: "m\(id ?? "")", userItems: newItems)
            }
        }
    }
    @objc dynamic var realmItems: RealmUserItems?
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
                realmParty = RealmUserParty(userID: "m\(id ?? "")", protocolObject: value)
            }
        }
    }
    @objc dynamic var realmParty: RealmUserParty?
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
                realmFlags = RealmFlags(id: "m\(id ?? "")", flags: newFlags)
            }
        }
    }
    @objc dynamic var realmFlags: RealmFlags?
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
                realmAuthentication = RealmAuthentication(userID: "m\(id ?? "")", protocolObject: value)
            }
        }
    }
    @objc dynamic var realmAuthentication: RealmAuthentication?
    @objc dynamic var loginIncentives: Int = 0

    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["flags", "preferences", "stats", "profile", "contributor", "items", "party", "flags", "authentication"]
    }
    
    convenience init(_ member: MemberProtocol) {
        self.init()
        id = member.id
        stats = member.stats
        preferences = member.preferences
        profile = member.profile
        contributor = member.contributor
        items = member.items
        party = member.party
        flags = member.flags
        authentication = member.authentication
        loginIncentives = member.loginIncentives
    }
}
