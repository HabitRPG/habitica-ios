//
//  FAQTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

class FAQViewController: BaseUIViewController {
    
    private let searchBar = UISearchBar()
    private let resetTutorialButton = UIButton()
    
    private let dataSource = FAQTableViewDataSource()
    private var selectedIndex: Int?
    
    private let userRepository = UserRepository()
    private let contentRepository = ContentRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    @IBOutlet private var mainStackView: UIStackView!
    @IBOutlet private var mechanicsTitleLabel: UILabel!
    @IBOutlet private var mechanicsStackView: UIStackView!
    @IBOutlet private var commonQuestionsTitleLabel: UILabel!
    @IBOutlet weak var commonQuestionsBackground: UIView!
    @IBOutlet private var commonQuestionsStackView: UIStackView!
    @IBOutlet weak var moreQuestionsStackView: UIStackView!
    @IBOutlet weak var moreQuestionsTitle: UILabel!
    @IBOutlet weak var moreQuestionsText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        topHeaderCoordinator?.followScrollView = false
        
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        moreQuestionsStackView.isLayoutMarginsRelativeArrangement = true
        moreQuestionsStackView.layoutMargins = UIEdgeInsets(top: 30, left: 22, bottom: 0, right: 22)
        commonQuestionsStackView.isLayoutMarginsRelativeArrangement = true
        commonQuestionsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        populateMechanics()
        contentRepository.getFAQEntries().on(value: {[weak self] entries in
            self?.populateFAQ(questions: entries.value)
            }).start()
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.basics
        mechanicsTitleLabel.text = L10n.gameMechanics.uppercased()
        commonQuestionsTitleLabel.text = L10n.commonQuestions.uppercased()
        moreQuestionsTitle.text = L10n.moreQuestionsTitle
        moreQuestionsText.text = L10n.moreQuestionsText
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        mechanicsTitleLabel.textColor = theme.quadTextColor
        commonQuestionsTitleLabel.textColor = theme.quadTextColor
        moreQuestionsTitle.textColor = theme.primaryTextColor
        moreQuestionsText.textColor = theme.ternaryTextColor
        commonQuestionsBackground.backgroundColor = theme.windowBackgroundColor
    }
    
    private func populateMechanics() {
        
    }
    
    private func populateFAQ(questions: [FAQEntryProtocol]) {
        commonQuestionsStackView.removeAllArrangedSubviews()
        questions.forEach { question in
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.spacing = 8
            stackView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 15)
            let title = UILabel()
            title.font = CustomFontMetrics.scaledSystemFont(ofSize: 15)
            title.text = question.question
            title.numberOfLines = 0
            title.textColor = ThemeService.shared.theme.primaryTextColor
            let imageView = UIImageView(image: Asset.caretRight.image)
            imageView.contentMode = .center
            imageView.addWidthConstraint(width: 9)
            stackView.addArrangedSubview(title)
            stackView.addArrangedSubview(imageView)
            stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(questionTapped)))
            commonQuestionsStackView.addArrangedSubview(stackView)
            let separator = UIView()
            separator.addHeightConstraint(height: 1)
            separator.backgroundColor = ThemeService.shared.theme.tableviewSeparatorColor
            commonQuestionsStackView.addArrangedSubview(separator)
        }
        commonQuestionsStackView.arrangedSubviews.last?.removeFromSuperview()
    }
    
    @objc
    private func questionTapped(_ source: UITapGestureRecognizer) {
        if let view = source.view {
            selectedIndex = (commonQuestionsStackView.arrangedSubviews.firstIndex(of: view) ?? 0) / 2
            perform(segue: StoryboardSegue.Support.showFAQDetailSegue)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Support.showFAQDetailSegue.rawValue {
            let destination = segue.destination as? FAQDetailViewController
            destination?.index = selectedIndex ?? 0
        }
    }
}
