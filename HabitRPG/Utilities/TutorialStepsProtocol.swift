//
//  File.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.08.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import UIKit

protocol TutorialStepsProtocol: AnyObject {
    var tutorialIdentifier: String? { get set }
    var displayedTutorialStep: Bool { get set }
    var activeTutorial: TutorialStepView? { get set }
    
    func getDefinitionFor(tutorial: String) -> [String]
}

extension TutorialStepsProtocol where Self: UIViewController {
    func displayTutorialStep() {
        if activeTutorial != nil {
            return
        }
        if let identifier = tutorialIdentifier, !displayedTutorialStep {
            if UserManager.shared.shouldDisplayTutorialStep(key: identifier) {
                let defaults = UserDefaults.standard
                let key = "tutorial\(identifier)"
                if let nextAppearance = defaults.value(forKey: key) as? Date {
                    if nextAppearance > Date() {
                        return
                    }
                }
                displayedTutorialStep = true
                displayExplanationView(identifier: identifier, defaultsKey: key, type: "common")
            }
        }
    }
    
    private func displayExplanationView(identifier: String, defaultsKey: String, type: String) {
        let definition = getDefinitionFor(tutorial: identifier)
        activeTutorial = TutorialStepView()
        activeTutorial?.setTexts(list: definition)
        if let view = parent?.parent?.view {
            activeTutorial?.display(onView: view, animated: true)
        }
        activeTutorial?.dismissAction = { [weak self] in
            self?.activeTutorial = nil
            UserManager.shared.markTutorialAsSeen(type: type, key: identifier)
        }
    }
    
    func removeActiveView() {
        if let tutorialView = activeTutorial {
            tutorialView.removeFromSuperview()
            self.activeTutorial = nil
        }
    }
}
