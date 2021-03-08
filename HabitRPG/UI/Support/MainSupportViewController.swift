//
//  MainSupportViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Habitica_Models

class MainSupportViewController: BaseUIViewController {
    private let configRepository = ConfigRepository()
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var questionsContainer: UIView!
    @IBOutlet weak var questionsTitleLabel: UILabel!
    @IBOutlet weak var questionsDescriptionLabel: UILabel!
    @IBOutlet weak var questionsButton: UIButton!
    @IBOutlet weak var bugContainer: UIView!
    @IBOutlet weak var bugTitle: UILabel!
    @IBOutlet weak var bugDescription: UILabel!
    @IBOutlet weak var bugButton: UIButton!
    @IBOutlet weak var suggestionsContainer: UIView!
    @IBOutlet weak var suggestionsTitle: UILabel!
    @IBOutlet weak var suggestionsDescription: UILabel!
    @IBOutlet weak var suggestionsButton: UIButton!
    @IBOutlet weak var resetTutorialContainer: UIView!
    @IBOutlet weak var resetTutorialButton: UIButton!
    
    override func viewDidLoad() {
        topHeaderCoordinator?.hideHeader = true
        super.viewDidLoad()
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func populateText() {
        navigationItem.title = L10n.Menu.support
        questionsTitleLabel.text = L10n.Support.questionsTitle
        questionsDescriptionLabel.text = L10n.Support.questionsDescription
        questionsButton.setTitle(L10n.Support.questionsButton, for: .normal)
        bugTitle.text = L10n.Support.bugFixesTitle
        bugDescription.text = L10n.Support.bugFixesDescription
        bugButton.setTitle(L10n.Support.bugFixesButton, for: .normal)
        suggestionsTitle.text = L10n.Support.suggestionsTitle
        suggestionsDescription.text = L10n.Support.suggestionsDescription
        suggestionsButton.setTitle(L10n.Support.suggestionsButton, for: .normal)
        
        resetTutorialButton.setTitle(L10n.resetTips, for: .normal)
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        let buttonTintColor = theme.fixedTintColor
        questionsContainer.backgroundColor = theme.windowBackgroundColor
        questionsTitleLabel.textColor = theme.primaryTextColor
        questionsDescriptionLabel.textColor = theme.ternaryTextColor
        questionsButton.backgroundColor = buttonTintColor
        
        bugContainer.backgroundColor = theme.windowBackgroundColor
        bugTitle.textColor = theme.primaryTextColor
        bugDescription.textColor = theme.ternaryTextColor
        bugButton.backgroundColor = buttonTintColor
        
        suggestionsContainer.backgroundColor = theme.windowBackgroundColor
        suggestionsTitle.textColor = theme.primaryTextColor
        suggestionsDescription.textColor = theme.ternaryTextColor
        suggestionsButton.backgroundColor = buttonTintColor
        
        resetTutorialContainer.backgroundColor = theme.windowBackgroundColor
        resetTutorialButton.backgroundColor = theme.offsetBackgroundColor
        resetTutorialButton.setTitleColor(theme.primaryTextColor, for: .normal)
    }
    
    @IBAction func suggestionButtonTapped(_ sender: Any) {
        if let url = URL(string: configRepository.string(variable: .feedbackURL) ?? "") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func resetTutorialButtonTapped(_ sender: Any) {
        disposable.inner.add(userRepository.getUser().take(first: 1)
            .map({ (user) -> [TutorialStepProtocol]? in
                return user.flags?.tutorials
            })
            .skipNil()
            .map({ (steps) -> [String: Bool] in
                var stepDict = [String: Bool]()
                steps.forEach({ (step) in
                    stepDict["flags.tutorial.\(step.type ?? "").\(step.key ?? "")"] = false
                })
                return stepDict
            })
            .flatMap(.latest, {[weak self] (updateDict) in
                return self?.userRepository.updateUser(updateDict) ?? Signal.empty
            }).start())
    }
}
