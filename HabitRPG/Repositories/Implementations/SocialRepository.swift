//
//  SocialRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Habitica_Models
import Habitica_API_Client
import Habitica_Database

class SocialRepository: BaseRepository<SocialLocalRepository> {
    
    private let userRepository = UserRepository()
    
    func getGroups(predicate: NSPredicate) -> SignalProducer<ReactiveResults<[GroupProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getGroups(predicate: predicate)
    }
    
    func getChallenges(predicate: NSPredicate?) -> SignalProducer<ReactiveResults<[ChallengeProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getChallenges(predicate: predicate)
    }
    
    func getChallengesDistinctGroups() -> SignalProducer<ReactiveResults<[ChallengeProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getChallengesDistinctGroups()
    }
    
    func retrieveGroups(_ groupType: String) -> Signal<[GroupProtocol]?, Never> {
        return RetrieveGroupsCall(groupType).arraySignal.on(value: {[weak self]groups in
            guard let groups = groups else {
                return
            }
            self?.localRepository.save(groups)
            if groupType == "guilds" {
                if let userID = AuthenticationManager.shared.currentUserId {
                    self?.localRepository.save(userID: userID, groupIDs: groups.map({ (group) -> String? in
                        return group.id
                    }))
                }
            }
        })
    }

    func retrieveGroup(groupID: String) -> Signal<GroupProtocol?, Never> {
        let call = RetrieveGroupCall(groupID: groupID)
        call.serverErrorSignal.observeValues {[weak self] (error) in
            if error.code == 404 || error.code == 401 {
                self?.localRepository.deleteGroup(groupID: groupID)
            }
        }
        return call.objectSignal.on(value: {[weak self]group in
            if let group = group {
                self?.localRepository.save(group)
            }
        })
    }
    
    func retrieveChallenges(page: Int, memberOnly: Bool) -> Signal<[ChallengeProtocol]?, Never> {
        return RetrieveChallengesCall(page: page, memberOnly: memberOnly).arraySignal.on(value: {[weak self]challenges in
            guard let challenges = challenges else {
                return
            }
            self?.localRepository.save(challenges)
        })
    }
    
    func retrieveChallenge(challengeID: String, withTasks: Bool = true) -> Signal<ChallengeProtocol?, Never> {
        let signal = RetrieveChallengeCall(challengeID: challengeID).objectSignal.on(value: {[weak self]challenge in
            if let challenge = challenge {
                self?.localRepository.save(challenge)
            }
        })
        if withTasks {
            let taskCall = RetrieveChallengeTasksCall(challengeID: challengeID)
            return signal.combineLatest(with: taskCall.arraySignal).on(value: {[weak self] (challenge, tasks) in
                if let tasks = tasks, let order = challenge?.tasksOrder {
                    self?.localRepository.save(challengeID: challengeID, tasks: tasks, order: order)
                }
            }).map({ (user, _) in
                return user
            })
        } else {
            return signal
        }
    }

    func retrieveGroupMembers(groupID: String) -> Signal<[MemberProtocol]?, Never> {
        return RetrieveGroupMembersCall(groupID: groupID).arraySignal.on(value: {[weak self]members in
            if let members = members {
                self?.localRepository.save(members)
            }
        })
    }
    
    func markChatAsSeen(groupID: String) -> Signal<EmptyResponseProtocol?, Never> {
        return MarkChatSeenCall(groupID: groupID).objectSignal.on(failed: { error in
            print(error)
        }, value: {[weak self] response in
            if response != nil, let userID = self?.currentUserId {
                self?.localRepository.setNoNewMessages(userID: userID, groupID: groupID)
            }
        })
    }
    
    func like(groupID: String, chatMessage: ChatMessageProtocol) -> Signal<ChatMessageProtocol?, Never> {
        return LikeChatMessageCall(groupID: groupID, chatMessage: chatMessage)
            .objectSignal.on(value: {[weak self]message in
            if let message = message {
                self?.localRepository.save(groupID: groupID, chatMessage: message)
            }
        })
    }
    
