//
//  RealmGroup.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 30.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmGroup: Object, GroupProtocol {
    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var groupDescription: String?
    @objc dynamic var summary: String?
    @objc dynamic var type: String?
    @objc dynamic var memberCount: Int = 0
    @objc dynamic var privacy: String?
    @objc dynamic var balance: Float = 0
    @objc dynamic var leaderID: String?
    @objc dynamic var quest: QuestStateProtocol? {
        get {
            return realmQuest
        }
        set {
            if let newQuest = newValue as? RealmQuestState {
                realmQuest = newQuest
            } else if let newQuest = newValue {
                realmQuest = RealmQuestState(id: id, state: newQuest)
            }
        }
    }
    @objc dynamic var realmQuest: RealmQuestState?
    var chat: [ChatMessageProtocol] {
        get {
            return realmChat.map({ (message) -> ChatMessageProtocol in
                return message
            })
        }
        set {
            realmChat.removeAll()
            newValue.forEach { (message) in
                if let realmMessage = message as? RealmChatMessage {
                    realmChat.append(realmMessage)
                } else {
                    realmChat.append(RealmChatMessage(groupID: id, chatMessage: message))
                }
            }
        }
    }
    var realmChat = List<RealmChatMessage>()
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["chat", "quest"]
    }
    
    convenience init(_ groupProtocol: GroupProtocol) {
        self.init()
        id = groupProtocol.id
        name = groupProtocol.name
        groupDescription = groupProtocol.groupDescription
        summary = groupProtocol.summary
        type = groupProtocol.type
        memberCount = groupProtocol.memberCount
        privacy = groupProtocol.privacy
        balance = groupProtocol.balance
        leaderID = groupProtocol.leaderID
        quest = groupProtocol.quest
        chat = groupProtocol.chat
    }
}
