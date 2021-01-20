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
    private var classSelected = false
    private var disabledClasses = false
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
        disposable.add(userRepository.getUser().on(value: {[weak self]user in
            self?.classSelected = user.flags?.classSelected ?? false
            self?.disabledClasses = user.preferences?.disableClasses ?? false
            if let stats = user.stats {
                self?.stats = stats
            }
        }).start())
        
        disposable.add(inventoryRepository.getOwnedItems(itemType: ItemType.special.rawValue)
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
        if (stats?.level ?? 0) >= 10 && !disabledClasses && classSelected {
        disposable.add(contentRepository.getSkills(habitClass: habitClass).on(value: {[weak self]result in
            self?.sections[0].items = result.value
            self?.notify(changes: result.changes)
        }).start())
        } else if disabledClasses {
            sections[0].items = [(L10n.classSystemDisabled, L10n.classSystemEnableInstructions)]
        } else if (stats?.level ?? 0) >= 10 {
            sections[0].items = [(L10n.unlocksSelectingClass, L10n.unlocksSelectingClassPrompt)]
        } else {
            sections[0].items = [(L10n.unlocksSelectingClass, L10n.unlocksSelectingClassDescription)]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let skill = item(at: indexPath) as? SkillProtocol
        let transformItem = item(at: indexPath) as? SpecialItemProtocol
        let canUse = (stats?.level ?? 0) >= (skill?.level ?? 1)
        var cellname = "SkillCell"
        if !canUse {
            cellname = "SkillLockedCell"
        } else if transformItem != nil {
            cellname = "TransformationItemCell"
        } else if skill == nil {
            cellname = "InformationCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellname, for: indexPath)
        if let skill = skill, let skillCell = cell as? SkillTableViewCell {
            if canUse {
                skillCell.configureUnlocked(skill: skill, manaLeft: stats?.mana ?? 0)
            } else {
                skillCell.configureLocked(skill: skill)
            }
        }
        if let skillCell = cell as? SkillTableViewCell, let item = transformItem {
            skillCell.configure(transformationItem: item, numberOwned: ownedItems[item.key ?? ""] ?? 0)
        }
        if let item = item(at: indexPath) as? (String, String) {
            let  theme = ThemeService.shared.theme
            cell.viewWithTag(4)?.backgroundColor = theme.windowBackgroundColor
            let titleLabel = cell.viewWithTag(1) as? UILabel
            titleLabel?.text = item.0
            titleLabel?.textColor = theme.primaryTextColor
            let messageLabel = cell.viewWithTag(2) as? UILabel
            messageLabel?.text = item.1
            messageLabel?.textColor = theme.secondaryTextColor
            cell.viewWithTag(3)?.isHidden = classSelected || disabledClasses || (stats?.level ?? 0) < 10
            cell.viewWithTag(3)?.tintColor = theme.tintColor
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
