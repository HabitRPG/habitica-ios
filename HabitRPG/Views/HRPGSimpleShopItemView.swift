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
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var useImmediatelyDisclaimerLabel: UILabel!
    @IBOutlet weak var useImmediatelyDisclaimerHeight: NSLayoutConstraint!
    
    private var user: UserProtocol?
    
    @IBInspectable var shouldHideNotes: Bool {
        get {
            return shopItemDescriptionLabel.isHidden
        }
        set(shouldHideNotes) {
            if shouldHideNotes {
                self.shopItemDescriptionLabel.isHidden = true
                if let label = shopItemDescriptionLabel {
                    let constraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                                                        toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
                    self.shopItemDescriptionLabel.addConstraint(constraint)
                    self.notesMargin.constant = 0
                }
            } else {
                shopItemDescriptionLabel.isHidden = false
                shopItemDescriptionLabel.removeConstraints(shopItemDescriptionLabel.constraints)
                notesMargin.constant = 12
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
    
    init(withReward reward: InAppRewardProtocol, withUser user: UserProtocol?, for contentView: UIView) {
        super.init(frame: contentView.bounds)
        setupView()
        self.user = user
        
        shopItemTitleLabel.text = reward.text

        var purchaseType = ""
        if let date = reward.eventEnd, date > Date() {
            setAvailableUntil(date: date)
        }
        var imageName = reward.imageName ?? ""
        if reward.path?.contains("timeTravelBackgrounds") == true {
            setImage(name: imageName.replacingOccurrences(of: "icon_", with: ""), fileExtension: "gif")
        } else {
            setImage(name: imageName)
        }
        
        if reward.key == "potion" {
            imageName = "shop_potion"
        } else if reward.key == "armoire" {
            imageName = "shop_armoire"
        } else if reward.imageName == "gem_shop" {
            imageName = "shop_gem"
        }
        
        if reward.key == "potion" || reward.key == "fortify" {
            useImmediatelyDisclaimerHeight.constant = 50
            useImmediatelyDisclaimerLabel.isHidden = false
            useImmediatelyDisclaimerLabel.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            useImmediatelyDisclaimerLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        }
        if let inAppPurchaseType = reward.purchaseType {
            purchaseType = inAppPurchaseType
        }

        if !purchaseType.isEmpty {
            configureFor(key: reward.key ?? "", purchaseType: purchaseType)
        }
        
        if let notes = reward.notes, purchaseType != "quests" {
            self.shopItemDescriptionLabel.text = notes
        } else {
            self.shopItemDescriptionLabel.text = ""
            if let label = shopItemDescriptionLabel {
                let constraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
                shopItemDescriptionLabel.addConstraint(constraint)
            }
        }
        
        if let lockedReason = reward.lockedReason, reward.locked {
            topBannerWrapper.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            topBannerLabel.textColor = ThemeService.shared.theme.secondaryTextColor
            topBannerLabel.text = lockedReason
        }
        topBannerWrapper.isHidden = false
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func setImage(name: String, fileExtension: String = "png") {
        var imageName = name
        if imageName.contains(" ") {
            imageName = imageName.components(separatedBy: " ")[1]
        }
        ImageManager.getImage(name: imageName, extension: fileExtension) {[weak self] (image, _) in
            self?.shopItemImageView.image = image
            self?.imageViewHeight.constant = image?.size.height ?? 0
            self?.imageViewWidth.constant = image?.size.width ?? 0
            self?.setNeedsLayout()
        }
    }

    func setGemsLeft(_ gemsLeft: Int, gemsTotal: Int) {
        topBannerLabel.text = L10n.Inventory.numberGemsLeft(gemsLeft, gemsTotal)
        if gemsLeft == 0 {
            topBannerWrapper.backgroundColor = UIColor.orange10
            additionalInfoLabel.text = L10n.Inventory.noGemsLeft
            additionalInfoLabel.textColor = UIColor.orange10
        } else {
            topBannerWrapper.backgroundColor = UIColor.green10
        }
        topBannerWrapper.isHidden = false
    }
    
    private func configureFor(key: String, purchaseType: String) {
        if purchaseType == "gear", let user = user {
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
                        self?.topBannerWrapper.backgroundColor = UIColor.gray100
                        self?.topBannerWrapper.isHidden = false
                    }
            }).start()
        }
    }
    
    private var timer: Timer?
    
    private func setAvailableUntil(date: Date) {
        timer?.invalidate()
        updateAvailableUntil(date: date)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {[weak self] _ in
            self?.updateAvailableUntil(date: date)
        })
    }
    
    @objc
    private func updateAvailableUntil(date: Date) {
        if date.compare(Date()) != .orderedAscending {
            topBannerLabel.text = L10n.Inventory.availableFor(date.getShortRemainingString())
            topBannerWrapper.backgroundColor = UIColor.purple300
            topBannerWrapper.isHidden = false
        } else {
            topBannerWrapper.isHidden = true
        }
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
            
            useImmediatelyDisclaimerLabel.text = L10n.useImmediatelyDisclaimer
            useImmediatelyDisclaimerLabel.isHidden = true
            useImmediatelyDisclaimerHeight.constant = 0
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
}
