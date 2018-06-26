//
//  RealmQuestParticipant.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 03.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmQuestParticipant: Object, QuestParticipantProtocol {
    @objc dynamic var combinedKey: String = ""
    var userID: String?
    var groupID: String?
    var accepted: Bool = false
    var responded: Bool = false
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init(groupID: String?, participantProtocol: QuestParticipantProtocol) {
        self.init()
        combinedKey = (groupID ?? "") + (participantProtocol.userID ?? "")
        userID = participantProtocol.userID
        self.groupID = participantProtocol.groupID
        accepted = participantProtocol.accepted
        responded = participantProtocol.responded
    }
}
