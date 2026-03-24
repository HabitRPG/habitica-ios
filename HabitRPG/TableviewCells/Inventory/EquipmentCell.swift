//
//  EquipmentCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class EquipmentCell: UITableViewCell {

    @IBOutlet weak var gearImageView: NetworkImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionlabel: UILabel!
    @IBOutlet weak var twoHandedView: UIView!
    @IBOutlet weak var twoHandedIconView: UIImageView!
    @IBOutlet weak var twoHandedLabel: UILabel!

    @IBOutlet weak var strengthLabel: UILabel!
    @IBOutlet weak var constitutionLabel: UILabel!
    @IBOutlet weak var intelligenceLabel: UILabel!
    @IBOutlet weak var perceptionLabel: UILabel!
    @IBOutlet weak var noBenefitsLabel: UILabel!

    private let equippedBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.largeCornerRadius
        view.isHidden = true
        return view
    }()

    var isEquipped: Bool = false {
        didSet {
            if isEquipped {
                equippedBackgroundView.isHidden = false
                equippedBackgroundView.backgroundColor = ThemeService.shared.theme.tintColor.withAlphaComponent(0.2)
                gearImageView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
            } else {
                equippedBackgroundView.isHidden = true
                gearImageView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            }
            backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        twoHandedIconView.image = HabiticaIcons.imageOfTwoHandedIcon
        twoHandedLabel.text = L10n.twoHanded
        noBenefitsLabel.text = L10n.noBenefit
        gearImageView.cornerRadius = UIConstants.largeCornerRadius

        contentView.insertSubview(equippedBackgroundView, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        equippedBackgroundView.frame = CGRect(
            x: 7,
            y: 0,
            width: contentView.bounds.width - 14,
            height: contentView.bounds.height
        )
    }
    
    func configure(_ gear: GearProtocol) {
        gearImageView.setImagewith(name: "shop_\(gear.key ?? "")")
        titleLabel.text = gear.text
        descriptionlabel.text = gear.notes
        
        if gear.twoHanded {
            twoHandedView.isHidden = false
        } else {
            twoHandedView.isHidden = true
        }
        
        strengthLabel.isHidden = true
        constitutionLabel.isHidden = true
        intelligenceLabel.isHidden = true
        perceptionLabel.isHidden = true
        noBenefitsLabel.isHidden = true
        
        var hasBenefits = false
        if gear.strength > 0 {
            strengthLabel.isHidden = false
            strengthLabel.attributedText = attributedLabel(title: "STR: ", value: "+\(gear.strength)")
            hasBenefits = true
        }
        if gear.constitution > 0 {
            constitutionLabel.isHidden = false
            constitutionLabel.attributedText = attributedLabel(title: "CON: ", value: "+\(gear.constitution)")
            hasBenefits = true
        }
        if gear.intelligence > 0 {
            intelligenceLabel.isHidden = false
            intelligenceLabel.attributedText = attributedLabel(title: "INT: ", value: "+\(gear.intelligence)")
            hasBenefits = true
        }
        if gear.perception > 0 {
            perceptionLabel.isHidden = false
            perceptionLabel.attributedText = attributedLabel(title: "PER: ", value: "+\(gear.perception)")
            hasBenefits = true
        }
        if !hasBenefits {
            noBenefitsLabel.isHidden = false
        }
    }
    
    private func attributedLabel(title: String, value: String) -> NSAttributedString {
        let titleString = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.gray200])
        return titleString + NSAttributedString(string: value, attributes: [.foregroundColor: UIColor.green50])
    }
}
