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
    @objc dynamic var combinedKey: String = ""
    @objc dynamic var rsvpNeeded: Bool = false
    @objc dynamic var completed: String?
    @objc dynamic var id: String?
    @objc dynamic var active: Bool = false
    @objc dynamic var key: String?
    @objc dynamic var leaderID: String?
    var members: [QuestParticipantProtocol] {
        get {
            return realmMembers.map({ (quest) -> QuestParticipantProtocol in
                return quest
            })
        }
        set {
            realmMembers.removeAll()
            newValue.forEach { (participant) in
                if let realmOwnedQuest = participant as? RealmQuestParticipant {
                    realmMembers.append(realmOwnedQuest)
                } else {
                    realmMembers.append(RealmQuestParticipant(groupID: id, participantProtocol: participant))
                }
            }
        }
    }
    var realmMembers = List<RealmQuestParticipant>()
    @objc dynamic var progress: QuestProgressProtocol? {
        get {
            return realmProgress
        }
        set {
            if let newProgress = newValue as? RealmQuestProgress {
                self.realmProgress = newProgress
            } else if let newProgress = newValue {
                realmProgress = RealmQuestProgress(combinedKey: combinedKey, id: id, progress: newProgress)
            }
        }
    }
    @objc dynamic var realmProgress: RealmQuestProgress?
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init(objectID: String?, id: String?, state: QuestStateProtocol) {
        self.init()
        combinedKey = (objectID ?? "") + (id ?? "")
        self.id = id
        active = state.active
        key = state.key
        progress = state.progress
        rsvpNeeded = state.rsvpNeeded
        completed = state.completed
        leaderID = state.leaderID
        members = state.members
    }
}
