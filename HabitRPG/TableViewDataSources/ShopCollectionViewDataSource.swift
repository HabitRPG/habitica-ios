//
//  HRPGShopCollectionViewDataSource.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/29/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

@objc
protocol ShopCollectionViewDataSourceProtocol: UICollectionViewDelegateFlowLayout {
    @objc weak var delegate: ShopCollectionViewDataSourceDelegate? { get set }
    
    @objc var needsGearSection: Bool { get set }
    @objc var selectedGearCategory: String? { get set }
    @objc var collectionView: UICollectionView? { get set }
    @objc
    func retrieveShopInventory(_ completed: (() -> Void)?)
    @objc
    func dispose()
}

@objc
class ShopCollectionViewDataSourceInstantiator: NSObject {
    @objc
    static func instantiate(identifier: String, delegate: ShopCollectionViewDataSourceDelegate) -> ShopCollectionViewDataSourceProtocol {
        return ShopCollectionViewDataSource(identifier: identifier, delegate: delegate)
    }
    
    @objc
    static func instantiateTimeTravelers(delegate: ShopCollectionViewDataSourceDelegate) -> ShopCollectionViewDataSourceProtocol {
        return TimeTravelersCollectionViewDataSource(identifier: "timeTravelersShop", delegate: delegate)
    }
}

@objc protocol ShopCollectionViewDataSourceDelegate {
    func didSelectItem(_ item: InAppRewardProtocol?)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func showGearSelection(sourceView: UIView)
    func updateShopHeader(shop: ShopProtocol?)
    func updateNavBar(gold: Int, gems: Int)
}

class ShopCollectionViewDataSource: BaseReactiveCollectionViewDataSource<InAppRewardProtocol>, ShopCollectionViewDataSourceProtocol {
    @objc weak var delegate: ShopCollectionViewDataSourceDelegate?
    
    private var userRepository = UserRepository()
    var inventoryRepository = InventoryRepository()
    private var fetchGearDisposable: Disposable?
    
    private var ownedItems = [String: OwnedItemProtocol]()
    private var pinnedItems = [String?]()
    private var user: UserProtocol?
    private var userClass: String? {
        return user?.stats?.habitClass
    }
    
    @objc var needsGearSection: Bool = false {
        didSet {
            sections[0].isHidden = !needsGearSection
        }
    }
    @objc var selectedGearCategory: String? {
        didSet {
            fetchGear()
            if selectedGearCategory == "mage" {
                selectedInternalGearCategory = "wizard"
            } else {
                selectedInternalGearCategory = selectedGearCategory
            }
        }
    }
    private var selectedInternalGearCategory: String?
    
    override var collectionView: UICollectionView? {
        didSet {
            collectionView?.delegate = self
            collectionView?.dataSource = self
            collectionView?.reloadData()
        }
    }
    
    private let shopIdentifier: String
    
    init(identifier: String, delegate: ShopCollectionViewDataSourceDelegate) {
        shopIdentifier = identifier
        self.delegate = delegate
        super.init()
        sections.append(ItemSection<InAppRewardProtocol>())
        sections[0].showIfEmpty = needsGearSection
        
        disposable.add(inventoryRepository.getShop(identifier: identifier).combineLatest(with: userRepository.getUser()).on(value: {[weak self] (shop, user) in
            let sectionCount = self?.sections.count ?? 0
            if sectionCount >= 2 {
                self?.sections.removeLast(sectionCount - 1)
            }
            
            var categories = shop?.categories ?? []
            if shop?.identifier == Constants.SeasonalShopKey {
                categories.reverse()
            }
            
            self?.loadCategories(shop?.categories ?? [], isSubscribed: user.isSubscribed)
            self?.delegate?.updateShopHeader(shop: shop)
            
            self?.user = user
            if self?.selectedGearCategory == nil {
                self?.selectedGearCategory = self?.userClass
            }
            self?.delegate?.updateNavBar(gold: Int(user.stats?.gold ?? 0), gems: user.gemCount)
        }).start())
        
        disposable.add(userRepository.getInAppRewards()
            .map({ (rewards, _) in
                return rewards.map({ (reward) in
                    return reward.key
                })
            }).on(value: {[weak self]rewards in
                self?.pinnedItems = rewards
            }).start())
        
        disposable.add(inventoryRepository.getOwnedItems().map({ (items, _) -> [String: OwnedItemProtocol] in
            var ownedItems: [String: OwnedItemProtocol] = [:]
            for item in items where item.key != nil {
                ownedItems["\(item.key ?? "")-\(item.itemType ?? "")"] = item
            }
            return ownedItems
        }).on(value: {[weak self] items in
            self?.ownedItems = items
            self?.collectionView?.reloadData()
            }).start())
    }
    
    deinit {
        if let disposable = fetchGearDisposable {
            disposable.dispose()
        }
    }
    
