//
//  UserTopHeader.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
import Habitica_Database
import PinLayout

class UserTopHeader: UIView, Themeable {
    
    @IBOutlet weak var avatarView: AvatarView!
    
    @IBOutlet weak var healthLabel: HRPGLabeledProgressBar!
    @IBOutlet weak var experienceLabel: HRPGLabeledProgressBar!
    @IBOutlet weak var magicLabel: HRPGLabeledProgressBar!
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var buffIconView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var classImageView: UIImageView!
    @IBOutlet weak var classImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var gemView: HRPGCurrencyCountView!
    @IBOutlet weak var goldView: HRPGCurrencyCountView!
    @IBOutlet weak var hourglassView: HRPGCurrencyCountView!
    
    private let repository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        healthLabel.icon = HabiticaIcons.imageOfHeartLightBg
        healthLabel.type = L10n.health
        
        experienceLabel.icon = HabiticaIcons.imageOfExperience
        experienceLabel.type = L10n.experience
        
        magicLabel.icon = HabiticaIcons.imageOfMagic
        magicLabel.type = L10n.mana
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            healthLabel.fontSize = 13
            experienceLabel.fontSize = 13
            magicLabel.fontSize = 13
        } else {
            healthLabel.fontSize = 11
            experienceLabel.fontSize = 11
            magicLabel.fontSize = 11
        }
        
        buffIconView.image = HabiticaIcons.imageOfBuffIcon
        
        goldView.currency = .gold
        gemView.currency = .gem
        hourglassView.currency = .hourglass
        
        gemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showGemView)))
        
        usernameLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 16)
        levelLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 11)
        
        disposable.inner.add(repository.getUser().on(value: {[weak self] user in
            self?.set(user: user)
        }).start())
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        backgroundColor = theme.contentBackgroundColor
        theme.applyBackgroundColor(views: [
            bottomView,
            classImageView,
            usernameLabel,
            levelLabel,
            hourglassView,
            gemView,
            goldView
            ], color: theme.contentBackgroundColorDimmed)
        healthLabel.textColor = theme.primaryTextColor
        healthLabel.backgroundColor = theme.contentBackgroundColor
        healthLabel.progressBar.barBackgroundColor = theme.contentBackgroundColorDimmed
        experienceLabel.textColor = theme.primaryTextColor
        experienceLabel.backgroundColor = theme.contentBackgroundColor
        experienceLabel.progressBar.barBackgroundColor = theme.contentBackgroundColorDimmed
        magicLabel.textColor = theme.primaryTextColor
        magicLabel.backgroundColor = theme.contentBackgroundColor
        magicLabel.progressBar.barBackgroundColor = theme.contentBackgroundColorDimmed
        
        if theme.isDark {
            healthLabel.color = UIColor.red50()
            experienceLabel.color = UIColor.yellow50()
            magicLabel.color = UIColor.blue50()
        } else {
            healthLabel.color = UIColor.red100()
            experienceLabel.color = UIColor.yellow100()
            magicLabel.color = UIColor.blue100()
        }
    }
    
    private func set(user: UserProtocol) {
        if !user.isValid {
            return
        }
        avatarView.avatar = AvatarViewModel(avatar: user)
        if let stats = user.stats {
            healthLabel.value = NSNumber(value: stats.health)
            if stats.maxHealth > 0 {
                healthLabel.maxValue = NSNumber(value: stats.maxHealth)
            }
            experienceLabel.value = NSNumber(value: stats.experience)
            if stats.toNextLevel > 0 {
                experienceLabel.maxValue = NSNumber(value: stats.toNextLevel)
            }
            
            if stats.level >= 10 && user.preferences?.disableClasses != true {
                magicLabel.value = NSNumber(value: stats.mana)
                if stats.maxMana > 0 {
                    magicLabel.maxValue = NSNumber(value: stats.maxMana)
                }
                magicLabel.isActive = true
                magicLabel.isHidden = false
            } else {
                if user.preferences?.disableClasses == true && user.flags?.classSelected != false {
                    magicLabel.isHidden = true
                } else {
                    magicLabel.isHidden = false
                    magicLabel.isActive = false
                    magicLabel.value = NSNumber(value: 0)
                    if stats.level >= 10 {
                        magicLabel.labelView.text = L10n.unlocksSelectingClass
                    } else {
                        magicLabel.labelView.text = L10n.unlocksLevelTen
                    }
                }
            }
            
            let levelString = L10n.level
            if user.preferences?.disableClasses != true && stats.level >= 10 {
                levelLabel.text = "\(levelString) \(stats.level) \(stats.habitClassNice?.capitalized ?? "")"
                switch stats.habitClass ?? "" {
                case "warrior":
                    classImageView.image = HabiticaIcons.imageOfWarriorLightBg
                case "wizard":
                    classImageView.image = HabiticaIcons.imageOfMageLightBg
                case "healer":
                    classImageView.image = HabiticaIcons.imageOfHealerLightBg
                case "rogue":
                    classImageView.image = HabiticaIcons.imageOfRogueLightBg
                default:
                    classImageView.image = nil
                }
                classImageViewWidthConstraint.constant = 36
            } else {
                levelLabel.text = "\(levelString) \(stats.level)"
                classImageView.image = nil
                classImageViewWidthConstraint.constant = 0
            }
            
            goldView.amount = Int(stats.gold)
            
            buffIconView.isHidden = stats.buffs?.isBuffed != true
        }
        usernameLabel.text = user.profile?.name
        if let contributor = user.contributor, contributor.level > 0 {
            usernameLabel.textColor = contributor.color
            levelLabel.textColor = contributor.color
        } else {
            usernameLabel.textColor = ThemeService.shared.theme.primaryTextColor
            levelLabel.textColor = ThemeService.shared.theme.primaryTextColor
        }
        gemView.amount = user.gemCount
        
        if let hourglasses = user.purchased?.subscriptionPlan?.consecutive?.hourglasses {
            hourglassView.isHidden = !(hourglasses > 0 || user.isSubscribed)
            hourglassView.amount = hourglasses
        } else {
            hourglassView.isHidden = true
        }
        
        setNeedsLayout()
    }
 
    @objc
    private func showGemView() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let levelLabelSize = levelLabel.sizeThatFits(levelLabel.bounds.size)
        buffIconView.pin.size(15).start(levelLabelSize.width + 6).bottom((levelLabelSize.height - 15)/2)
    }
}
