//
//  HRPGSimpleShopItemView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/7/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class HRPGSimpleShopItemView: UIView {
    @IBOutlet weak var topBannerLabel: PaddedLabel!
    @IBOutlet weak var shopItemImageView: UIImageView!
    @IBOutlet weak var shopItemTitleLabel: UILabel!
    @IBOutlet weak var shopItemDescriptionLabel: UILabel!
    @IBOutlet weak var notesMargin: NSLayoutConstraint!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    
    @IBInspectable var shouldHideNotes: Bool {
        get {
            return shopItemDescriptionLabel.isHidden
        }
        set(shouldHideNotes) {
            if shouldHideNotes {
                self.shopItemDescriptionLabel.isHidden = true
                if let label = self.shopItemDescriptionLabel {
                    let constraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
                                                        toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 0)
                    self.shopItemDescriptionLabel.addConstraint(constraint)
                    self.notesMargin.constant = 0
                }
            } else {
                self.shopItemDescriptionLabel.isHidden = false
                self.shopItemDescriptionLabel.removeConstraints(self.shopItemDescriptionLabel.constraints)
                self.notesMargin.constant = 12
            }
        }
    }
    
    @IBInspectable var image: UIImage? {
        get {
            return shopItemImageView.image
        }
        set (newImage) {
            shopItemImageView.image = newImage
        }
    }
    
    @IBInspectable var title: String? {
        get {
            return shopItemTitleLabel.text
        }
        set (newTitle) {
            shopItemTitleLabel.text = newTitle
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    init(withItem item: ShopItem, for contentView: UIView) {
        super.init(frame: contentView.bounds)
        setupView()
        
        self.shopItemTitleLabel.text = item.text
        
        if let imageName = item.imageName {
            if imageName.contains(" ") {
                HRPGManager.shared().setImage(imageName.components(separatedBy: " ")[1], withFormat: "png", on: self.shopItemImageView)
            } else {
                HRPGManager.shared().setImage(imageName, withFormat: "png", on: self.shopItemImageView)
            }
        }
        
        if let notes = item.notes {
            self.shopItemDescriptionLabel.text = notes
        } else {
            self.shopItemDescriptionLabel.text = ""
            if let label = self.shopItemDescriptionLabel {
                let constraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
                                                    toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 0)
                self.shopItemDescriptionLabel.addConstraint(constraint)
            }
        }
        
        if let key = item.key, let purchaseType = item.purchaseType {
            configureFor(key: key, purchaseType: purchaseType)
        }
        
        if item.key == "gem" {
            setGemsLeft(item.itemsLeft?.intValue ?? 0)
        }
    }
    
    init(withReward reward: MetaReward, for contentView: UIView) {
        super.init(frame: contentView.bounds)
        setupView()
        
        self.shopItemTitleLabel.text = reward.text

        var purchaseType = ""
        if let inAppReward = reward as? InAppReward {
            if inAppReward.imageName?.contains(" ") ?? false {
                HRPGManager.shared().setImage(inAppReward.imageName?.components(separatedBy: " ")[1], withFormat: "png", on: self.shopItemImageView)
            } else {
                HRPGManager.shared().setImage(inAppReward.imageName, withFormat: "png", on: self.shopItemImageView)
            }
            if let inAppPurchaseType = inAppReward.purchaseType {
                purchaseType = inAppPurchaseType
            }
            
            if inAppReward.key == "gem" {
                setGemsLeft(inAppReward.itemsLeft?.intValue ?? 0)
            }
        } else {
            if reward.key == "potion" {
                HRPGManager.shared().setImage("shop_potion", withFormat: "png", on: shopItemImageView)
            } else if reward.key == "armoire" {
                HRPGManager.shared().setImage("shop_armoire", withFormat: "png", on: shopItemImageView)
            }
        }
        if !purchaseType.isEmpty {
            configureFor(key: reward.key, purchaseType: purchaseType)
        }
        
        if let notes = reward.notes, purchaseType != "quests" {
            self.shopItemDescriptionLabel.text = notes
        } else {
            self.shopItemDescriptionLabel.text = ""
            if let label = self.shopItemDescriptionLabel {
                let constraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
                                                    toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 0)
                self.shopItemDescriptionLabel.addConstraint(constraint)
            }
        }
    }
    
    private func setGemsLeft(_ gemsLeft: Int) {
        let totalCount = HRPGManager.shared().getUser().subscriptionPlan.totalGemCap
        topBannerLabel.text = NSLocalizedString("Monthly Gems: \(gemsLeft)/\(totalCount) Remaining", comment: "")
        if gemsLeft == 0 {
            topBannerLabel.backgroundColor = UIColor.orange10()
            additionalInfoLabel.text = NSLocalizedString("No more Gems available this month. More become available within the first 3 days of each month.", comment: "")
            additionalInfoLabel.textColor = UIColor.orange10()
        } else {
            topBannerLabel.backgroundColor = UIColor.green10()
        }
        topBannerLabel.verticalPadding = 6
    }
    
    private func configureFor(key: String, purchaseType: String) {
        if purchaseType == "gear", let user = HRPGManager.shared().getUser() {
            let gear = InventoryRepository().getGear(key)
            var gearClass = gear?.klass
            if gearClass == "special" {
                gearClass = gear?.specialClass
            }
            if gearClass != user.hclass {
                topBannerLabel.text = NSLocalizedString("Only available for \(gear?.klass ?? "")", comment: "")
                topBannerLabel.backgroundColor = UIColor.orange10()
                topBannerLabel.verticalPadding = 6
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            translatesAutoresizingMaskIntoConstraints = false
            
            view.frame = bounds
            addSubview(view)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
}
