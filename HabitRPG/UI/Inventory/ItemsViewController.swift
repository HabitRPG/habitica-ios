//
//  ItemsViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class ItemsViewController: BaseTableViewController {
    
    private let dataSource = ItemsViewDataSource()
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    private var isHatching = false {
        didSet {
			if !isPresentedModally {
                navigationItem.rightBarButtonItem = isHatching ? cancelButton : nil
			}
            dataSource.isHatching = isHatching
        }
    }
    var itemType: String?
    
    private let inventoryRepository = InventoryRepository()
    private let userRepository = UserRepository()
    private var isPresentedModally = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.tableView = tableView
        dataSource.itemType = itemType
        
        if (navigationController as? TopHeaderViewController) != nil {
			navigationItem.rightBarButtonItem = nil
            isPresentedModally = false
        } else {
            isPresentedModally = true
        }
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.items
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource.item(at: indexPath)
        if isHatching {
            self.isHatching = false
            if let egg = dataSource.hatchingItem as? EggProtocol, let potion = item as? HatchingPotionProtocol {
                inventoryRepository.hatchPet(egg: egg, potion: potion).skipNil().observeValues {[weak self] _ in
                    self?.showHatchedDialog(egg: egg, potion: potion)
                }
            } else if let egg = item as? EggProtocol, let potion = dataSource.hatchingItem as? HatchingPotionProtocol {
                inventoryRepository.hatchPet(egg: egg, potion: potion).skipNil().observeValues {[weak self] _ in
                    self?.showHatchedDialog(egg: egg, potion: potion)
                }
            }
        } else if let item = item {
            showActionSheet(item: item, withSource: tableView.cellForRow(at: indexPath))
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (dataSource.numberOfSections(in: tableView) - 1) {
            return 150
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == (dataSource.numberOfSections(in: tableView) - 1) {
            let view = Bundle.main.loadNibNamed("ShopAdFooter", owner: self, options: nil)?.last as? UIView
            let label = view?.viewWithTag(2) as? UILabel
            let openShopButton = view?.viewWithTag(3) as? UIButton
            let theme = ThemeService.shared.theme
            openShopButton?.layer.borderColor = theme.tintColor.cgColor
            openShopButton?.setTitleColor(theme.tintColor, for: .normal)
            openShopButton?.layer.borderWidth = 1.0
            openShopButton?.layer.cornerRadius = 5
            
            label?.text = L10n.notGettingDrops
            label?.textColor = theme.primaryTextColor
            openShopButton?.addTarget(self, action: #selector(openMarket), for: .touchUpInside)
            return view
        } else {
            return nil
        }
    }
    
    @objc func openMarket() {
        let storyboard = UIStoryboard(name: "Shop", bundle: nil)
        if let viewController = storyboard.instantiateInitialViewController() as? HRPGShopViewController {
            viewController.shopIdentifier = Constants.MarketKey
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func showActionSheet(item: ItemProtocol, withSource sourceView: UIView?) {
        var type = ""
        switch item.itemType {
        case "eggs":
            type = L10n.egg
        case "hatchingPotions":
            type = L10n.hatchingPotion
        case "food":
            type = L10n.food
        case "quests":
            type = L10n.quest
        default:
            break
        }
        let alertController = UIAlertController(title: "\(item.text ?? "") \(type)", message: nil, preferredStyle: .actionSheet)
        if item.itemType == ItemType.eggs {
            alertController.addAction(UIAlertAction(title: L10n.hatchPotion, style: .default, handler: {[weak self] (_) in
                self?.dataSource.hatchingItem = item
                self?.isHatching = true
            }))
        } else if item.itemType == ItemType.hatchingPotions {
            alertController.addAction(UIAlertAction(title: L10n.hatchEgg, style: .default, handler: {[weak self] (_) in
                self?.dataSource.hatchingItem = item
                self?.isHatching = true
            }))
        } else if item.itemType == ItemType.quests {
            alertController.addAction(UIAlertAction(title: L10n.showDetails, style: .default, handler: {[weak self] (_) in
                if let quest = item as? QuestProtocol {
                    let alertController = HabiticaAlertController(title: quest.text)
                    let detailView = QuestDetailView(frame: CGRect.zero)
                    detailView.configure(quest: quest)
                    let imageView = UIImageView()
                    imageView.contentMode = .center
                    ImageManager.setImage(on: imageView, name: "quest_" + (quest.key ?? ""))
                    let textView = UITextView()
                    textView.isScrollEnabled = false
                    textView.attributedText = try? HabiticaMarkdownHelper.toHabiticaAttributedString(quest.notes ?? "")
                    textView.font = CustomFontMetrics.scaledSystemFont(ofSize: 14)
                    textView.textColor = ThemeService.shared.theme.primaryTextColor
                    textView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
                    let stackView = UIStackView(arrangedSubviews: [imageView, detailView, textView])
                    stackView.axis = .vertical
                    stackView.spacing = 12
                    alertController.contentView = stackView
                    alertController.addAction(title: L10n.inviteParty, style: .default, isMainAction: true) {[weak self] _ in
                        self?.inventoryRepository.inviteToQuest(quest: quest).observeCompleted {
                            self?.dismissIfNeeded()
                        }
                    }
                    alertController.addCloseAction()
                    alertController.show()
                }
            }))
            alertController.addAction(UIAlertAction(title: L10n.inviteParty, style: .default, handler: {[weak self] (_) in
                if let quest = item as? QuestProtocol {
                    self?.inventoryRepository.inviteToQuest(quest: quest).observeCompleted {
                        self?.dismissIfNeeded()
                    }
                }
            }))
        }
        if item.key != "Saddle" && item.itemType != ItemType.quests && item.itemType != ItemType.special {
            alertController.addAction(UIAlertAction(title: L10n.sell(Int(item.value)), style: .destructive, handler: {[weak self] (_) in
                self?.inventoryRepository.sell(item: item).observeCompleted {
                    self?.dismissIfNeeded()
                }
            }))
        }
        if item.key == "inventory_present" {
            alertController.addAction(UIAlertAction(title: L10n.open, style: .default, handler: {[weak self] (_) in
                self?.inventoryRepository.openMysteryItem().observeCompleted {
                    self?.dismissIfNeeded()
                }
            }))
        }
        if item.key != "inventory_present" && item.itemType == ItemType.special {
            alertController.addAction(UIAlertAction(title: L10n.use, style: .default, handler: {[weak self] _ in
                let navigationController = StoryboardScene.Main.spellUserNavigationController.instantiate()
                self?.present(navigationController, animated: true, completion: {
                    let controller = navigationController.topViewController as? SkillsUserTableViewController
                    controller?.item = item
                })
            }))
        }
        alertController.addAction(UIAlertAction.cancelAction())
        if let sourceView = sourceView {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        } else {
            alertController.setSourceInCenter(view)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    private func dismissIfNeeded() {
        if isPresentedModally {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showHatchedDialog(egg: EggProtocol, potion: HatchingPotionProtocol) {
        let imageAlert = ImageOverlayView(imageName: "Pet-\(egg.key ?? "")-\(potion.key ?? "")", title: L10n.Inventory.hatched, message: "\(potion.text ?? "") \(egg.text ?? "")")
        imageAlert.addAction(title: L10n.equip, isMainAction: true) {[weak self] _ in
            self?.inventoryRepository.equip(type: "pet", key: "\(egg.key ?? "")-\(potion.key ?? "")").observeCompleted {}
        }
        imageAlert.addAction(title: L10n.share) { (_) in
            HRPGSharingManager.shareItems([
                    L10n.Inventory.hatchedSharing(egg.text ?? "", potion.text ?? "")
                ], withPresenting: imageAlert, withSourceView: nil)
        }
        imageAlert.arrangeMessageLast = true
        imageAlert.containerViewSpacing = 12
        imageAlert.setCloseAction(title: L10n.close, handler: {})
        imageAlert.imageHeight = 99
        imageAlert.enqueue()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
		isHatching = false
		dismissIfNeeded()
    }
    
    @IBAction func unwindToListSave(_ segue: UIStoryboardSegue) {
        if segue.identifier == "CastUserSpellSegue" {
            guard let userViewController = segue.source as? SkillsUserTableViewController else {
                return
            }
            guard let item = userViewController.item as? SpecialItemProtocol else {
                return
            }
            userRepository.useTransformationItem(item: item, targetId: userViewController.selectedUserID ?? "").observeCompleted {}
        }
    }
}
