//
//  ChallengeTableViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class ChallengeTableViewDataSource: BaseReactiveTableViewDataSource<ChallengeProtocol> {
    @objc var predicate: NSPredicate? {
        didSet {
            fetchChallenges()
        }
    }
    
    var isShowingJoinedChallenges: Bool = true {
        didSet {
            updatePredicate()
        }
    }
    
    var isFiltering = false
    var showOwned = true
    var showNotOwned = true
    @objc var shownGuilds: [String]?
    var searchText: String?
    
    var nextPage = 0
    var loadedAllData = false
    var isLoading = false

    private var fetchChallengesDisposable: Disposable?
    private let socialRepository = SocialRepository()
    
    private var membershipIDs = [String]()
    
    override init() {
        super.init()
        sections.append(ItemSection<ChallengeProtocol>())
        fetchChallenges()
        
        disposable.inner.add(socialRepository.getChallengeMemberships().on(value: {[weak self]memberships, _ in
            self?.membershipIDs.removeAll()
            memberships.forEach({ (membership) in
                if let challengeID = membership.challengeID {
                    self?.membershipIDs.append(challengeID)
                }
            })
            DispatchQueue.main.async {
                self?.updatePredicate()
            }
        }).start())
    }
    
    private func fetchChallenges() {
        if let disposable = fetchChallengesDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
        fetchChallengesDisposable = socialRepository.getChallenges(predicate: predicate).on(value: {[weak self](challenges, changes) in
            self?.sections[0].items = challenges
            self?.notify(changes: changes)
        }).start()
    }
    
    func retrieveData(forced: Bool, completed: (() -> Void)?) {
        if forced {
            nextPage = 0
            loadedAllData = false
        }
        if loadedAllData || isLoading {
            return
        }
        isLoading = true
        socialRepository.retrieveChallenges(page: nextPage, memberOnly: isShowingJoinedChallenges)
            .on(value: { challenges in
                if challenges?.count ?? 0 < 10 {
                    self.loadedAllData = true
                }
                self.nextPage += 1
            })
            .observeCompleted {
                self.isLoading = false
                if let action = completed {
                    action()
                }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let challenge = item(at: indexPath), let challengeCell = cell as? ChallengeTableViewCell {
            challengeCell.setChallenge(challenge, isParticipating: membershipIDs.contains(challenge.id ?? ""), isOwner: challenge.leaderID == socialRepository.currentUserId)
            
            if self.isShowingJoinedChallenges {
                challengeCell.accessoryType = .disclosureIndicator
            } else {
                challengeCell.accessoryType = .none
            }
        }
        return cell
    }
    
    func updatePredicate() {
        predicate = getPredicate()
    }
    
    func getPredicate() -> NSPredicate? {
        var searchComponents = [String]()
        
        if self.showOwned != self.showNotOwned {
            let userId = socialRepository.currentUserId ?? ""
            if self.showOwned {
                searchComponents.append("leaderID == \'\(userId)\'")
            } else {
                searchComponents.append("leaderID != \'\(userId)\'")
            }
        }
        if let shownGuilds = self.shownGuilds {
            var component = "groupID IN {"
            if shownGuilds.isEmpty == false {
                component.append("\'\(shownGuilds[0])\'")
            }
            for id in shownGuilds.dropFirst() {
                component.append(", \'\(id)\'")
            }
            component.append("}")
            searchComponents.append(component)
        }
        if let searchText = self.searchText {
            if searchText.isEmpty == false {
                searchComponents.append("((name CONTAINS[cd] \'\(searchText)\') OR (notes CONTAINS[cd] \'\(searchText)\'))")
            }
        }
        
        if isShowingJoinedChallenges {
            var component = "id IN {"
            if membershipIDs.isEmpty == false {
                component.append("\'\(membershipIDs[0])\'")
            }
            for id in membershipIDs.dropFirst() {
                component.append(", \'\(id)\'")
            }
            component.append("}")
            searchComponents.append(component)
        }
        
        if searchComponents.isEmpty == false {
            return NSPredicate(format: searchComponents.joined(separator: " && "))
        } else {
            return nil
        }
    }
}
