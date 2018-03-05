//
//  StatsView.swift
//  Habitica
//
//  Created by Phillip Thelen on 28.11.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class StatsView: UIView {
    
    @IBOutlet private weak var topBackground: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var totalValueLabel: UILabel!
    @IBOutlet private weak var levelValueLabel: UILabel!
    @IBOutlet private weak var equipmentValueLabel: UILabel!
    @IBOutlet private weak var buffsValueLabel: UILabel!
    @IBOutlet private weak var allocatedValueLabel: UILabel!
    @IBOutlet private weak var allocatedLabel: UILabel!
    @IBOutlet private weak var allocatedBackgroundView: UIView!
    @IBOutlet private weak var allocateButton: UIButton!
    
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
    @IBInspectable var attributeTextColor: UIColor?
    
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
            if canAllocatePoints {
                allocateButton.backgroundColor = UIColor.gray600()
                allocatedBackgroundView.backgroundColor = UIColor.gray600()
                allocatedValueLabel.textColor = attributeTextColor
                allocatedLabel.textColor = attributeTextColor
            } else {
                allocateButton.backgroundColor = UIColor.gray700()
                allocatedBackgroundView.backgroundColor = UIColor.gray700()
                allocatedValueLabel.textColor = UIColor.gray50()
                allocatedLabel.textColor = UIColor.gray300()
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
            translatesAutoresizingMaskIntoConstraints = false
            
            view.frame = bounds
            addSubview(view)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            
            allocateButton.setImage(HabiticaIcons.imageOfAttributeAllocateButton, for: .normal)
            allocateButton.tintColor = UIColor(red: 0.529, green: 0.506, blue: 0.565, alpha: 1.000)
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    @objc
    @IBAction func allocateButtonTapped(_ sender: Any) {
        allocateButton.backgroundColor = UIColor.gray500()
        if let action = allocateAction {
            action()
        }
    }
}
