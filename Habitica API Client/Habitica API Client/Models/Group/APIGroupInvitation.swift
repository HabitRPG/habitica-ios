//
//  APIGroupInvitation.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 22.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

struct APIGroupInvitationHelper: Decodable {
    var guilds: [APIGroupInvitation]?
    var parties: [APIGroupInvitation]?
}

class APIGroupInvitation: GroupInvitationProtocol, Decodable {
    var id: String?
    var name: String?
    var inviterID: String?
    var isPartyInvitation: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case inviterID = "inviter"
    }
}
