//
//  RealmChatMessageReaction.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmChatMessageReaction: Object, ChatMessageReactionProtocol {
    @objc dynamic var combinedID: String?
    @objc dynamic var userID: String?
    @objc dynamic var hasReacted: Bool = false
    
    override static func primaryKey() -> String {
        return "combinedID"
    }
    
    convenience init(messageID: String?, reactionProtocol: ChatMessageReactionProtocol) {
        self.init()
        combinedID = (messageID ?? "") + (reactionProtocol.userID ?? "")
        userID = reactionProtocol.userID
        hasReacted = reactionProtocol.hasReacted
    }
}
