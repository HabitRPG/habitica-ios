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
    
    @IBInspectable public var buttonColor: UIColor = UIColor.purple200() {
        didSet {
            backgroundColor = buttonColor
        }
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
            backgroundColor = isEnabled ? buttonColor : UIColor.gray400()
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
        cornerRadius = 6
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .highlighted)
        setTitleColor(.white, for: .selected)
    }
}
