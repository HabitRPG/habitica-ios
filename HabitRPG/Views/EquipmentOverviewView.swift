//
//  EquipmentOverviewView.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import PinLayout

class EquipmentOverviewView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchLabelView: UILabel!
    @IBOutlet weak var switchView: UISwitch!
    @IBOutlet weak var containerView: UIView!
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
            switchView.accessibilityLabel = newValue
        }
    }
    
    var switchValue: Bool {
        get {
            return switchView.isOn
        }
        set {
            switchView.isOn = newValue
        }
    }
    
    var itemTapped: ((String) -> Void)?
    var switchToggled: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 375, height: 250))
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    func getTotalHeight(for width: CGFloat) -> CGFloat {
        let itemWidth = (width - (7*8)) / 4
        let itemHeights = (itemWidth+36)*2+(3*8)
        return itemHeights+79
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        layout()
        return CGSize(width: size.width, height: containerView.frame.origin.y+containerView.frame.size.height+25)
    }
    
    override var intrinsicContentSize: CGSize {
        layout()
        return CGSize(width: bounds.size.width, height: containerView.frame.origin.y+containerView.frame.size.height+25)
    }
    
    private func layout() {
        let sidePadding: CGFloat = traitCollection.isIPad ? 16 : 8
        let itemWidth = (bounds.size.width - (5*8) - (2*sidePadding)) / 4
        let itemHeight = itemWidth+36
        containerView.pin.top(54).start(sidePadding).end(sidePadding).height(itemHeight*2+(3*8))
        titleLabel.pin.top(0).start(sidePadding).above(of: containerView).sizeToFit(.height)
        switchView.pin.end(sidePadding).top(11)
        switchLabelView.pin.top(0).above(of: containerView).left(of: switchView).marginRight(8).sizeToFit(.height)
        
        weaponItemView.pin.top(8).left(8).width(itemWidth).height(itemHeight)
        offHandItemView.pin.top(8).right(of: weaponItemView).marginLeft(8).width(itemWidth).height(itemHeight)
        headItemView.pin.top(8).right(of: offHandItemView).marginLeft(8).width(itemWidth).height(itemHeight)
        armorItemView.pin.top(8).right(of: headItemView).marginLeft(8).width(itemWidth).height(itemHeight)
        
        headAccessoryItemView.pin.bottom(8).left(8).width(itemWidth).width(itemWidth).height(itemHeight)
        bodyAccessoryItemView.pin.bottom(8).right(of: headAccessoryItemView).marginLeft(8).width(itemWidth).height(itemHeight)
        backItemView.pin.bottom(8).right(of: bodyAccessoryItemView).marginLeft(8).width(itemWidth).height(itemHeight)
        eyewearItemView.pin.bottom(8).right(of: backItemView).marginLeft(8).width(itemWidth).height(itemHeight)
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            
            view.frame = bounds
            addSubview(view)

            setupLabels()
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func applyTheme(theme: Theme) {
        titleLabel.textColor = theme.primaryTextColor
        switchLabelView.textColor = theme.secondaryTextColor
        backgroundColor = theme.contentBackgroundColor
        weaponItemView.applyTheme(theme: theme)
        offHandItemView.applyTheme(theme: theme)
        headItemView.applyTheme(theme: theme)
        armorItemView.applyTheme(theme: theme)
        headAccessoryItemView.applyTheme(theme: theme)
        bodyAccessoryItemView.applyTheme(theme: theme)
        backItemView.applyTheme(theme: theme)
        eyewearItemView.applyTheme(theme: theme)
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
    @IBAction func switchValueChanged(_ sender: Any) {
        if let action = switchToggled {
            action(switchView.isOn)
        }
    }
}
