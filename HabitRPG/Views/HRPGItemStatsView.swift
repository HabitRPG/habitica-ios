//
//  HRPGItemStatsView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/18/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGItemStatsView: UIView {
    @IBOutlet weak var strLabel: UILabel!
    @IBOutlet weak var strStatLabel: UILabel!
    @IBOutlet weak var conLabel: UILabel!
    @IBOutlet weak var conStatLabel: UILabel!
    @IBOutlet weak var perLabel: UILabel!
    @IBOutlet weak var perStatLabel: UILabel!
    @IBOutlet weak var intLabel: UILabel!
    @IBOutlet weak var intStatLabel: UILabel!
    
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
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    public func configure(gear: Gear) {
        configureFields(descriptionLabel: strLabel, valueLabel: strStatLabel, value: gear.str.intValue)
        configureFields(descriptionLabel: conLabel, valueLabel: conStatLabel, value: gear.con.intValue)
        configureFields(descriptionLabel: perLabel, valueLabel: perStatLabel, value: gear.per.intValue)
        configureFields(descriptionLabel: intLabel, valueLabel: intStatLabel, value: gear.intelligence.intValue)
    }

    private func configureFields(descriptionLabel: UILabel, valueLabel: UILabel, value: Int) {
        valueLabel.text = "+\(value)"
        if value == 0 {
            descriptionLabel.textColor = .gray400()
            valueLabel.textColor = .gray400()
        }
    }
}
