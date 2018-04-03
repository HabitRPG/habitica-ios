//
//  SocialLocalRepository.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 29.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class SocialLocalRepository: BaseLocalRepository {
    
    public func save(_ group: GroupProtocol) {
        if let realmGroup = group as? RealmGroup {
            save(object: realmGroup)
            return
        }
        save(object: RealmGroup(group))
        removeOldChatMessages(groupID: group.id, newChatMessages: group.chat)
    }
    
    public func save(_ groups: [GroupProtocol]) {
        save(objects: groups.map { (group) in
            if let realmGroup = group as? RealmGroup {
                return realmGroup
            }
            return RealmGroup(group)
        })
    }
    
    public func save(groupID: String?, chatMessages: [ChatMessageProtocol]) {
        save(objects:chatMessages.map { (chatMessage) in
            if let realmChatMessage = chatMessage as? RealmTask {
                return realmChatMessage
            }
            return RealmChatMessage(groupID: groupID, chatMessage: chatMessage)
        })
        removeOldChatMessages(groupID: groupID, newChatMessages: chatMessages)
    }
    
    public func save(userID: String?, groupIDs: [String?]) {
        save(objects:groupIDs.filter({ (id) -> Bool in
            return id != nil
        }).map({ (groupID) -> RealmGroupMembership in
            return RealmGroupMembership(userID: userID, groupID: groupID)
        }))
    }
    
    private func removeOldChatMessages(groupID: String?, newChatMessages: [ChatMessageProtocol]) {
        let oldChatMessages = getRealm()?.objects(RealmChatMessage.self).filter("groupID == %@", groupID ?? "")
        var messagesToRemove = [RealmChatMessage]()
        oldChatMessages?.forEach({ (message) in
            if !newChatMessages.contains(where: { (newMessage) -> Bool in
                return newMessage.id == message.id
            }) {
                messagesToRemove.append(message)
            }
        })
        if messagesToRemove.count > 0 {
            let realm = getRealm()
            try? realm?.write {
                realm?.delete(messagesToRemove)
            }
        }
    }
    
    public func getGroup(groupID: String) -> SignalProducer<GroupProtocol, ReactiveSwiftRealmError> {
        return RealmGroup.findBy(query: "id == '\(groupID)'").reactive().map({ (groups, changes) -> GroupProtocol? in
            return groups.first
        }).skipNil()
    }
    
    public func getChatMessages(groupID: String) -> SignalProducer<ReactiveResults<[ChatMessageProtocol]>, ReactiveSwiftRealmError> {
        return RealmChatMessage.findBy(query: "groupID == '\(groupID)'").sorted(key: "timestamp", ascending: false).reactive().map({ (value, changeset) -> ReactiveResults<[ChatMessageProtocol]> in
            return (value.map({ (message) -> ChatMessageProtocol in return message }), changeset)
        })
    }
    
    public func getGroups(predicate: NSPredicate) -> SignalProducer<ReactiveResults<[GroupProtocol]>, ReactiveSwiftRealmError> {
        return RealmGroup.findBy(predicate: predicate).sorted(key: "memberCount", ascending: false).reactive().map({ (value, changeset) -> ReactiveResults<[GroupProtocol]> in
            return (value.map({ (group) -> GroupProtocol in return group }), changeset)
        })
    }
    
    public func getGroupMemberships(userID: String) -> SignalProducer<ReactiveResults<[GroupMembershipProtocol]>, ReactiveSwiftRealmError> {
        return RealmGroupMembership.findBy(query: "userID == '\(userID)'").reactive().map({ (value, changeset) -> ReactiveResults<[GroupMembershipProtocol]> in
            return (value.map({ (membership) -> GroupMembershipProtocol in return membership }), changeset)
        })
    }
}
