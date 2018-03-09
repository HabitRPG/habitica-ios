//
//  APIUser.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIUser: UserProtocol, Codable {
    public var id: String?
    public var stats: StatsProtocol?
    public var flags: FlagsProtocol?
    public var preferences: PreferencesProtocol?
    public var profile: ProfileProtocol?
    public var contributor: ContributorProtocol?
    public var balance: Float = 0
    public var tasksOrder: [String: [String]]
    
    enum CodingKeys: String, CodingKey {
        case id
        case stats
        case flags
        case preferences
        case profile
        case contributor
        case balance
        case tasksOrder
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String.self, forKey: .id)
        stats = (try! values.decode(APIStats.self, forKey: .stats))
        flags = (try! values.decode(APIFlags.self, forKey: .flags))
        preferences = (try! values.decode(APIPreferences.self, forKey: .preferences))
        profile = (try! values.decode(APIProfile.self, forKey: .profile))
        contributor = (try! values.decode(APIContributor.self, forKey: .contributor))
        balance = (try! values.decode(Float.self, forKey: .balance))
        tasksOrder = (try? values.decode([String: [String]].self, forKey: .tasksOrder)) ?? [:]
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
