//
//  RealmQuestBossRage.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmQuestBossRage: Object, QuestBossRageProtocol {
    @objc dynamic var key: String?
    var title: String?
    var rageDescription: String?
    var value: Int = 0
    
    convenience init(key: String?, protocolObject: QuestBossRageProtocol) {
        self.init()
        self.key = key
        title = protocolObject.title
        rageDescription = protocolObject.rageDescription
        value = protocolObject.value
    }
}
