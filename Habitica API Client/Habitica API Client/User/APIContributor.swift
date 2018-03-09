//
//  APIContributor.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIContributor: ContributorProtocol, Codable {
    var level: Int = 0
    var admin: Bool = false
    var text: String?
    var contributions: String?
    
    enum CodingKeys: String, CodingKey {
        case level
        case admin
        case text
        case contributions
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        level = (try? values.decode(Int.self, forKey: .level)) ?? 0
        admin = (try? values.decode(Bool.self, forKey: .admin)) ?? false
        text = try? values.decode(String.self, forKey: .text)
        contributions = try? values.decode(String.self, forKey: .contributions)
    }

}
