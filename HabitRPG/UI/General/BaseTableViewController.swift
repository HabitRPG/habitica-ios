//
//  BaseTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.03.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class BaseTableViewController: UITableViewController, Themeable, TutorialStepsProtocol {
    var topHeaderCoordinator: TopHeaderCoordinator?
    var tutorialIdentifier: String?
    var displayedTutorialStep: Bool = false
    var activeTutorial: TutorialStepView?
    
    func getDefinitionFor(tutorial: String) -> [String] {
        return []
    }
    
    var isVisible = false
    
    override func viewDidLoad() {
        if let topHeaderNavigationController = navigationController as? TopHeaderViewController {
            topHeaderCoordinator = TopHeaderCoordinator(topHeaderNavigationController: topHeaderNavigationController, scrollView: tableView)
        }
        super.viewDidLoad()
        populateText()
        ThemeService.shared.addThemeable(themable: self)
        topHeaderCoordinator?.viewDidLoad()
    }
    
    func applyTheme(theme: Theme) {
        if ThemeService.shared.themeMode == "dark" {
            self.overrideUserInterfaceStyle = .dark
        } else if ThemeService.shared.themeMode == "light" {
            self.overrideUserInterfaceStyle = .light
        } else {
            self.overrideUserInterfaceStyle = .unspecified
        }
        tableView.backgroundColor = theme.windowBackgroundColor
        tableView.separatorColor = theme.tableviewSeparatorColor
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topHeaderCoordinator?.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible = true
        displayTutorialStep()
        topHeaderCoordinator?.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        topHeaderCoordinator?.viewWillDisappear()
        isVisible = false
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
