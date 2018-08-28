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

class UserTopHeader: UIView {
    
    @IBOutlet weak var avatarView: AvatarView!
    
    @IBOutlet weak var healthLabel: LabeledProgressBar!
    @IBOutlet weak var experienceLabel: LabeledProgressBar!
    @IBOutlet weak var magicLabel: LabeledProgressBar!
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var buffIconView: UIImageView!
    
    @IBOutlet weak var classImageView: UIImageView!
    @IBOutlet weak var classImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var gemView: HRPGCurrencyCountView!
    @IBOutlet weak var goldView: HRPGCurrencyCountView!
    @IBOutlet weak var hourglassView: HRPGCurrencyCountView!
    
    private let repository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        healthLabel.color = UIColor.red100()
        healthLabel.icon = HabiticaIcons.imageOfHeartLightBg
        healthLabel.type = NSLocalizedString("Health", comment: "")
        
        experienceLabel.color = UIColor.yellow100()
        experienceLabel.icon = HabiticaIcons.imageOfExperience
        experienceLabel.type = NSLocalizedString("Experience", comment: "")
        
        magicLabel.color = UIColor.blue100()
        magicLabel.icon = HabiticaIcons.imageOfMagic
        magicLabel.type = NSLocalizedString("Mana", comment: "")
        
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
                        magicLabel.labelView.text = NSLocalizedString("Unlocks after selecting a class", comment: "")
                    } else {
                        magicLabel.labelView.text = NSLocalizedString("Unlocks at level 10", comment: "")
                    }
                }
            }
            
            let levelString = NSLocalizedString("Level", comment: "")
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
            usernameLabel.textColor = UIColor.gray10()
            levelLabel.textColor = UIColor.gray10()
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
