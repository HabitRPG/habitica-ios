//
//  APIChallengeMembership.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIChallengeMembership: ChallengeMembershipProtocol {
    var challengeID: String?
    
    init(challengeID: String?) {
        self.challengeID = challengeID
    }
}
