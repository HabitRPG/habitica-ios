//
//  APIMember.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIMember: MemberProtocol, Decodable {
    public var id: String?
    public var stats: StatsProtocol?
    public var preferences: PreferencesProtocol?
    public var profile: ProfileProtocol?
    public var contributor: ContributorProtocol?
    public var items: UserItemsProtocol?
    public var party: UserPartyProtocol?
    public var flags: FlagsProtocol?
    public var authentication: AuthenticationProtocol?
    public var isValid: Bool { return true }
    
    enum CodingKeys: String, CodingKey {
        case id
        case stats
        case flags
        case preferences
        case profile
        case contributor
        case items
        case party
        case authentication = "auth"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String.self, forKey: .id)
        stats = (try? values.decode(APIStats.self, forKey: .stats))
        preferences = (try? values.decode(APIPreferences.self, forKey: .preferences))
        profile = (try? values.decode(APIProfile.self, forKey: .profile))
        contributor = (try? values.decode(APIContributor.self, forKey: .contributor))
        items = (try? values.decode(APIMemberItems.self, forKey: .items))
        party = try? values.decode(APIUserParty.self, forKey: .party)
        flags = try? values.decode(APIFlags.self, forKey: .flags)
        authentication = try? values.decode(APIAuthentication.self, forKey: .authentication)
    }
}