    func loadCategories(_ categories: [ShopCategoryProtocol], isSubscribed: Bool) {
        for category in categories {
            let newSection = ItemSection<InAppRewardProtocol>(title: category.text)
            newSection.items = category.items.filter({ (inAppReward) -> Bool in
                if inAppReward.isSubscriberItem {
                    return isSubscribed
                }
                return true
            })
            sections.append(newSection)
        }
        collectionView?.reloadData()
    }
    
    private func fetchGear() {
        if !needsGearSection {
            return
        }
        if let disposable = fetchGearDisposable {
            disposable.dispose()
        }
        fetchGearDisposable = inventoryRepository.getShop(identifier: Constants.GearMarketKey)
            .map({ (shop) -> [InAppRewardProtocol] in
                return shop?.categories.first(where: {[weak self] (category) -> Bool in
                    category.identifier == self?.selectedInternalGearCategory
                })?.items ?? []
            })
            .combineLatest(with: inventoryRepository.getOwnedGear()
                .map({ (ownedGear, _) in
                    return ownedGear.map({ item -> String in
                        return item.key ?? ""
                    })
                })
            )
            .map({ (items, ownedGear) in
                return items.filter({ (item) -> Bool in
                    guard item.isValid, let key = item.key else {
                        return false
                    }
                    return !ownedGear.contains(key)
                })
            })
            .on(value: {[weak self] items in
                if (self?.sections.count ?? 0) > 0 {
                    self?.sections[0].items = items
                    self?.sections[0].showIfEmpty = true
                    self?.collectionView?.reloadData()
                }
        }).start()
    }
    
    func retrieveShopInventory(_ completed: (() -> Void)?) {
        inventoryRepository.retrieveShopInventory(identifier: shopIdentifier)
            .flatMap(.latest, {[weak self] (shop) -> Signal<ShopProtocol?, Never> in
                if shop?.identifier == Constants.MarketKey {
                    return self?.inventoryRepository.retrieveShopInventory(identifier: Constants.GearMarketKey) ?? Signal.empty
                } else {
                    let signal = Signal<ShopProtocol?, Never>.pipe()
                    signal.input.send(value: shop)
                    return signal.output
                }
            })
            .observeCompleted {
            if let action = completed {
                action()
            }
        }
    }
    
    // MARK: Collection view data source and delegate methods

    func titleFor(section: Int) -> String? {
        return visibleSections[section].title
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 && needsGearSection && !hasGearSection() {
            return 1
        } else {
            return super.collectionView(collectionView, numberOfItemsInSection: section)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "sectionHeader", for: indexPath
            ) as? HRPGShopSectionHeaderCollectionReusableView
        
        if let headerView = view {
            headerView.gearCategoryButton.isHidden = true
            headerView.otherClassDisclaimer.isHidden = true
            if indexPath.section == 0 && needsGearSection {
                headerView.titleLabel.text = L10n.Equipment.classEquipment
                headerView.gearCategoryLabel.text = selectedGearCategory?.capitalized
                headerView.gearCategoryButton.isHidden = false
                headerView.onGearCategoryLabelTapped = {[weak self] in
                    self?.delegate?.showGearSelection(sourceView: headerView.gearCategoryButton)
                }
                 headerView.otherClassDisclaimer.isHidden = userClass == selectedInternalGearCategory || selectedInternalGearCategory == "none"
                headerView.otherClassDisclaimer.text = L10n.Shops.otherClassDisclaimer
            } else {
                headerView.titleLabel.text = titleFor(section: indexPath.section)
                headerView.titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
            }
            headerView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
            return headerView
        }
        return UICollectionReusableView()
    }
   
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 && needsGearSection {
             if userClass != selectedInternalGearCategory {
                return CGSize(width: collectionView.bounds.width, height: 75)
            }
        }
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 && needsGearSection {
            if !hasGearSection() {
                return CGSize(width: collectionView.bounds.width, height: 80)
            }
        }
        return CGSize(width: 90, height: 120)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 && needsGearSection && !hasGearSection() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyGearCell", for: indexPath)
            (cell.viewWithTag(1) as? UILabel)?.text = L10n.Shops.purchasedAllGear
            cell.viewWithTag(2)?.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            return cell
        } else if let item = item(at: indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath)
            if let itemCell = cell as? InAppRewardCell {
                itemCell.configure(reward: item, user: user)
                if let ownedItem = ownedItems["\(item.key ?? "")-\(item.type ?? item.purchaseType ?? "")"] {
                    itemCell.itemsLeft = ownedItem.numberOwned
                }
                itemCell.isPinned = pinnedItems.contains(item.key)
            }
            return cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem(item(at: indexPath))
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
    
    private func hasGearSection() -> Bool {
        if let firstSection = sections.first {
            if let firstObject = firstSection.items.first {
                return firstObject.pinType == "marketGear"
            }
        }
        return false
    }
}
