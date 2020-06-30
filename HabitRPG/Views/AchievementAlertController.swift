//
//  AchievementAlertController.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.06.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class AchievementAlertController: HabiticaAlertController {
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 6
        return view
    }()
    private let iconStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 16
        return view
    }()
    private let iconView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 52, height: 56))
        return view
    }()
    private let achievementTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let leftSparkleView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 42, height: 56))
        view.image = Asset.sparkleStarsLeft.image
        return view
    }()
    private let rightSparkleView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 42, height: 56))
        view.image = Asset.sparkleStarsRight.image
        return view
    }()
    
    private var isOnboarding = false
    private var isLastOnboardingAchievement = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init() {
        super.init()
        title = L10n.youGotAchievement
        setupView()
    }
    
    private func setupView() {
        contentView = stackView
        stackView.addArrangedSubview(iconStackView)
        iconStackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(achievementTitleLabel)
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        achievementTitleLabel.textColor = theme.primaryTextColor
    }
    
    func setNotification(notification: NotificationProtocol, isOnboarding: Bool, isLastOnboardingAchievement: Bool) {
        self.isOnboarding = isOnboarding
        self.isLastOnboardingAchievement = isLastOnboardingAchievement
        let key = notification.achievementKey ?? notification.type.rawValue
        switch key {
        case HabiticaNotificationType.achievementPartyUp.rawValue:
            configureAlert(title: L10n.partyUpTitle, text: L10n.partyUpDescription, iconName: "partyUp")
        case HabiticaNotificationType.achievementPartyOn.rawValue:
            configureAlert(title: L10n.partyOnTitle, text: L10n.partyOnDescription, iconName: "partyOn")
        case HabiticaNotificationType.achievementBeastMaster.rawValue:
            configureAlert(title: L10n.beastMasterTitle, text: L10n.beastMasterDescription, iconName: "rat")
        case HabiticaNotificationType.achievementMountMaster.rawValue:
            configureAlert(title: L10n.mountMasterTitle, text: L10n.mountMasterDescription, iconName: "wolf")
        case HabiticaNotificationType.achievementTriadBingo.rawValue:
            configureAlert(title: L10n.triadBingoTitle, text: L10n.triadBingoDescription, iconName: "triadbingo")
        case HabiticaNotificationType.achievementGuildJoined.rawValue:
            configureAlert(title: L10n.guildJoinedTitle, text: L10n.guildJoinedDescription, iconName: "guild")
        case HabiticaNotificationType.achievementChallengeJoined.rawValue:
            configureAlert(title: L10n.challengeJoinedTitle, text: L10n.challengeJoinedDescription, iconName: "challenge")
        case HabiticaNotificationType.achievementInvitedFriend.rawValue:
            configureAlert(title: L10n.invitedFriendTitle, text: L10n.invitedFriendDescription, iconName: "friends")
        case "createdTask":
            configureAlert(title: L10n.createdTaskTitle, text: L10n.createdTaskDescription, iconName: "createdTask")
        case "completedTask":
            configureAlert(title: L10n.completedTaskTitle, text: L10n.completedTaskDescription, iconName: "completedTask")
        case "hatchedPet":
            configureAlert(title: L10n.hatchedPetTitle, text: L10n.hatchedPetDescription, iconName: "hatchedPet")
        case "fedPet":
            configureAlert(title: L10n.fedPetTitle, text: L10n.fedPetDescription, iconName: "fedPet")
        case "purchasedEquipment":
            configureAlert(title: L10n.purchasedEquipmentTitle, text: L10n.purchasedEquipmentDescription, iconName: "purchasedEquipment")
        case HabiticaNotificationType.achievementOnboardingComplete.rawValue:
            title = L10n.onboardingCompleteAchievementTitle
            configureAlert(title: L10n.onboardingCompleteTitle, text: L10n.onboardingCompleteDescription, iconName: "onboardingComplete")
        default:
            break
        }
    }
    
    private func configureAlert(title: String, text: String, iconName: String) {
        if iconName == "onboardingComplete" {
            iconView.image = Asset.onboardingDoneArt.image
            iconView.contentMode = .center
            iconStackView.addHeightConstraint(height: 90)
        } else {
            iconStackView.insertArrangedSubview(leftSparkleView, at: 0)
            iconView.setImagewith(name: "achievement-\(iconName)2x")
            iconStackView.addArrangedSubview(rightSparkleView)
        }
        achievementTitleLabel.text = title
        if iconName == "onboardingComplete" {
            let attrString = NSMutableAttributedString(string: text)
            attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: ThemeService.shared.theme.primaryTextColor, range: NSRange(location: 0, length: attrString.length))
            attrString.addAttributesToSubstring(string: L10n.fiveAchievements, attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)
            ])
            attrString.addAttributesToSubstring(string: L10n.hundredGold, attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold),
                NSAttributedString.Key.foregroundColor: UIColor.yellow5
            ])
            descriptionLabel.attributedText = attrString
        } else {
            descriptionLabel.text = text
            descriptionLabel.textColor = ThemeService.shared.theme.ternaryTextColor
        }
        let titleSize = achievementTitleLabel.sizeThatFits(CGSize(width: 300, height: 600))
        achievementTitleLabel.addHeightConstraint(height: titleSize.height)
        let size = descriptionLabel.sizeThatFits(CGSize(width: 300, height: 600))
        descriptionLabel.addHeightConstraint(height: size.height)
        
        addAction(title: L10n.onwards, isMainAction: true)
        if isOnboarding {
            if !isLastOnboardingAchievement {
                addAction(title: L10n.viewOnboardingTasks) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        RouterHandler.shared.handle(urlString: "/user/onboarding")
                    }
                }
            }
        } else {
            if !isLastOnboardingAchievement {
                addAction(title: L10n.viewAchievements) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        RouterHandler.shared.handle(urlString: "/user/achievements")
                    }
                }
            }
        }

        stackView.setNeedsUpdateConstraints()
        stackView.setNeedsLayout()
        view.setNeedsLayout()
    }
}
