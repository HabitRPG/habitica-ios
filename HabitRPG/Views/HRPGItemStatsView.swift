//
//  HRPGItemStatsView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/18/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class HRPGItemStatsView: UIView {
    @IBOutlet weak var strLabel: UILabel!
    @IBOutlet weak var strStatLabel: UILabel!
    @IBOutlet weak var conLabel: UILabel!
    @IBOutlet weak var conStatLabel: UILabel!
    @IBOutlet weak var perLabel: UILabel!
    @IBOutlet weak var perStatLabel: UILabel!
    @IBOutlet weak var intLabel: UILabel!
    @IBOutlet weak var intStatLabel: UILabel!
    
    @IBOutlet weak var classDisclaimerWrapper: UIView!
    @IBOutlet weak var classDisclaimerLabel: UILabel!
    
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
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            
            let theme = ThemeService.shared.theme
            view.backgroundColor = theme.contentBackgroundColor
            
            classDisclaimerWrapper.isHidden = true
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    public func configure(gear: GearProtocol, shopItem: InAppRewardProtocol?, userClass: String, userLevel: Int) {
        configureFields(descriptionLabel: strLabel, valueLabel: strStatLabel, value: gear.strength)
        configureFields(descriptionLabel: conLabel, valueLabel: conStatLabel, value: gear.constitution)
        configureFields(descriptionLabel: perLabel, valueLabel: perStatLabel, value: gear.perception)
        configureFields(descriptionLabel: intLabel, valueLabel: intStatLabel, value: gear.intelligence)
        
        if gear.habitClass != nil && gear.specialClass != nil && (gear.habitClass != "special" || shopItem?.pinType == "marketGear") && gear.habitClass != "armoire" && userClass != gear.specialClass {
            classDisclaimerWrapper.isHidden = false
            let className = gear.specialClass?.translatedClassNamePlural ?? ""
            if userLevel >= 10 {
                classDisclaimerLabel.text = L10n.classEquipmentShopDialog(className)
            } else {
                classDisclaimerLabel.text = L10n.insufficientLevelEquipmentDialogNew(className)
            }
            classDisclaimerWrapper.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            classDisclaimerLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        }
    }

    private func configureFields(descriptionLabel: UILabel, valueLabel: UILabel, value: Int) {
        valueLabel.text = "+\(value)"
        if value == 0 {
            descriptionLabel.textColor = ThemeService.shared.theme.dimmedTextColor
            valueLabel.textColor = ThemeService.shared.theme.dimmedTextColor
        } else {
            descriptionLabel.textColor = ThemeService.shared.theme.primaryTextColor
            valueLabel.textColor = ThemeService.shared.theme.successColor
        }
    }
}
