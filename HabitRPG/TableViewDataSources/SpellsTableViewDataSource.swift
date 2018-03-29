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

class SpellsTableViewDataSource: BaseReactiveDataSource, UITableViewDataSource {
    
    private var userRepository = UserRepository()
    private var contentRepository = ContentRepository()
    
    private var skills = [SkillProtocol]() {
        didSet {
            tableView?.reloadData()
        }
    }
    private var stats: StatsProtocol? {
        didSet {
            if let habitClass = stats?.habitClass {
                getSkills(habitClass: habitClass)
            }
        }
    }
    
    @objc weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.reloadData()
        }
    }
    
    override init() {
        super.init()
        disposable.inner.add(userRepository.getUser().on(value: { user in
            if let stats = user.stats {
                self.stats = stats
            }
        }).start())
    }
    
    private func getSkills(habitClass: String) {
        disposable.inner.add(contentRepository.getSkills(habitClass: habitClass).on(value: { result in
            self.skills = result.value
        }).start())
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let skill = itemAt(indexPath: indexPath)
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
    func itemAt(indexPath: IndexPath) -> SkillProtocol? {
        if indexPath.section == 0 {
            return skills[indexPath.item]
        }
        return nil
    }
}
