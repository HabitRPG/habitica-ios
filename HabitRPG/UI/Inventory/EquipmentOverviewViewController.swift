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
import PinLayout

class EquipmentOverviewViewController: BaseUIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gearView: EquipmentOverviewView!
    @IBOutlet weak var costumeView: EquipmentOverviewView!
    @IBOutlet weak var costumeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var gearViewHeightConstraint: NSLayoutConstraint!
    
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    @IBOutlet weak var costumeExplanationLabel: UILabel!
    
    private var selectedCostume = false
    private var selectedType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator = TopHeaderCoordinator(topHeaderNavigationController: hrpgTopHeaderNavigationController(), scrollView: scrollView)
        topHeaderCoordinator.viewDidLoad()
        scrollView.delegate = self
        
        gearView.title = L10n.Equipment.battleGear
        gearView.switchLabel = L10n.Equipment.autoEquip
        gearView.itemTapped = {[weak self] typeKey in
            self?.selectedCostume = false
            self?.selectedType = typeKey
            self?.perform(segue: StoryboardSegue.Main.equipmentDetailSegue)
        }
        gearView.switchToggled = {[weak self] value in
            self?.userRepository.updateUser(key: "preferences.autoEquip", value: value).observeCompleted {}
        }
        gearView.setNeedsLayout()
        
        costumeView.title = L10n.Equipment.costume
        costumeView.switchLabel = L10n.Equipment.useCostume
        costumeView.itemTapped = {[weak self] typeKey in
            self?.selectedCostume = true
            self?.selectedType = typeKey
            self?.perform(segue: StoryboardSegue.Main.equipmentDetailSegue)
        }
        costumeView.switchToggled = {[weak self] value in
            self?.userRepository.updateUser(key: "preferences.costume", value: value).observeCompleted {}
        }
        costumeView.setNeedsLayout()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            if let equipped = user.items?.gear?.equipped {
                self?.gearView.configure(outfit: equipped)
            }
            self?.gearView.switchValue = user.preferences?.autoEquip ?? false
            if let costume = user.items?.gear?.costume {
                self?.costumeView.configure(outfit: costume)
            }
            self?.costumeView.switchValue = user.preferences?.useCostume ?? false
        }).start())
    }
    
    override func viewWillLayoutSubviews() {
        gearViewHeightConstraint.constant = gearView.getTotalHeight(for: view.frame.width)
        costumeViewHeightConstraint.constant = costumeView.getTotalHeight(for: view.frame.width)
        super.viewWillLayoutSubviews()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        topHeaderCoordinator.scrollViewDidScroll()
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.equipment
        costumeExplanationLabel.text = L10n.Equipment.costumeExplanation
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.equipmentDetailSegue.rawValue {
            let destination = segue.destination as? EquipmentDetailViewController
            destination?.selectedType = self.selectedType
            destination?.selectedCostume = self.selectedCostume
        }
    }
}
