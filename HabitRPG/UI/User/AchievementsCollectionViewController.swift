//
//  AchievementsCollectionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class AchievementsCollectionViewController: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var dataSource: AchievementsViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = AchievementsViewDataSource()
        collectionView.register(AchievementCell.self, forCellWithReuseIdentifier: "Cell")
        dataSource?.collectionView = collectionView
        dataSource?.retrieveData(completed: nil)
    }
    
    override func populateText() {
        super.populateText()
        title = L10n.Titles.achievements
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return dataSource?.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? CGSize.zero
    }
}
