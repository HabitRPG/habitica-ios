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

    @objc dynamic var id: String?
    @objc dynamic var health: Float = 0
    @objc dynamic var rage: Float = 0
    @objc dynamic var up: Float = 0
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(id: String?, progress: QuestProgressProtocol) {
        self.init()
        self.id = id
        health = progress.health
        rage = progress.health
        up = progress.up
    }
}
