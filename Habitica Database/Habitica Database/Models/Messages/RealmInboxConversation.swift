//
//  RealmInboxConversation.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 11.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmInboxConversation: Object, InboxConversationProtocol {
    @objc dynamic var combinedID: String?
    @objc dynamic var uuid: String = ""
    @objc dynamic var userID: String = ""
    @objc dynamic var username: String?
    @objc dynamic var displayName: String?
    @objc dynamic var timestamp: Date?
    @objc dynamic var text: String?
    
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
                realmContributor = RealmContributor(id: uuid, contributor: newContributor)
            }
        }
    }
    @objc dynamic var realmContributor: RealmContributor?
    var userStyles: UserStyleProtocol? {
        get {
            return realmUserStyles
        }
        set {
            if let newUserStyle = newValue as? RealmUserStyle {
                realmUserStyles = newUserStyle
                return
            }
            if let newUserStyle = newValue {
                realmUserStyles = RealmUserStyle(messageID: uuid, userStyleProtocol: newUserStyle)
            }
        }
    }
    @objc dynamic var realmUserStyles: RealmUserStyle?
    
    var isValid: Bool {
        return !isInvalidated
    }
    
    override static func primaryKey() -> String {
        return "combinedID"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["contributor", "userStyles"]
    }
    
    convenience init(userID: String, inboxConversatin: InboxConversationProtocol) {
        self.init()
        combinedID = userID + inboxConversatin.uuid
        self.userID = userID
        uuid = inboxConversatin.uuid
        text = inboxConversatin.text
        timestamp = inboxConversatin.timestamp
        username = inboxConversatin.username
        displayName = inboxConversatin.displayName
        contributor = inboxConversatin.contributor
        userStyles = inboxConversatin.userStyles
    }
}
