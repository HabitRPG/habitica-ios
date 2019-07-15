//
//  AchievementsViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class AchievementsViewDataSource: BaseReactiveCollectionViewDataSource<AchievementProtocol> {
    
    private let userRepository = UserRepository()
    var isGridLayout = false {
        didSet {
            if isGridLayout {
                collectionView?.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
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
        sections.append(ItemSection<AchievementProtocol>())

        disposable.inner.add(userRepository.getAchievements().on(value: {[weak self] (achievements, changes) in
            self?.sections[0].items = achievements
            self?.notify(changes: changes)
        }).start())
    }
    
    override func retrieveData(completed: (() -> Void)?) {
        disposable.inner.add(userRepository.retrieveAchievements().observeCompleted {
            completed?()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        if let cell = cell as? AchievementCell, let achievement = item(at: indexPath) {
            cell.isGridLayout = isGridLayout
            cell.configure(achievement: achievement)
        }
        return cell
    }
}
