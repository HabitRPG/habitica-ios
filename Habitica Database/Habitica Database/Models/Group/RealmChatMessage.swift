//
//  RealmChatMessage.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 30.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmChatMessage: Object, ChatMessageProtocol {
    @objc dynamic var id: String?
    @objc dynamic var groupID: String?
    @objc dynamic var userID: String?
    @objc dynamic var text: String?
    var attributedText: NSAttributedString?
    @objc dynamic var timestamp: Date?
    @objc dynamic var username: String?
    @objc dynamic var flagCount: Int = 0
    var contributor: ContributorProtocol? {
        get {
            return realmContributor
        }
        set {
            if let newContributor = newValue as? RealmContributor {
                realmContributor = newContributor
                return
            }
            if let newContributor = newValue {
                realmContributor = RealmContributor(id: id, contributor: newContributor)
            }
        }
    }
    @objc dynamic var realmContributor: RealmContributor?
    
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["contributor", "attributedText"]
    }
    
    convenience init(groupID: String?, chatMessage: ChatMessageProtocol) {
        self.init()
        self.groupID = groupID
        id = chatMessage.id
        userID = chatMessage.userID
        text = chatMessage.text
        timestamp = chatMessage.timestamp
        username = chatMessage.username
        flagCount = chatMessage.flagCount
        contributor = chatMessage.contributor
    }
}
