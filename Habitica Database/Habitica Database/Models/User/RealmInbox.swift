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
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    @objc dynamic var blocks: [String] {
        get {
            if realmBlocks.isInvalidated {
                return []
            }
            return realmBlocks.map({ (date) in
                return date
            })
        }
        set {
            realmBlocks.removeAll()
            realmBlocks.append(objectsIn: newValue)
        }
    }
    var realmBlocks = List<String>()
    
    convenience init(id: String?, inboxProtocol: InboxProtocol) {
        self.init()
        self.id = id
        self.optOut = inboxProtocol.optOut
        self.numberNewMessages = inboxProtocol.numberNewMessages
        self.blocks = inboxProtocol.blocks
    }
}
