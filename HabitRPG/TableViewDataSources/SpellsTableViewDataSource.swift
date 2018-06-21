//
//  SpellsTableViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

@objc public protocol SpellsTableViewDataSourceProtocol {
    @objc weak var tableView: UITableView? { get set }
    
    @objc
    func useSkill(skill: SkillProtocol, targetId: String?)
    @objc
    func canUse(skill: SkillProtocol?) -> Bool
    @objc
    func hasManaFor(skill: SkillProtocol?) -> Bool
    @objc
    func skillAt(indexPath: IndexPath) -> SkillProtocol?
    @objc
    func itemAt(indexPath: IndexPath) -> SpecialItemProtocol?
    @objc
    func canUse(item: SpecialItemProtocol?) -> Bool
    @objc
    func useItem(item: SpecialItemProtocol, targetId: String?)
}

@objc
class SpellsTableViewDataSourceInstantiator: NSObject {
    @objc
    static func instantiate() -> SpellsTableViewDataSourceProtocol {
        return SpellsTableViewDataSource()
    }
}

class SpellsTableViewDataSource: BaseReactiveTableViewDataSource<Any>, SpellsTableViewDataSourceProtocol {
    
    private var userRepository = UserRepository()
    private var inventoryRepository = InventoryRepository()
    private var contentRepository = ContentRepository()
    private var stats: StatsProtocol? {
        didSet {
            habitClass = stats?.habitClass
            tableView?.reloadData()
        }
    }
    private var habitClass: String? {
        didSet {
            if habitClass == oldValue {
                return
            }
            if let habitClass = habitClass {
                DispatchQueue.main.async {[weak self] in
                    self?.getSkills(habitClass: habitClass)
                }
            }
        }
    }
    private var ownedItems = [String: Int]()

    override init() {
        super.init()
        sections.append(ItemSection<Any>())
        sections.append(ItemSection<Any>(title: L10n.Skills.transformationItems))
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            if let stats = user.stats {
                self?.stats = stats
            }
        }).start())
        
        disposable.inner.add(inventoryRepository.getOwnedItems(itemType: ItemType.special.rawValue)
            .on(value: {[weak self]ownedItems in
                self?.ownedItems.removeAll()
                ownedItems.value.forEach({ (item) in
                    self?.ownedItems[(item.key ?? "")] = item.numberOwned
                })
            })
            .map({ (data) -> [String] in
                return data.value.map({ ownedItem -> String in
                    return ownedItem.key ?? ""
                }).filter({ (key) -> Bool in
                    return !key.isEmpty
                })
            })
            .delay(0.1, on: QueueScheduler.main)
            .flatMap(.latest, {[weak self] (keys) in
                return self?.inventoryRepository.getSpecialItems(keys: keys) ?? SignalProducer.empty
            })
            .on(value: {[weak self](items) in
                self?.sections[1].items = items.value
                self?.notify(changes: items.changes)
            }).start())
    }
    
    private func getSkills(habitClass: String) {
        disposable.inner.add(contentRepository.getSkills(habitClass: habitClass).on(value: {[weak self]result in
            self?.sections[0].items = result.value
            self?.notify(changes: result.changes)
        }).start())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let skill = item(at: indexPath) as? SkillProtocol
        let canUse = (stats?.level ?? 0) >= (skill?.level ?? 1)
        var cellname = "SkillCell"
        if !canUse {
            cellname = "SkillLockedCell"
        } else if skill == nil {
            cellname = "TransformationItemCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellname, for: indexPath)
        if let skill = skill, let skillCell = cell as? SkillTableViewCell {
            if canUse {
                skillCell.configureUnlocked(skill: skill, manaLeft: stats?.mana ?? 0)
            } else {
                skillCell.configureLocked(skill: skill)
            }
        }
        if let item = item(at: indexPath) as? SpecialItemProtocol, let skillCell = cell as? SkillTableViewCell {
            skillCell.configure(transformationItem: item, numberOwned: ownedItems[item.key ?? ""] ?? 0)
        }
        return cell
    }
    
    @objc
    func useSkill(skill: SkillProtocol, targetId: String?) {
        userRepository.useSkill(skill: skill, targetId: targetId).observeCompleted {}
    }
    
    @objc
    func canUse(skill: SkillProtocol?) -> Bool {
        return (stats?.level ?? 0) >= (skill?.level ?? 0)
        
    }
    
    @objc
    func hasManaFor(skill: SkillProtocol?) -> Bool {
        return (stats?.mana ?? 0) >= Float(skill?.mana ?? 0)
    }
    
    @objc
    func skillAt(indexPath: IndexPath) -> SkillProtocol? {
        return item(at: indexPath) as? SkillProtocol
    }
    
    @objc
    func itemAt(indexPath: IndexPath) -> SpecialItemProtocol? {
        return item(at: indexPath) as? SpecialItemProtocol
    }
    
    @objc
    func canUse(item: SpecialItemProtocol?) -> Bool {
        return (ownedItems[item?.key ?? ""] ?? 0) > 0
    }
    
    @objc
    func useItem(item: SpecialItemProtocol, targetId: String?) {
        if let targetId = targetId {
            userRepository.useTransformationItem(item: item, targetId: targetId).observeCompleted {}
        }
    }
}
