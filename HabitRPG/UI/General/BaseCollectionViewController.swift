//
//  BaseCollectionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 06.05.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit

class BaseCollectionViewController: UICollectionViewController, Themeable, TutorialStepsProtocol {
    var tutorialIdentifier: String?
    var displayedTutorialStep: Bool = false
    var activeTutorial: TutorialStepView?
    func getDefinitionFor(tutorial: String) -> [String] {
        return []
    }
    
    var topHeaderCoordinator: TopHeaderCoordinator?
    
    override func viewDidLoad() {
        if let topHeaderNavigationController = navigationController as? TopHeaderViewController {
            topHeaderCoordinator = TopHeaderCoordinator(topHeaderNavigationController: topHeaderNavigationController, scrollView: collectionView)
        }
        super.viewDidLoad()
        populateText()
        ThemeService.shared.addThemeable(themable: self)
        topHeaderCoordinator?.viewDidLoad()
    }
    
    func applyTheme(theme: Theme) {
        collectionView.backgroundColor = theme.windowBackgroundColor
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topHeaderCoordinator?.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayTutorialStep()
        topHeaderCoordinator?.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        topHeaderCoordinator?.viewWillDisappear()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayedTutorialStep = false
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        topHeaderCoordinator?.scrollViewDidScroll()
    }
    
    func populateText() {
        
    }
}
