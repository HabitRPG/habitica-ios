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
protocol ShopCollectionViewDataSourceDelegate {
    func didSelectItem(_ item: InAppRewardProtocol?, indexPath: IndexPath)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func showGearSelection(sourceView: UIView)
    func updateShopHeader(shop: ShopProtocol?)
    func updateNavBar(gold: Int, gems: Int, hourglasses: Int)
}

class ShopCollectionViewDataSource: BaseReactiveCollectionViewDataSource<InAppRewardProtocol> {
    @objc weak var delegate: ShopCollectionViewDataSourceDelegate?
    
    private var userRepository = UserRepository()
    var inventoryRepository = InventoryRepository()
    private var fetchGearDisposable: Disposable?
    
    private var ownedItems = [String: OwnedItemProtocol]()
    private var pinnedItems = [String?]()
    private var completedQuests = [String?]()
    private var user: UserProtocol?
    private var userClass: String? {
        return user?.stats?.habitClass
    }
    private var armoireCount = 0
    
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
            self?.loadCategories(shop?.categories ?? [])
            self?.delegate?.updateShopHeader(shop: shop)
            
            self?.user = user
            if self?.selectedGearCategory == nil {
                self?.selectedGearCategory = self?.userClass
            }
            self?.delegate?.updateNavBar(gold: Int(user.stats?.gold ?? 0), gems: user.gemCount, hourglasses: user.purchased?.subscriptionPlan?.consecutive?.hourglasses ?? 0)
        }).start())
        
        disposable.add(userRepository.getInAppRewards()
            .map({ (rewards, _) in
                return rewards.map({ (reward) in
                    return reward.key
                })
            }).on(value: {[weak self]rewards in
                self?.pinnedItems = rewards
            }).start())
        
        disposable.add(userRepository.getAchievements().map { achievements in
            achievements.value.filter { $0.optionalCount > 0 && $0.isQuestAchievement }
        }.on(value: {[weak self] achievements in
            self?.completedQuests = achievements.map({ $0.key })
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
        
        disposable.add(inventoryRepository.getArmoireRemainingCount().on(value: {[weak self] count in
            self?.armoireCount = count.value.count
        }).start())
    }
    
    deinit {
        if let disposable = fetchGearDisposable {
            disposable.dispose()
        }
    }
    
    func loadCategories(_ categories: [ShopCategoryProtocol]) {
        for category in categories {
            let newSection = ItemSection<InAppRewardProtocol>(title: category.text)
            newSection.items = category.items
            newSection.key = category.identifier
            newSection.endDate = category.endDate
            newSection.showIfEmpty = true
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
            let sectionCount = super.collectionView(collectionView, numberOfItemsInSection: section)
            if sectionCount == 0 {
                return 1
            }
            return sectionCount
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "sectionHeader", for: indexPath
            ) as? HRPGShopSectionHeaderCollectionReusableView
        
        if let headerView = view {
            if indexPath.section == 0 && needsGearSection {
                let selectedClassName = ifWizardConvertToMage(selectedGearCategory)?.capitalized ?? ""
                headerView.titleLabel.text = L10n.Equipment.classEquipment.localizedUppercase
                headerView.setSecondRow(className: selectedClassName, classColor: .backgroundColorFor(habiticaClass: selectedGearCategory))
                headerView.onGearCategoryLabelTapped = {[weak self] in
                    self?.delegate?.showGearSelection(sourceView: headerView.gearCategoryLabel)
                }
                if userClass == selectedInternalGearCategory || selectedInternalGearCategory == "none" {
                    headerView.otherClassDisclaimer.isHidden = true
                    headerView.changeClassWrapper.isHidden = true
                } else {
                    headerView.newClassName = selectedClassName
                    headerView.onClassChange = {
                        let selectedClass = self.selectedInternalGearCategory
                        self.userRepository.selectClass(HabiticaClass(rawValue: selectedClass ?? "")).observeValues { _ in
                            self.retrieveShopInventory {
                                self.fetchGear()
                            }
                            collectionView.reloadData()
                        }
                    }
                    headerView.otherClassDisclaimer.isHidden = false
                    headerView.otherClassDisclaimer.text = L10n.Shops.otherClassDisclaimer
                    headerView.changeClassWrapper.isHidden = false
                    headerView.changeClassWrapper.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
                    headerView.changeClassTitle?.text = L10n.changeClassTo(selectedClassName)
                    headerView.changeClassTitle?.textColor = ThemeService.shared.theme.primaryTextColor
                    headerView.changeClassSubtitle?.text = L10n.unlockXGearAndSkills(selectedClassName)
                    headerView.changeClassSubtitle?.textColor = ThemeService.shared.theme.ternaryTextColor
                    headerView.changeClassPriceLabel?.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
                    headerView.changeClassPriceLabel?.currency = .gem
                    headerView.changeClassPriceLabel?.amount = 3
                }
            } else {
                let section = visibleSections[indexPath.section]
                if let endDate = section.endDate {
                    headerView.swapsInLabel.isHidden = false
                    headerView.setSecondRow(date: endDate)
                } else {
                    headerView.hideSecondRow()
                }
                headerView.titleLabel.text = titleFor(section: indexPath.section)?.localizedUppercase
                headerView.otherClassDisclaimer.isHidden = true
            }
            headerView.setNeedsLayout()
            headerView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
            if ThemeService.shared.theme.isDark {
                headerView.backgroundView.backgroundColor = UIColor("#55311D")
            } else {
                headerView.backgroundView.backgroundColor = UIColor("#B36213")
            }
            return headerView
        }
        return UICollectionReusableView()
    }

    private func ifWizardConvertToMage(_ category: String?) -> String? {
        return category == "wizard" ? "mage" : category
    }
   
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 && needsGearSection {
            if userClass != selectedInternalGearCategory {
                return CGSize(width: collectionView.bounds.width, height: 170)
            } else {
                return CGSize(width: collectionView.bounds.width, height: 75)
            }
        }
        let section = visibleSections[section]
        if section.endDate != nil {
            return CGSize(width: collectionView.bounds.width, height: 75)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 40)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 && needsGearSection {
            if !hasGearSection() {
                return CGSize(width: collectionView.bounds.width, height: 200)
            }
        }
        let section = visibleSections[indexPath.section]
        if section.items.isEmpty {
            let attributedString = attributedStringInEmptySection(section: section)
            let size = attributedString.boundingRect(with: CGSize(width: collectionView.bounds.width - 60, height: 200), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            return CGSize(width: collectionView.bounds.width, height: size.height + 30 + 34)
        }
        return CGSize(width: 90, height: 120)
    }
    
    private func attributedStringInEmptySection(section: ItemSection<InAppRewardProtocol>) -> NSAttributedString {
        var str = ""
        if section.key == "backgrounds" {
            str = L10n.Shops.tryOnCustomizeAvatarReturnNextMonth
        } else if section.key == "color" || section.key == "skin" {
            str = L10n.Shops.tryOnCustomizeAvatarReturnNextSeason
        } else if section.key == "mystery_sets" {
            str = L10n.Shops.tryOnEquipment
        } else {
            str = L10n.Shops.tryOnCustomizeAvatar
        }
        let att = NSMutableAttributedString(string: str)
        att.addAttribute(.font, value: UIFont.systemFont(ofSize: 14))
        for word in [L10n.Equipment.equipment, L10n.Shops.customizingYourAvatar] {
            let range = att.mutableString.range(of: word)
            if range.length > 0 {
                att.addAttribute(NSAttributedString.Key.foregroundColor, value: ThemeService.shared.theme.tintColor, range: range)
            }
        }
        return att
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 && needsGearSection && !hasGearSection() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyItemCell", for: indexPath)
            let className = userClass?.translatedClassName ?? ""
            (cell.viewWithTag(1) as? UILabel)?.text = L10n.Shops.purchasedAllGearTitle(className)
            (cell.viewWithTag(1) as? UILabel)?.textColor = ThemeService.shared.theme.primaryTextColor
            if armoireCount == 0 {
                (cell.viewWithTag(2) as? UILabel)?.text = L10n.Shops.purchasedAllGearArmoireEmpty
                cell.viewWithTag(4)?.isHidden = true
                cell.viewWithTag(5)?.isHidden = true
                cell.viewWithTag(9)?.isHidden = true
            } else {
                (cell.viewWithTag(2) as? UILabel)?.text = L10n.Shops.purchasedAllGear(armoireCount)
                cell.viewWithTag(4)?.isHidden = false
                if let imageView = (cell.viewWithTag(4)) as? NetworkImageView {
                    ImageManager.setImage(on: imageView, name: "shop_armoire")
                }
                cell.viewWithTag(5)?.isHidden = false
                (cell.viewWithTag(8) as? UIImageView)?.image = HabiticaIcons.imageOfGold
                cell.viewWithTag(9)?.isHidden = false
            }
            (cell.viewWithTag(2) as? UILabel)?.textColor = ThemeService.shared.theme.secondaryTextColor
            cell.viewWithTag(3)?.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            cell.viewWithTag(5)?.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor.withAlphaComponent(0.3)
            (cell.viewWithTag(6) as? UILabel)?.textColor = ThemeService.shared.theme.isDark ? .yellow500 : .yellow1
            return cell
        } else if let item = item(at: indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath)
            if let itemCell = cell as? InAppRewardCell {
                itemCell.configure(reward: item, user: user)
                if let ownedItem = ownedItems["\(item.key ?? "")-\(item.type ?? item.purchaseType ?? "")"] {
                    itemCell.itemCount = ownedItem.numberOwned
                }
                itemCell.isPinned = pinnedItems.contains(item.key)
                if item.type == "quests" || item.pinType == "quests" {
                    itemCell.isChecked = completedQuests.contains(item.key)
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyItemCell", for: indexPath)
            (cell.viewWithTag(1) as? UILabel)?.text = L10n.Shops.ownAllItems
            (cell.viewWithTag(1) as? UILabel)?.textColor = ThemeService.shared.theme.primaryTextColor
            let section = visibleSections[indexPath.section]
            (cell.viewWithTag(2) as? UILabel)?.textColor = ThemeService.shared.theme.secondaryTextColor
            (cell.viewWithTag(2) as? UILabel)?.attributedText = attributedStringInEmptySection(section: section)
            cell.viewWithTag(3)?.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            cell.viewWithTag(4)?.isHidden = true
            cell.viewWithTag(5)?.isHidden = true
            cell.viewWithTag(9)?.isHidden = true
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem(item(at: indexPath), indexPath: indexPath)
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
