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
    @IBOutlet weak var magicIconView: UIImageView!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        magicIconView.image = HabiticaIcons.imageOfMagic
    }
    
    func configureUnlocked(skill: SkillProtocol) {
        titleLabel.text = skill.text
        notesLabel.text = skill.notes
        costLabel.text = String(describing: skill.mana)
    }
    
    func configureLocked(skill: SkillProtocol) {
        titleLabel.text = L10n.Skills.unlocksAt(skill.level)
        magicIconView.image = HabiticaIcons.imageOfLocked
        magicIconView.contentMode = .center
    }
}
