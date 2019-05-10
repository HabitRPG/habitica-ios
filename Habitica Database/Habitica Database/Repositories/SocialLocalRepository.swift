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
import RealmSwift

public class SocialLocalRepository: BaseLocalRepository {
    
    public func save(_ group: GroupProtocol) {
        if let realmGroup = group as? RealmGroup {
            save(object: realmGroup)
            return
        }
        save(object: RealmGroup(group))
    }
    
    public func save(objectID: String, groupID: String, questState: QuestStateProtocol) {
        if let realmQuestState = questState as? RealmQuestState {
            save(object: realmQuestState)
        } else {
            save(object: RealmQuestState(objectID: objectID, id: groupID, state: questState))
        }
    }
    
    public func save(_ groups: [GroupProtocol]) {
        save(objects: groups.map { (group) in
            if let realmGroup = group as? RealmGroup {
                return realmGroup
            }
            return RealmGroup(group)
        })
    }
    
    public func save(_ member: MemberProtocol) {
        if let realmMember = member as? RealmMember {
            save(object: realmMember)
            return
        }
        save(object: RealmMember(member))
    }

    public func save(_ members: [MemberProtocol]) {
        save(objects: members.map { (member) in
            if let realmMember = member as? RealmMember {
                return realmMember
            }
            return RealmMember(member)
        })
    }
    
    public func save(_ challenge: ChallengeProtocol) {
        if let realmChallenge = challenge as? RealmChallenge {
            save(object: realmChallenge)
            return
        }
        save(object: RealmChallenge(challenge))
    }
    
    public func save(_ challenges: [ChallengeProtocol]) {
        save(objects: challenges.map { (challenge) in
            if let realmChallenge = challenge as? RealmChallenge {
                return realmChallenge
            }
            return RealmChallenge(challenge)
        })
    }
    
    public func save(groupID: String?, chatMessages: [ChatMessageProtocol]) {
        save(objects: chatMessages.map { (chatMessage) in
            if let realmChatMessage = chatMessage as? RealmChatMessage {
                return realmChatMessage
            }
            return RealmChatMessage(groupID: groupID, chatMessage: chatMessage)
        })
        removeOldChatMessages(groupID: groupID, newChatMessages: chatMessages)
    }
    
    public func save(groupID: String?, chatMessage: ChatMessageProtocol) {
        if let realmChatMessage = chatMessage as? RealmChatMessage {
            save(object: realmChatMessage)
        } else {
            let message = RealmChatMessage(groupID: groupID, chatMessage: chatMessage)
            if message.timestamp == nil, let existingMessage = getRealm()?.object(ofType: RealmChatMessage.self, forPrimaryKey: message.id) {
                message.timestamp = existingMessage.timestamp
            }
            save(object: message)
        }
    }
    
    public func save(userID: String?, message: InboxMessageProtocol) {
        if let realmMessage = message as? RealmInboxMessage {
            save(object: realmMessage)
        } else {
            save(object: RealmInboxMessage(userID: userID, inboxMessage: message))
        }
    }
    
    public func save(userID: String?, groupIDs: [String?]) {
        let newMemberships = groupIDs.filter({ (id) -> Bool in
            return id != nil
        }).map({ (groupID) -> RealmGroupMembership in
            return RealmGroupMembership(userID: userID, groupID: groupID)
        })
        let oldGroupMemberships = getRealm()?.objects(RealmGroupMembership.self).filter("userID == '\(userID ?? "")'")
        var membershipsToRemove = [Object]()
        oldGroupMemberships?.forEach({ (membership) in
            if !newMemberships.contains(where: { (newMembership) -> Bool in
                return newMembership.groupID == membership.groupID
            }) {
                membershipsToRemove.append(membership)
            }
        })
        updateCall { realm in
            if membershipsToRemove.isEmpty == false {
                realm.delete(membershipsToRemove)
            }
            realm.add(newMemberships, update: true)
        }
    }
    
    public func delete(_ chatMessage: ChatMessageProtocol) {
        if let realm = getRealm(), let message = realm.object(ofType: RealmChatMessage.self, forPrimaryKey: chatMessage.id) {
            updateCall { realm in
                if message.isInvalidated {
                    return
                }
                realm.delete(message)
            }
        }
    }
    
