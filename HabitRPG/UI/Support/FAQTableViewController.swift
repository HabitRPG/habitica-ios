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
import MessageUI
import SwiftUIX

struct ContributorTierList: View {
    static let tiers = [
        ["name": "Tier 1 (Friend)", "tier": 1],
        ["name": "Tier 2 (Friend)", "tier": 2],
        ["name": "Tier 3 (Elite)", "tier": 3],
        ["name": "Tier 4 (Elite)", "tier": 4],
        ["name": "Tier 5 (Champion)", "tier": 5],
        ["name": "Tier 6 (Champion)", "tier": 6],
        ["name": "Tier 7 (Legendary)", "tier": 7],
        ["name": "Tier 8 (Staff)", "tier": 8]
    ]
    var body: some View {
        VStack(spacing: 6) {
            ForEach(enumerating: ContributorTierList.tiers) { tier in
                let number = tier["tier"] as? Int ?? 0
                HStack(spacing: 3) {
                    Text(tier["name"] as? String ?? "")
                        .foregroundStyle(Color(UIColor.contributorColor(forTier: number)))
                        .scaledFont(size: 16, weight: .semibold)
                    Image(uiImage: HabiticaIcons.imageOfContributorBadge(tier: number))
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .border(Color(UIColor.contributorColor(forTier: number).withAlphaComponent(0.2)), width: 2, cornerRadius: UIConstants.mediumCornerRadius)
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 22)
    }
}

class FAQViewController: BaseUIViewController, MFMailComposeViewControllerDelegate, UIScrollViewDelegate {
    
    private let searchBar = UISearchBar()
    
    private let dataSource = FAQTableViewDataSource()
    private var selectedIndex: Int?
    
    private let userRepository = UserRepository()
    private let contentRepository = ContentRepository()
    private let configRepository = ConfigRepository.shared
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var mainStackView: UIStackView!
    @IBOutlet private var mechanicsTitleLabel: UILabel!
    @IBOutlet private var mechanicsStackView: UIStackView!
    @IBOutlet private var commonQuestionsTitleLabel: UILabel!
    @IBOutlet weak var commonQuestionsBackground: UIView!
    @IBOutlet private var commonQuestionsStackView: SeparatedStackView!
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
    
    private lazy var bannerView: NPCBannerView = {
        return NPCBannerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 124))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.alternativeHeader = bannerView
        topHeaderCoordinator?.scrollView = scrollView
        bannerView.setSprites(identifier: "tavern")
        bannerView.setNPCName(identifier: "support")
        scrollView.delegate = self
        
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        moreQuestionsStackView.isLayoutMarginsRelativeArrangement = true
        moreQuestionsStackView.layoutMargins = UIEdgeInsets(top: 30, left: 22, bottom: 0, right: 22)
        commonQuestionsStackView.isLayoutMarginsRelativeArrangement = true
        commonQuestionsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        commonQuestionsStackView.separatorBetweenItems = true
        commonQuestionsStackView.separatorInsets = UIEdgeInsets(top: 0, left: 66, bottom: 0, right: 0)
        
        populateMechanics()
        disposable.inner.add(contentRepository.getFAQEntries().on(value: {[weak self] entries in
            self?.populateFAQ(questions: entries.value)
            }).start())
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start())
        