    func flag(groupID: String, chatMessage: ChatMessageProtocol) -> Signal<EmptyResponseProtocol?, Never> {
        return FlagChatMessageCall(groupID: groupID, chatMessage: chatMessage)
            .objectSignal
    }
    
    func delete(groupID: String, chatMessage: ChatMessageProtocol) -> Signal<EmptyResponseProtocol?, Never> {
        if !chatMessage.isValid {
            return Signal.empty
        }
        return DeleteChatMessageCall(groupID: groupID, chatMessage: chatMessage)
            .objectSignal.on(value: {[weak self]_ in
            if chatMessage.isValid {
                self?.localRepository.delete(chatMessage)
            }
        })
    }
    
    func delete(message: InboxMessageProtocol) -> Signal<EmptyResponseProtocol?, Never> {
        return DeleteInboxMessageCall(message: message)
            .objectSignal.on(value: {[weak self]_ in
            self?.localRepository.delete(message)
        })
    }
    
    func post(chatMessage: String, toGroup groupID: String) -> Signal<ChatMessageProtocol?, Never> {
        return PostChatMessageCall(groupID: groupID, chatMessage: chatMessage).objectSignal.on(value: {[weak self] chatMessage in
            if let chatMessage = chatMessage {
                chatMessage.timestamp = Date()
                self?.localRepository.save(groupID: groupID, chatMessage: chatMessage)
            }
        })
    }
    
    func post(inboxMessage: String, toUserID userID: String) -> Signal<[InboxMessageProtocol]?, Never> {
        return PostInboxMessageCall(userID: userID, inboxMessage: inboxMessage).objectSignal.flatMap(.latest, {[weak self] (_) in
            return self?.userRepository.retrieveInboxMessages(conversationID: userID, page: 0) ?? Signal.empty
        })
    }
    
    func retrieveChat(groupID: String) -> Signal<[ChatMessageProtocol]?, Never> {
        return RetrieveChatCall(groupID: groupID).arraySignal.on(value: {[weak self] chatMessages in
            if let chatMessages = chatMessages {
                self?.localRepository.save(groupID: groupID, chatMessages: chatMessages)
            }
        })
    }
    
    public func getGroup(groupID: String, retrieveIfNotFound: Bool = false) -> SignalProducer<GroupProtocol?, Never> {
        return localRepository.getGroup(groupID: groupID)
            .flatMapError({ (_) -> SignalProducer<GroupProtocol?, Never> in
                return SignalProducer.empty
            })
            .flatMap(.concat, {[weak self] (group) -> SignalProducer<GroupProtocol?, Never> in
                if retrieveIfNotFound, let weakSelf = self {
                    return SignalProducer(weakSelf.retrieveGroup(groupID: groupID))
                } else {
                    return SignalProducer(value: group)
                }
            })
    }
    
    public func getChallenge(challengeID: String, retrieveIfNotFound: Bool = false) -> SignalProducer<ChallengeProtocol?, Never> {
        return localRepository.getChallenge(challengeID: challengeID)
            .flatMapError({ (_) -> SignalProducer<ChallengeProtocol?, Never> in
                return SignalProducer.empty
            })
            .flatMap(.concat, {[weak self] (challenge) -> SignalProducer<ChallengeProtocol?, Never> in
                if challenge == nil && retrieveIfNotFound, let weakSelf = self {
                    return SignalProducer(weakSelf.retrieveChallenge(challengeID: challengeID))
                } else {
                    return SignalProducer(value: challenge)
                }
            })
    }
    
    public func getChallengeTasks(challengeID: String) -> SignalProducer<ReactiveResults<[TaskProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getChallengeTasks(challengeID: challengeID)
    }

    func getGroupMembers(groupID: String) -> SignalProducer<ReactiveResults<[MemberProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getGroupMembers(groupID: groupID)
    }
    
    public func getChatMessages(groupID: String) -> SignalProducer<ReactiveResults<[ChatMessageProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getChatMessages(groupID: groupID)
    }

