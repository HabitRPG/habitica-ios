//
//  GuildsOverviewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class GuildsOverviewDataSource: BaseReactiveTableViewDataSource<GroupProtocol> {
    @objc var predicate: NSPredicate? {
        didSet {
            fetchGuilds()
        }
    }
    
    var isShowingPrivateGuilds: Bool = true {
        didSet {
            updatePredicate()
        }
    }
    
    var searchText: String? {
        didSet {
            updatePredicate()
        }
    }
    
    var invitationListView: GroupInvitationListView?
    
    private var fetchGuildsDisposable: Disposable?
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    
    private var membershipIDs = [String]()
    
    override init() {
        super.init()
        sections.append(ItemSection<GroupProtocol>())
        fetchGuilds()
        
        self.predicate = getPredicate()

        disposable.inner.add(socialRepository.getGroupMemberships().on(value: {[weak self]memberships, _ in
            self?.membershipIDs.removeAll()
            memberships.forEach({ (membership) in
                if let groupID = membership.groupID {
                    self?.membershipIDs.append(groupID)
                }
            })
            self?.updatePredicate()
        }).start())
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.invitationListView?.set(invitations: user.invitations.filter({ (invitation) -> Bool in
                return !invitation.isPartyInvitation
            }))
            self?.tableView?.setNeedsLayout()
        }).start())
    }
    
    private func fetchGuilds() {
        if let disposable = fetchGuildsDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
        if let predicate = self.predicate {
            DispatchQueue.main.async {[weak self] in
            self?.fetchGuildsDisposable = self?.socialRepository.getGroups(predicate: predicate).on(value: {[weak self](guilds, changes) in
                self?.sections[0].items = guilds
                self?.notify(changes: changes)
            }).start()
            }
        }
    }
    
    override func retrieveData(completed: (() -> Void)?) {
        var guildType = "guilds"
        if !isShowingPrivateGuilds {
            guildType = "privateGuilds,publicGuilds"
        }
        socialRepository.retrieveGroups(guildType).observeCompleted {
            if let action = completed {
                action()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: isShowingPrivateGuilds ? "MyGuildCell" : "PublicGuildCell", for: indexPath)
        if let guild = item(at: indexPath) {
            if let myGuildCell = cell as? MyGuildCell {
                myGuildCell.configure(group: guild)
            } else if let publicGuildCell = cell as? PublicGuildCell {
                publicGuildCell.configure(group: guild)
            }
        }
        return cell
    }
    
    private func updatePredicate() {
        predicate = getPredicate()
    }
    
    private func getPredicate() -> NSPredicate {
        var predicates = [NSPredicate]()
        if isShowingPrivateGuilds {
            predicates.append(NSPredicate(format: "type == 'guild' && id IN %@", membershipIDs))
        } else {
            predicates.append(NSPredicate(format: "type == 'guild'"))
        }
        if let searchText = searchText, searchText.isEmpty == false {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@ || summary CONTAINS[cd] %@", searchText, searchText))
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
