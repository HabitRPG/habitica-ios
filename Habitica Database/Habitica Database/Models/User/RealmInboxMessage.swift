//
//  RealmInboxMessage.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 25.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmInboxMessage: Object, InboxMessageProtocol {

    @objc dynamic var id: String?
    @objc dynamic var ownUserID: String?
    @objc dynamic var userID: String?
    @objc dynamic var text: String?
    var attributedText: NSAttributedString?
    @objc dynamic var timestamp: Date?
    @objc dynamic var displayName: String?
    @objc dynamic var username: String?
    @objc dynamic var flagCount: Int = 0
    var sent: Bool = false
    var sort: Int = 0
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
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["contributor", "attributedText", "likes", "flags"]
    }
    
    convenience init(userID: String?, inboxMessage: InboxMessageProtocol) {
        self.init()
        self.ownUserID = userID
        id = inboxMessage.id
        self.userID = inboxMessage.userID
        text = inboxMessage.text
        timestamp = inboxMessage.timestamp
        displayName = inboxMessage.displayName
        username = inboxMessage.username
        flagCount = inboxMessage.flagCount
        contributor = inboxMessage.contributor
        likes = inboxMessage.likes
        flags = inboxMessage.flags
        sent = inboxMessage.sent
        sort = inboxMessage.sort
    }
}
