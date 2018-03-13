//
//  RealmQuestCollect.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmQuestCollect: Object, QuestCollectProtocol {
    var key: String?
    var text: String?
    var count: Int = 0
    
    convenience init(_ questCollect: QuestCollectProtocol) {
        self.init()
        key = questCollect.key
        text = questCollect.text
        count = questCollect.count
    }
}
