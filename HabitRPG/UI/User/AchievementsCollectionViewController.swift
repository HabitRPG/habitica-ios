//
//  AchievementsCollectionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit

class AchievementsCollectionViewController: BaseCollectionViewController {
    
    private var dataSource: AchievementsViewDataSource?
    @IBOutlet weak var viewSwitcherButton: UIBarButtonItem!
    
  override func viewDidLoad() {
      super.viewDidLoad()

      configureTopHeaderCoordinator()
      setupCollectionView()
      configureDataSource()
      configureViewSwitcherButton()
  }

  private func configureTopHeaderCoordinator() {
      topHeaderCoordinator?.hideHeader = true
      topHeaderCoordinator?.followScrollView = false
  }

  private func setupCollectionView() {
      collectionView.register(AchievementCell.self, forCellWithReuseIdentifier: "Cell")
      collectionView.register(AchievementHeaderReusableView.self,
                              forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                              withReuseIdentifier: "SectionHeader")

      if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
          flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
          flowLayout.headerReferenceSize = CGSize(width: collectionView.bounds.size.width, height: 54)
      }
  }

  private func configureDataSource() {
      dataSource = AchievementsViewDataSource()
      dataSource?.collectionView = collectionView
      dataSource?.retrieveData(completed: nil)
  }

  private func configureViewSwitcherButton() {
      viewSwitcherButton.image = Asset.buttonGrid.image
  }

    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
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
