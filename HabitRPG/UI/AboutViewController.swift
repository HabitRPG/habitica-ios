//
//  AboutViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.10.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Realm
import Habitica_Models
import MessageUI
import ReactiveSwift

class AboutViewController: BaseTableViewController, MFMailComposeViewControllerDelegate {

    private let configRepository = ConfigRepository.shared
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())

    private let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"]

    private lazy var appVersionString: String = {
        let testingLevel = configRepository.testingLevel
        if testingLevel != .production {
            return "\(versionString ?? "") (\(buildNumber ?? "")) \(testingLevel.rawValue)"
        } else {
            return "\(versionString ?? "") (\(buildNumber ?? ""))"
        }
    }()

    private var cardTitles: [String] {
        return [L10n.About.commonQuestionsTitle, L10n.About.bugsTitle, L10n.About.feedbackTitle]
    }
    private var cardBodies: [String] {
        return [L10n.About.commonQuestionsBody, L10n.About.bugsBody, L10n.About.feedbackBody]
    }
    private var cardButtonTitles: [String] {
        return [L10n.About.commonQuestionsButton, L10n.About.bugsButton, L10n.About.feedbackButton]
    }

    private var linkTitles: [String] {
        return [
            L10n.resetTips,
            L10n.About.habiticaOnWeb,
            L10n.About.rateOurApp,
            L10n.Titles.hallOfContributors,
            L10n.Titles.hallOfPatrons
        ]
    }

    private let scrollView = UIScrollView()
    private let backButton = UIButton(type: .custom)
    private let titleLabel = UILabel()

    private var cardContainers: [UIView] = []
    private var cardTitleLabels: [UILabel] = []
    private var cardBodyLabels: [UILabel] = []
    private var cardButtons: [UIButton] = []
    private var linkButtons: [UIButton] = []
    private var sparkleViews: [UIView] = []
    private let sparkleSpecs: [(x: CGFloat, yOffset: CGFloat, size: CGFloat)] = [
        (36, 28, 11), (345, 36, 9), (357, 66, 7), (55, 101, 12), (18, 133, 9), (338, 161, 11)
    ]

    private let waveImageView = UIImageView(image: UIImage(named: "menuWave"))
    private let purpleBand = UIView()
    private let versionLabel = UILabel()
    private let updateButton = UIButton(type: .custom)
    private let subtitleLabel = UILabel()
    private let socialImageView = UIImageView(image: UIImage(named: "menuSocialIcons"))
    private var socialButtons: [UIButton] = []
    private let privacyButton = UIButton(type: .custom)
    private let termsButton = UIButton(type: .custom)
    private let stretchView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        topHeaderCoordinator?.hideNavBar = true
        topHeaderCoordinator?.followScrollView = false

        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.contentInsetAdjustmentBehavior = .never

        setupUI()
        applyTheme(theme: ThemeService.shared.theme)
    }

    private func setupHeader() {
        backButton.layer.cornerRadius = 19
        backButton.clipsToBounds = true
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: chevronConfig)?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.accessibilityLabel = L10n.back
        tableView.addSubview(backButton)

        titleLabel.text = L10n.Menu.helpAbout
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .left
        scrollView.addSubview(titleLabel)
    }

    private func setupUI() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: tableView.frameLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: tableView.frameLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: tableView.frameLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: tableView.frameLayoutGuide.bottomAnchor)
        ])
        scrollView.insertSubview(stretchView, at: 0)
        stretchView.backgroundColor = .purple400
        stretchView.isHidden = true
        scrollView.delegate = self

        setupHeader()

        for index in 0..<cardTitles.count {
            let container = UIView()
            container.layer.cornerRadius = 16
            container.clipsToBounds = true
            scrollView.addSubview(container)

            let title = UILabel()
            title.text = cardTitles[index]
            title.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            title.textAlignment = .center
            container.addSubview(title)

            let body = UILabel()
            body.numberOfLines = 0
            body.textAlignment = .center
            container.addSubview(body)

            let button = UIButton(type: .custom)
            button.setTitle(cardButtonTitles[index], for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            button.backgroundColor = UIColor("#925CF3")
            button.layer.cornerRadius = 22
            button.clipsToBounds = true
            button.tag = index
            button.addTarget(self, action: #selector(cardButtonTapped(_:)), for: .touchUpInside)
            container.addSubview(button)

            cardContainers.append(container)
            cardTitleLabels.append(title)
            cardBodyLabels.append(body)
            cardButtons.append(button)
        }

        for index in 0..<linkTitles.count {
            let button = UIButton(type: .custom)
            button.setTitle(linkTitles[index], for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            button.tag = index
            button.addTarget(self, action: #selector(linkTapped(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            linkButtons.append(button)
        }

        for spec in sparkleSpecs {
            let sparkle = makeSparkle(size: spec.size)
            scrollView.addSubview(sparkle)
            sparkleViews.append(sparkle)
        }

        purpleBand.backgroundColor = UIColor("#925CF3")
        scrollView.addSubview(purpleBand)

        waveImageView.contentMode = .scaleToFill
        scrollView.addSubview(waveImageView)

        versionLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        versionLabel.textAlignment = .center
        versionLabel.textColor = .white
        scrollView.addSubview(versionLabel)

        subtitleLabel.text = L10n.About.openSourceNote
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = UIColor(white: 1, alpha: 0.9)
        scrollView.addSubview(subtitleLabel)

        socialImageView.contentMode = .scaleAspectFit
        scrollView.addSubview(socialImageView)
        for index in 0..<3 {
            let button = UIButton(type: .custom)
            button.tag = index
            button.addTarget(self, action: #selector(socialTapped(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            socialButtons.append(button)
        }

        privacyButton.setTitle(L10n.privacyPolicy, for: .normal)
        privacyButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        scrollView.addSubview(privacyButton)

        termsButton.setTitle(L10n.termsOfService, for: .normal)
        termsButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
        scrollView.addSubview(termsButton)

        versionLabel.text = L10n.About.versionNumber(appVersionString)
        setupUpdatePrompt()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        if contentHeight > 0 {
            let bottomSize = max(0, scrollView.contentOffset.y - (contentHeight - scrollView.frame.size.height))
            stretchView.frame = CGRect(x: 0, y: contentHeight, width: scrollView.frame.size.width, height: bottomSize)
            stretchView.isHidden = false
        }
        super.scrollViewDidScroll(scrollView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.bounds.width
        guard width > 0 else { return }
        let margin: CGFloat = 16
        let cardW = width - margin * 2

        let headerLeft = view.safeAreaInsets.left + 16
        let headerTop = max(view.safeAreaInsets.top, 20)
        backButton.frame = CGRect(x: headerLeft, y: headerTop, width: 38, height: 38)
        titleLabel.frame = CGRect(x: headerLeft + 50, y: headerTop, width: max(0, width - headerLeft - 50 - view.safeAreaInsets.right - 16), height: 38)

        for index in 0..<cardContainers.count {
            let top = 120 + CGFloat(index) * 172
            cardContainers[index].frame = CGRect(x: margin, y: top, width: cardW, height: 158)
            cardTitleLabels[index].frame = CGRect(x: 0, y: 16, width: cardW, height: 24)
            let bodyWidth = cardW - 40
            let bodyHeight = cardBodyLabels[index].sizeThatFits(CGSize(width: bodyWidth, height: .greatestFiniteMagnitude)).height
            cardBodyLabels[index].frame = CGRect(x: 20, y: 44, width: bodyWidth, height: bodyHeight)
            cardButtons[index].frame = CGRect(x: 16, y: 102, width: cardW - 32, height: 44)
        }

        let lastCardBottom = 120 + CGFloat(cardContainers.count - 1) * 172 + 158
        let linksTop = lastCardBottom + 32
        for index in 0..<linkButtons.count {
            linkButtons[index].frame = CGRect(x: 0, y: linksTop + CGFloat(index) * 43, width: width, height: 43)
        }
        let linksBottom = linksTop + CGFloat(linkButtons.count - 1) * 43

        for index in 0..<sparkleViews.count {
            let spec = sparkleSpecs[index]
            sparkleViews[index].frame = CGRect(x: spec.x, y: linksTop + spec.yOffset, width: spec.size, height: spec.size)
        }

        let waveTop = linksBottom + 42
        let waveHeight = (64 * width / 393).rounded()
        waveImageView.frame = CGRect(x: 0, y: waveTop, width: width, height: waveHeight)

        let purpleTop = waveTop + waveHeight - 4
        versionLabel.frame = CGRect(x: 24, y: purpleTop + 10, width: width - 48, height: 20)
        var footerY = versionLabel.frame.maxY + 4
        if !updateButton.isHidden {
            let updateHeight = updateButton.sizeThatFits(CGSize(width: width - 48, height: .greatestFiniteMagnitude)).height
            updateButton.frame = CGRect(x: 24, y: footerY, width: width - 48, height: max(updateHeight, 36))
            footerY = updateButton.frame.maxY + 8
        }
        subtitleLabel.frame = CGRect(x: (width - 261) / 2, y: footerY, width: 261, height: 34)

        let socialW: CGFloat = 214
        let socialH: CGFloat = 50
        socialImageView.frame = CGRect(x: (width - socialW) / 2, y: subtitleLabel.frame.maxY + 10, width: socialW, height: socialH)
        let iconCenters: [CGFloat] = [0.14, 0.5, 0.86]
        for index in 0..<socialButtons.count {
            let centerX = socialImageView.frame.minX + socialW * iconCenters[index]
            socialButtons[index].frame = CGRect(x: centerX - 25, y: socialImageView.frame.minY, width: 50, height: 50)
        }

        let policyY = socialImageView.frame.maxY + 26
        privacyButton.sizeToFit()
        termsButton.sizeToFit()
        let gap: CGFloat = 56
        let policyWidth = privacyButton.frame.width + gap + termsButton.frame.width
        var policyX = (width - policyWidth) / 2
        privacyButton.frame = CGRect(x: policyX, y: policyY, width: privacyButton.frame.width, height: 20)
        policyX += privacyButton.frame.width + gap
        termsButton.frame = CGRect(x: policyX, y: policyY, width: termsButton.frame.width, height: 20)

        let bottomInset = view.safeAreaInsets.bottom
        let contentBottom = privacyButton.frame.maxY + 24 + bottomInset
        purpleBand.frame = CGRect(x: 0, y: purpleTop, width: width, height: contentBottom - purpleTop)
        scrollView.contentSize = CGSize(width: width, height: contentBottom)
    }

    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        let screenBg = themed("#FFFFFF", "#1A181D", theme: theme)
        view.backgroundColor = screenBg
        tableView.backgroundColor = screenBg
        scrollView.backgroundColor = screenBg

        backButton.backgroundColor = themed("#EFEDF4", "#37343E", theme: theme)
        backButton.tintColor = themed("#4E4A57", "#FFFFFF", theme: theme)
        titleLabel.textColor = themed("#25242A", "#FFFFFF", theme: theme)

        let cardBg = themed("#F9F9F9", "#23202A", theme: theme)
        let cardTitleColor = themed("#25242A", "#FFFFFF", theme: theme)
        let cardBodyColor = themed("#686274", "#B7B3BF", theme: theme)
        for index in 0..<cardContainers.count {
            cardContainers[index].backgroundColor = cardBg
            cardTitleLabels[index].textColor = cardTitleColor
            cardBodyLabels[index].attributedText = bodyAttributed(cardBodies[index], color: cardBodyColor)
        }

        for button in linkButtons {
            button.setTitleColor(UIColor("#925CF3"), for: .normal)
        }

        purpleBand.backgroundColor = UIColor("#925CF3")
        versionLabel.textColor = .white
        updateButton.setTitleColor(.white, for: .normal)
        subtitleLabel.attributedText = subtitleAttributed(subtitleLabel.text ?? "", color: UIColor(white: 1, alpha: 0.9))
        privacyButton.setTitleColor(UIColor(white: 1, alpha: 0.8), for: .normal)
        termsButton.setTitleColor(UIColor(white: 1, alpha: 0.8), for: .normal)
    }

    override func populateText() {
        navigationItem.title = L10n.Titles.about
    }

    private func themed(_ light: String, _ dark: String, theme: Theme) -> UIColor {
        return theme.isDark ? UIColor(dark) : UIColor(light)
    }

    private func bodyAttributed(_ text: String, color: UIColor) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 3
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ])
    }

    private func subtitleAttributed(_ text: String, color: UIColor) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 2
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ])
    }

    private func makeSparkle(size: CGFloat) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        container.backgroundColor = .clear
        container.isUserInteractionEnabled = false
        let mid = size / 2
        let path = UIBezierPath()
        path.move(to: CGPoint(x: mid, y: 0))
        path.addLine(to: CGPoint(x: size * 0.6, y: size * 0.4))
        path.addLine(to: CGPoint(x: size, y: mid))
        path.addLine(to: CGPoint(x: size * 0.6, y: size * 0.6))
        path.addLine(to: CGPoint(x: mid, y: size))
        path.addLine(to: CGPoint(x: size * 0.4, y: size * 0.6))
        path.addLine(to: CGPoint(x: 0, y: mid))
        path.addLine(to: CGPoint(x: size * 0.4, y: size * 0.4))
        path.close()
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.fillColor = UIColor("#C4ADF6").cgColor
        container.layer.addSublayer(shape)
        return container
    }

    @objc
    private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc
    private func cardButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            let viewController = StoryboardScene.Support.faqViewController.instantiate()
            navigationController?.pushViewController(viewController, animated: true)
        case 1:
            handleBugReport()
        default:
            handleAppFeedback()
        }
    }

    @objc
    private func linkTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            resetTutorials()
        case 1:
            open(url: "https://habitica.com")
        case 2:
            open(url: configRepository.string(variable: .appstoreUrl) ?? "")
        case 3:
            perform(segue: StoryboardSegue.Main.hallOfContributorsSegue)
        default:
            perform(segue: StoryboardSegue.Main.hallOfPatronsSegue)
        }
    }

    @objc
    private func socialTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            open(url: "https://github.com/HabitRPG/habitica-ios")
        case 1:
            open(url: "https://bsky.app/profile/habitica.com")
        default:
            open(url: "https://instagram.com/\(configRepository.string(variable: .instagramUsername) ?? "")")
        }
    }

    private func setupUpdatePrompt() {
        updateButton.titleLabel?.numberOfLines = 0
        updateButton.titleLabel?.textAlignment = .center
        updateButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        updateButton.addTarget(self, action: #selector(updateTapped), for: .touchUpInside)
        updateButton.isHidden = !needsUpdate()
        if needsUpdate() {
            let newVersion = configRepository.string(variable: .lastVersionNumber) ?? ""
            updateButton.setTitle("\(L10n.About.newVersion(newVersion))\n\(L10n.About.whatsNew)", for: .normal)
        }
        scrollView.addSubview(updateButton)
    }

    private func needsUpdate() -> Bool {
        return (buildNumber as? NSString)?.intValue ?? 0 < configRepository.integer(variable: .lastVersionCode)
    }

    @objc
    private func updateTapped() {
        open(url: configRepository.string(variable: .appstoreUrl) ?? "")
    }

    @objc
    private func privacyTapped() {
        open(url: "https://habitica.com/static/privacy")
    }

    @objc
    private func termsTapped() {
        open(url: "https://habitica.com/static/terms")
    }

    private func resetTutorials() {
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

    private func open(url urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func handleAppFeedback() {
        open(url: configRepository.string(variable: .feedbackURL) ?? "")
    }

    private func handleBugReport() {
        let viewController = StoryboardScene.Support.reportBugViewController.instantiate()
        if let navController = navigationController {
            navController.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true)
        }
    }
}
