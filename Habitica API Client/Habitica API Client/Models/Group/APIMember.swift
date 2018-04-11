//
//  APIMember.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIMember: MemberProtocol, Codable {
    public var id: String?
    public var stats: StatsProtocol?
    public var preferences: PreferencesProtocol?
    public var profile: ProfileProtocol?
    public var contributor: ContributorProtocol?
    public var items: UserItemsProtocol?
    
    enum CodingKeys: String, CodingKey {
        case id
        case stats
        case flags
        case preferences
        case profile
        case contributor
        case items
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String.self, forKey: .id)
        stats = (try! values.decode(APIStats.self, forKey: .stats))
        preferences = (try! values.decode(APIPreferences.self, forKey: .preferences))
        profile = (try! values.decode(APIProfile.self, forKey: .profile))
        contributor = (try! values.decode(APIContributor.self, forKey: .contributor))
        items = (try! values.decode(APIUserItems.self, forKey: .items))
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
