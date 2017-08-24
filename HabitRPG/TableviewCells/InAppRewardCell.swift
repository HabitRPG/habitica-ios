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
        currencyView.amount = reward.value.intValue
        if let inAppReward = reward as? InAppReward {
            imageName = inAppReward.imageName ?? ""
            if let currencyString = inAppReward.currency, let currency = Currency(rawValue: currencyString) {
                currencyView.currency = currency
            }
        } else {
            currencyView.currency = .gold
            if reward.key == "potion" {
                HRPGManager.shared().setImage("shop_potion", withFormat: "png", on: imageView)
            } else if reward.key == "armoire" {
                HRPGManager.shared().setImage("shop_armoire", withFormat: "png", on: imageView)
            }
        }
    }
    
    func configure(item: ShopItem) {
        currencyView.amount = item.value?.intValue ?? 0
        imageName = item.imageName ?? ""
        if let currencyString = item.currency, let currency = Currency(rawValue: currencyString) {
            currencyView.currency = currency
        }
    }
}
