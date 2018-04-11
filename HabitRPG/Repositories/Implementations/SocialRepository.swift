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
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return HRPGManager.shared().getManagedObjectContext()
    }()
    
    func getFetchRequest<T: NSManagedObject>(entityName: String, predicate: NSPredicate) -> NSFetchRequest<T> {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    internal func makeFetchRequest<T: NSManagedObject>(entityName: String, predicate: NSPredicate) -> T? {
        let fetchRequest: NSFetchRequest<T> = getFetchRequest(entityName: entityName, predicate: predicate)
        let result = try? managedObjectContext.fetch(fetchRequest)
        if result?.count ?? 0 > 0, let item = result?[0] {
            return item
        }
        return nil
    }
    
    func getGroup(_ groupID: String) -> Group? {
        return makeFetchRequest(entityName: "Group", predicate: NSPredicate(format: "id == %@", groupID))
    }
    
    func getGroups(predicate: NSPredicate) -> SignalProducer<ReactiveResults<[GroupProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getGroups(predicate: predicate)
    }
    
    func retrieveGroups(_ groupType: String) -> Signal<[GroupProtocol]?, NoError> {
        let call = RetrieveGroupsCall(groupType)
        call.fire()
        return call.arraySignal.on(value: { groups in
            guard let groups = groups else {
                return
            }
            self.localRepository.save(groups)
            if groupType == "guilds" {
                if let userID = AuthenticationManager.shared.currentUserId {
                    self.localRepository.save(userID: userID, groupIDs: groups.map({ (group) -> String? in
                        return group.id
                    }))
                }
            }
        })
    }
    
    func retrieveGroup(groupID: String) -> Signal<GroupProtocol?, NoError> {
        let call = RetrieveGroupCall(groupID: groupID)
        call.fire()
        return call.objectSignal.on(value: { group in
            if let group = group {
                self.localRepository.save(group)
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
        return call.objectSignal
    }
    
    func flag(groupID: String, chatMessage: ChatMessageProtocol) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = FlagChatMessageCall(groupID: groupID, chatMessage: chatMessage)
        call.fire()
        return call.objectSignal
    }
    
    func delete(groupID: String, chatMessage: ChatMessageProtocol) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = DeleteChatMessageCall(groupID: groupID, chatMessage: chatMessage)
        call.fire()
        return call.objectSignal
    }
    
    func post(chatMessage: String, toGroup groupID: String) -> Signal<ChatMessageProtocol?, NoError> {
        let call = PostChatMessageCall(groupID: groupID, chatMessage: chatMessage)
        call.fire()
        return call.objectSignal
    }
    
    func retrieveChat(groupID: String) -> Signal<[ChatMessageProtocol]?, NoError> {
        let call = RetrieveChatCall(groupID: groupID)
        call.fire()
        return call.arraySignal.on(value: { chatMessages in
            if let chatMessages = chatMessages {
                self.localRepository.save(groupID: groupID, chatMessages: chatMessages)
            }
        })
    }
    
    public func getGroup(groupID: String, retrieveIfNotFound: Bool = false) -> SignalProducer<GroupProtocol?, NoError> {
        return localRepository.getGroup(groupID: groupID)
            .flatMapError({ (_) -> SignalProducer<GroupProtocol?, NoError> in
                return SignalProducer.empty
            })
            .flatMap(.concat, { (group) -> SignalProducer<GroupProtocol?, NoError> in
                if retrieveIfNotFound {
                    return SignalProducer(self.retrieveGroup(groupID: groupID))
                } else {
                    return SignalProducer(value: group)
                }
            })
    }
    
    public func getChatMessages(groupID: String) -> SignalProducer<ReactiveResults<[ChatMessageProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getChatMessages(groupID: groupID)
    }

    public func getGroupMemberships() -> SignalProducer<ReactiveResults<[GroupMembershipProtocol]>, ReactiveSwiftRealmError> {
        if let userId = AuthenticationManager.shared.currentUserId {
            return localRepository.getGroupMemberships(userID: userId)
        } else {
            return SignalProducer {(sink, _) in
                sink.sendCompleted()
            }
        }
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
            .flatMap(.concat, { (member) -> SignalProducer<MemberProtocol?, NoError> in
                if retrieveIfNotFound && member == nil {
                    return SignalProducer(self.retrieveMember(userID: userID))
                } else {
                    return SignalProducer(value: member)
                }
            })
    }
    
    public func isUserGuildMember(groupID: String) -> SignalProducer<Bool, ReactiveSwiftRealmError> {
        return localRepository.getGroupMembership(userID: AuthenticationManager.shared.currentUserId ?? "", groupID: groupID).map({ (membership) in
            return membership != nil
        })
    }
    
    public func joinGroup(groupID: String) -> Signal<GroupProtocol?, NoError> {
        let call = JoinGroupCall(groupID: groupID)
        call.fire()
        return call.objectSignal.on(value: { group in
            if let userID = AuthenticationManager.shared.currentUserId {
                self.localRepository.joinGroup(userID: userID, groupID: groupID, group: group)
            }
        })
    }
    
    public func leaveGroup(groupID: String, leaveChallenges: Bool) -> Signal<GroupProtocol?, NoError> {
        let call = LeaveGroupCall(groupID: groupID, leaveChallenges: leaveChallenges)
        call.fire()
        return call.objectSignal.on(value: { group in
            if let userID = AuthenticationManager.shared.currentUserId {
                self.localRepository.leaveGroup(userID: userID, groupID: groupID, group: group)
            }
        })
    }
}