    public func save(challengeID: String?, tasks: [TaskProtocol], order: [String: [String]]) {
        let tags = getRealm()?.objects(RealmTag.self)
        save(objects: tasks.map { (task) in
            task.order = order[(task.type ?? "")+"s"]?.index(of: task.id ?? "") ?? 0
            if let realmTask = task as? RealmTask {
                return realmTask
            }
            return RealmTask(ownerID: challengeID, taskProtocol: task, tags: tags)
        })
    }
    
    public func delete(_ message: InboxMessageProtocol) {
        if let realm = getRealm(), let message = realm.object(ofType: RealmInboxMessage.self, forPrimaryKey: message.id) {
            updateCall { realm in
                if message.isInvalidated {
                    return
                }
                realm.delete(message)
            }
        }
    }
    
    public func joinGroup(userID: String, groupID: String, group: GroupProtocol?) {
        let realm = getRealm()
        updateCall { realm in
            realm.add(RealmGroupMembership(userID: userID, groupID: groupID), update: true)
        }
        if group?.type == "party", let user = realm?.object(ofType: RealmUser.self, forPrimaryKey: userID) {
            let userParty = RealmUserParty()
            userParty.id = groupID
            userParty.userID = userID
            updateCall { realm in
                realm.add(userParty, update: true)
                user.party = userParty
            }
        }
    }
    
    public func leaveGroup(userID: String, groupID: String, group: GroupProtocol?) {
        let realm = getRealm()
        if let membership = realm?.object(ofType: RealmGroupMembership.self, forPrimaryKey: userID+groupID) {
            updateCall { realm in
                realm.delete(membership)
                if let group = group {
                    realm.add(RealmGroup(group), update: true)
                }
            }
        }
        if group?.type == "party", let userParty = realm?.object(ofType: RealmUserParty.self, forPrimaryKey: userID) {
            updateCall { realm in
                userParty.id = nil
            }
        }
    }
    
    public func deleteGroupInvitation(userID: String, groupID: String) {
        let realm = getRealm()
        if let invitation = realm?.object(ofType: RealmGroupInvitation.self, forPrimaryKey: userID+groupID) {
            updateCall { realm in
                realm.delete(invitation)
            }
        }
    }
    
    public func deleteGroup(groupID: String) {
        guard let realm = getRealm() else {
            return
        }
        let guild = realm.object(ofType: RealmGroup.self, forPrimaryKey: groupID)
        let messages = realm.objects(RealmChatMessage.self).filter("groupID == %@", groupID)
        updateCall({ (realm) in
            if let guild = guild {
                realm.delete(guild)
            }
            realm.delete(messages)
        })
    }
    
    public func joinChallenge(userID: String, challengeID: String, challenge: ChallengeProtocol?) {
        updateCall { realm in
            realm.add(RealmChallengeMembership(userID: userID, challengeID: challengeID), update: true)
        }
    }
    
    public func leaveChallenge(userID: String, challengeID: String, challenge: ChallengeProtocol?) {
        let realm = getRealm()
        if let membership = realm?.object(ofType: RealmChallengeMembership.self, forPrimaryKey: userID+challengeID) {
            updateCall { realm in
                realm.delete(membership)
                if let challenge = challenge {
                    realm.add(RealmChallenge(challenge), update: true)
                }
            }
        }
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
        if messagesToRemove.isEmpty == false {
            updateCall { realm in
                realm.delete(messagesToRemove)
            }
        }
    }
    
    public func getGroup(groupID: String) -> SignalProducer<GroupProtocol?, ReactiveSwiftRealmError> {
        return RealmGroup.findBy(query: "id == '\(groupID)'").reactive().map({ (groups, _) -> GroupProtocol? in
            return groups.first
        })
    }
    
    public func getChallenge(challengeID: String) -> SignalProducer<ChallengeProtocol?, ReactiveSwiftRealmError> {
        return RealmChallenge.findBy(query: "id == '\(challengeID)'").reactive().map({ (groups, _) -> ChallengeProtocol? in
            return groups.first
        })
    }
    
    public func getChallengeTasks(challengeID: String) -> SignalProducer<ReactiveResults<[TaskProtocol]>, ReactiveSwiftRealmError> {
        return RealmTask.findBy(query: "ownerID == '\(challengeID)'").reactive().map({ (value, changeset) -> ReactiveResults<[TaskProtocol]> in
            return (value.map({ (task) -> TaskProtocol in return task }), changeset)
        })
    }
    
