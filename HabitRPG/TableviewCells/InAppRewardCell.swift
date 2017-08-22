//
//  InAppRewardCell.swift
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class InAppRewardCell: UICollectionViewCell {
    
    @IBOutlet weak var currencyView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(reward: MetaReward, manager: HRPGManager) {
        amountLabel.text = reward.value?.stringValue
        if let inAppReward = reward as? InAppReward {
            manager.setImage(inAppReward.imageName, withFormat: "png", on: imageView)
            if inAppReward.currency == "gold" {
                currencyView.image = #imageLiteral(resourceName: "gold_coin")
                amountLabel.textColor = UIColor.yellow10()
            } else if inAppReward.currency == "gems" {
                currencyView.image = #imageLiteral(resourceName: "Gem")
                amountLabel.textColor = UIColor.green10()
            } else if inAppReward.currency == "hourglasses" {
                currencyView.image = #imageLiteral(resourceName: "hourglass")
                amountLabel.textColor = UIColor.blue10()
            }
        } else {
            currencyView.image = #imageLiteral(resourceName: "gold_coin")
            amountLabel.textColor = UIColor.yellow10()
            if reward.key == "potion" {
                manager.setImage("shop_potion", withFormat: "png", on: imageView)
            } else if reward.key == "armoire" {
                manager.setImage("shop_armoire", withFormat: "png", on: imageView)
            }
        }
    }
    
}
