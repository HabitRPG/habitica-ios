//
//  EquipmentDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class EquipmentDetailViewController: BaseTableViewController {
    
    var selectedType: String?
    var selectedCostume = false
    
    var datasource: EquipmentViewDataSource?
    private let inventoryRepository = InventoryRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let gearType = selectedType {
            datasource = EquipmentViewDataSource(useCostume: selectedCostume, gearType: gearType)
            datasource?.tableView = self.tableView
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let gear = datasource?.item(at: indexPath) {
            inventoryRepository.equip(type: selectedCostume ? "costume" : "equipped", key: gear.key ?? "").observeCompleted {}
        }
    }
}
