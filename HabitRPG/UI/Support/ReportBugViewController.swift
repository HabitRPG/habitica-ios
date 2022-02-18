//
//  ReportBugViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import MessageUI
import Habitica_Models

class ReportBugViewController: BaseUIViewController, MFMailComposeViewControllerDelegate {
    private let configRepository = ConfigRepository.shared
    private let userRepository = UserRepository()
    
    private let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"]
    private lazy var appVersionString: String = {
        return "\(versionString ?? "") (\(buildNumber ?? ""))"
    }()
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var knownIssuesTitleLabel: UILabel!
    @IBOutlet weak var knownIssuesBackground: UIView!
    @IBOutlet weak var knownIssuesStackView: SeparatedStackView!
    @IBOutlet weak var commonFixesTitleLabel: UILabel!
    @IBOutlet weak var commonFixesStackView: UIStackView!
    @IBOutlet weak var clearCacheBackground: UIView!
    @IBOutlet weak var clearCacheTitleLabel: UILabel!
    @IBOutlet weak var clearCacheDescriptionLabel: UILabel!
    @IBOutlet weak var manualSyncBackground: UIView!
    @IBOutlet weak var manualSyncTitleLabel: UILabel!
    @IBOutlet weak var manualSyncDescriptionLabel: UILabel!
    @IBOutlet weak var updateAppBackground: UIView!
    @IBOutlet weak var updateAppTitleLabel: UILabel!
    @IBOutlet weak var updateAppDescriptionLabel: UILabel!
    @IBOutlet weak var moreHelpStackView: UIStackView!
    @IBOutlet weak var moreHelpTitleLabel: UILabel!
    @IBOutlet weak var moreHelpDescriptionLabel: UILabel!
    @IBOutlet weak var moreHelpButton: UIButton!
    
    private var supportEmail = ""
    private var user: UserProtocol?
    
    private var knownIssues: NSArray = []
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        topHeaderCoordinator?.followScrollView = false
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        moreHelpStackView.isLayoutMarginsRelativeArrangement = true
        moreHelpStackView.layoutMargins = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        knownIssuesStackView.isLayoutMarginsRelativeArrangement = true
        knownIssuesStackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        knownIssuesStackView.separatorBetweenItems = true
        knownIssuesStackView.separatorInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        supportEmail = configRepository.string(variable: .supportEmail, defaultValue: "admin@habitica.com")
        
        userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start()
        
        knownIssues = configRepository.array(variable: .knownIssues)
        populateKnownIssues()
    }
    
    override func populateText() {
        super.populateText()
        knownIssuesTitleLabel.text = L10n.knownIssues.uppercased()
        commonFixesTitleLabel.text = L10n.commonFixes.uppercased()
        moreHelpTitleLabel.text = L10n.moreHelpTitle
        moreHelpDescriptionLabel.text = L10n.moreHelpDescription
        moreHelpButton.setTitle(L10n.moreHelpButton, for: .normal)
        clearCacheTitleLabel.text = L10n.clearCacheTitle
        clearCacheDescriptionLabel.text = L10n.clearCacheDescription
        manualSyncTitleLabel.text = L10n.manualSyncTitle
        manualSyncDescriptionLabel.text = L10n.manualSyncDescription
        updateAppTitleLabel.text = L10n.updateAppTitle
        updateAppDescriptionLabel.text = L10n.updateAppDescription
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        knownIssuesTitleLabel.textColor = theme.quadTextColor
        commonFixesTitleLabel.textColor = theme.quadTextColor
        clearCacheBackground.backgroundColor = theme.windowBackgroundColor
        clearCacheTitleLabel.textColor = theme.primaryTextColor
        clearCacheDescriptionLabel.textColor = theme.ternaryTextColor
        manualSyncBackground.backgroundColor = theme.windowBackgroundColor
        manualSyncTitleLabel.textColor = theme.primaryTextColor
        manualSyncDescriptionLabel.textColor = theme.ternaryTextColor
        updateAppBackground.backgroundColor = theme.windowBackgroundColor
        updateAppTitleLabel.textColor = theme.primaryTextColor
        updateAppDescriptionLabel.textColor = theme.ternaryTextColor
        moreHelpTitleLabel.textColor = theme.primaryTextColor
        moreHelpDescriptionLabel.textColor = theme.ternaryTextColor
        moreHelpButton.backgroundColor = theme.fixedTintColor
        moreHelpButton.setTitleColor(theme.lightTextColor, for: .normal)
        knownIssuesBackground.backgroundColor = theme.windowBackgroundColor
    }
    
    private func populateKnownIssues() {
        knownIssuesStackView.removeAllArrangedSubviews()
        knownIssues.forEach { issue in
            guard let issueDict = issue as? NSDictionary else {
                return
            }
            let stackView = SeparatedStackView()
            stackView.axis = .horizontal
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.spacing = 8
            stackView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 15)
            let title = UILabel()
            title.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15)
            title.text = issueDict["title"] as? String
            title.numberOfLines = 0
            title.textColor = ThemeService.shared.theme.primaryTextColor
            let imageView = UIImageView(image: Asset.caretRight.image)
            imageView.contentMode = .center
            imageView.addWidthConstraint(width: 9)
            stackView.addArrangedSubview(title)
            stackView.addArrangedSubview(imageView)
            stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(knownIssueTapped)))
            knownIssuesStackView.addArrangedSubview(stackView)
        }
        knownIssuesStackView.arrangedSubviews.last?.removeFromSuperview()
    }
    
    private func sendEmail(subject: String) {
        if MFMailComposeViewController.canSendMail() {
            let composeViewController = MFMailComposeViewController(nibName: nil, bundle: nil)
            composeViewController.mailComposeDelegate = self
            composeViewController.setToRecipients([supportEmail])
            composeViewController.setSubject(subject)
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
        var informationString = "Please describe the bug you encountered:\n\n\n\n\n\n\n\n\n\n\n\n"
        informationString.append("The following lines help us find and squash the Bug you encountered. Please do not delete/change them.\n")
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
            if let useCostume = user.preferences?.useCostume {
                informationString.append("Uses Costume: \(useCostume)\n")
            }
            if let cds = user.preferences?.dayStart {
                informationString.append("Custom Day Start: \(cds)\n")
            }
        }
        return informationString
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportBugButtonTapped(_ sender: Any) {
        sendEmail(subject: "[iOS] Bugreport")
    }
    
    @objc
    private func knownIssueTapped(_ source: UITapGestureRecognizer) {
        if let view = source.view {
            selectedIndex = knownIssuesStackView.arrangedSubviews.firstIndex(of: view) ?? 0
            perform(segue: StoryboardSegue.Support.showKnownIssueDetailSegue)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Support.showKnownIssueDetailSegue.rawValue {
            let destination = segue.destination as? FAQDetailViewController
            guard let issue = knownIssues[selectedIndex] as? NSDictionary else {
                return
            }
            destination?.faqTitle = issue["title"] as? String
            destination?.faqText = issue["text"] as? String
        }
    }
}
