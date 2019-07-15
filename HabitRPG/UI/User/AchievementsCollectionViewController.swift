//
//  AchievementsCollectionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class AchievementsCollectionViewController: BaseCollectionViewController {
    
    private var dataSource: AchievementsViewDataSource?
    @IBOutlet weak var viewSwitcherButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        topHeaderCoordinator.followScrollView = false
        dataSource = AchievementsViewDataSource()
        collectionView.register(AchievementCell.self, forCellWithReuseIdentifier: "Cell")
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            if #available(iOS 10.0, *) {
                flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            } else {
                flowLayout.estimatedItemSize = CGSize(width: 100, height: 100)
            }
        }
        dataSource?.collectionView = collectionView
        dataSource?.retrieveData(completed: nil)
        viewSwitcherButton.image = Asset.buttonGrid.image
    }
    
    override func applyTheme(theme: Theme) {
        collectionView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
    }
    
    override func populateText() {
        super.populateText()
        title = L10n.Titles.achievements
    }
    
    @IBAction func viewSwitcherTapped(_ sender: Any) {
        dataSource?.isGridLayout = !(dataSource?.isGridLayout ?? true)
        if dataSource?.isGridLayout == true {
            viewSwitcherButton.image = Asset.buttonList.image
        } else {
            viewSwitcherButton.image = Asset.buttonGrid.image
        }
    }
}
