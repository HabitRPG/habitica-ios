//
//  LoginEntryView.swift
//  Habitica
//
//  Created by Phillip on 27.07.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation

@IBDesignable
class LoginEntryView: UIView, UITextFieldDelegate {
    
    @IBInspectable var placeholderText: String? {
        didSet {
            if let text = placeholderText {
                let color = UIColor.white.withAlphaComponent(0.5)
                entryView.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: color])
            } else {
                entryView.placeholder = ""
            }
        }
    }
    
    @IBInspectable var icon: UIImage? {
        didSet {
            iconView.image = icon
        }
    }
    
    @IBInspectable var keyboard: Int {
        get {
            return self.entryView.keyboardType.rawValue
        }
        set(keyboardIndex) {
            if let type = UIKeyboardType.init(rawValue: keyboardIndex) {
            self.entryView.keyboardType = type
            }
            
        }
    }
    
    @IBInspectable var isSecureTextEntry: Bool = false {
        didSet {
            entryView.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    @IBOutlet weak var entryView: UITextField!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var bottomBorder: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        if let view = loadViewFromNib() {
            view.frame = bounds
            view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
            addSubview(view)
        }
    }
    
    func loadViewFromNib() -> UIView? {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        
        return view
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.bottomBorder.alpha = 1.0

        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.bottomBorder.alpha = 0.15
        }
    }
}
