//
//  RealmUserParty.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 01.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmUserParty: Object, UserPartyProtocol {
    var order: String?
    var orderAscending: Bool = false
    var quest: QuestStateProtocol? {
        get {
            return realmQuest
        }
        set {
            if let value = newValue as? RealmQuestState {
                realmQuest = value
                return
            }
            if let value = newValue {
                realmQuest = RealmQuestState(objectID: userID, id: id, state: value)
            }
        }
    }
    @objc dynamic var realmQuest: RealmQuestState?
    @objc dynamic var userID: String?
    
    dynamic var id: String?
    override static func primaryKey() -> String {
        return "userID"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["quest"]
    }
    
    convenience init(userID: String?, protocolObject: UserPartyProtocol) {
        self.init()
        self.userID = userID
        id = protocolObject.id
        order = protocolObject.order
        orderAscending = protocolObject.orderAscending
        quest = protocolObject.quest
    }
}
