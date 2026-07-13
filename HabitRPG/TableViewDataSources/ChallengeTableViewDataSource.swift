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
import RealmSwift
import SwiftUI
import SwiftUIX

class ChallengeTableViewDataSource: BaseReactiveTableViewDataSource<ChallengeProtocol> {
    @objc var predicate: NSPredicate? {
        didSet {
            fetchChallenges()
        }
    }
    
    var isShowingJoinedChallenges: Bool = true {
        didSet {
            updatePredicate()
            loadTabIfNeeded()
        }
    }
    private var loadedTabs = Set<Bool>()
    private var discoverIDs = [String]()
    
    var filterState = ChallengeFilterState()
    @objc var shownGuilds: [String]?
    var searchText: String?
    
    var nextPage = 0
    var loadedAllData = false
    var isLoading = false
    weak var emptyView: UIHostingView<NoContentView<Image, Text, Text>>?

    private var fetchChallengesDisposable: Disposable?
    private let socialRepository = SocialRepository()
    
    private var membershipIDs = [String]()
    
    override init() {
        super.init()
        sections.append(ItemSection<ChallengeProtocol>())
        fetchChallenges()
        
        disposable.add(socialRepository.getChallengeMemberships().on(value: {[weak self]memberships, _ in
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
            if challenges.isEmpty {
                self?.emptyView?.isHidden = false
            } else {
                self?.emptyView?.isHidden = true
            }
            self?.sections[0].items = challenges
            self?.notify(changes: changes)
        }).start()
    }
    
    func initialDataLoad() {
        loadTabIfNeeded(clearsCache: true)
    }

    private func loadTabIfNeeded(clearsCache: Bool = false) {
        if loadedTabs.contains(isShowingJoinedChallenges) {
            return
        }
        let tab = isShowingJoinedChallenges
        retrieveData(forced: true, clearsCache: clearsCache) { [weak self] in
            self?.loadedTabs.insert(tab)
        }
    }

    func retrieveData(forced: Bool, clearsCache: Bool = true, completed: (() -> Void)?) {
        if forced {
            nextPage = 0
            loadedAllData = false
        }
        if loadedAllData || isLoading {
            return
        }
        isLoading = true
        let page = nextPage
        let memberOnly = isShowingJoinedChallenges
        let shouldClear = clearsCache && page == 0
        if shouldClear {
            loadedTabs = loadedTabs.filter { $0 == memberOnly }
        }
        socialRepository.retrieveChallenges(page: page, memberOnly: memberOnly, clearCache: shouldClear)
            .on(value: { [weak self] challenges in
                guard let self = self else { return }
                if !memberOnly {
                    let ids = (challenges ?? []).compactMap { $0.id }
                    DispatchQueue.main.async {
                        if page == 0 {
                            self.discoverIDs.removeAll()
                        }
                        self.discoverIDs.append(contentsOf: ids)
                        self.updatePredicate()
                    }
                }
                if challenges?.count ?? 0 < 10 {
                    self.loadedAllData = true
                }
                self.nextPage += 1
            })
            .observeCompleted { [weak self] in
                self?.isLoading = false
                if let action = completed {
                    action()
                }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let challenge = item(at: indexPath) {
            if let realmChallenge = challenge as? Object, realmChallenge.isInvalidated {
                return cell
            }
            let isOwner = challenge.leaderID == socialRepository.currentUserId
            let isParticipating = membershipIDs.contains(challenge.id ?? "")
            cell.contentConfiguration = UIHostingConfiguration {
                ChallengeListCard(challenge: challenge, isParticipating: isParticipating, isOwner: isOwner)
            }
            .margins(.horizontal, 16)
            .margins(.vertical, 7)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.accessoryType = .none
        }
        return cell
    }
    
    func updatePredicate() {
        predicate = getPredicate()
    }
    
    func getPredicate() -> NSPredicate? {
        var searchComponents = [String]()
        let userId = socialRepository.currentUserId ?? ""

        if filterState.showOwned != filterState.showNotOwned {
            if filterState.showOwned {
                searchComponents.append("leaderID == \'\(userId)\'")
            } else {
                searchComponents.append("leaderID != \'\(userId)\'")
            }
        }
        if let searchText = self.searchText {
            if searchText.isEmpty == false {
                searchComponents.append("((name CONTAINS[cd] \'\(searchText)\') OR (notes CONTAINS[cd] \'\(searchText)\'))")
            }
        }
        
        if isShowingJoinedChallenges || filterState.showParticipating != filterState.showNotParticipating {
            var component = "(id IN {"
            if !isShowingJoinedChallenges && filterState.showNotParticipating {
                component = "!(id IN {"
            }
            if membershipIDs.isEmpty == false {
                component.append("\'\(membershipIDs[0])\'")
            }
            for id in membershipIDs.dropFirst() {
                component.append(", \'\(id)\'")
            }
            component.append("}")
            if filterState.showOwned {
                component.append(" || leaderID == \'\(userId)\')")
            } else {
                component.append(")")
            }
            searchComponents.append(component)
        }

        if !isShowingJoinedChallenges {
            let ids = discoverIDs.isEmpty ? ["-"] : discoverIDs
            let idList = ids.map { "\'\($0)\'" }.joined(separator: ", ")
            searchComponents.append("id IN {\(idList)}")
        }

        if filterState.selectedCategories.isEmpty == false {
            let slugs = filterState.selectedCategories.map { "\'\($0)\'" }.joined(separator: ", ")
            searchComponents.append("SUBQUERY(realmCategories, $category, $category.slug IN {\(slugs)}).@count > 0")
        }

        if searchComponents.isEmpty == false {
            return NSPredicate(format: searchComponents.joined(separator: " && "))
        } else {
            return nil
        }
    }
}
