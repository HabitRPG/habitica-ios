//
//  EquipmentOverviewView.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class EquipmentOverviewView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchLabelView: UILabel!
    @IBOutlet weak var weaponItemView: EquipmentOverviewItemView!
    @IBOutlet weak var offHandItemView: EquipmentOverviewItemView!
    @IBOutlet weak var headItemView: EquipmentOverviewItemView!
    @IBOutlet weak var armorItemView: EquipmentOverviewItemView!
    @IBOutlet weak var headAccessoryItemView: EquipmentOverviewItemView!
    @IBOutlet weak var bodyAccessoryItemView: EquipmentOverviewItemView!
    @IBOutlet weak var backItemView: EquipmentOverviewItemView!
    @IBOutlet weak var eyewearItemView: EquipmentOverviewItemView!
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var switchLabel: String? {
        get {
            return switchLabelView.text
        }
        set {
            switchLabelView.text = newValue
        }
    }
    
    var itemTapped: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 154, height: 36))
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            translatesAutoresizingMaskIntoConstraints = false
            
            view.frame = bounds
            addSubview(view)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))

            setupLabels()
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private func setupLabels() {
        weaponItemView.setup(title: L10n.Equipment.weapon) {[weak self] in
            self?.onItemTapped("weapon")
        }
        offHandItemView.setup(title: L10n.Equipment.offHand) {[weak self] in
            self?.onItemTapped("shield")
        }
        headItemView.setup(title: L10n.Equipment.head) {[weak self] in
            self?.onItemTapped("head")
        }
        armorItemView.setup(title: L10n.Equipment.armor) {[weak self] in
            self?.onItemTapped("armor")
        }
        headAccessoryItemView.setup(title: L10n.Equipment.headAccessory) {[weak self] in
            self?.onItemTapped("headAccessory")
        }
        bodyAccessoryItemView.setup(title: L10n.Equipment.body) {[weak self] in
            self?.onItemTapped("body")
        }
        backItemView.setup(title: L10n.Equipment.back) {[weak self] in
            self?.onItemTapped("back")
        }
        eyewearItemView.setup(title: L10n.Equipment.eyewear) {[weak self] in
            self?.onItemTapped("eyewear")
        }
    }
    
    func configure(outfit: OutfitProtocol) {
        weaponItemView.configure(outfit.weapon)
        offHandItemView.configure(outfit.shield)
        headItemView.configure(outfit.head)
        armorItemView.configure(outfit.armor)
        headAccessoryItemView.configure(outfit.headAccessory)
        bodyAccessoryItemView.configure(outfit.body)
        backItemView.configure(outfit.back)
        eyewearItemView.configure(outfit.eyewear)
    }
    
    private func onItemTapped(_ typeKey: String) {
        if let action = itemTapped {
            action(typeKey)
        }
    }
}