    public func getChatMessages(groupID: String) -> SignalProducer<ReactiveResults<[ChatMessageProtocol]>, ReactiveSwiftRealmError> {
        return RealmChatMessage.findBy(query: "groupID == '\(groupID)'").sorted(key: "timestamp", ascending: false).reactive().map({ (value, changeset) -> ReactiveResults<[ChatMessageProtocol]> in
            return (value.map({ (message) -> ChatMessageProtocol in return message }), changeset)
        })
    }
    
    public func getGroups(predicate: NSPredicate) -> SignalProducer<ReactiveResults<[GroupProtocol]>, ReactiveSwiftRealmError> {
        return RealmGroup.findBy(predicate: NSCompoundPredicate.init(andPredicateWithSubpredicates: [NSPredicate(format: "id != 'habitrpg'"), predicate])).sorted(key: "memberCount", ascending: false).reactive().map({ (value, changeset) -> ReactiveResults<[GroupProtocol]> in
            return (value.map({ (group) -> GroupProtocol in return group }), changeset)
        })
    }
    
    public func getChallenges(predicate: NSPredicate?) -> SignalProducer<ReactiveResults<[ChallengeProtocol]>, ReactiveSwiftRealmError> {
        var query: SignalProducer<Results<RealmChallenge>, ReactiveSwiftRealmError>?
        if let predicate = predicate {
            query = RealmChallenge.findBy(predicate: predicate)
        } else {
            query = RealmChallenge.findAll()
        }
        // swiftlint:disable:next force_unwrapping
        return query!.sorted(key: "memberCount", ascending: false).reactive().map({ (value, changeset) -> ReactiveResults<[ChallengeProtocol]> in
            return (value.map({ (challenge) -> ChallengeProtocol in return challenge }), changeset)
        })
    }
    
    public func getChallengesDistinctGroups() -> SignalProducer<ReactiveResults<[ChallengeProtocol]>, ReactiveSwiftRealmError> {
        return RealmChallenge.findAll().distinct(by: ["groupID"]).sorted(key: "memberCount", ascending: false).reactive().map({ (value, changeset) -> ReactiveResults<[ChallengeProtocol]> in
            return (value.map({ (challenge) -> ChallengeProtocol in return challenge }), changeset)
        })
    }

    public func getGroupMembers(groupID: String) -> SignalProducer<ReactiveResults<[MemberProtocol]>, ReactiveSwiftRealmError> {
        return RealmMember.findBy(query: "realmParty.id == '\(groupID)'").reactive().map({ (value, changeset) -> ReactiveResults<[MemberProtocol]> in
            return (value.map({ (member) -> MemberProtocol in return member }), changeset)
        })
    }

    public func getGroupMemberships(userID: String) -> SignalProducer<ReactiveResults<[GroupMembershipProtocol]>, ReactiveSwiftRealmError> {
        return RealmGroupMembership.findBy(query: "userID == '\(userID)'").reactive().map({ (value, changeset) -> ReactiveResults<[GroupMembershipProtocol]> in
            return (value.map({ (membership) -> GroupMembershipProtocol in return membership }), changeset)
        })
    }
    
    public func getChallengeMemberships(userID: String) -> SignalProducer<ReactiveResults<[ChallengeMembershipProtocol]>, ReactiveSwiftRealmError> {
        return RealmChallengeMembership.findBy(query: "userID == '\(userID)'").reactive().map({ (value, changeset) -> ReactiveResults<[ChallengeMembershipProtocol]> in
            return (value.map({ (membership) -> ChallengeMembershipProtocol in return membership }), changeset)
        })
    }
    
    public func getGroupMembership(userID: String, groupID: String) -> SignalProducer<GroupMembershipProtocol?, ReactiveSwiftRealmError> {
        return RealmGroupMembership.findBy(query: "userID == '\(userID)' && groupID == '\(groupID)'").reactive().map({ (memberships, _) -> GroupMembershipProtocol? in
            return memberships.first
        })
    }
    
