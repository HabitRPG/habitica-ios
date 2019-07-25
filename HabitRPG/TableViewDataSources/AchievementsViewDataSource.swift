//
//  AchievementsViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class AchievementsViewDataSource: BaseReactiveCollectionViewDataSource<AchievementProtocol> {
    
    private let inventoryReqpository = InventoryRepository()
    private let userRepository = UserRepository()
    private var quests: [String: QuestProtocol] = [:]
    var isGridLayout = false {
        didSet {
            if isGridLayout {
                let totalWidth = Int((collectionView?.frame.size.width ?? 188))
                let columnCount = Int(totalWidth / 156)
                let remainingSpace = totalWidth - (columnCount * 156)
                let additionalSideSpace = CGFloat(remainingSpace / (columnCount + 1))
                collectionView?.contentInset = UIEdgeInsets(top: 16, left: additionalSideSpace, bottom: 16, right: additionalSideSpace)
                if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.minimumLineSpacing = 16
                }
            } else {
                collectionView?.contentInset = UIEdgeInsets.zero
                
                if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.minimumLineSpacing = 1
                }
            }
            collectionView?.reloadData()
        }
    }
    
    override init() {
        super.init()
        sections.append(ItemSection<AchievementProtocol>(title: L10n.Achievements.basic))
        sections.append(ItemSection<AchievementProtocol>(title: L10n.Achievements.seasonal))
        sections.append(ItemSection<AchievementProtocol>(title: L10n.Achievements.special))
        sections.append(ItemSection<AchievementProtocol>(title: L10n.Achievements.quests))

        disposable.inner.add(userRepository.getAchievements().on(value: {[weak self] (achievements, changes) in
            self?.sections[0].items = achievements.filter({ $0.category == "basic" })
            self?.sections[1].items = achievements.filter({ $0.category == "seasonal" })
            self?.sections[2].items = achievements.filter({ $0.category == "special" })
            self?.sections[3].items = achievements.filter({ $0.category == "quests" })
        }).flatMap(.latest, {[weak self] (achievements, changes) in
            return self?.inventoryReqpository.getQuests(keys: achievements.map { $0.key ?? "" }) ?? SignalProducer.empty
        }).on(value: {[weak self] (quests, changes) in
            self?.quests = Dictionary(uniqueKeysWithValues: quests.map{ ($0.key ?? "", $0) })
            self?.notify(changes: changes)
        }).start())
    }
    
    override func retrieveData(completed: (() -> Void)?) {
        disposable.inner.add(userRepository.retrieveAchievements().observeCompleted {
            completed?()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeader", for: indexPath
            ) as? AchievementHeaderReusableView
        
        if let headerView = view {
            let section = sections[indexPath.section]
            headerView.titleLabel.text = section.title
            headerView.earnedCountLabel.number = section.items.filter({ (achievement) -> Bool in
                return achievement.earned
            }).count
            return headerView
        }
        return UICollectionReusableView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        if let cell = cell as? AchievementCell, let achievement = item(at: indexPath) {
            if (achievement.isQuestAchievement) {
                if let quest = quests[achievement.key ?? ""] {
                    cell.configure(achievement: achievement, quest: quest)
                } else {
                    cell.configure(achievement: achievement)
                }
            } else {
                cell.configure(achievement: achievement)
            }
            cell.isGridLayout = isGridLayout
        }
        return cell
    }
}
