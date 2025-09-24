//
//  UserTopHeader.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import Habitica_Database
import PinLayout
import SwiftUI

class UserTopHeader: UIView, Themeable {
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var avatarView: AvatarView!
    
    @IBOutlet weak var healthLabel: LabeledProgressBar!
    @IBOutlet weak var experienceLabel: LabeledProgressBar!
    @IBOutlet weak var magicLabel: LabeledProgressBar!
    
    @IBOutlet weak var levelStackview: UIStackView!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var classImageView: UIImageView!
    
    @IBOutlet weak var currencyStackView: StackView!
    @IBOutlet weak var gemView: CurrencyCountView!
    @IBOutlet weak var goldView: CurrencyCountView!
    @IBOutlet weak var hourglassView: CurrencyCountView!
    
    @IBOutlet weak var healthLabelAvatarSpacing: NSLayoutConstraint!
    @IBOutlet weak var experienceLabelAvatarSpacing: NSLayoutConstraint!
    @IBOutlet weak var magicLabelAvatarSpacing: NSLayoutConstraint!
    
    @IBOutlet weak var avatarLeadingSpacing: NSLayoutConstraint!
    
    private var user: UserProtocol?
    
    private var contributorTier: Int = 0 {
        didSet {
        }
    }
    
    private var displayName = ""
    private var userID = ""
    
