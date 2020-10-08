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
import Down

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
    @IBOutlet private var commonQuestionsStackView: SeparatedStackView!
    @IBOutlet weak var moreQuestionsStackView: UIStackView!
    @IBOutlet weak var moreQuestionsTitle: UILabel!
    @IBOutlet weak var moreQuestionsText: MarkdownTextView!
    
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
        commonQuestionsStackView.separatorBetweenItems = true
        commonQuestionsStackView.separatorInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
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
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        moreQuestionsText.setMarkdownString(L10n.moreQuestionsText, attributes: [.paragraphStyle: paragraphStyle])
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        mechanicsTitleLabel.textColor = theme.quadTextColor
        commonQuestionsTitleLabel.textColor = theme.quadTextColor
        moreQuestionsTitle.textColor = theme.primaryTextColor
        moreQuestionsText.textColor = theme.ternaryTextColor
        commonQuestionsBackground.backgroundColor = theme.windowBackgroundColor
        populateMechanics()
    }
    
    private func populateMechanics() {
        mechanicsStackView.removeAllArrangedSubviews()
        FAQViewController.mechanics.forEach { entry in
            let stackView = CollapsibleStackView()
            stackView.titleView?.text = entry["title"] as? String
            stackView.titleView?.subtitle = entry["subtitle"] as? String
            stackView.titleView?.font = CustomFontMetrics.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
            stackView.titleView?.subtitleFont = CustomFontMetrics.scaledSystemFont(ofSize: 15)
            stackView.titleView?.icon = entry["icon"] as? UIImage
            stackView.titleView?.showCarret = false
            stackView.titleView?.insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            stackView.cornerRadius = 6
            stackView.showSeparators = false
            stackView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            let textView = MarkdownTextView()
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.setMarkdownString(entry["text"] as? String)
            textView.backgroundColor = .clear
            textView.textContainerInset = UIEdgeInsets(top: 4, left: 12, bottom: 16, right: 12)
            textView.font = CustomFontMetrics.scaledSystemFont(ofSize: 13)
            textView.textColor = ThemeService.shared.theme.secondaryTextColor
            stackView.addArrangedSubview(textView)
            mechanicsStackView.addArrangedSubview(stackView)
            stackView.isCollapsed = true
        }
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
        }
        commonQuestionsStackView.arrangedSubviews.last?.removeFromSuperview()
    }
    
    @objc
    private func questionTapped(_ source: UITapGestureRecognizer) {
        if let view = source.view {
            selectedIndex = (commonQuestionsStackView.arrangedSubviews.firstIndex(of: view) ?? 0)
            perform(segue: StoryboardSegue.Support.showFAQDetailSegue)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Support.showFAQDetailSegue.rawValue {
            let destination = segue.destination as? FAQDetailViewController
            destination?.index = selectedIndex ?? 0
        }
    }

    private static let mechanics = [
        ["title": L10n.healthPoints, "subtitle": "HP", "icon": HabiticaIcons.imageOfHeartLarge, "text": L10n.healthDescription],
        ["title": L10n.experiencePoints, "subtitle": "EXP", "icon": HabiticaIcons.imageOfExperienceReward, "text": L10n.experienceDescription],
        ["title": L10n.manaPoints, "subtitle": "MP", "icon": HabiticaIcons.imageOfMagic, "text": L10n.manaDescription],
        ["title": L10n.gold, "subtitle": L10n.currency, "icon": HabiticaIcons.imageOfGoldReward, "text": L10n.goldDescription],
        ["title": L10n.gems, "subtitle": L10n.premiumCurrency, "icon": HabiticaIcons.imageOfGem, "text": L10n.gemsDescription],
        ["title": L10n.mysticHourglasses, "subtitle": L10n.premiumCurrency, "icon": HabiticaIcons.imageOfHourglass, "text": L10n.hourglassesDescription],
        ["title": L10n.statAllocation, "subtitle": "STR, CON, INT, PER", "icon": HabiticaIcons.imageOfStats, "text": L10n.statDescription]
    ]
}
