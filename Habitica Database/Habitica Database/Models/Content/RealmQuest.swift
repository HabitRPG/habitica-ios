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
    @objc dynamic var realmBoss: RealmQuestBoss?
    var collect: [QuestCollectProtocol]? {
        get {
            return realmCollect.map({ (collectItem) -> QuestCollectProtocol in
                return collectItem
            })
        }
        set {
            realmCollect.removeAll()
            newValue?.forEach { (collectItem) in
                if let realmCollectItem = collectItem as? RealmQuestCollect {
                    realmCollect.append(realmCollectItem)
                } else {
                    realmCollect.append(RealmQuestCollect(collectItem))
                }
            }
        }
    }
    var realmCollect = List<RealmQuestCollect>()
    var drop: QuestDropProtocol? {
        get {
            return realmDrop
        }
        set {
            if let newDrop = newValue as? RealmQuestDrop {
                realmDrop = newDrop
                return
            }
            if let newDrop = newValue {
                realmDrop = RealmQuestDrop(key: key, protocolObject: newDrop)
            }
        }
    }
    @objc dynamic var realmDrop: RealmQuestDrop?
    var colors: QuestColorsProtocol? {
        get {
            return realmColors
        }
        set {
            if let newColor = newValue as? RealmQuestColors {
                realmColors = newColor
                return
            }
            if let newColor = newValue {
                realmColors = RealmQuestColors(key: key, protocolObject: newColor)
            }
        }
    }
    @objc dynamic var realmColors: RealmQuestColors?
    
    override static func ignoredProperties() -> [String] {
        return ["boss", "collect"]
    }
    
    convenience init(_ quest: QuestProtocol) {
        self.init(item: quest)
        completion = quest.completion
        category = quest.category
        boss = quest.boss
        collect = quest.collect
        drop = quest.drop
        itemType = ItemType.quests.rawValue
        colors = quest.colors
    }
}
