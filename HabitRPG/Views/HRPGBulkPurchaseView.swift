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
class HRPGBulkPurchaseView: UIView, Themeable {
    private let inventoryRepository = InventoryRepository()
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var subtractButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var leadingSpace: NSLayoutConstraint!
    
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
                        
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
            view.backgroundColor = .clear
            ThemeService.shared.addThemeable(themable: self)
            
            let keyboardDoneButtonView = UIToolbar.init()
            keyboardDoneButtonView.sizeToFit()
            let doneButton = UIBarButtonItem.init(barButtonSystemItem: .done,
                                                               target: self,
                                                               action: #selector(doneClicked(sender:)))

            keyboardDoneButtonView.items = [doneButton]
            textField.inputAccessoryView = keyboardDoneButtonView
            
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
            
            value = 1
            addButton.setImage(Asset.plus.image.withRenderingMode(.alwaysTemplate), for: .normal)
            subtractButton.setImage(Asset.minus.image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    @objc
    func doneClicked(sender: AnyObject) {
      textField.endEditing(true)
    }
    
    func applyTheme(theme: Theme) {
        textField.textColor = theme.primaryTextColor
        errorLabel.textColor = theme.ternaryTextColor
        inputContainer.backgroundColor = theme.windowBackgroundColor
        inputContainer.borderColor = theme.separatorColor
        backgroundColor = .clear
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
    
    func hideGemIcon(isHidden: Bool) {
        iconView.isHidden = isHidden
        if isHidden {
            leadingSpace.constant = 12
        } else {
            leadingSpace.constant = 26
        }
    }
}
