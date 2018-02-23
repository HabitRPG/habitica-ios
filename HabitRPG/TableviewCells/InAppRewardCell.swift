//
//  InAppRewardCell.swift
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class InAppRewardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var currencyView: HRPGCurrencyCountView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var pinnedIndicatorView: UIImageView!
    @IBOutlet weak var purchaseConfirmationView: UIImageView!
    
    private var itemName = ""
    
    var itemsLeft = 0 {
        didSet {
            if itemsLeft > 0 {
                infoImageView.image = HabiticaIcons.imageOfItemIndicatorNumber
                infoImageView.isHidden = false
                infoLabel.isHidden = false
                infoLabel.text = String(describing: itemsLeft)
            } else {
                infoImageView.isHidden = true
                infoLabel.isHidden = true
            }
        }
    }
    
    private var isLocked = false {
        didSet {
            if isLocked {
                infoImageView.image = HabiticaIcons.imageOfItemIndicatorLocked
                infoImageView.isHidden = false
                infoLabel.isHidden = true
            } else {
                infoImageView.isHidden = true
                infoLabel.isHidden = true
            }
        }
    }
    
    private var availableUntil: Date? = nil {
        didSet {
            if availableUntil != nil {
                infoImageView.image = HabiticaIcons.imageOfItemIndicatorLimited
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
            if imageName.count == 0 {
                return
            }
            if imageName.contains(" ") {
                HRPGManager.shared().setImage(imageName.components(separatedBy: " ")[1], withFormat: "png", on: imageView)
            } else {
                HRPGManager.shared().setImage(imageName, withFormat: "png", on: imageView)
            }
        }
    }
    
    public var isPinned = false {
        didSet {
            pinnedIndicatorView.isHidden = !isPinned
            if isPinned {
                pinnedIndicatorView.image = HabiticaIcons.imageOfPinnedItem
            }
        }
    }
    
    func configure(reward: InAppReward) {
        var currency: Currency?
        let price = reward.value?.floatValue ?? 0
        currencyView.amount = reward.value?.intValue ?? 0
        imageName = reward.imageName ?? ""
        itemName = reward.text ?? ""
        if let currencyString = reward.currency, let thisCurrency = Currency(rawValue: currencyString) {
            currencyView.currency = thisCurrency
            currency = thisCurrency
        }
        isLocked = reward.locked?.boolValue ?? false
        
        if let currency = currency {
            setCanAfford(price, currency: currency)
        }
        isPinned = false
        
        if let lastPurchased = reward.lastPurchased, wasRecentlyPurchased(lastPurchased) {
            showPurchaseConfirmation()
        }
        availableUntil = reward.availableUntil
        applyAccessibility()
    }
    
    func configure(item: ShopItem) {
        currencyView.amount = item.value?.intValue ?? 0
        imageName = item.imageName ?? ""
        itemName = item.text ?? ""
        isLocked = item.locked?.boolValue ?? false
        if let currencyString = item.currency, let currency = Currency(rawValue: currencyString) {
            currencyView.currency = currency
            setCanAfford( item.value?.floatValue ?? 0, currency: currency)
        }
        
        if let lastPurchased = item.lastPurchased, wasRecentlyPurchased(lastPurchased) {
            showPurchaseConfirmation()
        }
        availableUntil = item.availableUntil
        applyAccessibility()
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
    
    func setCanAfford(_ price: Float, currency: Currency) {
        var canAfford = false

        if let user = HRPGManager.shared().getUser() {
            switch currency {
            case .gold:
                canAfford = price < user.gold.floatValue
            case .gem:
                canAfford = price < user.balance.floatValue*4
            case .hourglass:
                canAfford = price < user.subscriptionPlan.consecutiveTrinkets?.floatValue ?? 0
            }
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
