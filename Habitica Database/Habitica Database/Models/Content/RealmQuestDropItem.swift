//
//  RealmQuestDropItem.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 18.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmQuestDropItem: Object, QuestDropItemProtocol {
    @objc dynamic var combinedKey: String?
    @objc dynamic var questKey: String?
    var type: String?
    var key: String?
    var text: String?
    var onlyOwner: Bool = false
    var count: Int = 0
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init(questKey: String?, protocolObject: QuestDropItemProtocol) {
        self.init()
        self.questKey = questKey
        self.combinedKey = (questKey ?? "") + (protocolObject.key ?? "")
        key = protocolObject.key
        type = protocolObject.type
        text = protocolObject.text
        onlyOwner = protocolObject.onlyOwner
        count = protocolObject.count
    }
}