        moreQuestionsText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moreQuestionsTapped)))
        supportEmail = configRepository.string(variable: .supportEmail, defaultValue: "admin@habitica.com")
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        topHeaderCoordinator?.scrollViewDidScroll()
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.basics
        mechanicsTitleLabel.text = L10n.glossary
        commonQuestionsTitleLabel.text = L10n.commonQuestions
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
        bannerView.applyTheme(backgroundColor: theme.contentBackgroundColor)
    }
    
    private func populateMechanics() {
        mechanicsStackView.removeAllArrangedSubviews()
        FAQViewController.mechanics.forEach { entry in
            let stackView = CollapsibleStackView()
            stackView.titleView?.text = entry["title"] as? String
            stackView.titleView?.subtitle = entry["subtitle"] as? String
            stackView.titleView?.font = UIFontMetrics.default.scaledSystemFont(ofSize: 17, ofWeight: .semibold)
            stackView.titleColor = entry["color"] as? UIColor ?? ThemeService.shared.theme.primaryTextColor
            stackView.titleView?.subtitleFont = UIFontMetrics.default.scaledSystemFont(ofSize: 17)
            stackView.titleView?.icon = entry["icon"] as? UIImage
            stackView.titleView?.showCarret = false
            stackView.titleView?.insets = UIEdgeInsets(top: 20, left: 8, bottom: 20, right: 8)
            stackView.cornerRadius = UIConstants.largeCornerRadius
            stackView.showSeparators = false
            stackView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            let textView = MarkdownTextView()
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.setMarkdownString(entry["text"] as? String)
            textView.backgroundColor = .clear
            textView.textContainerInset = UIEdgeInsets(top: 4, left: 12, bottom: 16, right: 12)
            textView.font = UIFontMetrics.default.scaledSystemFont(ofSize: 14)
            textView.textColor = ThemeService.shared.theme.secondaryTextColor
            stackView.addArrangedSubview(textView)
            if let show = entry["showContributorTiers"] as? Bool, show == true {
                let contributorList = UIHostingView(rootView: ContributorTierList())
                stackView.addArrangedSubview(contributorList)
            }
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
            stackView.spacing = 22
            stackView.layoutMargins = UIEdgeInsets(top: 12, left: 26, bottom: 12, right: 26)
            let imageView = UIImageView(image: Asset.faqIcon.image)
            imageView.contentMode = .center
            imageView.addWidthConstraint(width: 9)
            stackView.addArrangedSubview(imageView)
            let title = UILabel()
            title.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15)
            title.text = question.question
            title.numberOfLines = 0
            title.textColor = ThemeService.shared.theme.primaryTextColor
            stackView.addArrangedSubview(title)
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

    private static var mechanics: [[String: Any]] {
        let isDark = ThemeService.shared.theme.isDark
        return [
            ["title": L10n.healthPoints, "subtitle": "HP", "icon": HabiticaIcons.imageOfHeartLarge, "text": L10n.healthDescription, "color": isDark ? UIColor.red500 : UIColor.red10],
            ["title": L10n.experiencePoints, "subtitle": "EXP", "icon": HabiticaIcons.imageOfExperienceReward, "text": L10n.experienceDescription, "color": isDark ? UIColor.yellow500 : UIColor.yellow5],
            ["title": L10n.manaPoints, "subtitle": "MP", "icon": HabiticaIcons.imageOfMagic, "text": L10n.manaDescription, "color": isDark ? UIColor.blue500 : UIColor.blue10],
            ["title": L10n.gold, "subtitle": L10n.currency, "icon": HabiticaIcons.imageOfGoldReward, "text": L10n.goldDescription, "color": isDark ? UIColor.orange500 : UIColor.orange10],
            ["title": L10n.gems, "subtitle": L10n.premiumCurrency, "icon": HabiticaIcons.imageOfGem, "text": L10n.gemsDescription, "color": isDark ? UIColor.green500 : UIColor.green10],
            ["title": L10n.mysticHourglasses, "subtitle": L10n.subscriberCurrency, "icon": HabiticaIcons.imageOfHourglass, "text": L10n.hourglassesDescription, "color": isDark ? UIColor.purple500 : UIColor.purple300],
            ["title": L10n.statAllocation, "subtitle": "STR, CON, INT, PER", "icon": HabiticaIcons.imageOfStats, "text": L10n.statDescription, "color": isDark ? UIColor.orange100 : UIColor.orange1],
            ["title": L10n.contributorTiers, "subtitle": L10n.habiticaHelpers, "icon": Asset.contributorsFaqIcon.image, "text": L10n.contributorTiersDescription, "color": isDark ? UIColor.teal500 : UIColor.teal10, "showContributorTiers": true]
        ]
    }
    
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
}
