//
//  StatsSliderView.swift
//  Habitica
//
//  Created by Phillip Thelen on 30.11.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class StatsSliderView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var originalValueLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var allocatedTextField: UITextField!
    
    @IBInspectable var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBInspectable var attributeColor: UIColor? {
        didSet {
            slider.minimumTrackTintColor = attributeColor
            titleLabel.textColor = attributeColor
        }
    }
    
    var maxValue: Int = 0 {
        didSet {
            slider.maximumValue = Float(maxValue)
        }
    }
    
    var originalValue: Int = 0 {
        didSet {
            originalValueLabel.text = String(originalValue)
        }
    }
    
    var value: Int = 0 {
        didSet {
            slider.value = Float(value)
            allocatedTextField.text = String(value)
            allocateAction?(value)
        }
    }
    
    var allocateAction: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    @objc
    func sliderChanged() {
        let newValue = roundf(slider.value)
        slider.value = newValue
        let intValue = Int(newValue)
        if value != intValue {
            value = intValue
        }
    }
    
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

            value = 0

            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
}
