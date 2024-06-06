//
//  ShopViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.08.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class ShopViewController: BaseCollectionViewController, ShopCollectionViewDataSourceDelegate {
    
    private let userRepository = UserRepository()
    
    func showGearSelection(sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for title in ["warrior", "mage", "healer", "rogue", "none"] {
            let action = UIAlertAction(title: title.localizedCapitalized, style: .default) {[weak self] _ in
                self?.selectedGearCategory = title
            }
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction.cancelAction())
        alertController.popoverPresentationController?.sourceView = sourceView
        alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        present(alertController, animated: true, completion: nil)
    }
    
    func updateShopHeader(shop: ShopProtocol?) {
        bannerView.shop = shop
        collectionView.contentInset = .init(top: bannerView.intrinsicContentSize.height + 20, left: 0, bottom: 0, right: 0)
    }
    
    func updateNavBar(gold: Int, gems: Int, hourglasses: Int) {
        goldView.amount = gold
        gemView.amount = gems
        hourglassView.amount = hourglasses
    }
    
    var shopIdentifier: String?
    var openToSection: String?
    
    private lazy var bannerView: NPCBannerView = {
        return NPCBannerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 156))
    }()
    private var dataSource: ShopCollectionViewDataSource?
    private var selectedIndex: NSIndexPath?
    private var insetWasSetup: Bool?
    private var selectedGearCategory: String? {
        didSet {
            dataSource?.selectedGearCategory = selectedGearCategory
        }
    }
    private var hourglassView = CurrencyCountView(currency: .hourglass)
    private var gemView = CurrencyCountView(currency: .gem)
    private var goldView = CurrencyCountView(currency: .gold)
    
    var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.alternativeHeader = bannerView
        if let identifier = shopIdentifier {
            bannerView.setSprites(identifier: identifier)
            bannerView.setNPCName(identifier: identifier)
        }
        
        setupNavBar()
        setupCollectionView()
        
        dataSource?.selectedGearCategory = selectedGearCategory
        dataSource?.needsGearSection = shopIdentifier == "market"
        
        refresh()
        
        HabiticaAnalytics.shared.logNavigationEvent("navigated \(shopIdentifier ?? "") screen")
        
        refresher = HabiticaRefresControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.addSubview(refresher)
    }
    
    private var isSubscribed: Bool?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isSubscribed == nil {
            userRepository.getUser().take(first: 1).on(value: { user in
                self.isSubscribed = user.isSubscribed
                if self.shopIdentifier == "timeTravelersShop" && !user.isSubscribed && user.purchased?.subscriptionPlan?.consecutive?.hourglasses == 0 {
                    SubscriptionModalViewController(presentationPoint: .timetravelers).show()
                }
            }).start()
        }
        
        if let sectionKey = openToSection {
            let section = dataSource?.sections.firstIndex(where: { section in
                section.key == sectionKey
            })
            collectionView.scrollToItem(at: IndexPath(row: 0, section: section ?? 0), at: .top, animated: true)
        }
    }
    
    private func setupNavBar() {
        if shopIdentifier == "timeTravelersShop" {
            hourglassView.currency = .hourglass
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(customView: hourglassView)
            ]
        } else {
            gemView.currency = .gem
            goldView.currency = .gold
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(customView: gemView),
                UIBarButtonItem(customView: goldView)
            ]
        }
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "InAppRewardCell", bundle: nibBundle), forCellWithReuseIdentifier: "ItemCell")
        guard let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        collectionViewLayout.itemSize = CGSize(width: 90, height: 120)
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 6, bottom: 40, right: 6)
        collectionView.contentInset = .zero
        collectionView.collectionViewLayout = collectionViewLayout
        
        if let identifier = shopIdentifier {
            if identifier == "timeTravelersShop" {
                dataSource = TimeTravelersCollectionViewDataSource(identifier: identifier, delegate: self)
            } else if identifier == "seasonalShop" {
                dataSource = SeasonalShopCollectionViewDataSource(identifier: identifier, delegate: self)
            } else {
                dataSource = ShopCollectionViewDataSource(identifier: identifier, delegate: self)
            }
        }
        
        dataSource?.collectionView = collectionView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataSource?.dispose()
    }
    
    @objc
    private func refresh() {
        dataSource?.retrieveShopInventory({
            self.refresher.endRefreshing()
        })
    }
    
    func didSelectItem(_ item: InAppRewardProtocol?, indexPath: IndexPath) {
        if item?.key == "gem" && isSubscribed == false {
            let sheet = SubscriptionModalViewController(presentationPoint: .gemForGold)
            sheet.show()
            return
        }
        if item == nil {
            if shopIdentifier == Constants.MarketKey && indexPath.section == 0 {
                userRepository.getInAppRewards()
                    .take(first: 1)
                    .map { result in
                    return result.value.first { reward in
                        return reward.key == "armoire"
                    }
                }.skipNil()
                    .on(value: { armoire in
                        self.displayBuyDialogFor(item: armoire)
                    })
                    .start()
            } else {
                if shopIdentifier == Constants.CustomizationShopKey {
                    if let identifier = dataSource?.visibleSections[indexPath.section].key {
                        var type = identifier
                        var group: String?
                        if identifier == "color" {
                            type = "hair"
                            group = "color"
                        } else if identifier == "facialHair" {
                            type = "hair"
                            group = "beard"
                        } else if identifier == "base" {
                            type = "hair"
                            group = "base"
                        } else if identifier == "animalEars" {
                            type = "headAccessory"
                        } else if identifier == "animalTails" {
                            type = "back"
                        } else if identifier == "backgrounds" {
                            type = "background"
                        }
                        RouterHandler.shared.handle(.customizations(type: type, group: group))
                    }
                } else if shopIdentifier == Constants.TimeTravelersShopKey {
                    RouterHandler.shared.handle(.equipment)
                }
                return
            }
        }
        if let item = item {
            displayBuyDialogFor(item: item)
        }
    }
    
    private func displayBuyDialogFor(item: InAppRewardProtocol) {
        let viewController = StoryboardScene.BuyModal.hrpgBuyItemModalViewController.instantiate()
        viewController.reward = item
        viewController.shopIdentifier = shopIdentifier
        viewController.onInventoryRefresh = {[weak self] in
            self?.dataSource?.retrieveShopInventory(nil)
        }
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        viewController.shopViewController = self
        if let controller = tabBarController ?? navigationController {
            controller.present(viewController, animated: true, completion: nil)
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        collectionView.backgroundColor = theme.contentBackgroundColor
        bannerView.applyTheme(backgroundColor: theme.contentBackgroundColor)
        if theme.isDark {
            bannerView.notesLabel.textColor = theme.primaryTextColor
        } else {
            bannerView.notesLabel.textColor = UIColor("#7F3300FF")
        }

    }
}
