//
//  HRPGSimpleShopItemView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/7/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

@IBDesignable
class HRPGSimpleShopItemView: UIView {
    private let inventoryRepository = InventoryRepository()
    
    @IBOutlet weak var topBannerLabel: UILabel!
    @IBOutlet weak var topBannerWrapper: UIView!
    @IBOutlet weak var shopItemImageView: UIImageView!
    @IBOutlet weak var shopItemTitleLabel: UILabel!
    @IBOutlet weak var shopItemDescriptionLabel: UILabel!
    @IBOutlet weak var notesMargin: NSLayoutConstraint!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    private var user: UserProtocol?
    
    @IBInspectable var shouldHideNotes: Bool {
        get {
            return shopItemDescriptionLabel.isHidden
        }
        set(shouldHideNotes) {
            if shouldHideNotes {
                self.shopItemDescriptionLabel.isHidden = true
                if let label = self.shopItemDescriptionLabel {
                    let constraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                                                        toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
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
    
    var imageName = "" {
        didSet {
            setImage(name: imageName)
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
    
    init(withReward reward: InAppRewardProtocol, withUser user: UserProtocol?, for contentView: UIView) {
        super.init(frame: contentView.bounds)
        setupView()
        self.user = user
        
        self.shopItemTitleLabel.text = reward.text

        var purchaseType = ""
        if let availableUntil = reward.availableUntil {
            setAvailableUntil(date: availableUntil)
        }
        self.imageName = reward.imageName ?? ""
        self.setImage(name: imageName)
        
        if reward.key == "potion" {
            imageName = "shop_potion"
        } else if reward.key == "armoire" {
            imageName = "shop_armoire"
        }
        if let inAppPurchaseType = reward.purchaseType {
            purchaseType = inAppPurchaseType
        }
        
        if reward.key == "gem" {
            //setGemsLeft(inAppReward.itemsLeft?.intValue ?? 0)
        }
        if !purchaseType.isEmpty {
            configureFor(key: reward.key ?? "", purchaseType: purchaseType)
        }
        
        if let notes = reward.notes, purchaseType != "quests" {
            self.shopItemDescriptionLabel.text = notes
        } else {
            self.shopItemDescriptionLabel.text = ""
            if let label = self.shopItemDescriptionLabel {
                let constraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
                self.shopItemDescriptionLabel.addConstraint(constraint)
            }
        }
    }
    
    private func setImage(name: String) {
        var name = imageName
        if imageName.contains(" ") {
            name = imageName.components(separatedBy: " ")[1]
        }
        ImageManager.getImage(name: name) { (image, _) in
            self.shopItemImageView.image = image
            self.imageViewHeight.constant = image?.size.height ?? 0
            self.setNeedsLayout()
        }
    }
    
    private func setGemsLeft(_ gemsLeft: Int) {
        let totalCount = self.user?.purchased?.subscriptionPlan?.gemCapTotal ?? 0
        topBannerLabel.text = L10n.Inventory.numberGemsLeft(gemsLeft, totalCount)
        if gemsLeft == 0 {
            topBannerWrapper.backgroundColor = UIColor.orange10()
            additionalInfoLabel.text = L10n.Inventory.noGemsLeft
            additionalInfoLabel.textColor = UIColor.orange10()
        } else {
            topBannerWrapper.backgroundColor = UIColor.green10()
        }
        topBannerWrapper.isHidden = false
    }
    
    private func configureFor(key: String, purchaseType: String) {
        if purchaseType == "gear", let user = self.user {
            inventoryRepository.getGear(keys: [key])
                .take(first: 1)
                .map({ (gear, _) -> GearProtocol? in
                    return gear.first
                })
                .skipNil()
                .on(value: {[weak self] gear in
                    var gearClass = gear.habitClass
                    if gearClass == "special" {
                        gearClass = gear.specialClass
                    }
                    if gearClass == "wizard" {
                        gearClass = "mage"
                    }
                    if gearClass != user.stats?.habitClass && gearClass != nil && gearClass != "special" && gearClass != "armoire" {
                        self?.topBannerLabel.text = L10n.Inventory.wrongClass(gearClass?.capitalized ?? "")
                        self?.topBannerWrapper.backgroundColor = UIColor.gray100()
                        self?.topBannerWrapper.isHidden = false
                    }
            }).start()
        }
    }
    
    private func setAvailableUntil(date: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.timeZone = TimeZone(identifier: "UTC")
        let dateString = formatter.string(from: date)
        topBannerLabel.text = L10n.Inventory.availableUntil(dateString)
        topBannerWrapper.backgroundColor = UIColor.purple200()
        topBannerWrapper.isHidden = false
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            translatesAutoresizingMaskIntoConstraints = false
            
            view.frame = bounds
            addSubview(view)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            
            let theme = ThemeService.shared.theme
            view.backgroundColor = theme.contentBackgroundColor
            shopItemTitleLabel.textColor = theme.primaryTextColor
            shopItemDescriptionLabel.textColor = theme.secondaryTextColor
            topBannerWrapper.backgroundColor = theme.contentBackgroundColor
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
}
