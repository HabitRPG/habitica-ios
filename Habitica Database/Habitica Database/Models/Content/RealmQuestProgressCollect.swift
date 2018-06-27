//
//  RealmQuestProgressCollect.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 27.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmQuestProgressCollect: Object, QuestProgressCollectProtocol {
    @objc dynamic var combinedKey: String?
    @objc dynamic var groupID: String?
    var key: String?
    var count: Int = 0
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init(groupID: String?, protocolObject: QuestProgressCollectProtocol) {
        self.init()
        self.groupID = groupID
        key = protocolObject.key
        count = protocolObject.count
        combinedKey = (groupID ?? "") + (key ?? "")
    }
}
