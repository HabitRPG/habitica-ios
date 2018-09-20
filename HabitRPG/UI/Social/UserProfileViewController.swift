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
import Result

class UserProfileViewController: HRPGBaseViewController {
    
    private let socialRepository = SocialRepository()
    private let inventoryRepository = InventoryRepository()
    var interactor = CalculateUserStatsInteractor()
    private let (lifetime, token) = Lifetime.make()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    @objc var userID: String?
    @objc var username: String?
    
    private var member: MemberProtocol? {
        didSet {
            tableView.reloadData()
        }
    }
    private var calculatedStats = CalculatedUserStats() {
        didSet {
            tableView.reloadData()
        }
    }
    private var gearDictionary: [String: GearProtocol] = [:]
    private var isAttributesExpanded = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        
        navigationItem.title = username
        
        let subscriber = Signal<CalculatedUserStats, NSError>.Observer(value: {[weak self] stats in
            self?.calculatedStats = stats
        })
        
        disposable.inner.add(interactor.reactive.take(during: lifetime).observe(subscriber))
        
        disposable.inner.add(inventoryRepository.getGear().on(value: {[weak self]gear in
            self?.gearDictionary.removeAll()
            gear.value.forEach({ (gearItem) in
                self?.gearDictionary[gearItem.key ?? ""] = gearItem
            })
        }).start())
        
        if let userID = userID {
            disposable.inner.add(socialRepository.getMember(userID: userID).skipNil().flatMap(.latest, { (member) in
                return self.fetchGearStats(member: member)
            }).on(value: {[weak self] (member, gear) in
                self?.member = member
                self?.navigationItem.title = member.profile?.name
                if let stats = member.stats {
                    self?.interactor.run(with: (stats, gear))
                }
            }).start())
        }
        
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
        
        let healthLabel = cell.viewWithTag(2) as? LabeledProgressBar
        healthLabel?.color = UIColor.red100()
        healthLabel?.icon = HabiticaIcons.imageOfHeartLightBg
        healthLabel?.type = L10n.health
        healthLabel?.value = NSNumber(value: stats.health)
        healthLabel?.maxValue = NSNumber(value: stats.maxHealth)
        
        let experienceLabel = cell.viewWithTag(3) as? LabeledProgressBar
        experienceLabel?.color = UIColor.yellow100()
        experienceLabel?.icon = HabiticaIcons.imageOfExperience
        experienceLabel?.type = L10n.experience
        experienceLabel?.value = NSNumber(value: stats.experience)
        experienceLabel?.maxValue = NSNumber(value: stats.toNextLevel)
        
        let magicLabel = cell.viewWithTag(4) as? LabeledProgressBar
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
        
        var strength = 0
        var intelligence = 0
        var constitution = 0
        var perception = 0
        if (index == 1 && !isAttributesExpanded) || index == 6 {
            strength = calculatedStats.totalStrength
            intelligence = calculatedStats.totalIntelligence
            constitution = calculatedStats.totalConstitution
            perception = calculatedStats.totalPerception
        } else if index == 1 {
            descriptionLabel?.text = L10n.Stats.level
            strength = calculatedStats.levelStat
            intelligence = calculatedStats.levelStat
            constitution = calculatedStats.levelStat
            perception = calculatedStats.levelStat
        } else if index == 2 {
            descriptionLabel?.text = L10n.Stats.battleGear
            strength = calculatedStats.gearStrength
            intelligence = calculatedStats.gearIntelligence
            constitution = calculatedStats.gearConstitution
            perception = calculatedStats.gearPerception
        } else if index == 3 {
            descriptionLabel?.text = L10n.Stats.classBonus
            strength = calculatedStats.gearBonusStrength
            intelligence = calculatedStats.gearBonusIntelligence
            constitution = calculatedStats.gearBonusConstitution
            perception = calculatedStats.gearBonusPerception
        } else if index == 4 {
            descriptionLabel?.text = L10n.Stats.allocated
            strength = calculatedStats.allocatedStrength
            intelligence = calculatedStats.allocatedIntelligence
            constitution = calculatedStats.allocatedConstitution
            perception = calculatedStats.allocatedPerception
        } else if index == 5 {
            descriptionLabel?.text = L10n.Stats.buffs
            strength = calculatedStats.buffStrength
            intelligence = calculatedStats.buffIntelligence
            constitution = calculatedStats.buffConstitution
            perception = calculatedStats.buffPerception
        }
        
        strengthLabel?.text = String(strength)
        intelligenceLabel?.text = String(intelligence)
        constitutionLabel?.text = String(constitution)
        perceptionLabel?.text = String(perception)
    }
    
    private func fetchGearStats(member: MemberProtocol) -> SignalProducer<(MemberProtocol, [GearProtocol]), NoError> {
        var keys = [String]()
        if let outfit = member.items?.gear?.equipped {
            keys.append(outfit.armor ?? "")
            keys.append(outfit.back ?? "")
            keys.append(outfit.body ?? "")
            keys.append(outfit.eyewear ?? "")
            keys.append(outfit.head ?? "")
            keys.append(outfit.headAccessory ?? "")
            keys.append(outfit.weapon ?? "")
            keys.append(outfit.shield ?? "")
        }
        
        let gearProducer = inventoryRepository.getGear(predicate: NSPredicate(format: "key in %@", keys)).map({ gear in
            return gear.value
        }).flatMapError({ (_) -> SignalProducer<[GearProtocol], NoError> in
            return SignalProducer.empty
        })
        
        return gearProducer.withLatest(from: SignalProducer<MemberProtocol, NoError>(value: member)).map({ (gear, user) in
            return (user, gear)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.writeMessageSegue.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let chatViewController = navigationController?.topViewController as? HRPGInboxChatViewController
            chatViewController?.isPresentedModally = true
            chatViewController?.userID = userID
            chatViewController?.username = username
        }
    }
}
