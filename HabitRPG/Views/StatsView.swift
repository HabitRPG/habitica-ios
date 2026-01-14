//
//  StatsView.swift
//  Habitica
//
//  Created by Phillip Thelen on 28.11.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class StatsView: UIView, Themeable {
    
    @IBOutlet private weak var topBackground: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var totalValueLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet private weak var levelValueLabel: UILabel!
    @IBOutlet weak var equipmentLabel: UILabel!
    @IBOutlet private weak var equipmentValueLabel: UILabel!
    @IBOutlet weak var buffsLabel: UILabel!
    @IBOutlet private weak var buffsValueLabel: UILabel!
    @IBOutlet private weak var allocatedValueLabel: UILabel!
    @IBOutlet private weak var allocatedLabel: UILabel!
    @IBOutlet private weak var allocatedBackgroundView: UIView!
    @IBOutlet private weak var allocateButton: UIButton!
    @IBOutlet weak var topBarTrailingConstraint: NSLayoutConstraint!
    
    private var containedView: UIView?
    
    @IBInspectable var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    @IBInspectable var attributeBackgroundColor: UIColor? {
        didSet {
            topBackground.backgroundColor = attributeBackgroundColor
        }
    }
    @IBInspectable var attributeTextColor: UIColor? {
        didSet {
            titleLabel.textColor = attributeTextColor
            totalValueLabel.textColor = attributeTextColor
        }
    }
    @IBInspectable var allocateButtonBackgroundColor: UIColor?
    @IBInspectable var allocateButtonTextColor: UIColor?

    var totalValue: Int = 0 {
        didSet {
            totalValueLabel.text = String(totalValue)
        }
    }
    
    var levelValue: Int = 0 {
        didSet {
            levelValueLabel.text = String(levelValue)
        }
    }
    var equipmentValue: Int = 0 {
        didSet {
            equipmentValueLabel.text = String(equipmentValue)
        }
    }
    var buffValue: Int = 0 {
        didSet {
            buffsValueLabel.text = String(buffValue)
        }
    }
    var allocatedValue: Int = 0 {
        didSet {
            allocatedValueLabel.text = String(allocatedValue)
        }
    }
    
    var canAllocatePoints: Bool = false {
        didSet {
            allocateButton.isHidden = !canAllocatePoints
            let theme = ThemeService.shared.theme
            if canAllocatePoints {
                allocateButton.backgroundColor = allocateButtonBackgroundColor
                allocateButton.tintColor = allocateButtonTextColor
                topBarTrailingConstraint.constant = 0
            } else {
                allocateButton.backgroundColor = theme.windowBackgroundColor
                topBarTrailingConstraint.constant = 26
            }
        }
    }
    
    var allocateAction: (() -> Void)?
    
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
            containedView = view
            translatesAutoresizingMaskIntoConstraints = false
            
            view.frame = bounds
            addSubview(view)
            
            levelLabel.text = L10n.level
            equipmentLabel.text = L10n.Equipment.equipment
            buffsLabel.text = L10n.buffs
            allocatedLabel.text = L10n.allocated
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
                        
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        backgroundColor = theme.contentBackgroundColor
        containedView?.backgroundColor = theme.contentBackgroundColorDimmed
        levelLabel.textColor = theme.secondaryTextColor
        levelValueLabel.textColor = theme.primaryTextColor
        equipmentLabel.textColor = theme.secondaryTextColor
        equipmentValueLabel.textColor = theme.primaryTextColor
        buffsLabel.textColor = theme.secondaryTextColor
        buffsValueLabel.textColor = theme.primaryTextColor
        allocatedLabel.textColor = theme.secondaryTextColor
        allocatedValueLabel.textColor = theme.primaryTextColor
    }
    
    @IBAction func allocateButtonTapped(_ sender: Any) {
        allocateButton.backgroundColor = UIColor.gray500
        if let action = allocateAction {
            action()
        }
    }
}
