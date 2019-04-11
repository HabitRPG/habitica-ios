//
//  ItemsViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class ItemsViewController: BaseTableViewController {
    
    private let dataSource = ItemsViewDataSource()
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    private var isHatching = false {
        didSet {
            dataSource.isHatching = isHatching
        }
    }
    var itemType: String?
    
    private let inventoryRepository = InventoryRepository()
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
    
    private func showActionSheet(item: ItemProtocol, withSource sourceView: UIView?) {
        let alertController = UIAlertController(title: item.text, message: nil, preferredStyle: .actionSheet)
        if item.itemType == ItemType.eggs {
            alertController.addAction(UIAlertAction(title: L10n.hatchEgg, style: .default, handler: {[weak self] (_) in
                self?.dataSource.hatchingItem = item
                self?.isHatching = true
            }))
        } else if item.itemType == ItemType.hatchingPotions {
            alertController.addAction(UIAlertAction(title: L10n.hatchPotion, style: .default, handler: {[weak self] (_) in
                self?.dataSource.hatchingItem = item
                self?.isHatching = true
            }))
        } else if item.itemType == ItemType.quests {
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
        alertController.addAction(UIAlertAction.cancelAction())
        if let sourceView = sourceView {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        } else {
            alertController.setSourceInCenter(view)
        }
        alertController.show()
    }
    
    private func dismissIfNeeded() {
        if isPresentedModally {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showHatchedDialog(egg: EggProtocol, potion: HatchingPotionProtocol) {
        let imageAlert = ImageOverlayView(imageName: "Pet-\(egg.key ?? "")-\(potion.key ?? "")", title: L10n.Inventory.hatched, message: "\(potion.text ?? "") \(egg.text ?? "")")
        imageAlert.addShareAction { (_) in
            HRPGSharingManager.shareItems([
                    L10n.Inventory.hatchedSharing(egg.text ?? "", potion.text ?? "")
                ], withPresenting: imageAlert, withSourceView: nil)
        }
        imageAlert.containerViewSpacing = 12
        imageAlert.addCloseAction()
        imageAlert.imageHeight = 99
        imageAlert.titleLabel.textColor = .white
        imageAlert.titleBackgroundColor = ThemeService.shared.theme.backgroundTintColor
        imageAlert.show()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
