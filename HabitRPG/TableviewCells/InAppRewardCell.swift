//
//  InAppRewardCell.swift
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class InAppRewardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: NetworkImageView!
    @IBOutlet weak var currencyView: CurrencyCountView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var pinnedIndicatorView: UIImageView!
    @IBOutlet weak var checkmarkView: UIImageView!
    @IBOutlet weak var purchaseConfirmationView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var currencyBackgroundView: UIView!
    @IBOutlet weak var unlockLabel: UILabel!
    
    private var itemName = ""
    
    var itemCount = 0 {
        didSet {
            if itemCount > 0 {
                infoLabel.isHidden = false
                infoLabel.text = String(describing: itemCount)
                infoImageView.isHidden = true
            } else {
                infoImageView.isHidden = true
                infoLabel.isHidden = true
            }
        }
    }
    
    private var isLocked = false {
        didSet {
            if isLocked {
                if availableUntil != nil {
                    infoImageView.image = HabiticaIcons.imageOfItemIndicatorLocked(indicatorLocked: .purple300, lockColor: .white)
                } else {
                    if ThemeService.shared.theme.isDark {
                        infoImageView.image = HabiticaIcons.imageOfItemIndicatorLockedDark()
                    } else {
                        infoImageView.image = HabiticaIcons.imageOfItemIndicatorLocked()
                    }
                }
                infoImageView.isHidden = false
                infoLabel.isHidden = true
            } else if availableUntil == nil {
                infoImageView.isHidden = true
                infoLabel.isHidden = true
            }
        }
    }
    
    private var availableUntil: Date? {
        didSet {
            if availableUntil != nil {
                infoImageView.image = HabiticaIcons.imageOfItemIndicatorLimited()
                infoImageView.isHidden = false
                infoLabel.isHidden = true
            } else if isLocked == false {
                infoImageView.isHidden = true
                infoLabel.isHidden = true
            }
        }
    }
    
    public var imageName = "" {
        didSet {
            if imageName.isEmpty {
                return
            }
            if imageName.contains(" ") {
                imageView.setImagewith(name: imageName.components(separatedBy: " ")[1])
            } else {
                imageView.setImagewith(name: imageName)
            }
        }
    }
    
    public var isPinned = false {
        didSet {
            pinnedIndicatorView.isHidden = !isPinned
            if isPinned {
                pinnedIndicatorView.image = HabiticaIcons.imageOfPinnedItem.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    public var isChecked = false {
        didSet {
            checkmarkView.isHidden = !isChecked
            if isChecked {
                checkmarkView.image = Asset.checkmarkSmall.image.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    func configure(reward: InAppRewardProtocol, user: UserProtocol?) {
        var currency: Currency?
        let price = reward.value
        currencyView.amount = Int(reward.value)
        imageName = reward.iconName
        itemName = reward.text ?? ""
        if let currencyString = reward.currency, let thisCurrency = Currency(rawValue: currencyString) {
            currencyView.currency = thisCurrency
            currency = thisCurrency
        }
        
        if let currency = currency {
            setCanAfford(price, currency: currency, user: user, isLocked: reward.locked)
        } else {
            currencyView.state = .normal
        }
        isPinned = false
        
        if let lastPurchased = reward.lastPurchased, wasRecentlyPurchased(lastPurchased) {
            showPurchaseConfirmation()
        }
        
        if let date = reward.availableUntil() {
            availableUntil = date
            infoLabel.backgroundColor = .purple300
            infoLabel.textColor = .white
        } else {
            availableUntil = nil
            infoLabel.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            infoLabel.textColor = ThemeService.shared.theme.quadTextColor
        }
        applyAccessibility()
        
        if let lockedReason = reward.shortLockedReason, reward.locked {
            unlockLabel.text = lockedReason
            unlockLabel.isHidden = false
            currencyView.isHidden = true
        } else {
            unlockLabel.isHidden = true
            currencyView.isHidden = false
        }
        isLocked = reward.locked
        
        if reward.key == "gem" {
            if user?.isSubscribed != true {
                infoImageView.image = Asset.subBenefitIndicator.image
                infoImageView.isHidden = false
            } else {
                itemCount = user?.purchased?.subscriptionPlan?.gemsRemaining ?? 0
            }
        }
        
        let theme = ThemeService.shared.theme
        backgroundColor = theme.contentBackgroundColor
        containerView.backgroundColor = theme.windowBackgroundColor
        currencyBackgroundView.backgroundColor = theme.offsetBackgroundColor.withAlphaComponent(0.3)
        unlockLabel.textColor = theme.secondaryTextColor
        pinnedIndicatorView.tintColor = theme.dimmedTextColor
        checkmarkView.tintColor = theme.dimmedTextColor
    }
    
    func wasRecentlyPurchased(_ lastPurchase: Date) -> Bool {
        let now = Date().addingTimeInterval(-30)
        return now < lastPurchase
    }
    
    func showPurchaseConfirmation() {
        purchaseConfirmationView.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: .white, percentage: 1.0)
        UIView.animate(withDuration: 0.25, animations: {[weak self] in
            self?.purchaseConfirmationView.alpha = 1
        }, completion: {[weak self] (_) in
            UIView.animate(withDuration: 0.25, delay: 1.5, options: [], animations: {
                self?.purchaseConfirmationView.alpha = 0
            }, completion: nil)
        })
    }
    
    func setCanAfford(_ price: Float, currency: Currency, user: UserProtocol?, isLocked: Bool) {
        var canAfford = false

        if let user = user, currency == .gold {
            canAfford = price <= user.stats?.gold ?? 0
        } else {
            canAfford = true
        }
    
        if canAfford && !isLocked {
            currencyView.state = .normal
        } else {
            currencyView.state = .locked
        }
    }
    
    private func applyAccessibility() {
        shouldGroupAccessibilityChildren = true
        currencyView.isAccessibilityElement = false
        isAccessibilityElement = true
        accessibilityLabel = "\(itemName), \(currencyView.accessibilityLabel ?? "")"
    }
}

extension InAppRewardCell: PathTraceable {
    func visiblePath() -> UIBezierPath {
        let path = UIBezierPath(roundedRect: containerView.frame, cornerRadius: containerView.cornerRadius)
        if isLocked || availableUntil != nil {
            path.append(UIBezierPath(ovalIn: infoImageView.frame))
        }
        return path
    }
}
