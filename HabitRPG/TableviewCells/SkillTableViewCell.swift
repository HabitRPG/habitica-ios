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
    
    @IBOutlet weak var containerView: UIView?
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
    
    func configureUnlocked(skill: SkillProtocol, manaLeft: Float) {
        titleLabel.text = skill.text
        notesLabel.text = skill.notes
        costLabel?.text = String(describing: skill.mana)
        if manaLeft < Float(skill.mana) {
            buyButton.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            magicIconView?.alpha = 0.3
            costLabel?.alpha = 0.3
        } else {
            buyButton.backgroundColor = UIColor.blue500().withAlphaComponent(0.24)
            magicIconView?.alpha = 1.0
            costLabel?.alpha = 1.0
        }
        skillImageView.setShopImagewith(name: skill.key)
    }
    
    func configureLocked(skill: SkillProtocol) {
        titleLabel.text = L10n.Skills.unlocksAt(skill.level)
        magicIconView?.image = HabiticaIcons.imageOfLocked()
        magicIconView?.contentMode = .center
        skillImageView.setShopImagewith(name: skill.key)
        skillImageView.alpha = 0.3
        containerView?.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
        buyButton.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
    }
    
    func configure(transformationItem: SpecialItemProtocol, numberOwned: Int) {
        titleLabel.text = transformationItem.text
        notesLabel.text = transformationItem.notes
        skillImageView.setShopImagewith(name: transformationItem.key)
        numberOwnedLabel?.text = String(numberOwned)
        
        (buyButton.viewWithTag(1) as? UILabel)?.text = L10n.use
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            UIView.animate(withDuration: animated ? 0.2 : 0) {[weak self] in
                self?.containerView?.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            }
        } else {
            UIView.animate(withDuration: animated ? 0.2 : 0) {[weak self] in
                self?.containerView?.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            }
            
        }
    }
}