    public func getChallengeMembership(userID: String, challengeID: String) -> SignalProducer<ChallengeMembershipProtocol?, ReactiveSwiftRealmError> {
        return RealmChallengeMembership.findBy(query: "userID == '\(userID)' && challengeID == '\(challengeID)'").reactive().map({ (memberships, _) -> ChallengeMembershipProtocol? in
            return memberships.first
        })
    }
    
    public func getMember(userID: String) -> SignalProducer<MemberProtocol?, ReactiveSwiftRealmError> {
        return RealmMember.findBy(query: "id == '\(userID)'").reactive().map({ (members, _) -> MemberProtocol? in
            return members.first
        })
    }
    
    public func getMembers(userIDs: [String]) -> SignalProducer<ReactiveResults<[MemberProtocol]>, ReactiveSwiftRealmError> {
        return RealmMember.findBy(predicate: NSPredicate(format: "id IN %@", userIDs)).reactive().map({ (value, changeset) -> ReactiveResults<[MemberProtocol]> in
            return (value.map({ (member) -> MemberProtocol in return member }), changeset)
        })
    }
    
    public func getMessagesThreads(userID: String) -> SignalProducer<ReactiveResults<[InboxMessageProtocol]>, ReactiveSwiftRealmError> {
        return RealmInboxMessage.findBy(query: "ownUserID == '\(userID)'")
            .sorted(key: "timestamp", ascending: false)
            .distinct(by: ["userID"])
            .reactive().map({ (value, changeset) -> ReactiveResults<[InboxMessageProtocol]> in
            return (value.map({ (message) -> InboxMessageProtocol in return message }), changeset)
        })
    }
    
    public func getMessages(userID: String, withUserID: String) -> SignalProducer<ReactiveResults<[InboxMessageProtocol]>, ReactiveSwiftRealmError> {
        return RealmInboxMessage.findBy(query: "ownUserID == '\(userID)' && userID = '\(withUserID)'")
            .sorted(key: "timestamp", ascending: false)
            .reactive().map({ (value, changeset) -> ReactiveResults<[InboxMessageProtocol]> in
                return (value.map({ (message) -> InboxMessageProtocol in return message }), changeset)
            })
    }
    
    public func changeQuestRSVP(userID: String, rsvpNeeded: Bool) {
        // swiftlint:disable:next first_where
        if let realm = getRealm(), let questState = realm.objects(RealmQuestState.self).filter("combinedKey BEGINSWITH %@", userID).first {
            updateCall { _ in
                questState.rsvpNeeded = rsvpNeeded
            }
        }
    }
    
    public func getNewGroup() -> GroupProtocol {
        return RealmGroup()
    }
    
    public func getEditableGroup(id: String) -> GroupProtocol? {
        if let group = getRealm()?.object(ofType: RealmGroup.self, forPrimaryKey: id) {
            return RealmGroup(value: group)
        }
        return nil
    }
    
    public func markInboxAsSeen(userID: String) {
        if let realm = getRealm(), let user = realm.object(ofType: RealmUser.self, forPrimaryKey: userID) {
            updateCall { _ in
                user.inbox?.numberNewMessages = 0
            }
        }
    }
    
    public func setNoNewMessages(userID: String, groupID: String) {
        if let realm = getRealm(), let user = realm.object(ofType: RealmUser.self, forPrimaryKey: userID) {
            updateCall { _ in
                let newMessages = user.hasNewMessages.first(where: { (newMessages) -> Bool in
                    return newMessages.id == groupID
                })
                newMessages?.hasNewMessages = false
            }
        }
    }
    
    public func findUsernames(_ username: String, id: String?) -> SignalProducer<[MemberProtocol], ReactiveSwiftRealmError> {
        return RealmChatMessage.findBy(query: "groupID == '\(id ?? "")' && username BEGINSWITH[c] '\(username)'")
            .distinct(by: ["username"])
            .sorted(key: "timestamp", ascending: false)
            .reactive()
            .map({ (result, _) -> [MemberProtocol] in
                return result.map({ (message) -> MemberProtocol in
                    let member = RealmMember()
                    member.authentication = RealmAuthentication()
                    member.authentication?.local = RealmLocalAuthentication()
                    member.authentication?.local?.username = message.username
                    member.profile = RealmProfile()
                    member.profile?.name = message.displayName
                    member.contributor = RealmContributor()
                    member.contributor?.level = message.contributor?.level ?? 0
                    return member
                })
            })
    }
}
