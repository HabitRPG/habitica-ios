//
//  HRPGBulkPurchaseView.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.04.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

@IBDesignable
class HRPGBulkPurchaseView: UIView {
    private let inventoryRepository = InventoryRepository()
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var subtractButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var user: UserProtocol?
    
    var onValueChanged: ((Int) -> Void)?
    
    var maxValue: Int = 0
    var value: Int = 1 {
        didSet {
            if value < 1 {
                value = 1
            }
            if maxValue > 0 && value > maxValue {
                value = maxValue
            }
            if value <= 1 {
                subtractButton.isEnabled = false
            } else {
                subtractButton.isEnabled = true
            }
            if maxValue != 0 && value >= maxValue {
                addButton.isEnabled = false
            } else {
                addButton.isEnabled = true
            }
            textField.text = String(value)
            if let action = onValueChanged {
                action(value)
            }
            errorLabel.alpha = 0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    init(for contentView: UIView) {
        super.init(frame: contentView.bounds)
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
            textField.textColor = theme.primaryTextColor
            errorLabel.textColor = theme.ternaryTextColor
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
            
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
            
            value = 1
            addButton.setImage(Asset.plus.image.withRenderingMode(.alwaysTemplate), for: .normal)
            subtractButton.setImage(Asset.minus.image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        value += 1
    }
    @IBAction func subtractButtonTapped(_ sender: Any) {
        value -= 1
    }
    @IBAction func textFieldDidChange(_ sender: Any) {
        guard let intValue = Int(textField.text ?? "") else {
            if textField.text?.isEmpty != true {
                value = 1
            }
            return
        }
        if intValue != value {
            value = intValue
        }
    }
    
    @objc
    func tapped() {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
}
