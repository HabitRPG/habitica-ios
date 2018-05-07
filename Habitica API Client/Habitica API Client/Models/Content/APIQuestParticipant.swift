//
//  APIQuestParticipant.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 03.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestParticipant: QuestParticipantProtocol, Decodable {
    var userID: String?
    var groupID: String?
    var accepted: Bool
    var responded: Bool
    
    init(userID: String?, response: Bool?) {
        self.userID = userID
        responded = response != nil
        accepted = response ?? false
    }
    
}
