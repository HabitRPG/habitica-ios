//
//  InAppRewardCell.swift
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class InAppRewardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var currencyView: HRPGCurrencyCountView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    private var itemsLeft = 0 {
        didSet {
            if itemsLeft > 0 {
                infoImageView.image = #imageLiteral(resourceName: "item_count_bubble")
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
                infoImageView.image = #imageLiteral(resourceName: "item_locked_bubble")
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
                infoImageView.image = #imageLiteral(resourceName: "item_limited_bubble")
                infoImageView.isHidden = false
                infoLabel.isHidden = true
            } else {
                infoImageView.isHidden = true
                infoLabel.isHidden = true
            }
        }
    }
    
    public var imageName = "" {
        didSet {
            if imageName.characters.count == 0 {
                return
            }
            if imageName.contains(" ") {
                HRPGManager.shared().setImage(imageName.components(separatedBy: " ")[1], withFormat: "png", on: imageView)
            } else {
                HRPGManager.shared().setImage(imageName, withFormat: "png", on: imageView)
            }
        }
    }
    
    func configure(reward: MetaReward) {
        var currency: Currency?
        let price = reward.value.floatValue
        currencyView.amount = reward.value.intValue
        if let inAppReward = reward as? InAppReward {
            imageName = inAppReward.imageName ?? ""
            if let currencyString = inAppReward.currency, let thisCurrency = Currency(rawValue: currencyString) {
                currencyView.currency = thisCurrency
                currency = thisCurrency
            }
            isLocked = inAppReward.locked?.boolValue ?? false
        } else {
            isLocked = false
            currency = .gold
            if reward.key == "potion" {
                HRPGManager.shared().setImage("shop_potion", withFormat: "png", on: imageView)
            } else if reward.key == "armoire" {
                HRPGManager.shared().setImage("shop_armoire", withFormat: "png", on: imageView)
            }
        }
        
        if let currency = currency {
            setCanAfford(price, currency: currency)
        }
    }
    
    func configure(item: ShopItem) {
        currencyView.amount = item.value?.intValue ?? 0
        imageName = item.imageName ?? ""
        isLocked = item.locked?.boolValue ?? false
        itemsLeft = item.itemsLeft?.intValue ?? 0
        if let currencyString = item.currency, let currency = Currency(rawValue: currencyString) {
            currencyView.currency = currency
            setCanAfford( item.value?.floatValue ?? 0, currency: currency)
        }
    }
    
    func setCanAfford(_ price: Float, currency: Currency) {
        var canAfford = false

        if let user = HRPGManager.shared().getUser() {
            switch currency {
            case .gold:
                canAfford = price < user.gold.floatValue
                break
            case .gem:
                canAfford = price < user.balance.floatValue*4
                break
            case .hourglass:
                canAfford = price < user.subscriptionPlan.consecutiveTrinkets?.floatValue ?? 0
                break
            }
        }
    
        if canAfford && !isLocked {
            currencyView.state = .normal
        } else {
            currencyView.state = .locked
        }
    }
}
