//
//  RealmInbox.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 03.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmInbox: Object, InboxProtocol {
    @objc dynamic var id: String?
    @objc dynamic var optOut: Bool = false
    @objc dynamic var numberNewMessages: Int = 0
    var messages: [InboxMessageProtocol] {
        get {
            return realmMessages.map({ (quest) -> InboxMessageProtocol in
                return quest
            })
        }
        set {
            realmMessages.removeAll()
            newValue.forEach { (message) in
                if let realmMessage = message as? RealmInboxMessage {
                    realmMessages.append(realmMessage)
                } else {
                    realmMessages.append(RealmInboxMessage(userID: id, inboxMessage: message))
                }
            }
        }
    }
    var realmMessages = List<RealmInboxMessage>()
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(id: String?, inboxProtocol: InboxProtocol) {
        self.init()
        self.id = id
        self.optOut = inboxProtocol.optOut
        self.numberNewMessages = inboxProtocol.numberNewMessages
        self.messages = inboxProtocol.messages
    }
}
