//
//  EquipmentViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class EquipmentViewDataSource: BaseReactiveTableViewDataSource<GearProtocol> {
    
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    
    private var equippedKey: String?
    
    init(useCostume: Bool, gearType: String) {
        super.init()
        sections.append(ItemSection<GearProtocol>())
        
        disposable.add(inventoryRepository.getOwnedGear()
            .map({ (data) -> [String] in
                return data.value.map({ (ownedGear) -> String in
                    return ownedGear.key ?? ""
                }).filter({ (key) -> Bool in
                    return !key.isEmpty
                })
            })
            .flatMap(.latest, {[weak self] (keys) in
                return self?.inventoryRepository.getGear(predicate: NSPredicate(format: "key IN %@ && type == %@", keys, gearType)) ?? SignalProducer.empty
            })
            .on(value: {[weak self](gear, changes) in
                self?.sections[0].items = gear
                self?.notify(changes: changes)
            })
            .start())
        
        disposable.add(userRepository.getUser().on(value: {[weak self]user in
            if useCostume {
                self?.equippedKey = user.items?.gear?.costume?.keyFor(type: gearType)
            } else {
                self?.equippedKey = user.items?.gear?.equipped?.keyFor(type: gearType)
            }
        }).start())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let gear = item(at: indexPath), let equipmentCell = cell as? EquipmentCell {
            equipmentCell.configure(gear)
            equipmentCell.isEquipped = gear.key == equippedKey
        }
        
        return cell
    }
}
