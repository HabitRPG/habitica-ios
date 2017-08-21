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
            let itemView = HRPGSimpleShopItemView(with: item, for: contentView)
            if let purchaseType = item?.purchaseType {
                switch purchaseType {
                case "quests":
                    
                    break
                case "gear":
                    if let identifier = shopIdentifier, identifier == TimeTravelersShopKey {
                        addItemSet(itemView: itemView, to: contentView)
                    } else {
                        let statsView = HRPGItemStatsView(frame: CGRect.zero)
                        addItemAndStats(itemView, statsView, to: contentView)
                    }
                    break
                default:
                    contentView.addSingleViewWithConstraints(itemView)
                    break
                }
            }
            contentView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.triggerLayout()
        }
    }
    
    func addItemAndStats(_ itemView: UIView, _ statsView: UIView, to contentView: UIView) {
        let views = ["itemView": itemView, "statsView": statsView]
        contentView.addSubview(itemView)
        contentView.addSubview(statsView)
        contentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(itemView))
        contentView.addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[itemView]-0-[statsView]-20-|", views))
        contentView.addConstraint(NSLayoutConstraint(item: statsView, attribute: NSLayoutAttribute.centerX,
                                                     relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
    }
    
    func addItemSet(itemView: UIView, to contentView: UIView) {
        let scrollView = UIScrollView()
        let scrollContentView = UIView()
        
        scrollContentView.addSubview(itemView)
        scrollContentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(itemView))
        
        let firstGearSetItem = HRPGGearSetItem(frame: CGRect.zero)
        let secondGearSetItem = HRPGGearSetItem(frame: CGRect.zero)
        let thirdGearSetItem = HRPGGearSetItem(frame: CGRect.zero)
        let fourthGearSetItem = HRPGGearSetItem(frame: CGRect.zero)
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
