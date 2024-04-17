//
//  AvatarShopItemView.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.04.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

@IBDesignable
class AvatarShopItemView: UIView {
    private let inventoryRepository = InventoryRepository()
    
    @IBOutlet weak var topBannerLabel: UILabel!
    @IBOutlet weak var topBannerWrapper: UIView!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var shopItemTitleLabel: UILabel!
    @IBOutlet weak var shopItemDescriptionLabel: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    
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
                }
            } else {
                shopItemDescriptionLabel.isHidden = false
                shopItemDescriptionLabel.removeConstraints(shopItemDescriptionLabel.constraints)
            }
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
        if let date = reward.eventEnd {
            setAvailableUntil(date: date)
        }
        
        let layerKey: String
        if reward.path?.contains("skin") == true {
            layerKey = "skin"
        } else if reward.path?.contains("shirt") == true {
            layerKey = "shirt"
        } else if reward.path?.contains("color") == true {
            layerKey = "hair-bangs"
        } else if reward.path?.contains("base") == true {
            layerKey = "hair-base"
        } else if reward.path?.contains("bangs") == true {
            layerKey = "hair-bangs"
        } else if reward.path?.contains("beard") == true {
            layerKey = "hair-beard"
        } else if reward.path?.contains("mustache") == true {
            layerKey = "hair-mustache"
        } else if reward.path?.contains("background") == true {
            layerKey = "background"
        } else {
            layerKey = ""
        }
        avatarView.swappedDict = [
            layerKey: reward.imageName?.replacingOccurrences(of: "icon_", with: "") ?? ""
        ]
        
        if let user = user {
            avatarView.avatar = AvatarViewModel(avatar: user)
        }

        if let inAppPurchaseType = reward.purchaseType {
            purchaseType = inAppPurchaseType
        }

        if !purchaseType.isEmpty {
            configureFor(key: reward.key ?? "", purchaseType: purchaseType)
        }
        
        if let notes = reward.notes {
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
            topBannerWrapper.backgroundColor = ThemeService.shared.theme.backgroundTintColor
            topBannerLabel.textColor = .white
            topBannerLabel.text = lockedReason
            topBannerWrapper.isHidden = false
        } else {
            topBannerWrapper.isHidden = true
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func setAvatar(_ avatar: AvatarProtocol) {
        avatarView.avatar = AvatarViewModel(avatar: avatar)
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
        if date > Date() {
            topBannerLabel.text = L10n.Inventory.availableFor(date.getShortRemainingString())
            topBannerWrapper.backgroundColor = UIColor.purple300
            topBannerWrapper.isHidden = false
        } else {
            topBannerLabel.text = L10n.Inventory.noLongerAvailable
            topBannerWrapper.backgroundColor = UIColor.gray100
            topBannerWrapper.isHidden = false
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
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
}
