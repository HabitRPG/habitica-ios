//
//  HRPGBuyItemModalViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/3/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class HRPGBuyItemModalViewController: UIViewController {
    var item: ShopItem?
    var reward: MetaReward?
    var shopIdentifier: String?
    let inventoryRepository = InventoryRepository()
    let showPinning = ConfigRepository().bool(variable: .enableNewShops)
    
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var bottomButtons: UIView!
    
    @IBOutlet weak var hourglassCountView: HRPGCurrencyCountView!
    @IBOutlet weak var gemCountView: HRPGCurrencyCountView!
    @IBOutlet weak var goldCountView: HRPGCurrencyCountView!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var buyButton: UIView!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var currencyCountView: HRPGCurrencyCountView!
    @IBOutlet weak var closableShopModal: HRPGCloseableShopModalView!

    private var isPinned: Bool = false {
        didSet {
            if isPinned {
                pinButton.setTitle(NSLocalizedString("Unpin from Rewards", comment: ""), for: .normal)
            } else {
                pinButton.setTitle(NSLocalizedString("Pin to Rewards", comment: ""), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topContentView.superview?.bringSubview(toFront: topContentView)
        bottomButtons.superview?.bringSubview(toFront: bottomButtons)
        styleViews()
        setupItem()
        
        closableShopModal.closeButton.addTarget(self, action: #selector(closePressed), for: UIControlEvents.touchUpInside)
        buyButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyPressed)))
        
        pinButton.isHidden = !showPinning
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
        currencyCountView.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
        
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
                isPinned = true
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
        var isLocked = false
        if let item = self.item {
            if let currencyString = item.currency, let currency = Currency(rawValue: currencyString) {
                currencyCountView.currency = currency
            }
            currencyCountView.amount = item.value?.intValue ?? 0
            isLocked = item.locked?.boolValue ?? false
        } else if let reward = self.reward {
            if let inAppReward = reward as? InAppReward, let currencyString = inAppReward.currency, let currency = Currency(rawValue: currencyString) {
                currencyCountView.currency = currency
                isLocked = inAppReward.locked?.boolValue ?? false
            } else {
                currencyCountView.currency = .gold
            }
            currencyCountView.amount = reward.value.intValue
        }
        if canAfford() && !isLocked {
            currencyCountView.state = .normal
        } else {
            buyLabel.textColor = .gray400()
            if isLocked {
                currencyCountView.state = .locked
            } else {
                currencyCountView.state = .cantAfford
            }
        }
    }
    
    func canAfford() -> Bool {
        var currency: Currency?
        var price: Float = 0.0
        
        if let item = self.item, let currencyString = item.currency {
                currency = Currency(rawValue: currencyString)
            price = item.value?.floatValue ?? 0
        } else if let inAppReward = reward as? InAppReward, let currencyString = inAppReward.currency {
            currency = Currency(rawValue: currencyString)
            price = inAppReward.value?.floatValue ?? 0
        }
        
        if let user = HRPGManager.shared().getUser(), let currency = currency {
            switch currency {
            case .gold:
                return price <= user.gold.floatValue
            case .gem:
                return price <= user.balance.floatValue*4
            case .hourglass:
                return price <= user.subscriptionPlan.consecutiveTrinkets?.floatValue ?? 0
            }
        }
        
        return false
    }
    
    func itemIsLocked() -> Bool {
        var isLocked = false
        if let item = self.item {
            isLocked = item.locked?.boolValue ?? false
        } else if let inAppReward = reward as? InAppReward {
            isLocked = inAppReward.locked?.boolValue ?? false
        }
        return isLocked
    }
    
    func canBuy() -> Bool {
        return canAfford() && itemIsLocked()
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
        var path = ""
        var pinType = ""
        if let shopItem = item {
            path = shopItem.path ?? ""
            pinType = shopItem.pinType ?? ""
        } else if let inAppReward = reward as? InAppReward {
            path = inAppReward.path ?? ""
            pinType = inAppReward.pinType ?? ""
        }
        HRPGManager.shared().togglePinnedItem(pinType, withPath: path, onSuccess: {[weak self] in
            self?.isPinned = !(self?.isPinned ?? false)
        }, onError: nil)
    }
    
    func buyPressed() {
        if itemIsLocked() {
            return
        }
        var key = ""
        var purchaseType = ""
        var text = ""
        var imageName = ""
        var currency = Currency.gold
        var setIdentifier = ""
        var value: NSNumber = 0
        if let shopItem = item {
            key = shopItem.key ?? ""
            purchaseType = shopItem.purchaseType ?? ""
            text = shopItem.text ?? ""
            imageName = shopItem.imageName ?? ""
            setIdentifier = shopItem.category?.identifier ?? ""
            value = shopItem.value ?? 0
            if let currencyString = shopItem.currency, let thisCurrency = Currency(rawValue: currencyString) {
                currency = thisCurrency
            }
        } else if let inAppReward = reward as? InAppReward {
            key = inAppReward.key ?? ""
            purchaseType = inAppReward.purchaseType ?? ""
            text = inAppReward.text ?? ""
            imageName = inAppReward.imageName ?? ""
            setIdentifier = inAppReward.key ?? ""
            value = inAppReward.value ?? 0
            if let currencyString = inAppReward.currency, let thisCurrency = Currency(rawValue: currencyString) {
                currency = thisCurrency
            }
        }
        
        if key != "" {
            self.dismiss(animated: true, completion: nil)
            if currency == .hourglass {
                if purchaseType == "gear" || purchaseType == "mystery_set" {
                    HRPGManager.shared().purchaseMysterySet(setIdentifier, onSuccess: nil, onError: {
                        self.performSegue(withIdentifier: "insufficientHourglasses", sender: self)
                    })
                } else {
                    HRPGManager.shared().purchaseHourglassItem(key, withPurchaseType: purchaseType, withText: text, withImageName: imageName, onSuccess: nil, onError: {
                            self.performSegue(withIdentifier: "insufficientHourglasses", sender: self)
                    })
                }
            } else if currency == .gem && value.floatValue > HRPGManager.shared().getUser().balance.floatValue * 4.0 {
                performSegue(withIdentifier: "insufficientGems", sender: self)
            } else if currency == .gem || purchaseType == "gems" {
                HRPGManager.shared().purchaseItem(key, withPurchaseType: purchaseType, withText: text, withImageName: imageName, onSuccess: nil, onError: {
                    self.performSegue(withIdentifier: "insufficientGems", sender: self)
                })
            } else {
                if currency == .gold && purchaseType == "quests" {
                    HRPGManager.shared().purchaseQuest(key, withText: text, withImageName: imageName, onSuccess: nil, onError: {
                        self.performSegue(withIdentifier: "insufficientGold", sender: self)
                    })
                } else {
                    HRPGManager.shared().buyObject(key, withValue: value, withText: text, onSuccess: nil, onError: {
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