    private let repository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        healthLabel.icon = HabiticaIcons.imageOfHeartLightBg
        experienceLabel.icon = HabiticaIcons.imageOfExperience
        magicLabel.icon = HabiticaIcons.imageOfMagic
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            healthLabel.fontSize = 14
            experienceLabel.fontSize = 14
            magicLabel.fontSize = 14
        } else {
            healthLabel.fontSize = 12
            experienceLabel.fontSize = 12
            magicLabel.fontSize = 12
        }
        
        configureAccessibilitySizing()
                
        goldView.currency = .gold
        gemView.currency = .gem
        hourglassView.currency = .hourglass
        
        avatarButton.menu = UIMenu(children: [
            UIAction(title: L10n.openProfile, image: UIImage(systemName: "person.crop.circle")) { _ in
                RouterHandler.shared.handle(urlString: "/profile/" + self.userID)
            },
            UIAction(title: L10n.Menu.customizeAvatar, image: UIImage(systemName: "theatermask.and.paintbrush")) { _ in
                RouterHandler.shared.handle(urlString: "/user/avatar")
            },
            UIAction(title: L10n.Equipment.equipment.localizedCapitalized, image: UIImage(systemName: "shirt")) { _ in
                RouterHandler.shared.handle(urlString: "/user/equipment")
            },
            UIAction(title: L10n.shareAvatar, image: UIImage(systemName: "square.and.arrow.up")) { _ in
                if let user = self.user {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        SharingManager.share(avatar: user)
                    }
                }
            }
        ])
        avatarView.isUserInteractionEnabled = true
        avatarButton.showsMenuAsPrimaryAction = true

        gemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showGemView)))
        
        levelLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .bold)
        hourglassView.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .bold)
        gemView.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .bold)
        goldView.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .bold)
        
        healthLabel.type = "HP"
        experienceLabel.type = "EXP"
        magicLabel.type = "MP"
        
        healthLabel.progressBar.showGradient = true
        healthLabel.progressBar.gStartColor = UIColor("#F74E52")
        healthLabel.progressBar.gEndColor = UIColor("#FF976A")
        experienceLabel.progressBar.showGradient = true
        experienceLabel.progressBar.gStartColor = UIColor("#FF944C")
        experienceLabel.progressBar.gEndColor = UIColor("#FFD76F")
        magicLabel.progressBar.showGradient = true
        magicLabel.progressBar.gStartColor = UIColor("#46A7D9")
        magicLabel.progressBar.gEndColor = UIColor("#5ADEEA")
        
        disposable.inner.add(repository.getUser().on(value: {[weak self] user in
            self?.set(user: user)
        }).start())
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        NotificationCenter.default.addObserver(self, selector: #selector(preferredContentSizeChanged(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    override func removeFromSuperview() {
        NotificationCenter.default.removeObserver(self)
        super.removeFromSuperview()
    }
    
    @objc
    func preferredContentSizeChanged(_ notification: Notification) {
        configureAccessibilitySizing()
        
        goldView.invalidateIntrinsicContentSize()
        gemView.invalidateIntrinsicContentSize()
        hourglassView.invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
    
    private func configureAccessibilitySizing() {
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory && healthLabelAvatarSpacing.constant != 10 {
            healthLabelAvatarSpacing.constant = 8
            experienceLabelAvatarSpacing.constant = 8
            magicLabelAvatarSpacing.constant = 8
        } else if !traitCollection.preferredContentSizeCategory.isAccessibilityCategory && healthLabelAvatarSpacing.constant != 25 {
            healthLabelAvatarSpacing.constant = 13
            experienceLabelAvatarSpacing.constant = 13
            magicLabelAvatarSpacing.constant = 13
        }
    }
    
    func applyTheme(theme: Theme) {
        avatarView.borderColor = theme.contentBackgroundColor
        healthLabel.textColor = theme.isDark ? UIColor.maroon500 : UIColor.maroon100
        healthLabel.backgroundColor = theme.contentBackgroundColor
        healthLabel.progressBar.barBackgroundColor = theme.contentBackgroundColorDimmed
        experienceLabel.textColor = theme.isDark ? UIColor.yellow500 : UIColor.yellow1
        experienceLabel.backgroundColor = theme.contentBackgroundColor
        experienceLabel.progressBar.barBackgroundColor = theme.contentBackgroundColorDimmed
        magicLabel.textColor = theme.isDark ? UIColor.blue500 : UIColor.blue10
        magicLabel.backgroundColor = theme.contentBackgroundColor
        magicLabel.progressBar.barBackgroundColor = theme.contentBackgroundColorDimmed
        
        if theme.isDark {
            healthLabel.color = UIColor.red50.withAlphaComponent(0.75)
            experienceLabel.color = UIColor.yellow50.withAlphaComponent(0.75)
            magicLabel.color = UIColor.blue50.withAlphaComponent(0.75)
            healthLabel.iconView.alpha = 0.8
            experienceLabel.iconView.alpha = 0.8
            magicLabel.iconView.alpha = 0.8
            classImageView.alpha = 0.8
        } else {
            healthLabel.color = UIColor.red100
            experienceLabel.color = UIColor.yellow100
            magicLabel.color = UIColor.blue100
            healthLabel.iconView.alpha = 1.0
            experienceLabel.iconView.alpha = 1.0
            magicLabel.iconView.alpha = 1.0
            classImageView.alpha = 1.0
        }
        currencyStackView.backgroundColor = theme.windowBackgroundColor
        currencyStackView.cornerRadius = 50
        levelStackview.cornerRadius = 20
        goldView.updateStateValues()
        gemView.updateStateValues()
        hourglassView.updateStateValues()
    }
    
    private func set(user: UserProtocol) {
        if !user.isValid {
            return
        }
        self.user = user
        userID = user.id ?? ""
        displayName = user.profile?.name ?? ""
        avatarView.avatar = AvatarViewModel(avatar: user)
        if let stats = user.stats {
            healthLabel.value = stats.health
            if stats.maxHealth > 0 {
                healthLabel.maxValue = stats.maxHealth
            }
            experienceLabel.value = stats.experience
            if stats.toNextLevel > 0 {
                experienceLabel.maxValue = stats.toNextLevel
            }
            
            configureMagicBar(user: user)
            
            let levelString = L10n.level
            configureClassDisplay(user: user)
            goldView.amount = Int(stats.gold)
        }
        contributorTier = user.contributor?.level ?? 0
        gemView.amount = user.gemCount
        
        if let hourglasses = user.purchased?.subscriptionPlan?.consecutive?.hourglasses {
            hourglassView.isHidden = !(hourglasses > 0 || user.isSubscribed)
            hourglassView.amount = hourglasses
        } else {
            hourglassView.isHidden = true
        }
        
        setNeedsLayout()
    }
 
    private func configureMagicBar(user: UserProtocol) {
        guard let stats = user.stats else {
            return
        }
        if stats.level >= 10 && user.preferences?.disableClasses != true {
            magicLabel.value = stats.mana
            if stats.maxMana > 0 {
                magicLabel.maxValue = stats.maxMana
            }
            magicLabel.isActive = true
            magicLabel.isHidden = false
        } else {
            if user.preferences?.disableClasses == true && user.flags?.classSelected != false {
                magicLabel.isHidden = true
            } else {
                magicLabel.isHidden = false
                magicLabel.isActive = false
                magicLabel.value = 0
                if stats.level >= 10 {
                    magicLabel.labelView.text = L10n.unlocksSelectingClass
                } else {
                    magicLabel.labelView.text = L10n.unlocksLevelTen
                }
            }
        }
    }
    
    private func configureClassDisplay(user: UserProtocol) {
        levelLabel.text = "Lvl \(user.stats?.level ?? 0)"
        if user.preferences?.disableClasses != true && (user.stats?.level ?? 0) >= 10 {
            switch user.stats?.habitClass ?? "" {
            case "warrior":
                classImageView.image = HabiticaIcons.imageOfWarriorLightBg
                levelStackview.backgroundColor = .red500.withAlphaComponent(0.3)
                if ThemeService.shared.theme.isDark {
                    levelLabel.textColor = .red500
                } else {
                    levelLabel.textColor = .red1
                }
            case "wizard":
                classImageView.image = HabiticaIcons.imageOfMageLightBg
                levelStackview.backgroundColor = .blue500.withAlphaComponent(0.3)
                if ThemeService.shared.theme.isDark {
                    levelLabel.textColor = .blue500
                } else {
                    levelLabel.textColor = .blue1
                }
            case "healer":
                classImageView.image = HabiticaIcons.imageOfHealerLightBg
                levelStackview.backgroundColor = .yellow500.withAlphaComponent(0.3)
                if ThemeService.shared.theme.isDark {
                    levelLabel.textColor = .yellow500
                } else {
                    levelLabel.textColor = .yellow1
                }
            case "rogue":
                classImageView.image = HabiticaIcons.imageOfRogueLightBg
                levelStackview.backgroundColor = .purple500.withAlphaComponent(0.3)
                if ThemeService.shared.theme.isDark {
                    levelLabel.textColor = .purple500
                } else {
                    levelLabel.textColor = .purple300
                }
            default:
                classImageView.image = nil
            }
            classImageView.isHidden = false
        } else {
            classImageView.image = nil
            classImageView.isHidden = true
            levelStackview.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        }
    }
    
    @objc
    private func showGemView() {
        
    }
}

extension UIView {
    func getImageFromCurrentContext(bounds: CGRect? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds?.size ?? self.bounds.size, false, 0.0)
        self.drawHierarchy(in: bounds ?? self.bounds, afterScreenUpdates: true)

        guard let currentImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        UIGraphicsEndImageContext()

        return currentImage
    }
}
