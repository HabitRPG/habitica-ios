//
//  RealmQuest.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmQuest: RealmItem, QuestProtocol {
    var completion: String?
    var category: String?
    var boss: QuestBossProtocol? {
        get {
            return realmBoss
        }
        set {
            if let newBoss = newValue as? RealmQuestBoss {
                realmBoss = newBoss
                return
            }
            if let newBoss = newValue {
                realmBoss = RealmQuestBoss(key: key, questBoss: newBoss)
            }
        }
    }
    var realmBoss: RealmQuestBoss?
    var collect: [QuestCollectProtocol]? {
        get {
            return realmCollect?.map({ (collectItem) -> QuestCollectProtocol in
                return collectItem
            })
        }
        set {
            realmCollect?.removeAll()
            newValue?.forEach { (collectItem) in
                if let realmCollectItem = collectItem as? RealmQuestCollect {
                    realmCollect?.append(realmCollectItem)
                }
                realmCollect?.append(RealmQuestCollect(collectItem))
            }
        }
    }
    var realmCollect: List<RealmQuestCollect>?
    
    override static func ignoredProperties() -> [String] {
        return ["boss", "collect"]
    }
    
    convenience init(_ quest: QuestProtocol) {
        self.init(item: quest)
        completion = quest.completion
        category = quest.category
        boss = quest.boss
        collect = quest.collect
    }
}
