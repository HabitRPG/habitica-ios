//
//  RealmTaskPreferences.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 29.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

@objc
class RealmTaskPreferences: Object, TaskPreferencesProtocol {
    @objc dynamic var confirmScoreNotes: Bool = false
    @objc dynamic var groupByChallenge: Bool = false
    
    @objc dynamic var mirrorGroupTasks: [String]? {
        get {
            if realmMirrorGroupTasks.isInvalidated {
                return []
            }
            return realmMirrorGroupTasks.map({ (tag) -> String in
                return tag
            })
        }
        set {
            realmMirrorGroupTasks.removeAll()
            newValue?.forEach { (groupID) in
                realmMirrorGroupTasks.append(groupID)
            }
        }
    }
    var realmMirrorGroupTasks = List<String>()
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(id: String?, protocolObject: TaskPreferencesProtocol) {
        self.init()
        self.id = id
        self.confirmScoreNotes = protocolObject.confirmScoreNotes
        self.groupByChallenge = protocolObject.groupByChallenge
        self.mirrorGroupTasks = protocolObject.mirrorGroupTasks
    }
}
