//
//  BaseHostingViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 14.06.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftUI

class BaseHostingViewController<Content: View>: UIHostingController<Content>, Themeable, TutorialStepsProtocol {
    var displayedTutorialStep: Bool = false
    
    var activeTutorial: TutorialStepView?
    
    func getDefinitionFor(tutorial: String) -> [String] {
        return []
    }
    
    lazy var topHeaderCoordinator: TopHeaderCoordinator? = {
        if let topHeaderNavigationController = navigationController as? TopHeaderViewController {
            return TopHeaderCoordinator(topHeaderNavigationController: topHeaderNavigationController)
        }
        return nil
    }()
    
    var tutorialIdentifier: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateText()
        ThemeService.shared.addThemeable(themable: self)
        topHeaderCoordinator?.viewDidLoad()
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
    
    func populateText() {
        
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.contentBackgroundColor
    }
}
