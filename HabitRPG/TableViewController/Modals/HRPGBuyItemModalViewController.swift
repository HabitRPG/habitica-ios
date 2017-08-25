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
    var reward: MetaReward?
    var shopIdentifier: String?
    let inventoryRepository = InventoryRepository()
    
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var bottomButtons: UIStackView!
    
    @IBOutlet weak var hourglassCountView: HRPGCurrencyCountView!
    @IBOutlet weak var gemCountView: HRPGCurrencyCountView!
    @IBOutlet weak var goldCountView: HRPGCurrencyCountView!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var buyButton: UIView!
    @IBOutlet weak var currencyCountView: HRPGCurrencyCountView!
    @IBOutlet weak var closableShopModal: HRPGCloseableShopModalView!

    override func viewDidLoad() {
        super.viewDidLoad()

        topContentView.superview?.bringSubview(toFront: topContentView)
        bottomButtons.superview?.bringSubview(toFront: bottomButtons)
        styleViews()
        setupItem()
        
        closableShopModal.closeButton.addTarget(self, action: #selector(closePressed), for: UIControlEvents.touchUpInside)
        buyButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyPressed)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        hourglassCountView.currency = .hourglass
        gemCountView.currency = .gem
        goldCountView.currency = .gold
    }
    
    func refreshBalances() {
        if let user = HRPGManager.shared().getUser() {
            gemCountView.amount = Int(user.balance.floatValue * 4.0)
            goldCountView.amount = user.gold.intValue
            if let hourglasses = user.subscriptionPlan.consecutiveTrinkets {
                hourglassCountView.amount = hourglasses.intValue
            }
        }
    }
    
    func setupItem() {
        if let contentView = closableShopModal.shopModalBgView.contentView {
            var itemView: HRPGSimpleShopItemView?
            if let item = self.item {
                itemView = HRPGSimpleShopItemView(withItem: item, for: contentView)
            } else if let reward = self.reward {
                itemView = HRPGSimpleShopItemView(withReward: reward, for: contentView)
            }
            updateBuyButton()
            let key = item?.key ?? reward?.key ?? ""
            if let itemView = itemView {
                switch getPurchaseType() {
                case "quests":
                    let questView = QuestDetailView(frame: CGRect.zero)
                    if let quest = inventoryRepository.getQuest(key) {
                        questView.configure(quest: quest)
                    }
                    addItemAndDetails(itemView, questView, to: contentView)
                    break
                case "gear":
                    if let identifier = shopIdentifier, identifier == TimeTravelersShopKey {
                        addItemSet(itemView: itemView, to: contentView)
                    } else {
                        let statsView = HRPGItemStatsView(frame: CGRect.zero)
                        if let gear = inventoryRepository.getGear(key) {
                            statsView.configure(gear: gear)
                        }
                        addItemAndDetails(itemView, statsView, to: contentView)
                    }
                    break
                case "mystery_set":
                    addItemSet(itemView: itemView, to: contentView)
                default:
                    contentView.addSingleViewWithConstraints(itemView)
                    break
                }
            }
            contentView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.triggerLayout()
        }
    }
    
    func updateBuyButton() {
        if let item = self.item {
            if let currencyString = item.currency, let currency = Currency(rawValue: currencyString) {
                currencyCountView.currency = currency
            }
            currencyCountView.amount = item.value?.intValue ?? 0
        } else if let reward = self.reward {
            if let inAppReward = reward as? InAppReward, let currencyString = inAppReward.currency, let currency = Currency(rawValue: currencyString) {
                currencyCountView.currency = currency
            } else {
                currencyCountView.currency = .gold
            }
            currencyCountView.amount = reward.value.intValue
        }
    }
    
    func getPurchaseType() -> String {
        if let shopItem = self.item {
            return shopItem.purchaseType ?? ""
        } else if let reward = self.reward as? InAppReward {
            return reward.purchaseType ?? ""
        } else {
            return ""
        }
    }
    
    func addItemAndDetails(_ itemView: UIView, _ detailView: UIView, to contentView: UIView) {
        let views = ["itemView": itemView, "detailView": detailView]
        contentView.addSubview(itemView)
        contentView.addSubview(detailView)
        contentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(itemView))
        contentView.addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[itemView]-0-[detailView]-20-|", views))
        contentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(detailView))
    }
    
    func addItemSet(itemView: UIView, to contentView: UIView) {
        contentView.addSubview(itemView)
        contentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(itemView))
        contentView.addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[itemView]-20-|", ["itemView": itemView]))
        
        let firstGearSetItem = HRPGGearSetItem(frame: CGRect.zero)
        let secondGearSetItem = HRPGGearSetItem(frame: CGRect.zero)
        let thirdGearSetItem = HRPGGearSetItem(frame: CGRect.zero)
        let fourthGearSetItem = HRPGGearSetItem(frame: CGRect.zero)
    }
    
    // MARK: actions

    @IBAction func pinPressed() {
    }
    
    func buyPressed() {
        if let shopItem = item, let relevantCurrency = shopItem.currency {
            if let identifier = shopIdentifier, identifier == TimeTravelersShopKey {
                if shopItem.purchaseType == "gear" {
                    HRPGManager.shared().purchaseMysterySet(shopItem.category?.identifier, onSuccess: {
                        self.dismiss(animated: true, completion: nil)
                    }, onError: {
                        self.performSegue(withIdentifier: "insufficientHourglasses", sender: self)
                    })
                } else {
                    HRPGManager.shared().purchaseHourglassItem(shopItem, onSuccess: {
                        self.dismiss(animated: true, completion: nil)
                        }, onError: {
                            self.performSegue(withIdentifier: "insufficientHourglasses", sender: self)
                    })
                }
            } else if relevantCurrency == "gems" && !shopItem.canBuy(NSNumber(value: HRPGManager.shared().getUser().balance.floatValue * 4.0)) {
                performSegue(withIdentifier: "insufficientGems", sender: self)
            } else {
                if relevantCurrency == "gold" && shopItem.purchaseType == "quests" {
                    HRPGManager.shared().purchaseQuest(shopItem, onSuccess: {
                        self.dismiss(animated: true, completion: nil)
                    }, onError: {
                        self.performSegue(withIdentifier: "insufficientGold", sender: self)
                    })
                } else {
                    HRPGManager.shared().purchaseItem(shopItem, onSuccess: {
                        self.dismiss(animated: true, completion: nil)
                    }, onError: {
                        self.performSegue(withIdentifier: "insufficientGold", sender: self)
                    })
                }
            }
        }
    }
    
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        closableShopModal.shopModalBgView.maxHeightConstraint.constant = view.frame.size.height - 200
    }
}

extension NSLayoutConstraint {
    static func defaultVerticalConstraints(_ visualFormat: String, _ views: [String: UIView]) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                              options: NSLayoutFormatOptions(rawValue: 0),
                                              metrics: nil,
                                              views: views)
    }
    
    static func defaultHorizontalConstraints(_ view: UIView) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|",
                                              options: NSLayoutFormatOptions(rawValue: 0),
                                              metrics: nil,
                                              views: ["view": view])
    }
}

extension UIView {
    func addSingleViewWithConstraints(_ view: UIView) {
        self.addSubview(view)
        self.addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[view]-0-|", ["view": view]))
        self.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(view))
    }
    
    func triggerLayout() {
        self.setNeedsUpdateConstraints()
        self.updateConstraints()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
