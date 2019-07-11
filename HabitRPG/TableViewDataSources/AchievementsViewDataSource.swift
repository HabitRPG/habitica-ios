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
    private var isGridLayout = false
    
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
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.frame.size.width
        if isGridLayout {
            return CGSize(width: totalWidth/2, height: 106)
        } else {
            return CGSize(width: totalWidth, height: 40)
        }
    }
}
