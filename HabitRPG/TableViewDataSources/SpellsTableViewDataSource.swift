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
    func canUse(skill: SkillProtocol) -> Bool
    @objc
    func hasManaFor(skill: SkillProtocol) -> Bool
    @objc
    func skillAt(indexPath: IndexPath) -> SkillProtocol?
}

@objc
class SpellsTableViewDataSourceInstantiator: NSObject {
    @objc
    static func instantiate() -> SpellsTableViewDataSourceProtocol {
        return SpellsTableViewDataSource()
    }
}

class SpellsTableViewDataSource: BaseReactiveTableViewDataSource<SkillProtocol>, SpellsTableViewDataSourceProtocol {
    
    private var userRepository = UserRepository()
    private var contentRepository = ContentRepository()
    private var stats: StatsProtocol? {
        didSet {
            if let habitClass = stats?.habitClass {
                getSkills(habitClass: habitClass)
            }
        }
    }
    
    override init() {
        super.init()
        sections.append(ItemSection<SkillProtocol>())
        disposable.inner.add(userRepository.getUser().on(value: { user in
            if let stats = user.stats {
                self.stats = stats
            }
        }).start())
    }
    
    private func getSkills(habitClass: String) {
        disposable.inner.add(contentRepository.getSkills(habitClass: habitClass).on(value: { result in
            self.sections[0].items = result.value
            self.notifyDataUpdate(tableView: self.tableView, changes: result.changes)
        }).start())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let skill = item(at: indexPath)
        let canUse = (stats?.level ?? 0) >= (skill?.level ?? 1)
        let cell = tableView.dequeueReusableCell(withIdentifier: canUse ? "SkillCell": "SkillLockedCell", for: indexPath)
        if let skill = skill, let skillCell = cell as? SkillTableViewCell {
            if canUse {
                skillCell.configureUnlocked(skill: skill)
            } else {
                skillCell.configureLocked(skill: skill)
            }
        }
        return cell
    }
    
    @objc
    func useSkill(skill: SkillProtocol, targetId: String?) {
        userRepository.useSkill(skill: skill, targetId: targetId).observeCompleted {}
    }
    
    @objc
    func canUse(skill: SkillProtocol) -> Bool {
        return (stats?.level ?? 0) >= skill.level
    }
    
    @objc
    func hasManaFor(skill: SkillProtocol) -> Bool {
        return (stats?.mana ?? 0) >= Float(skill.mana)
    }
    
    @objc
    func skillAt(indexPath: IndexPath) -> SkillProtocol? {
        return item(at: indexPath)
    }
}
