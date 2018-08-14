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
import Result

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
    
    func retrieveGroups(_ groupType: String) -> Signal<[GroupProtocol]?, NoError> {
        let call = RetrieveGroupsCall(groupType)
        call.fire()
        return call.arraySignal.on(value: {[weak self]groups in
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

    func retrieveGroup(groupID: String) -> Signal<GroupProtocol?, NoError> {
        let call = RetrieveGroupCall(groupID: groupID)
        call.fire()
        return call.objectSignal.on(value: {[weak self]group in
            if let group = group {
                self?.localRepository.save(group)
            }
        })
    }
    
    func retrieveChallenges() -> Signal<[ChallengeProtocol]?, NoError> {
        let call = RetrieveChallengesCall()
        call.fire()
        return call.arraySignal.on(value: {[weak self]challenges in
            guard let challenges = challenges else {
                return
            }
            self?.localRepository.save(challenges)
        })
    }
    
    func retrieveChallenge(challengeID: String, withTasks: Bool = true) -> Signal<ChallengeProtocol?, NoError> {
        let call = RetrieveChallengeCall(challengeID: challengeID)
        call.fire()
        let signal = call.objectSignal.on(value: {[weak self]challenge in
            if let challenge = challenge {
                self?.localRepository.save(challenge)
            }
        })
        if withTasks {
            let taskCall = RetrieveChallengeTasksCall(challengeID: challengeID)
            taskCall.fire()
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

    func retrieveGroupMembers(groupID: String) -> Signal<[MemberProtocol]?, NoError> {
        let call = RetrieveGroupMembersCall(groupID: groupID)
        call.fire()
        return call.arraySignal.on(value: {[weak self]members in
            if let members = members {
                self?.localRepository.save(members)
            }
        })
    }
    
    func markChatAsSeen(groupID: String) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = MarkChatSeenCall(groupID: groupID)
        call.fire()
        return call.objectSignal
    }
    
    func like(groupID: String, chatMessage: ChatMessageProtocol) -> Signal<ChatMessageProtocol?, NoError> {
        let call = LikeChatMessageCall(groupID: groupID, chatMessage: chatMessage)
        call.fire()
        return call.objectSignal.on(value: {[weak self]message in
            if let message = message {
                self?.localRepository.save(groupID: groupID, chatMessage: message)
            }
        })
    }
    
    func flag(groupID: String, chatMessage: ChatMessageProtocol) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = FlagChatMessageCall(groupID: groupID, chatMessage: chatMessage)
        call.fire()
        return call.objectSignal
    }
    
    func delete(groupID: String, chatMessage: ChatMessageProtocol) -> Signal<EmptyResponseProtocol?, NoError> {
        if !chatMessage.isValid {
            return Signal.empty
        }
        let call = DeleteChatMessageCall(groupID: groupID, chatMessage: chatMessage)
        call.fire()
        return call.objectSignal.on(value: {[weak self]_ in
            if chatMessage.isValid {
                self?.localRepository.delete(chatMessage)
            }
        })
    }
    
    func delete(message: InboxMessageProtocol) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = DeleteInboxMessageCall(message: message)
        call.fire()
        return call.objectSignal.on(value: {[weak self]_ in
            self?.localRepository.delete(message)
        })
    }
    
    func post(chatMessage: String, toGroup groupID: String) -> Signal<ChatMessageProtocol?, NoError> {
        let call = PostChatMessageCall(groupID: groupID, chatMessage: chatMessage)
        call.fire()
        return call.objectSignal.on(value: {[weak self]chatMessage in
            if let chatMessage = chatMessage {
                chatMessage.timestamp = Date()
                self?.localRepository.save(groupID: groupID, chatMessage: chatMessage)
            }
        })
    }
    
    func post(inboxMessage: String, toUserID userID: String) -> Signal<UserProtocol?, NoError> {
        let call = PostInboxMessageCall(userID: userID, inboxMessage: inboxMessage)
        call.fire()
        return call.objectSignal.flatMap(.latest, {[weak self] (_) in
            return self?.userRepository.retrieveUser() ?? Signal.empty
        })
    }
    
    func retrieveChat(groupID: String) -> Signal<[ChatMessageProtocol]?, NoError> {
        let call = RetrieveChatCall(groupID: groupID)
        call.fire()
        return call.arraySignal.on(value: {[weak self]chatMessages in
            if let chatMessages = chatMessages {
                self?.localRepository.save(groupID: groupID, chatMessages: chatMessages)
            }
        })
    }
    
    public func getGroup(groupID: String, retrieveIfNotFound: Bool = false) -> SignalProducer<GroupProtocol?, NoError> {
        return localRepository.getGroup(groupID: groupID)
            .flatMapError({ (_) -> SignalProducer<GroupProtocol?, NoError> in
                return SignalProducer.empty
            })
            .flatMap(.concat, {[weak self] (group) -> SignalProducer<GroupProtocol?, NoError> in
                if retrieveIfNotFound, let weakSelf = self {
                    return SignalProducer(weakSelf.retrieveGroup(groupID: groupID))
                } else {
                    return SignalProducer(value: group)
                }
            })
    }
    
    public func getChallenge(challengeID: String, retrieveIfNotFound: Bool = false) -> SignalProducer<ChallengeProtocol?, NoError> {
        return localRepository.getChallenge(challengeID: challengeID)
            .flatMapError({ (_) -> SignalProducer<ChallengeProtocol?, NoError> in
                return SignalProducer.empty
            })
            .flatMap(.concat, {[weak self] (challenge) -> SignalProducer<ChallengeProtocol?, NoError> in
                if retrieveIfNotFound, let weakSelf = self {
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
    
    public func retrieveMember(userID: String) -> Signal<MemberProtocol?, NoError> {
        let call = RetrieveMemberCall(userID: userID)
        call.fire()
        return call.objectSignal.on(value: {[weak self] member in
            if let member = member {
                self?.localRepository.save(member)
            }
        })
    }
    
    public func getMember(userID: String, retrieveIfNotFound: Bool = false) -> SignalProducer<MemberProtocol?, NoError> {
        return localRepository.getMember(userID: userID)
            .flatMapError({ (_) -> SignalProducer<MemberProtocol?, NoError> in
                return SignalProducer.empty
            })
            .flatMap(.concat, {[weak self] (member) -> SignalProducer<MemberProtocol?, NoError> in
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
    
    public func joinGroup(groupID: String) -> Signal<GroupProtocol?, NoError> {
        let call = JoinGroupCall(groupID: groupID)
        call.fire()
        return call.objectSignal.on(value: {[weak self]group in
            if let userID = AuthenticationManager.shared.currentUserId {
                self?.localRepository.joinGroup(userID: userID, groupID: groupID, group: group)
                self?.localRepository.deleteGroupInvitation(userID: userID, groupID: groupID)
            }
        })
    }
    
    public func leaveGroup(groupID: String, leaveChallenges: Bool) -> Signal<GroupProtocol?, NoError> {
        let call = LeaveGroupCall(groupID: groupID, leaveChallenges: leaveChallenges)
        call.fire()
        return call.objectSignal.on(value: {[weak self]group in
            if let userID = AuthenticationManager.shared.currentUserId {
                self?.localRepository.leaveGroup(userID: userID, groupID: groupID, group: group)
            }
        })
    }
    
    public func rejectGroupInvitation(groupID: String) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = RejectGroupInvitationCall(groupID: groupID)
        call.fire()
        return call.objectSignal.on(value: {[weak self] response in
            if response != nil, let userID = AuthenticationManager.shared.currentUserId {
                self?.localRepository.deleteGroupInvitation(userID: userID, groupID: groupID)
            }
        })
    }
    
    public func invite(toGroup groupID: String, invitationType: String, inviter: String, members: [String]) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = InviteToGroupCall(groupID: groupID, invitationType: invitationType, inviter: inviter, members: members)
        call.fire()
        call.habiticaResponseSignal.observeValues { (response) in
            if let error = response?.message {
                ToastManager.show(text: error, color: .red)
            } else {
                ToastManager.show(text: L10n.usersInvited, color: .blue)
            }
        }
        return call.objectSignal
    }
    
    public func joinChallenge(challengeID: String) -> Signal<ChallengeProtocol?, NoError> {
        let call = JoinChallengeCall(challengeID: challengeID)
        call.fire()
        return call.objectSignal.on(value: {[weak self]challenge in
            if let userID = AuthenticationManager.shared.currentUserId {
                self?.localRepository.joinChallenge(userID: userID, challengeID: challengeID, challenge: challenge)
            }
        }).flatMap(.latest, {[weak self] challenge -> Signal<ChallengeProtocol?, NoError> in
            return self?.userRepository.retrieveUser().map({ _ in
                challenge
            }) ?? Signal.empty
        })
    }
    
    public func leaveChallenge(challengeID: String, keepTasks: Bool) -> Signal<ChallengeProtocol?, NoError> {
        let call = LeaveChallengeCall(challengeID: challengeID, keepTasks: keepTasks)
        call.fire()
        return call.objectSignal.on(value: {[weak self]challenge in
            if let userID = AuthenticationManager.shared.currentUserId {
                self?.localRepository.leaveChallenge(userID: userID, challengeID: challengeID, challenge: challenge)
            }
        })
    }
    
    public func getMessagesThreads() -> SignalProducer<ReactiveResults<[InboxMessageProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getMessagesThreads(userID: userID) ?? SignalProducer.empty
        })
    }
    
    public func getMessages(withUserID: String) -> SignalProducer<ReactiveResults<[InboxMessageProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getMessages(userID: userID, withUserID: withUserID) ?? SignalProducer.empty
        })
    }
    
    public func markInboxAsSeen() -> Signal<EmptyResponseProtocol?, NoError> {
        let call = MarkInboxAsSeenCall()
        call.fire()
        return call.objectSignal.on(value: {[weak self] _ in
            self?.localRepository.markInboxAsSeen(userID: self?.currentUserId ?? "")
        })
    }
    
    public func rejectQuestInvitation(groupID: String) -> Signal<QuestStateProtocol?, NoError> {
        localRepository.changeQuestRSVP(userID: currentUserId ?? "", rsvpNeeded: false)
        let call = RejectQuestInvitationCall(groupID: groupID)
        call.fire()
        return call.objectSignal.on(value: saveQuestState(objectID: groupID, groupID: groupID))
    }
    
    public func acceptQuestInvitation(groupID: String) -> Signal<QuestStateProtocol?, NoError> {
        localRepository.changeQuestRSVP(userID: currentUserId ?? "", rsvpNeeded: false)
        let call = AcceptQuestInvitationCall(groupID: groupID)
        call.fire()
        return call.objectSignal.on(value: saveQuestState(objectID: groupID, groupID: groupID))
    }
    
    public func cancelQuestInvitation(groupID: String) -> Signal<QuestStateProtocol?, NoError> {
        let call = CancelQuestInvitationCall(groupID: groupID)
        call.fire()
        return call.objectSignal.on(value: saveQuestState(objectID: groupID, groupID: groupID))
    }
    
    public func abortQuest(groupID: String) -> Signal<QuestStateProtocol?, NoError> {
        let call = AbortQuestCall(groupID: groupID)
        call.fire()
        return call.objectSignal.on(value: saveQuestState(objectID: groupID, groupID: groupID))
    }
    
    public func forceStartQuest(groupID: String) -> Signal<QuestStateProtocol?, NoError> {
        let call = ForceStartQuestCall(groupID: groupID)
        call.fire()
        return call.objectSignal.on(value: saveQuestState(objectID: groupID, groupID: groupID))
    }
    
    private func saveQuestState(objectID: String, groupID: String) -> ((QuestStateProtocol?) -> Void) {
        return { questState in
            if let questState = questState {
                self.localRepository.save(objectID: objectID, groupID: groupID, questState: questState)
            }
        }
    }
    
    func getNewGroup() -> GroupProtocol {
        return localRepository.getNewGroup()
    }

    func getEditableGroup(id: String) -> GroupProtocol? {
        return localRepository.getEditableGroup(id: id)
    }
    
    func createGroup(_ group: GroupProtocol) -> Signal<GroupProtocol?, NoError> {
        localRepository.save(group)
        let call = CreateGroupCall(group: group)
        call.fire()
        return call.objectSignal.on(value: {[weak self] returnedGroup in
            if let returnedGroup = returnedGroup {
                self?.localRepository.save(returnedGroup)
                self?.localRepository.joinGroup(userID: self?.currentUserId ?? "", groupID: returnedGroup.id ?? "", group: returnedGroup)
            }
        })
    }
    
    func updateGroup(_ group: GroupProtocol) -> Signal<GroupProtocol?, NoError> {
        localRepository.save(group)
        let call = UpdateGroupCall(group: group)
        call.fire()
        return call.objectSignal.on(value: {[weak self] returnedGroup in
            if let returnedGroup = returnedGroup {
                self?.localRepository.save(returnedGroup)
            }
        })
    }
}
