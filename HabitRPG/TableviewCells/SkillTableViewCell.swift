//
//  SpellTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class SkillTableViewCell: UITableViewCell {
    
    @IBOutlet weak var skillImageView: UIImageView!
    @IBOutlet weak var buyButton: UIView!
    @IBOutlet weak var magicIconView: UIImageView?
    @IBOutlet weak var costLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var numberOwnedLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        magicIconView?.image = HabiticaIcons.imageOfMagic
    }
    
    func configureUnlocked(skill: SkillProtocol) {
        titleLabel.text = skill.text
        notesLabel.text = skill.notes
        costLabel?.text = String(describing: skill.mana)
        skillImageView.setShopImagewith(name: skill.key)
    }
    
    func configureLocked(skill: SkillProtocol) {
        titleLabel.text = L10n.Skills.unlocksAt(skill.level)
        magicIconView?.image = HabiticaIcons.imageOfLocked
        magicIconView?.contentMode = .center
        skillImageView.setShopImagewith(name: skill.key)
        skillImageView.alpha = 0.3
    }
    
    func configure(transformationItem: SpecialItemProtocol, numberOwned: Int) {
        titleLabel.text = transformationItem.text
        notesLabel.text = transformationItem.notes
        skillImageView.setShopImagewith(name: transformationItem.key)
        numberOwnedLabel?.text = String(numberOwned)
    }
}
