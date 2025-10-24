//
//  FAQTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

// swiftlint:disable file_length

import UIKit
import Habitica_Models
import ReactiveSwift
import Down
import MessageUI

enum SearchableFAQItem {
    case collapsible(
        title: String,
        subtitle: String?,
        description: String,
        view: CollapsibleStackView,
        matchSnippet: String?
    )

    case navigable(
        article: FAQEntryProtocol,
        matchSnippet: String?
    )

    var displayTitle: String {
        switch self {
        case .collapsible(let title, _, _, _, _):
            return title
        case .navigable(let article, _):
            return article.question ?? ""
        }
    }

    var snippet: String? {
        switch self {
        case .collapsible(_, _, _, _, let snippet):
            return snippet
        case .navigable:
            return nil
        }
    }

    var collapsibleView: CollapsibleStackView? {
        switch self {
        case .collapsible(_, _, _, let view, _):
            return view
        case .navigable:
            return nil
        }
    }

    var article: FAQEntryProtocol? {
        switch self {
        case .collapsible:
            return nil
        case .navigable(let article, _):
            return article
        }
    }
}

// swiftlint:disable:next type_body_length
class FAQViewController: BaseUIViewController, MFMailComposeViewControllerDelegate {

    private let searchBar = UISearchBar()
    private let dataSource = FAQTableViewDataSource()
    var selectedIndex: Int?

    private let userRepository = UserRepository()
    private let contentRepository = ContentRepository()
    private let configRepository = ConfigRepository.shared
    private let disposable = ScopedDisposable(CompositeDisposable())

    var searchQuery: String = ""
    var searchDebounceTimer: Timer?
    var faqArticles: [FAQEntryProtocol] = []
    var searchResults: [SearchableFAQItem] = []
    var isSearchActive: Bool = false
    var searchResultsContainerView: UIView?

    @IBOutlet var mainStackView: UIStackView!
    @IBOutlet var mechanicsTitleLabel: UILabel!
    @IBOutlet var mechanicsStackView: UIStackView!
    @IBOutlet var commonQuestionsTitleLabel: UILabel!
    @IBOutlet var commonQuestionsBackground: UIView!
    @IBOutlet var commonQuestionsStackView: SeparatedStackView!
    @IBOutlet weak var moreQuestionsStackView: UIStackView!
    @IBOutlet weak var moreQuestionsTitle: UILabel!
    @IBOutlet weak var moreQuestionsText: MarkdownTextView!
    
    private let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"]
    private lazy var appVersionString: String = {
        return "\(versionString ?? "") (\(buildNumber ?? ""))"
    }()
    private var supportEmail = ""
    private var user: UserProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        topHeaderCoordinator?.followScrollView = false

