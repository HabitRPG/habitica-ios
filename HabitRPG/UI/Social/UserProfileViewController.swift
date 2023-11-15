//
//  UserProfileViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import Down

// swiftlint:disable type_body_length
class UserProfileViewController: BaseTableViewController {
    
    private var isModerator = false
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    private let configRepository = ConfigRepository.shared
    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    var interactor = CalculateUserStatsInteractor()
    private let (lifetime, token) = Lifetime.make()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    @objc var userID: String?
    @objc var username: String?
    @objc var needsDoneButton = false
    
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
    
    private var user: UserProtocol? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var isBlocked: Bool {
        return user?.inbox?.blocks.contains(userID ?? "") == true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        topHeaderCoordinator?.followScrollView = false
        
        navigationItem.title = username
        
        let subscriber = Signal<CalculatedUserStats, NSError>.Observer(value: {[weak self] stats in
            self?.calculatedStats = stats
        })
        
        disposable.inner.add(interactor.reactive.take(during: lifetime).observe(subscriber))
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.isModerator = user.hasPermission(.userSupport)
            if self?.member == nil {
                self?.refresh()
            }
            self?.tableView.reloadData()
            if self?.isModerator == true {
                self?.disposable.inner.add(self?.socialRepository.retrieveMember(userID: self?.userID ?? "", fromHall: true).observeValues({ member in
                    self?.member = member
                }))
            }
        }).start())
        
        disposable.inner.add(inventoryRepository.getGear().on(value: {[weak self]gear in
            self?.gearDictionary.removeAll()
            gear.value.forEach({ (gearItem) in
                self?.gearDictionary[gearItem.key ?? ""] = gearItem
            })
        }).start())
        
        if let userID = userID {
            disposable.inner.add(socialRepository.getMember(userID: userID).skipNil().flatMap(.latest, {[weak self] (member) in
                return self?.fetchGearStats(member: member) ?? SignalProducer.empty
            }).on(value: {[weak self] (member, gear) in
                self?.member = member
                if self?.username == nil {
                    self?.username = member.username
                }
                self?.navigationItem.title = member.profile?.name
                if let stats = member.stats {
                    self?.interactor.run(with: (stats, gear))
                }
            }).start())
        }
        
        disposable.inner.add( userRepository.getUser().take(first: 1).on(
            value: {[weak self] user in
                self?.user = user
            }).start())
        
        if needsDoneButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    @objc
    private func doneTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func refresh() {
        if let userID = self.userID {
            socialRepository.retrieveMember(userID: userID, fromHall: false).observeCompleted {}
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if member == nil {
            return 0
        } else {
            if isBlocked {
                return 5
            }
            return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var actualSection = section
        if isBlocked && actualSection > 0 {
            actualSection -= 1
        } else if isBlocked && actualSection == 0 {
            return nil
        }
        switch actualSection {
        case 0:
            return member?.contributor?.text
        case 1:
            return L10n.Equipment.battleGear
        case 2:
            return L10n.Equipment.costume
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var actualSection = section
        if isBlocked && actualSection > 0 {
            actualSection -= 1
        } else if isBlocked && actualSection == 0 {
            return 1
        }
        switch section {
        case 0:
            if isModerator {
                return 8
            }
            return 7
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
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellname = "Cell"
        var section = indexPath.section
        if isBlocked && section > 0 {
            section -= 1
        } else if isBlocked && section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedCell", for: indexPath)
            cell.contentView.backgroundColor = ThemeService.shared.theme.errorColor
            return cell
        }
        switch section {
        case 0:
            switch indexPath.item {
            case 0:
                cellname = "ProfileCell"
            case 4:
                cellname = "ImageCell"
            case 3:
                cellname = "TextCell"
            case 1, 2, 5, 6, 7:
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
        cell.detailTextLabel?.textColor = ThemeService.shared.theme.primaryTextColor
        switch section {
        case 0:
            switch indexPath.item {
            case 0:
                configureUserStatsCell(cell)
            case 1:
                cell.textLabel?.text = L10n.username
                cell.detailTextLabel?.text = member?.authentication?.local?.username ?? username
            case 2:
                cell.textLabel?.text = L10n.userID
                cell.detailTextLabel?.text = member?.id
            case 3:
                let textView = cell.viewWithTag(1) as? MarkdownTextView
                textView?.setMarkdownString(member?.profile?.blurb)
            case 4:
                if let imageUrl = member?.profile?.photoUrl {
                    let imageView = cell.viewWithTag(1) as? NetworkImageView
                    imageView?.kf.setImage(with: URL(string: imageUrl))
                }
            case 5:
                cell.textLabel?.text = L10n.Member.memberSince
                if let date = member?.authentication?.timestamps?.createdAt {
                    cell.detailTextLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
                }
            case 6:
                cell.textLabel?.text = L10n.Member.lastLoggedIn
                if let date = member?.authentication?.timestamps?.loggedIn {
                    cell.detailTextLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
                }
            case 7:
                cell.textLabel?.text = "Status"
                var entries = [String]()
                if member?.authentication?.blocked == true {
                    entries.append("Banned")
                }
                if member?.flags?.chatShadowMuted == true {
                    entries.append("Shadow Muted")
                }
                if member?.flags?.chatRevoked == true {
                    entries.append("Muted")
                }
                if entries.isEmpty {
                    cell.detailTextLabel?.text = "Normal Access"
                    cell.detailTextLabel?.textColor = ThemeService.shared.theme.successColor
                } else {
                    cell.detailTextLabel?.text = String(entries.joined(separator: ", "))
                    cell.detailTextLabel?.textColor = ThemeService.shared.theme.errorColor
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
        var section = indexPath.section
        if isBlocked && section > 0 {
            section -= 1
        }
        if indexPath.section == 0 {
            if indexPath.item == 1 || indexPath.item == 2 {
                let cell = tableView.cellForRow(at: indexPath)
                let pasteboard = UIPasteboard.general
                pasteboard.string = cell?.detailTextLabel?.text
                ToastManager.show(text: L10n.copiedXToClipboard(cell?.textLabel?.text ?? ""), color: .green)
            }
        } else if indexPath.section == 3 {
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
        if let className = stats.habitClassNice {
            levelLabel?.text = className + " - " + L10n.levelNumber(stats.level)
        } else {
            levelLabel?.text = L10n.levelNumber(stats.level)
        }
        
        let healthLabel = cell.viewWithTag(2) as? LabeledProgressBar
        if ThemeService.shared.theme.isDark {
            healthLabel?.color = UIColor.red50.withAlphaComponent(0.75)
            healthLabel?.iconView.alpha = 0.8
        } else {
            healthLabel?.color = UIColor.red100
            healthLabel?.iconView.alpha = 1.0
        }
        healthLabel?.icon = HabiticaIcons.imageOfHeartLightBg
        healthLabel?.type = L10n.health
        healthLabel?.value = stats.health
        healthLabel?.maxValue = stats.maxHealth
        
        let experienceLabel = cell.viewWithTag(3) as? LabeledProgressBar
        if ThemeService.shared.theme.isDark {
            experienceLabel?.color = UIColor.yellow50.withAlphaComponent(0.75)
            experienceLabel?.iconView.alpha = 0.8
        } else {
            experienceLabel?.color = UIColor.yellow100
            experienceLabel?.iconView.alpha = 1.0
        }
        experienceLabel?.icon = HabiticaIcons.imageOfExperience
        experienceLabel?.type = L10n.experience
        experienceLabel?.value = stats.experience
        experienceLabel?.maxValue = stats.toNextLevel
        
        let magicLabel = cell.viewWithTag(4) as? LabeledProgressBar
        if stats.level >= 10 {
            if ThemeService.shared.theme.isDark {
                magicLabel?.color = UIColor.blue50.withAlphaComponent(0.75)
                magicLabel?.iconView.alpha = 0.8
            } else {
                magicLabel?.color = UIColor.blue100
                magicLabel?.iconView.alpha = 1.0
            }
            magicLabel?.icon = HabiticaIcons.imageOfMagic
            magicLabel?.type = L10n.mana
            magicLabel?.value = stats.mana
            magicLabel?.maxValue = stats.maxMana
            magicLabel?.isHidden = false
        } else {
            magicLabel?.isHidden = true
        }
        let avatarView = cell.viewWithTag(8) as? AvatarView
        avatarView?.avatar = AvatarViewModel(avatar: member)
        
        let theme = ThemeService.shared.theme
        healthLabel?.textColor = theme.primaryTextColor
        healthLabel?.backgroundColor = theme.contentBackgroundColor
        healthLabel?.progressBar.barBackgroundColor = theme.contentBackgroundColorDimmed
        experienceLabel?.textColor = theme.primaryTextColor
        experienceLabel?.backgroundColor = theme.contentBackgroundColor
        experienceLabel?.progressBar.barBackgroundColor = theme.contentBackgroundColorDimmed
        magicLabel?.textColor = theme.primaryTextColor
        magicLabel?.backgroundColor = theme.contentBackgroundColor
        magicLabel?.progressBar.barBackgroundColor = theme.contentBackgroundColorDimmed
    }
    
    private func configureEquipmentCell(_ cell: UITableViewCell, atIndex index: Int, outfit: OutfitProtocol) {
        let typeLabel = cell.viewWithTag(1) as? UILabel
        let attributeLabel = cell.viewWithTag(2) as? UILabel
        let detailTextLabel = cell.viewWithTag(3) as? UILabel
        let imageView = cell.viewWithTag(4) as? NetworkImageView
        
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
            detailTextLabel?.textColor = ThemeService.shared.theme.primaryTextColor
            attributeLabel?.text = gear?.statsText
        } else {
            imageView?.setImagewith(name: "")
            detailTextLabel?.text = L10n.Equipment.nothingEquipped
            detailTextLabel?.textColor = ThemeService.shared.theme.dimmedTextColor
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
            descriptionLabel?.text = L10n.Stats.total
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
    
    private func fetchGearStats(member: MemberProtocol) -> SignalProducer<(MemberProtocol, [GearProtocol]), Never> {
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
        }).flatMapError({ (_) -> SignalProducer<[GearProtocol], Never> in
            return SignalProducer.empty
        })
        
        return gearProducer.withLatest(from: SignalProducer<MemberProtocol, Never>(value: member)).map({ (gear, user) in
            return (user, gear)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.writeMessageSegue.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let chatViewController = navigationController?.topViewController as? InboxChatViewController
            chatViewController?.isPresentedModally = true
            chatViewController?.userID = userID
            chatViewController?.username = username
            chatViewController?.displayName = member?.profile?.name
        } else if segue.identifier == StoryboardSegue.Social.giftSubscriptionSegue.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let giftViewController = navigationController?.topViewController as? GiftSubscriptionViewController
            giftViewController?.giftRecipientUsername = username ?? userID
        } else if segue.identifier == StoryboardSegue.Social.giftGemsSegue.rawValue {
                   let navigationController = segue.destination as? UINavigationController
                   let giftViewController = navigationController?.topViewController as? GiftGemsViewController
                   giftViewController?.giftRecipientUsername = username ?? userID
               }
    }
    @IBAction func showOverflowMenu(_ sender: Any) {
        let sheet = HostingBottomSheetController(rootView: BottomSheetMenu(menuItems: {
                if user?.id != userID {
                    if isBlocked {
                        BottomSheetMenuitem(title: L10n.unblockUser, style: .destructive) {[weak self] in
                            self?.socialRepository.blockMember(userID: self?.userID ?? self?.username ?? "").observeCompleted {
                                ToastManager.show(text: L10n.userWasUnblocked(self?.username ?? ""), color: .red)
                            }
                        }
                    } else {
                        BottomSheetMenuitem(title: L10n.block, style: .destructive) {[weak self] in
                            self?.showBlockDialog()
                        }
                    }
                }
            BottomSheetMenuitem(title: L10n.giftGems) {[weak self] in
                self?.perform(segue: StoryboardSegue.Social.giftGemsSegue)
            }
            BottomSheetMenuitem(title: L10n.giftSubscription) {[weak self] in
                self?.perform(segue: StoryboardSegue.Social.giftSubscriptionSegue)
            }
            if user?.hasPermission(.userSupport) == true {
                BottomSheetMenuSeparator()
                BottomSheetMenuitem(title: member?.authentication?.blocked == true ? L10n.unbanUser : L10n.banUser, style: .destructive) {[weak self] in
                    self?.showBanDialog()
                }
                
                BottomSheetMenuitem(title: member?.flags?.chatShadowMuted == true ? L10n.unshadowMuteUser : L10n.shadowMuteUser, style: .destructive) {[weak self] in
                    self?.showShadowMuteDialog()
                }
                
                BottomSheetMenuitem(title: member?.flags?.chatRevoked == true ? L10n.unmuteUser : L10n.muteUser, style: .destructive) {[weak self] in
                    self?.showMuteDialog()
                }
            }
        }))
        present(sheet, animated: true)
    }
    
    private func showBlockDialog() {
        let alert = HabiticaAlertController(title: L10n.blockUsername(username ?? member?.profile?.name ?? userID ?? ""), message: L10n.blockDescription)
        let confirmationText = L10n.userWasBlocked(username ?? "")
        alert.addAction(title: L10n.block, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.socialRepository.blockMember(userID: self?.userID ?? self?.username ?? "").observeCompleted {
                ToastManager.show(text: confirmationText, color: .red)
            }
        }
        alert.addCancelAction()
        alert.show()
    }
    
    private func showBanDialog() {
        let isBanned = member?.authentication?.blocked == true
        let alert = HabiticaAlertController(title: isBanned ? L10n.unbanUserConfirm : L10n.banUserConfirm)
        alert.addAction(title: L10n.block, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.socialRepository.updateMember(userID: self?.userID ?? "", key: "auth.blocked", value: !isBanned).observeCompleted {
                ToastManager.show(text: L10n.completed, color: .green)
            }
        }
        alert.addCancelAction()
        alert.show()
    }
    
    private func showShadowMuteDialog() {
        let isShadowMuted = member?.flags?.chatShadowMuted == true
        let alert = HabiticaAlertController(title: isShadowMuted ? L10n.unshadowMuteUserConfirm : L10n.shadowMuteUserConfirm)
        alert.addAction(title: L10n.block, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.socialRepository.updateMember(userID: self?.userID ?? "", key: "flags.chatShadowMuted", value: !isShadowMuted).observeCompleted {
                ToastManager.show(text: L10n.completed, color: .green)
            }
        }
        alert.addCancelAction()
        alert.show()
    }
    
    private func showMuteDialog() {
        let isMuted = member?.authentication?.blocked == true
        let alert = HabiticaAlertController(title: isMuted ? L10n.unmuteUserConfirm : L10n.muteUserConfirm)
        alert.addAction(title: L10n.block, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.socialRepository.updateMember(userID: self?.userID ?? "", key: "flags.chatRevoked", value: !isMuted).observeCompleted {
                ToastManager.show(text: L10n.completed, color: .green)
            }
        }
        alert.addCancelAction()
        alert.show()
    }
}
