//
//  ItemsViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class ItemsViewDataSource: BaseReactiveTableViewDataSource<ItemProtocol> {

    var itemType: String? {
        didSet {
            if itemType != nil {
                sections.forEach { section in
                    section.isHidden = section.key != itemType
                }
            } else {
                sections.forEach { section in
                    section.isHidden = false
                }
            }
            tableView?.reloadData()
        }
    }
    
    private let inventoryRepository = InventoryRepository()
    private let stableRepository = StableRepository()
    private let userRepository = UserRepository()
    private var fetchDisposable: Disposable?
    
    private var ownedItems = [String: Int]()
    private var ownedPets = [String]()
    private var pets = [String]()
    
    var hatchingItem: ItemProtocol?
    var isHatching = false {
        didSet {
            if isHatching {
                if hatchingItem?.itemType == ItemType.eggs.rawValue {
                    sections[0].isHidden = true
                    sections[2].isHidden = false
                } else if hatchingItem?.itemType == ItemType.hatchingPotions.rawValue {
                    sections[0].isHidden = false
                    sections[2].isHidden = true
                }
                sections[1].isHidden = true
                sections[3].isHidden = true
                sections[4].isHidden = true
            } else {
                sections[0].isHidden = false
                sections[1].isHidden = false
                sections[2].isHidden = false
                sections[3].isHidden = false
                sections[4].isHidden = false
            }
            self.tableView?.reloadData()
        }
    }
    
    override init() {
        super.init()
        sections.append(ItemSection<ItemProtocol>(key: "eggs", title: L10n.eggs))
        sections.append(ItemSection<ItemProtocol>(key: "food", title: L10n.food))
        sections.append(ItemSection<ItemProtocol>(key: "hatchingPotions", title: L10n.hatchingPotions))
        sections.append(ItemSection<ItemProtocol>(key: "special", title: L10n.specialItems))
        sections.append(ItemSection<ItemProtocol>(key: "quests", title: L10n.quests))
        
        sections.forEach { section in
            section.showIfEmpty = true
        }
        
        fetchItems()
        
        disposable.add(stableRepository.getOwnedPets()
            .map({ pets -> [String] in
                return pets.value.filter({ ownedPet -> Bool in
                    return ownedPet.isOwned
                }).map({ (ownedPet) in
                    return ownedPet.key ?? ""
                })
            })
            .on(value: {[weak self]ownedPets in
                self?.ownedPets = ownedPets
        }).start())
        disposable.add(stableRepository.getPets()
            .map({ pets -> [String] in
                return pets.value.map({ (pet) in
                    return pet.key ?? ""
                })
            })
            .on(value: {[weak self]pets in
                self?.pets = pets
            }).start())
    }
    
    private func fetchItems() {
        if let disposable = fetchDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
        DispatchQueue.main.async {[weak self] in
            self?.fetchDisposable = self?.inventoryRepository.getOwnedItems().combineLatest(with: self?.userRepository.getUser().flatMapError({ _ in
                return SignalProducer.empty
            }) ?? SignalProducer.empty)
            .on(value: {[weak self] (ownedItems, user) in
                self?.ownedItems.removeAll()
                ownedItems.value.forEach({ (item) in
                    self?.ownedItems[(item.key ?? "") + (item.itemType ?? "")] = item.numberOwned
                })
                if let mysteryItemCount = user.purchased?.subscriptionPlan?.mysteryItems.count, mysteryItemCount > 0 {
                    self?.ownedItems["inventory_presentspecial"] = mysteryItemCount
                }
            })
                .map({ (data, user) -> [ItemType: [String]] in
                var keys: [ItemType: [String]] = [
                    ItemType.eggs: [String](),
                    ItemType.food: [String](),
                    ItemType.hatchingPotions: [String](),
                    ItemType.quests: [String](),
                    ItemType.special: [String]()
                ]
                data.value.forEach({ ownedItem in
                    if let key = ownedItem.key, let itemType = ItemType(rawValue: ownedItem.itemType ?? "") {
                        keys[itemType]?.append(key)
                    }
                })
                if let mysteryItemCount = user.purchased?.subscriptionPlan?.mysteryItems.count, mysteryItemCount > 0 {
                    keys[ItemType.special]?.append("inventory_present")
                }
                return keys
            })
            .flatMap(.latest, {[weak self] (keys) in
                return self?.inventoryRepository.getItems(keys: keys) ?? SignalProducer.empty
            })
            .on(value: {[weak self](eggs, food, hatchingPotions, specialItems, quests) in
                self?.sections[0].items = eggs.value
                self?.notify(changes: eggs.changes)
                self?.sections[1].items = food.value
                self?.notify(changes: food.changes, section: 1)
                self?.sections[2].items = hatchingPotions.value
                self?.notify(changes: hatchingPotions.changes, section: 2)
                self?.sections[3].items = specialItems.value
                self?.notify(changes: specialItems.changes, section: 3)
                self?.sections[4].items = quests.value
                self?.notify(changes: quests.changes, section: 4)
            })
            .start()
        }
    }
    
    deinit {
        if let disposable = fetchDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return visibleSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = visibleSections[section].items.count
        // swiftlint:disable:next empty_count
        if count == 0 {
            count = 1
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if visibleSections.isEmpty {
            return nil
        }
        return visibleSections[section].title
    }
    
    override func item(at indexPath: IndexPath?) -> ItemProtocol? {
        guard let indexPath = indexPath else {
            return nil
        }
        if indexPath.item < 0 || indexPath.section < 0 {
            return nil
        }
        if indexPath.section < visibleSections.count {
            if indexPath.item < visibleSections[indexPath.section].items.count {
                return visibleSections[indexPath.section].items[indexPath.item]
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theme = ThemeService.shared.theme
        if let ownedItem = item(at: indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

            cell.backgroundColor = theme.windowBackgroundColor
            let label = cell.viewWithTag(1) as? UILabel
            label?.text = ownedItem.text
            label?.textColor = theme.primaryTextColor
            let detailLabel = cell.viewWithTag(2) as? UILabel
            detailLabel?.text = "\(ownedItems[(ownedItem.key ?? "") + (ownedItem.itemType ?? "")] ?? 0)"
            detailLabel?.textColor = theme.secondaryTextColor
            let imageView = cell.viewWithTag(3) as? NetworkImageView
            imageView?.setImagewith(name: ownedItem.imageName)
            
            imageView?.alpha = 1.0
            label?.alpha = 1.0
            if isHatching, let hatchingItem = self.hatchingItem {
                if !canHatch(ownedItem, otherItem: hatchingItem) {
                    imageView?.alpha = 0.3
                    label?.alpha = 0.3
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath)
            cell.backgroundColor = theme.windowBackgroundColor
            let imageView = cell.viewWithTag(23) as? UIImageView
            let titleView = cell.viewWithTag(24) as? UILabel
            titleView?.textColor = theme.primaryTextColor
            let descriptionView = cell.viewWithTag(25) as? UILabel
            descriptionView?.textColor = theme.secondaryTextColor
            titleView?.text = L10n.noX(self.tableView(tableView, titleForHeaderInSection: indexPath.section) ?? L10n.Titles.items)
            let text: String
            if itemType == "quests" {
                imageView?.image = Asset.Empty.quests.image
                text = L10n.Items.Empty.questDescription
            } else {
                switch indexPath.section {
                case 0:
                    imageView?.image = Asset.Empty.eggs.image
                    text = L10n.Items.Empty.eggDescription
                case 1:
                    imageView?.image = Asset.Empty.food.image
                    text = L10n.Items.Empty.foodDescription
                case 2:
                    imageView?.image = Asset.Empty.hatchingPotions.image
                    text = L10n.Items.Empty.potionDescription
                case 3:
                    imageView?.image = Asset.Empty.special.image
                    text = L10n.Items.Empty.specialDescription
                case 4:
                    imageView?.image = Asset.Empty.quests.image
                    text = L10n.Items.Empty.questDescription
                default:
                    return cell
                }
            }
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.highlightWords(words: L10n.Locations.market, L10n.Locations.questShop, L10n.subscribe)

            descriptionView?.attributedText = attributedText
            return cell
        }
    }
    
    func canHatch(_ firstItem: ItemProtocol, otherItem: ItemProtocol) -> Bool {
        guard let egg = firstItem as? EggProtocol ?? otherItem as? EggProtocol else {
            return false
        }
        guard let potion = firstItem as? HatchingPotionProtocol ?? otherItem as? HatchingPotionProtocol else {
            return false
        }
        if ownedPets.contains("\(egg.key ?? "")-\(potion.key ?? "")") || (egg.key == "Gryphon" && potion.key == "RoyalPurple") {
            return false
        }
        if let egg = firstItem as? EggProtocol, let potion = otherItem as? HatchingPotionProtocol {
            return pets.contains("\(egg.key ?? "")-\(potion.key ?? "")")
        } else if let egg = otherItem as? EggProtocol, let potion = firstItem as? HatchingPotionProtocol {
            return pets.contains("\(egg.key ?? "")-\(potion.key ?? "")")
        }
        return false
    }
}
