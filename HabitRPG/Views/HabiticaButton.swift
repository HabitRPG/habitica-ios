//
//  HabiticaButton.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.11.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class HabiticaButton: UIButton {
    
    @IBInspectable public var buttonColor: UIColor = UIColor.purple200 {
        didSet {
            backgroundColor = buttonColor
            
            updateLegibility()
        }
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        updateLegibility()
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? buttonColor.lighter(by: 15) : buttonColor
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            backgroundColor = isHighlighted ? buttonColor.lighter(by: 25) : buttonColor
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? buttonColor : UIColor.gray400
        }
    }
    
    override open var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
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
    
    func setupView() {
        cornerRadius = 12
        setTitleColor(.white, for: .normal)
        isPointerInteractionEnabled = true
    }
    
    private func updateLegibility() {
        // Calling super here since we don't want to accidentally create an infinite recursion
        if (backgroundColor?.difference(between: currentTitleColor) ?? 1.0) < 1.0 {
            if backgroundColor?.isLight() == true {
                if currentTitleColor.brightness > 0.9 {
                    super.setTitleColor(ThemeService.shared.theme.primaryTextColor, for: .normal)
                } else {
                    super.setTitleColor(ThemeService.shared.theme.backgroundTintColor, for: .normal)
                }
            } else {
                if currentTitleColor.brightness < 0.2 {
                    super.setTitleColor(ThemeService.shared.theme.lightTextColor, for: .normal)
                } else {
                    super.setTitleColor(currentTitleColor.lighter(by: 10), for: .normal)
                }
            }
        }
    }
}
