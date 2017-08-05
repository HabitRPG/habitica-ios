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
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var hourglassCountView: HRPGHourglassCountView!
    @IBOutlet weak var gemCountView: HRPGGemCountView!
    @IBOutlet weak var goldCountView: HRPGGoldCountView!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var itemHolderView: UIView!
    @IBOutlet weak var itemHolderHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        styleViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshBalances()
    }
    
    func styleViews() {
        containerView.cornerRadius = 12
        
        closeButton.cornerRadius = 12
        closeButton.setTitleColor(UIColor.purple400(), for: UIControlState.normal)
        
        pinButton.layer.borderWidth = 0.5
        pinButton.layer.borderColor = UIColor.gray400().cgColor
        pinButton.setTitleColor(UIColor.purple400(), for: UIControlState.normal)
        
        buyButton.layer.borderWidth = 0.5
        buyButton.layer.borderColor = UIColor.gray400().cgColor
        buyButton.setTitleColor(UIColor.purple400(), for: UIControlState.normal)
    }
    
    func refreshBalances() {
        if let user = HRPGManager.shared().getUser() {
            gemCountView.countLabel.text = String(describing: user.balance.floatValue * 4.0)
            goldCountView.countLabel.text = String(describing: user.gold.intValue)
            if let hourglasses = user.subscriptionPlan.consecutiveTrinkets {
                hourglassCountView.countLabel.text = String(describing: hourglasses.intValue)
            }
        }
    }

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
                let storyboard = UIStoryboard(name: "Main", bundle:nil)
                let navigationController = storyboard.instantiateViewController(withIdentifier: "PurchaseGemNavController")
                present(navigationController, animated: true, completion: nil)
            } else {
                if relevantCurrency == "gear" {
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
    
    @IBAction func closePressed() {
        dismiss(animated: true, completion: nil)
    }
}
