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
    
    private var isHatching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.tableView = tableView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource.item(at: indexPath)
        if isHatching {
            
        } else if let item = item {
            showActionSheet(item: item)
        }
    }
    
    private func showActionSheet(item: ItemProtocol) {
        let alertController = UIAlertController(title: item.text
            , message: nil, preferredStyle: .actionSheet)
        if item.itemType == ItemType.egg.rawValue {
            alertController.addAction(UIAlertAction(title: L10n.hatchEgg, style: .default, handler: { (_) in
                
            }))
        } else if item.itemType == ItemType.hatchingPotion.rawValue {
            alertController.addAction(UIAlertAction(title: L10n.hatchPotion, style: .default, handler: { (_) in
                
            }))
        } else if item.itemType == ItemType.quest.rawValue {
            alertController.addAction(UIAlertAction(title: L10n.inviteParty, style: .destructive, handler: { (_) in
                
            }))
        }
        if item.key != "Saddle" {
            alertController.addAction(UIAlertAction(title: L10n.sell(Int(item.value)), style: .destructive, handler: { (_) in
                
            }))
        }
        alertController.addAction(UIAlertAction.cancelAction())
        alertController.show()
    }
}
