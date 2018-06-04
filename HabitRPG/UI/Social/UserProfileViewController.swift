//
//  UserProfileViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
import Down

private struct StatsContainer {
    var strength: Double = 0
    var intelligence: Double = 0
    var constitution: Double = 0
    var perception: Double = 0
    
    static func + (left: StatsContainer, right: StatsContainer) -> StatsContainer {
        return StatsContainer(strength: left.strength + right.strength,
                              intelligence: left.intelligence + right.intelligence,
                              constitution: left.constitution + right.constitution,
                              perception: left.perception + right.perception)
    }
}

class UserProfileViewController: HRPGBaseViewController {
    
    private let socialRepository = SocialRepository()
    private let inventoryRepository = InventoryRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    @objc var userID: String?
    @objc var username: String?
    
    private var member: MemberProtocol? {
        didSet {
            tableView.reloadData()
        }
    }
    private var gearDictionary: [String: GearProtocol] = [:]
    private var isAttributesExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        
        navigationItem.title = username
        
        if let userID = userID {
            disposable.inner.add(socialRepository.getMember(userID: userID).on(value: {[weak self]member in
                self?.member = member
                self?.navigationItem.title = member?.profile?.name
            }).start())
        }
        
        disposable.inner.add(inventoryRepository.getGear().on(value: {[weak self]gear in
            self?.gearDictionary.removeAll()
            gear.value.forEach({ (gearItem) in
                self?.gearDictionary[gearItem.key ?? ""] = gearItem
            })
        }).start())
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    private func refresh() {
        if let userID = self.userID {
            socialRepository.retrieveMember(userID: userID).observeCompleted {}
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if member == nil {
            return 0
        } else {
            return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return L10n.Equipment.battleGear
        case 2:
            return L10n.Equipment.costume
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1, 2:
            return 8
        case 3:
            if isAttributesExpanded {
                return 7
            } else {
                return 2
            }
        default:
            return 0
        }
    }
    
    //swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellname = "Cell"
        switch indexPath.section {
        case 0:
            switch indexPath.item {
            case 0:
                cellname = "ProfileCell"
            case 1:
                cellname = "TextCell"
            case 2, 3:
                cellname = "SubtitleCell"
            default:
                break
            }
        case 1, 2:
            cellname = "EquipmentCell"
        case 3:
            if indexPath.item == 0 {
                cellname = "AttributeHeaderCell"
            } else {
                cellname = "AttributeCell"
            }
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellname, for: indexPath)
        switch indexPath.section {
        case 0:
            switch indexPath.item {
            case 0:
                configureUserStatsCell(cell)
            case 1:
                let textView = cell.viewWithTag(1) as? UITextView
                textView?.attributedText = try? Down(markdownString: member?.profile?.blurb ?? "").toHabiticaAttributedString()
            case 2:
                cell.textLabel?.text = L10n.Member.memberSince
                if let date = member?.authentication?.timestamps?.createdAt {
                    cell.detailTextLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
                }
            case 3:
                cell.textLabel?.text = L10n.Member.lastLoggedIn
                if let date = member?.authentication?.timestamps?.loggedIn {
                    cell.detailTextLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
                }
            default:
                break
            }
        case 1:
            if let outfit = member?.items?.gear?.equipped {
                configureEquipmentCell(cell, atIndex: indexPath.item, outfit: outfit)
            }
        case 2:
            if let outfit = member?.items?.gear?.costume {
                configureEquipmentCell(cell, atIndex: indexPath.item, outfit: outfit)
            }
        case 3:
            if indexPath.item > 0 {
                configureAttributeCell(cell, atIndex: indexPath.item)
            }
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3 {
            isAttributesExpanded = !isAttributesExpanded
            let rows = [IndexPath(item: 1, section: 3), IndexPath(item: 2, section: 3), IndexPath(item: 3, section: 3), IndexPath(item: 4, section: 3), IndexPath(item: 5, section: 3)]
            if isAttributesExpanded {
                tableView.insertRows(at: rows, with: .top)
            } else {
                tableView.deleteRows(at: rows, with: .top)
            }
        }
    }
    
    private func configureUserStatsCell(_ cell: UITableViewCell) {
        guard let member = self.member else {
            return
        }
        guard let stats = member.stats else {
            return
        }
        let levelLabel = cell.viewWithTag(1) as? UILabel
        levelLabel?.text = L10n.levelNumber(stats.level)
        
        let healthLabel = cell.viewWithTag(2) as? HRPGLabeledProgressBar
        healthLabel?.color = UIColor.red100()
        healthLabel?.icon = HabiticaIcons.imageOfHeartLightBg
        healthLabel?.type = L10n.health
        healthLabel?.value = NSNumber(value: stats.health)
        healthLabel?.maxValue = NSNumber(value: stats.maxHealth)
        
        let experienceLabel = cell.viewWithTag(3) as? HRPGLabeledProgressBar
        experienceLabel?.color = UIColor.yellow100()
        experienceLabel?.icon = HabiticaIcons.imageOfExperience
        experienceLabel?.type = L10n.experience
        experienceLabel?.value = NSNumber(value: stats.experience)
        experienceLabel?.maxValue = NSNumber(value: stats.toNextLevel)
        
        let magicLabel = cell.viewWithTag(4) as? HRPGLabeledProgressBar
        if stats.level >= 10 {
            magicLabel?.color = UIColor.blue100()
            magicLabel?.icon = HabiticaIcons.imageOfMagic
            magicLabel?.type = L10n.mana
            magicLabel?.value = NSNumber(value: stats.mana)
            magicLabel?.maxValue = NSNumber(value: stats.maxMana)
            magicLabel?.isHidden = false
        } else {
            magicLabel?.isHidden = true
        }
        let avatarView = cell.viewWithTag(8) as? AvatarView
        avatarView?.avatar = AvatarViewModel(avatar: member)
    }
    
    private func configureEquipmentCell(_ cell: UITableViewCell, atIndex index: Int, outfit: OutfitProtocol) {
        let typeLabel = cell.viewWithTag(1) as? UILabel
        let attributeLabel = cell.viewWithTag(2) as? UILabel
        let detailTextLabel = cell.viewWithTag(3) as? UILabel
        let imageView = cell.viewWithTag(4) as? UIImageView
        
        var equipmentKey: String?
        var typeName: String?
        
        switch index {
        case 0:
            equipmentKey = outfit.head
            typeName = L10n.Equipment.head
        case 1:
            equipmentKey = outfit.headAccessory
            typeName = L10n.Equipment.headAccessory
        case 2:
            equipmentKey = outfit.eyewear
            typeName = L10n.Equipment.eyewear
        case 3:
            equipmentKey = outfit.armor
            typeName = L10n.Equipment.armor
        case 4:
            equipmentKey = outfit.body
            typeName = L10n.Equipment.body
        case 5:
            equipmentKey = outfit.back
            typeName = L10n.Equipment.back
        case 6:
            equipmentKey = outfit.shield
            typeName = L10n.Equipment.offHand
        case 7:
            equipmentKey = outfit.weapon
            typeName = L10n.Equipment.weapon
        default:
            break
        }
        
        typeLabel?.text = typeName
        if let equipmentKey = equipmentKey {
            imageView?.setImagewith(name: "shop_\(equipmentKey)")
            let gear = gearDictionary[equipmentKey]
            detailTextLabel?.text = gear?.text
            detailTextLabel?.textColor = .black
            attributeLabel?.text = gear?.statsText
        } else {
            detailTextLabel?.text = L10n.Equipment.nothingEquipped
            detailTextLabel?.textColor = .gray
            attributeLabel?.text = nil
        }
    }
    
    private func configureAttributeCell(_ cell: UITableViewCell, atIndex index: Int) {
        let descriptionLabel = cell.viewWithTag(1) as? UILabel
        let strengthLabel = cell.viewWithTag(2) as? UILabel
        let intelligenceLabel = cell.viewWithTag(3) as? UILabel
        let constitutionLabel = cell.viewWithTag(4) as? UILabel
        let perceptionLabel = cell.viewWithTag(5) as? UILabel
        
        var values = StatsContainer()
        if (index == 1 && !isAttributesExpanded) || index == 6 {
            let levelValues = levelAttributes()
            let gearValues = gearAttributes()
            let classBonusValues = classBonusAttributes()
            let allocatedValues = allocatedAttributes()
            let buffedValues = buffedAttributes()
            
            values.strength = (levelValues + gearValues + classBonusValues + allocatedValues + buffedValues).strength
            values.intelligence = (levelValues + gearValues + classBonusValues + allocatedValues + buffedValues).intelligence
            values.constitution = (levelValues + gearValues + classBonusValues + allocatedValues + buffedValues).constitution
            values.perception = (levelValues + gearValues + classBonusValues + allocatedValues + buffedValues).perception
        } else if index == 1 {
            descriptionLabel?.text = L10n.Stats.level
            values = levelAttributes()
        } else if index == 2 {
            descriptionLabel?.text = L10n.Stats.battleGear
            values = gearAttributes()
        } else if index == 3 {
            descriptionLabel?.text = L10n.Stats.classBonus
            values = classBonusAttributes()
        } else if index == 4{
            descriptionLabel?.text = L10n.Stats.allocated
            values = allocatedAttributes()
        } else if index == 5 {
            descriptionLabel?.text = L10n.Stats.buffs
            values = buffedAttributes()
        }
        
        strengthLabel?.text = String(Int(values.strength))
        intelligenceLabel?.text = String(Int(values.intelligence))
        constitutionLabel?.text = String(Int(values.constitution))
        perceptionLabel?.text = String(Int(values.perception))
    }
    
    private func levelAttributes() -> StatsContainer {
        return StatsContainer(strength: Double(member?.stats?.level ?? 0) * 0.5,
                              intelligence: Double(member?.stats?.level ?? 0) * 0.5,
                              constitution: Double(member?.stats?.level ?? 0) * 0.5,
                              perception: Double(member?.stats?.level ?? 0) * 0.5)
    }
    
    private func allocatedAttributes() -> StatsContainer {
        return StatsContainer(strength: Double(member?.stats?.strength ?? 0),
                              intelligence: Double(member?.stats?.intelligence ?? 0),
                              constitution: Double(member?.stats?.constitution ?? 0),
                              perception: Double(member?.stats?.perception ?? 0))
    }
    
    private func buffedAttributes() -> StatsContainer {
        return StatsContainer(strength: Double(member?.stats?.buffs?.strength ?? 0),
                              intelligence: Double(member?.stats?.buffs?.intelligence ?? 0),
                              constitution: Double(member?.stats?.buffs?.constitution ?? 0),
                              perception: Double(member?.stats?.buffs?.perception ?? 0))
    }
    
    private func gearAttributes() -> StatsContainer {
        var strengthValue: Double = 0
        var intelligenceValue: Double = 0
        var constitutionValue: Double = 0
        var perceptionValue: Double = 0
        
        for gear in battleGearList() {
            strengthValue += Double(gear?.strength ?? 0)
            intelligenceValue += Double(gear?.intelligence ?? 0)
            constitutionValue += Double(gear?.constitution ?? 0)
            perceptionValue += Double(gear?.perception ?? 0)
        }
        return StatsContainer(strength: strengthValue, intelligence: intelligenceValue, constitution: constitutionValue, perception: perceptionValue)
    }
    
    private func classBonusAttributes() -> StatsContainer {
        var strengthValue: Double = 0
        var intelligenceValue: Double = 0
        var constitutionValue: Double = 0
        var perceptionValue: Double = 0
        
        for gear in battleGearList() where gear?.habitClass == member?.stats?.habitClass {
            strengthValue += Double(gear?.strength ?? 0)
            intelligenceValue += Double(gear?.intelligence ?? 0)
            constitutionValue += Double(gear?.constitution ?? 0)
            perceptionValue += Double(gear?.perception ?? 0)
        }
        return StatsContainer(strength: strengthValue, intelligence: intelligenceValue, constitution: constitutionValue, perception: perceptionValue)
    }
    
    private func battleGearList() -> [GearProtocol?] {
        var gearList = [GearProtocol?]()
        guard let outfit = member?.items?.gear?.equipped else {
            return gearList
        }
        if let key = outfit.head {
            gearList.append(gearDictionary[key])
        }
        if let key = outfit.headAccessory {
            gearList.append(gearDictionary[key])
        }
        if let key = outfit.eyewear {
            gearList.append(gearDictionary[key])
        }
        if let key = outfit.armor {
            gearList.append(gearDictionary[key])
        }
        if let key = outfit.body {
            gearList.append(gearDictionary[key])
        }
        if let key = outfit.shield {
            gearList.append(gearDictionary[key])
        }
        if let key = outfit.weapon {
            gearList.append(gearDictionary[key])
        }
        return gearList
    }
}
