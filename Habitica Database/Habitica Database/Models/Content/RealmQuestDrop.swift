//
//  RealmQuestDrop.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 18.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmQuestDrop: Object, QuestDropProtocol {
    @objc dynamic var key: String?
    var gold: Int = 0
    var experience: Int = 0
    var unlock: String?
    var items: [QuestDropItemProtocol] {
        get {
            return realmItems.map({ (collectItem) -> QuestDropItemProtocol in
                return collectItem
            })
        }
        set {
            realmItems.removeAll()
            newValue.forEach { (collectItem) in
                if let realmCollectItem = collectItem as? RealmQuestDropItem {
                    realmItems.append(realmCollectItem)
                } else {
                    realmItems.append(RealmQuestDropItem(questKey: key, protocolObject: collectItem))
                }
            }
        }
    }
    var realmItems = List<RealmQuestDropItem>()
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    convenience init(key: String?, protocolObject: QuestDropProtocol) {
        self.init()
        self.key = key
        gold = protocolObject.gold
        experience = protocolObject.experience
        unlock = protocolObject.unlock
        items = protocolObject.items
    }
}
