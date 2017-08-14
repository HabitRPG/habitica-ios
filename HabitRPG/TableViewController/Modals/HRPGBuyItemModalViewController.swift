//
//  HRPGBuyItemModalViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/3/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGBuyItemModalViewController: UIViewController {
    var item: ShopItem?
    var shopIdentifier: String?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var hourglassCountView: HRPGHourglassCountView!
    @IBOutlet weak var gemCountView: HRPGGemCountView!
    @IBOutlet weak var goldCountView: HRPGGoldCountView!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var closableShopModal: HRPGCloseableShopModalView!

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.superview?.bringSubview(toFront: containerView)
        styleViews()
        setupItem()
        
        closableShopModal.closeButton.addTarget(self, action: #selector(closePressed), for: UIControlEvents.touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshBalances()
    }
    
    deinit {
        closableShopModal.closeButton.removeTarget(self, action: #selector(closePressed), for: UIControlEvents.touchUpInside)
    }
    
    func styleViews() {
        pinButton.layer.borderWidth = 0.5
        pinButton.layer.borderColor = UIColor.gray400().cgColor
        pinButton.setTitleColor(UIColor.purple400(), for: UIControlState.normal)
        
        buyButton.layer.borderWidth = 0.5
        buyButton.layer.borderColor = UIColor.gray400().cgColor
        buyButton.setTitleColor(UIColor.purple400(), for: UIControlState.normal)
    }
    
    func refreshBalances() {
        if let user = HRPGManager.shared().getUser() {
            gemCountView.countLabel.text = String(describing: Int(user.balance.floatValue * 4.0))
            goldCountView.countLabel.text = String(describing: user.gold.intValue)
            if let hourglasses = user.subscriptionPlan.consecutiveTrinkets {
                hourglassCountView.countLabel.text = String(describing: hourglasses.intValue)
            }
        }
    }
    
    func setupItem() {
        if let contentView = closableShopModal.shopModalBgView.contentView {
            let itemView = HRPGSimpleShopItemView(frame: contentView.bounds)
            itemView.shopItemTitleLabel.text = item?.text
            if let imageName = item?.imageName {
                HRPGManager.shared().setImage(imageName, withFormat: "png", on: itemView.shopItemImageView)
            }
            contentView.addSubview(itemView)
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[itemView]-0-|",
                                                                      options: NSLayoutFormatOptions(rawValue: 0),
                                                                      metrics: nil,
                                                                      views: ["itemView": itemView]))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[itemView]-0-|",
                                                                      options: NSLayoutFormatOptions(rawValue: 0),
                                                                      metrics: nil,
                                                                      views: ["itemView": itemView]))
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.setNeedsUpdateConstraints()
            contentView.updateConstraints()
            contentView.setNeedsLayout()
            contentView.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    // MARK: actions

    @IBAction func pinPressed() {
    }
    
    @IBAction func buyPressed() {
        if let shopItem = item, let relevantCurrency = shopItem.currency {
            if let identifier = shopIdentifier, identifier == TimeTravelersShopKey {
                if shopItem.purchaseType == "gear" {
                    HRPGManager.shared().purchaseMysterySet(shopItem.category?.identifier, onSuccess: {
                        self.dismiss(animated: true, completion: nil)
                    }, onError: nil)
                } else {
                    HRPGManager.shared().purchaseHourglassItem(shopItem, onSuccess: {
                        self.dismiss(animated: true, completion: nil)
                    }, onError: nil)
                }
            } else if relevantCurrency == "gems" && !shopItem.canBuy(NSNumber(value: HRPGManager.shared().getUser().balance.floatValue * 4.0)) {
                performSegue(withIdentifier: "insufficientGems", sender: self)
            } else {
                if relevantCurrency == "gold" && shopItem.purchaseType == "quests" {
                    HRPGManager.shared().purchaseQuest(shopItem, onSuccess: {
                        self.dismiss(animated: true, completion: nil)
                    }, onError: nil)
                } else {
                    HRPGManager.shared().purchaseItem(shopItem, onSuccess: {
                        self.dismiss(animated: true, completion: nil)
                    }, onError: nil)
                }
            }
        }
    }
    
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }
}
