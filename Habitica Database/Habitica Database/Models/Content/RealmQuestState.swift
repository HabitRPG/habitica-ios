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
    var active: Bool = false
    var key: String?
    var progress: QuestProgressProtocol? {
        get {
            return realmProgress
        }
        set {
            if let newProgress = newValue as? RealmQuestProgress {
                self.realmProgress = newProgress
            } else if let newProgress = newValue {
                realmProgress = RealmQuestProgress(newProgress)
            }
        }
    }
    var realmProgress: RealmQuestProgress?
    
    
    convenience init(_ state: QuestStateProtocol) {
        self.init()
        active = state.active
        key = state.key
        progress = state.progress
    }
}
