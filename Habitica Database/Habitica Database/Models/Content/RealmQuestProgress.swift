//
//  RealmQuestProgress.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmQuestProgress: Object, QuestProgressProtocol {
    @objc dynamic var combinedKey: String = ""
    @objc dynamic var id: String?
    @objc dynamic var health: Float = 0
    @objc dynamic var rage: Float = 0
    @objc dynamic var up: Float = 0
    var collect: [QuestProgressCollectProtocol] {
        get {
            return realmCollect.map({ (collectItem) -> QuestProgressCollectProtocol in
                return collectItem
            })
        }
        set {
            realmCollect.removeAll()
            newValue.forEach { (collectItem) in
                if let realmProgressCollect = collectItem as? RealmQuestProgressCollect {
                    realmCollect.append(realmProgressCollect)
                } else {
                    realmCollect.append(RealmQuestProgressCollect(groupID: id, protocolObject: collectItem))
                }
            }
        }
    }
    var realmCollect = List<RealmQuestProgressCollect>()
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init(combinedKey: String, id: String?, progress: QuestProgressProtocol) {
        self.init()
        self.combinedKey = combinedKey
        self.id = id
        health = progress.health
        rage = progress.rage
        up = progress.up
        collect = progress.collect
    }
}
