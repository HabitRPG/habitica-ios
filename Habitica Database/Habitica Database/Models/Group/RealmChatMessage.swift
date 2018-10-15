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
    @objc dynamic var displayName: String?
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
    var likes: [ChatMessageReactionProtocol] {
        get {
            return realmLikes.map({ (reaction) -> ChatMessageReactionProtocol in
                return reaction
            })
        }
        set {
            realmLikes.removeAll()
            newValue.forEach { (reaction) in
                if let realmReaction = reaction as? RealmChatMessageReaction {
                    realmLikes.append(realmReaction)
                } else {
                    realmLikes.append(RealmChatMessageReaction(messageID: id, reactionProtocol: reaction))
                }
            }
        }
    }
    var realmLikes = List<RealmChatMessageReaction>()

    var flags: [ChatMessageReactionProtocol] {
        get {
            return realmFlags.map({ (reaction) -> ChatMessageReactionProtocol in
                return reaction
            })
        }
        set {
            realmFlags.removeAll()
            newValue.forEach { (reaction) in
                if let realmReaction = reaction as? RealmChatMessageReaction {
                    realmFlags.append(realmReaction)
                } else {
                    realmFlags.append(RealmChatMessageReaction(messageID: id, reactionProtocol: reaction))
                }
            }
        }
    }
    var realmFlags = List<RealmChatMessageReaction>()
    
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
                realmUserStyles = RealmUserStyle(messageID: id, userStyleProtocol: newUserStyle)
            }
        }
    }
    @objc dynamic var realmUserStyles: RealmUserStyle?
    
    var isValid: Bool {
        return !isInvalidated
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["contributor", "attributedText", "likes", "flags", "userStyles"]
    }
    
    convenience init(groupID: String?, chatMessage: ChatMessageProtocol) {
        self.init()
        self.groupID = groupID
        id = chatMessage.id
        userID = chatMessage.userID
        text = chatMessage.text
        timestamp = chatMessage.timestamp
        displayName = chatMessage.displayName
        username = chatMessage.username
        flagCount = chatMessage.flagCount
        contributor = chatMessage.contributor
        likes = chatMessage.likes
        flags = chatMessage.flags
        userStyles = chatMessage.userStyles
    }
}
