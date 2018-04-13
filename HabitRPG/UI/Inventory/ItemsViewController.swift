//
//  ItemsViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class ItemsViewController: HRPGBaseViewController {
    
    private let dataSource = ItemsViewDataSource()
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    private var isHatching = false {
        didSet {
            dataSource.isHatching = isHatching
        }
    }
    
    private var inventoryRepository = InventoryRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.tableView = tableView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource.item(at: indexPath)
        if isHatching {
            self.isHatching = false
            if let egg = dataSource.hatchingItem as? EggProtocol, let potion = item as? HatchingPotionProtocol {
                inventoryRepository.hatchPet(egg: egg, potion: potion).skipNil().observeValues { _ in
                    self.showHatchedDialog(egg: egg, potion: potion)
                }
            } else if let egg = item as? EggProtocol, let potion = dataSource.hatchingItem as? HatchingPotionProtocol {
                inventoryRepository.hatchPet(egg: egg, potion: potion).skipNil().observeValues { _ in
                    self.showHatchedDialog(egg: egg, potion: potion)
                }
            }
        } else if let item = item {
            showActionSheet(item: item)
        }
    }
    
    private func showActionSheet(item: ItemProtocol) {
        let alertController = UIAlertController(title: item.text, message: nil, preferredStyle: .actionSheet)
        if item.itemType == ItemType.eggs.rawValue {
            alertController.addAction(UIAlertAction(title: L10n.hatchEgg, style: .default, handler: { (_) in
                self.dataSource.hatchingItem = item
                self.isHatching = true
            }))
        } else if item.itemType == ItemType.hatchingPotions.rawValue {
            alertController.addAction(UIAlertAction(title: L10n.hatchPotion, style: .default, handler: { (_) in
                self.dataSource.hatchingItem = item
                self.isHatching = true
            }))
        } else if item.itemType == ItemType.quests.rawValue {
            alertController.addAction(UIAlertAction(title: L10n.inviteParty, style: .default, handler: { (_) in
                if let quest = item as? QuestProtocol {
                    self.inventoryRepository.inviteToQuest(quest: quest).observeCompleted {}
                }
            }))
        }
        if item.key != "Saddle" && item.itemType != ItemType.quests.rawValue {
            alertController.addAction(UIAlertAction(title: L10n.sell(Int(item.value)), style: .destructive, handler: { (_) in
                self.inventoryRepository.sell(item: item).observeCompleted {}
            }))
        }
        alertController.addAction(UIAlertAction.cancelAction())
        alertController.show()
    }
    
    private func showHatchedDialog(egg: EggProtocol, potion: HatchingPotionProtocol) {
        let imageAlert = ImageOverlayView(imageName: "Pet-\(egg.key ?? "")-\(potion.key ?? "")", title: L10n.Inventory.hatched, message: "\(potion.text ?? "") \(egg.text ?? "")")
        imageAlert.addShareAction { (_) in
            HRPGSharingManager.shareItems([
                    L10n.Inventory.hatchedSharing(egg.text ?? "", potion.text ?? "")
                ], withPresenting: self, withSourceView: nil)
        }
        imageAlert.addCloseAction()
        imageAlert.imageHeight = 99
        imageAlert.titleLabel.textColor = .white
        imageAlert.titleBackgroundColor = UIColor.purple300()
        imageAlert.show()
    }
}
