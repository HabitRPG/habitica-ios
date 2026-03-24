//
//  GlassTextField.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.09.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import UIKit

class GlassTextField: UIVisualEffectView {
    let textField = UITextField()
    
    var text: String? {
        get {
            return textField.text
        }
        set(value) {
            textField.text = value
        }
    }
    
    init() {
        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect()
            effect.tintColor = ThemeService.shared.theme.offsetBackgroundColor.withAlphaComponent(0.4)
            super.init(effect: effect)
        } else {
            super.init(effect: .none)
        }
        contentView.addSubview(textField)
        
        if #available(iOS 26.0, *) {
            cornerConfiguration = .capsule()
        } else {
            textField.borderStyle = .roundedRect
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.pin.vertically(12).horizontally(16)
    }
    
    override var intrinsicContentSize: CGSize {
        let fieldSize = textField.intrinsicContentSize
        return CGSize(width: fieldSize.width + 32, height: fieldSize.height + 24)
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
}
