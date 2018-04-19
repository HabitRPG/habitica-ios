//
//  EquipmentOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class EquipmentOverviewViewController: HRPGUIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gearView: EquipmentOverviewView!
    @IBOutlet weak var costumeView: EquipmentOverviewView!
    
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    private var selectedCostume = false
    private var selectedType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator = TopHeaderCoordinator(topHeaderNavigationController: hrpgTopHeaderNavigationController(), scrollView: scrollView)
        topHeaderCoordinator.viewDidLoad()
        
        gearView.title = L10n.Equipment.battleGear
        gearView.switchLabel = L10n.Equipment.autoEquip
        gearView.itemTapped = { typeKey in
            self.selectedCostume = false
            self.selectedType = typeKey
            self.perform(segue: StoryboardSegue.Main.equipmentDetailSegue)
        }
        
        costumeView.title = L10n.Equipment.costume
        costumeView.switchLabel = L10n.Equipment.useCostume
        costumeView.itemTapped = { typeKey in
            self.selectedCostume = true
            self.selectedType = typeKey
            self.perform(segue: StoryboardSegue.Main.equipmentDetailSegue)
        }
        
        disposable.inner.add(userRepository.getUser().on(value: { user in
            if let equipped = user.items?.gear?.equipped {
                self.gearView.configure(outfit: equipped)
            }
            if let costume = user.items?.gear?.costume {
                self.costumeView.configure(outfit: costume)
            }
        }).start())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.equipmentDetailSegue.rawValue {
            let destination = segue.destination as? EquipmentDetailViewController
            destination?.selectedType = self.selectedType
            destination?.selectedCostume = self.selectedCostume
        }
    }
}
