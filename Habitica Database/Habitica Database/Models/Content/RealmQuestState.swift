//
//  RealmQuestState.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmQuestState: Object, QuestStateProtocol {
    @objc dynamic var id: String?
    @objc dynamic var active: Bool = false
    @objc dynamic var key: String?
    @objc dynamic var progress: QuestProgressProtocol? {
        get {
            return realmProgress
        }
        set {
            if let newProgress = newValue as? RealmQuestProgress {
                self.realmProgress = newProgress
            } else if let newProgress = newValue {
                realmProgress = RealmQuestProgress(id: id, progress: newProgress)
            }
        }
    }
    @objc dynamic var realmProgress: RealmQuestProgress?
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(id: String?, state: QuestStateProtocol) {
        self.init()
        self.id = id
        active = state.active
        key = state.key
        progress = state.progress
    }
}