        setupSearchBar()

        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        moreQuestionsStackView.isLayoutMarginsRelativeArrangement = true
        moreQuestionsStackView.layoutMargins = UIEdgeInsets(top: 30, left: 22, bottom: 0, right: 22)
        commonQuestionsStackView.isLayoutMarginsRelativeArrangement = true
        commonQuestionsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        commonQuestionsStackView.separatorBetweenItems = true
        commonQuestionsStackView.separatorInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        populateMechanics()
        disposable.inner.add(contentRepository.getFAQEntries().on(value: {[weak self] entries in
            self?.faqArticles = entries.value
            self?.populateFAQ(questions: entries.value)
        }).start())

        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start())

        moreQuestionsText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moreQuestionsTapped)))
        supportEmail = configRepository.string(variable: .supportEmail, defaultValue: "admin@habitica.com")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Re-run search if query exists to prevent duplicates when returning from detail screen
        if isSearchActive && !searchQuery.isEmpty {
            performSearch(query: searchQuery)
        }
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
            stackView.titleView?.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
            stackView.titleView?.subtitleFont = UIFontMetrics.default.scaledSystemFont(ofSize: 15)
            stackView.titleView?.icon = entry["icon"] as? UIImage
            stackView.titleView?.showCarret = false
            stackView.titleView?.insets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
            stackView.cornerRadius = 13
            stackView.showSeparators = false
            stackView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            let textView = MarkdownTextView()
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.setMarkdownString(entry["text"] as? String)
            textView.backgroundColor = .clear
            textView.textContainerInset = UIEdgeInsets(top: 4, left: 12, bottom: 16, right: 12)
            textView.font = UIFontMetrics.default.scaledSystemFont(ofSize: 13)
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
            title.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15)
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

    static let mechanics = [
        ["title": L10n.healthPoints, "subtitle": "HP", "icon": HabiticaIcons.imageOfHeartLarge, "text": L10n.healthDescription],
        ["title": L10n.experiencePoints, "subtitle": "EXP", "icon": HabiticaIcons.imageOfExperienceReward, "text": L10n.experienceDescription],
        ["title": L10n.manaPoints, "subtitle": "MP", "icon": HabiticaIcons.imageOfMagic, "text": L10n.manaDescription],
        ["title": L10n.gold, "subtitle": L10n.currency, "icon": HabiticaIcons.imageOfGoldReward, "text": L10n.goldDescription],
        ["title": L10n.gems, "subtitle": L10n.premiumCurrency, "icon": HabiticaIcons.imageOfGem, "text": L10n.gemsDescription],
        ["title": L10n.mysticHourglasses, "subtitle": L10n.premiumCurrency, "icon": HabiticaIcons.imageOfHourglass, "text": L10n.hourglassesDescription],
        ["title": L10n.statAllocation, "subtitle": "STR, CON, INT, PER", "icon": HabiticaIcons.imageOfStats, "text": L10n.statDescription]
    ]

    @objc
    private func moreQuestionsTapped() {
        if MFMailComposeViewController.canSendMail() {
            let composeViewController = MFMailComposeViewController(nibName: nil, bundle: nil)
            composeViewController.mailComposeDelegate = self
            composeViewController.setToRecipients([supportEmail])
            composeViewController.setSubject("[iOS] Question")
            composeViewController.setMessageBody(createDeviceInformationString(), isHTML: false)
            present(composeViewController, animated: true, completion: nil)
        } else {
            showNoEmailAlert()
        }
    }
    
    private func showNoEmailAlert() {
        let alert = HabiticaAlertController(title: L10n.About.noEmailTitle, message: L10n.About.noEmailMessage(supportEmail))
        alert.addCloseAction()
        alert.show()
    }
    
    private func createDeviceInformationString() -> String {
        var informationString = "Ask your question here!\n\n\n\n\n\n\n\n\n\n\n\n"
        informationString.append("The following lines help us answer your questions. Please do not delete or change them.\n")
        informationString.append("iOS Version: \(UIDevice.current.systemVersion)\n")
        informationString.append("Device: \(UIDevice.modelName)\n")
        informationString.append("App Version: \(appVersionString)\n")
        informationString.append("User ID: \(AuthenticationManager.shared.currentUserId ?? "")\n")
        if let user = self.user {
            if let level = user.stats?.level {
                informationString.append("Level: \(level)\n")
            }
            if let disableClass = user.preferences?.disableClasses {
                if disableClass {
                    informationString.append("Class: Disabled\n")
                } else {
                    if let habitClass = user.stats?.habitClassNice {
                        informationString.append("Class: \(habitClass)\n")
                    }
                }
            }
            if let sleep = user.preferences?.sleep {
                informationString.append("Is in Inn: \(sleep)\n")
            }
            informationString.append("Is subscribed: \(user.isSubscribed)\n")
            if let useCostume = user.preferences?.useCostume {
                informationString.append("Uses Costume: \(useCostume)\n")
            }
            if let cds = user.preferences?.dayStart {
                informationString.append("Custom Day Start: \(cds)\n")
            }
            if let consent = user.preferences?.analyticsConsent {
                informationString.append("Analytics Enabled: \(consent)\n")
            } else {
                informationString.append("Analytics Enabled: No Response\n")
            }
        }
        return informationString
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = L10n.searchQuestions
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear

        mainStackView.insertArrangedSubview(searchBar, at: 0)
    }

    func performSearch(query: String) {
        searchQuery = query

        if query.isEmpty {
            restoreOriginalLayout()
            return
        }

        searchResultsContainerView?.removeFromSuperview()
        searchResultsContainerView = nil

        isSearchActive = true
        searchResults = []

        populateMechanics()

        let lowercasedQuery = query.lowercased()

        for (index, mechanic) in FAQViewController.mechanics.enumerated() {
            let title = mechanic["title"] as? String ?? ""
            let subtitle = mechanic["subtitle"] as? String ?? ""
            let description = mechanic["text"] as? String ?? ""

            let titleMatch = title.lowercased().contains(lowercasedQuery)
            let subtitleMatch = subtitle.lowercased().contains(lowercasedQuery)
            let descriptionMatch = description.lowercased().contains(lowercasedQuery)

            if titleMatch || subtitleMatch || descriptionMatch {
                if index < mechanicsStackView.arrangedSubviews.count,
                   let collapsibleView = mechanicsStackView.arrangedSubviews[index] as? CollapsibleStackView {
                    let item = SearchableFAQItem.collapsible(
                        title: title,
                        subtitle: subtitle,
                        description: description,
                        view: collapsibleView,
                        matchSnippet: nil
                    )
                    searchResults.append(item)
                }
            }
        }

        for article in faqArticles {
            let question = article.question ?? ""
            let answer = article.answer

            let questionMatch = question.lowercased().contains(lowercasedQuery)
            let answerMatch = answer.lowercased().contains(lowercasedQuery)

            if questionMatch || answerMatch {
                let item = SearchableFAQItem.navigable(
                    article: article,
                    matchSnippet: nil
                )
                searchResults.append(item)
            }
        }

        displaySearchResults()
    }

    func displaySearchResults() {
        mechanicsTitleLabel.isHidden = true
        mechanicsStackView.isHidden = true
        commonQuestionsTitleLabel.isHidden = true
        commonQuestionsStackView.isHidden = true
        commonQuestionsBackground.isHidden = true
        moreQuestionsStackView.isHidden = true

        searchResultsContainerView?.removeFromSuperview()

        if searchResults.isEmpty {
            displayEmptyState()
            return
        }

        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.spacing = 8
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

        for (index, result) in searchResults.enumerated() {
            switch result {
            case .collapsible(_, _, _, let view, _):
                view.alpha = 0
                view.transform = CGAffineTransform(translationX: 0, y: 20)
                containerView.addArrangedSubview(view)

                UIView.animate(withDuration: 0.2, delay: Double(index) * 0.03, options: .curveEaseOut) {
                    view.alpha = 1
                    view.transform = .identity
                }

            case .navigable(let article, _):
                let questionView = createQuestionView(for: article)
                questionView.alpha = 0
                questionView.transform = CGAffineTransform(translationX: 0, y: 20)
                containerView.addArrangedSubview(questionView)

                UIView.animate(withDuration: 0.2, delay: Double(index) * 0.03, options: .curveEaseOut) {
                    questionView.alpha = 1
                    questionView.transform = .identity
                }
            }
        }

        mainStackView.insertArrangedSubview(containerView, at: 1)
        searchResultsContainerView = containerView
    }

    func createQuestionView(for article: FAQEntryProtocol) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 15)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15)
        title.text = article.question
        title.numberOfLines = 0
        title.textColor = ThemeService.shared.theme.primaryTextColor

        let imageView = UIImageView(image: Asset.caretRight.image)
        imageView.contentMode = .center
        imageView.addWidthConstraint(width: 9)

        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(imageView)

        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchResultQuestionTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true

        if let index = faqArticles.firstIndex(where: { $0.index == article.index }) {
            containerView.tag = index
        }

        return containerView
    }

    func displayEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = L10n.noMatchingQuestions
        emptyLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15)
        emptyLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0

        let containerView = UIView()
        containerView.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 60),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 20),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: 200)
        ])

        mainStackView.insertArrangedSubview(containerView, at: 1)
        searchResultsContainerView = containerView
    }

    func restoreOriginalLayout() {
        isSearchActive = false
        searchResults = []

        searchResultsContainerView?.removeFromSuperview()
        searchResultsContainerView = nil

        mechanicsTitleLabel.isHidden = false
        mechanicsStackView.isHidden = false
        commonQuestionsTitleLabel.isHidden = false
        commonQuestionsStackView.isHidden = false
        commonQuestionsBackground.isHidden = false
        moreQuestionsStackView.isHidden = false

        populateMechanics()
    }

    @objc
    func searchResultQuestionTapped(_ gesture: UITapGestureRecognizer) {
        if let containerView = gesture.view {
            selectedIndex = containerView.tag
            perform(segue: StoryboardSegue.Support.showFAQDetailSegue)
        }
    }
}

extension FAQViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDebounceTimer?.invalidate()

        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
            self?.performSearch(query: searchText)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