    public func getGroupMemberships() -> SignalProducer<ReactiveResults<[GroupMembershipProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getGroupMemberships(userID: userID) ?? SignalProducer.empty
        })
    }
    
    public func getChallengeMemberships() -> SignalProducer<ReactiveResults<[ChallengeMembershipProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getChallengeMemberships(userID: userID) ?? SignalProducer.empty
        })
    }
    
    public func getChallengeMembership(challengeID: String) -> SignalProducer<ChallengeMembershipProtocol?, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getChallengeMembership(userID: userID, challengeID: challengeID) ?? SignalProducer.empty
        })
    }
    
    public func retrieveMember(userID: String) -> Signal<MemberProtocol?, Never> {
        return RetrieveMemberCall(userID: userID).objectSignal.on(value: {[weak self] member in
            if let member = member {
                self?.localRepository.save(member)
            }
        })
    }
    
    public func retrieveMemberWithUsername(_ username: String) -> Signal<MemberProtocol?, Never> {
        return RetrieveMemberUsernameCall(username: username).objectSignal.on(value: {[weak self] member in
            if let member = member {
                self?.localRepository.save(member)
            }
        })
    }
    
    public func findUsernames(_ username: String, context: String?, id: String?) -> Signal<[MemberProtocol], Never> {
        return FindUsernamesCall(username: username, context: context, id: id).arraySignal.map({ result in
            return result ?? []
        })
    }
    
    public func findUsernamesLocally(_ username: String, id: String?) -> SignalProducer<[MemberProtocol], Never> {
        return localRepository.findUsernames(username, id: id)
            .flatMapError({ (_) -> SignalProducer<[MemberProtocol], Never> in
                return SignalProducer.empty
            })
    }
    
    public func getMember(userID: String, retrieveIfNotFound: Bool = false) -> SignalProducer<MemberProtocol?, Never> {
        return localRepository.getMember(userID: userID)
            .flatMapError({ (_) -> SignalProducer<MemberProtocol?, Never> in
                return SignalProducer.empty
            })
            .flatMap(.concat, {[weak self] (member) -> SignalProducer<MemberProtocol?, Never> in
                if retrieveIfNotFound && member == nil, let weakSelf = self {
                    return SignalProducer(weakSelf.retrieveMember(userID: userID))
                } else {
                    return SignalProducer(value: member)
                }
            })
    }
    
    public func getMembers(userIDs: [String]) -> SignalProducer<ReactiveResults<[MemberProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getMembers(userIDs: userIDs)
    }
    
    public func isUserGuildMember(groupID: String) -> SignalProducer<Bool, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getGroupMembership(userID: AuthenticationManager.shared.currentUserId ?? "", groupID: groupID).map({ (membership) in
                return membership != nil
            }) ?? SignalProducer.empty
        })
    }
    
    public func joinGroup(groupID: String) -> Signal<GroupProtocol?, Never> {
        UISelectionFeedbackGenerator.oneShotSelectionChanged()
        return JoinGroupCall(groupID: groupID).objectSignal.on(value: {[weak self]group in
            if let userID = AuthenticationManager.shared.currentUserId {
                ToastManager.show(text: L10n.Guilds.joinedGuild, color: .green)
                self?.localRepository.joinGroup(userID: userID, groupID: groupID, group: group)
                self?.localRepository.deleteGroupInvitation(userID: userID, groupID: groupID)
            }
        })
    }
    
    public func leaveGroup(groupID: String, leaveChallenges: Bool) -> Signal<GroupProtocol?, Never> {
        UISelectionFeedbackGenerator.oneShotSelectionChanged()
        return LeaveGroupCall(groupID: groupID, leaveChallenges: leaveChallenges)
            .objectSignal.on(value: {[weak self]group in
            if let userID = AuthenticationManager.shared.currentUserId {
                ToastManager.show(text: L10n.Guilds.leftGuild, color: .green)
                self?.localRepository.leaveGroup(userID: userID, groupID: groupID, group: group)
            }
        })
    }
    
    public func rejectGroupInvitation(groupID: String) -> Signal<EmptyResponseProtocol?, Never> {
        UISelectionFeedbackGenerator.oneShotSelectionChanged()
        return RejectGroupInvitationCall(groupID: groupID)
            .objectSignal.on(value: {[weak self] response in
            if response != nil, let userID = AuthenticationManager.shared.currentUserId {
                self?.localRepository.deleteGroupInvitation(userID: userID, groupID: groupID)
            }
        })
    }
    
    public func invite(toGroup groupID: String, members: [String: Any]) -> Signal<EmptyResponseProtocol?, Never> {
        let call = InviteToGroupCall(groupID: groupID, members: members)
        call.habiticaResponseSignal.observeValues { (response) in
            DispatchQueue.main.asyncAfter(wallDeadline: .now()+1) {
                if let error = response?.message {
                    ToastManager.show(text: error, color: .red)
                    UINotificationFeedbackGenerator.oneShotNotificationOccurred(.error)
                } else if response != nil {
                    ToastManager.show(text: L10n.usersInvited, color: .green)
                    UINotificationFeedbackGenerator.oneShotNotificationOccurred(.success)
                }
            }
        }
        return call.objectSignal
    }
    
    public func joinChallenge(challengeID: String) -> Signal<ChallengeProtocol?, Never> {
        UISelectionFeedbackGenerator.oneShotSelectionChanged()
        if let userID = AuthenticationManager.shared.currentUserId {
            localRepository.joinChallenge(userID: userID, challengeID: challengeID, challenge: nil)
        }
        return JoinChallengeCall(challengeID: challengeID)
            .objectSignal.on(value: {[weak self]challenge in
            if let userID = AuthenticationManager.shared.currentUserId {
                self?.localRepository.joinChallenge(userID: userID, challengeID: challengeID, challenge: challenge)
            }
                ToastManager.show(text: L10n.joinedChallenge, color: .green)
        }).flatMap(.latest, {[weak self] challenge -> Signal<ChallengeProtocol?, Never> in
            return self?.userRepository.retrieveUser().map({ _ in
                challenge
            }) ?? Signal.empty
        })
    }
    
    public func leaveChallenge(challengeID: String, keepTasks: Bool) -> Signal<ChallengeProtocol?, Never> {
        UISelectionFeedbackGenerator.oneShotSelectionChanged()
        if let userID = AuthenticationManager.shared.currentUserId {
            localRepository.leaveChallenge(userID: userID, challengeID: challengeID, challenge: nil)
        }
        return LeaveChallengeCall(challengeID: challengeID, keepTasks: keepTasks)
            .objectSignal.on(value: {[weak self]challenge in
            if let userID = AuthenticationManager.shared.currentUserId {
                self?.localRepository.leaveChallenge(userID: userID, challengeID: challengeID, challenge: challenge)
            }
            ToastManager.show(text: L10n.leftChallenge, color: .green)
        })
    }
    
    public func getMessagesThreads() -> SignalProducer<ReactiveResults<[InboxConversationProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getMessagesThreads(userID: userID) ?? SignalProducer.empty
        })
    }
    
    public func getMessages(withUserID: String) -> SignalProducer<ReactiveResults<[InboxMessageProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getMessages(userID: userID, withUserID: withUserID) ?? SignalProducer.empty
        })
    }
    
    public func markInboxAsSeen() -> Signal<EmptyResponseProtocol?, Never> {
        return MarkInboxAsSeenCall()
            .objectSignal.on(value: {[weak self] _ in
            self?.localRepository.markInboxAsSeen(userID: self?.currentUserId ?? "")
        })
    }
    
    public func rejectQuestInvitation(groupID: String) -> Signal<QuestStateProtocol?, Never> {
        UISelectionFeedbackGenerator.oneShotSelectionChanged()
        localRepository.changeQuestRSVP(userID: currentUserId ?? "", rsvpNeeded: false)
        return RejectQuestInvitationCall(groupID: groupID)
            .objectSignal.on(value: saveQuestState(objectID: groupID, groupID: groupID))
    }
    
    public func acceptQuestInvitation(groupID: String) -> Signal<QuestStateProtocol?, Never> {
        UISelectionFeedbackGenerator.oneShotSelectionChanged()
        localRepository.changeQuestRSVP(userID: currentUserId ?? "", rsvpNeeded: false)
        return AcceptQuestInvitationCall(groupID: groupID)
            .objectSignal.on(value: saveQuestState(objectID: groupID, groupID: groupID))
    }
    
    public func cancelQuestInvitation(groupID: String) -> Signal<QuestStateProtocol?, Never> {
        UISelectionFeedbackGenerator.oneShotSelectionChanged()
        return CancelQuestInvitationCall(groupID: groupID)
            .objectSignal.on(value: saveQuestState(objectID: groupID, groupID: groupID))
    }
    
    public func abortQuest(groupID: String) -> Signal<QuestStateProtocol?, Never> {
        UISelectionFeedbackGenerator.oneShotSelectionChanged()
        return AbortQuestCall(groupID: groupID)
            .objectSignal.on(value: saveQuestState(objectID: groupID, groupID: groupID))
    }
    
    public func forceStartQuest(groupID: String) -> Signal<QuestStateProtocol?, Never> {
        UISelectionFeedbackGenerator.oneShotSelectionChanged()
        return ForceStartQuestCall(groupID: groupID)
            .objectSignal.on(value: saveQuestState(objectID: groupID, groupID: groupID))
    }
    
    public func leaveQuest(groupID: String) -> Signal<EmptyResponseProtocol?, Never> {
        UISelectionFeedbackGenerator.oneShotSelectionChanged()
        return LeaveQuestCall(groupID: groupID)
    }
    
    private func saveQuestState(objectID: String, groupID: String) -> ((QuestStateProtocol?) -> Void) {
        return {[weak self] questState in
            if let questState = questState {
                self?.localRepository.save(objectID: objectID, groupID: groupID, questState: questState)
            }
        }
    }
    
    func getNewGroup() -> GroupProtocol {
        return localRepository.getNewGroup()
    }

    func getEditableGroup(id: String) -> GroupProtocol? {
        return localRepository.getEditableGroup(id: id)
    }
    
    func createGroup(_ group: GroupProtocol) -> Signal<GroupProtocol?, Never> {
        localRepository.save(group)
        return CreateGroupCall(group: group)
            .objectSignal.on(value: {[weak self] returnedGroup in
            if let returnedGroup = returnedGroup {
                self?.localRepository.save(returnedGroup)
                self?.localRepository.joinGroup(userID: self?.currentUserId ?? "", groupID: returnedGroup.id ?? "", group: returnedGroup)
            }
        })
    }
    
    func updateGroup(_ group: GroupProtocol) -> Signal<GroupProtocol?, Never> {
        localRepository.save(group)
        return UpdateGroupCall(group: group)
            .objectSignal.on(value: {[weak self] returnedGroup in
            if let returnedGroup = returnedGroup {
                self?.localRepository.save(returnedGroup)
            }
        })
    }
    
    func transferOwnership(groupID: String, userID: String) -> SignalProducer<GroupProtocol?, ReactiveSwiftRealmError> {
        return localRepository.getGroup(groupID: groupID).take(first: 1)
            .skipNil()
            .map({ group in
                let newGroup = self.localRepository.getNewGroup()
                newGroup.id = group.id
                newGroup.name = group.name
                newGroup.groupDescription = group.groupDescription
                newGroup.summary = group.summary
                newGroup.leaderID = userID
                newGroup.name = group.name
                newGroup.type = group.type
                newGroup.privacy = group.privacy
                return newGroup
            })
            .flatMap(.latest) { group in
                return self.updateGroup(group).producer
        }
    }
    
    func removeMember(groupID: String, userID: String) -> Signal<GroupProtocol?, Never> {
        return RemoveMemberCall(groupID: groupID, userID: userID).objectSignal
            .flatMap(.latest) { _ in
                return self.retrieveGroup(groupID: groupID)
        }
    }
    
    func blockMember(userID: String) -> Signal<UserProtocol?, Never> {
        return BlockMemberCall(userID: userID).objectSignal.flatMap(.latest) { _ in
            return self.userRepository.retrieveUser()
        }
    }
}
