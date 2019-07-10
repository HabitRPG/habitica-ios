//
//  LoginEntryView.swift
//  Habitica
//
//  Created by Phillip on 27.07.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

@IBDesignable
class LoginEntryView: UIView, UITextFieldDelegate {
    
    @IBInspectable var placeholderText: String? {
        didSet {
            if let text = placeholderText {
                let color = UIColor.white.withAlphaComponent(0.5)
                entryView.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: color])
            } else {
                entryView.placeholder = ""
            }
        }
    }
    
    weak public var delegate: UITextFieldDelegate?
    
    @IBInspectable var icon: UIImage? {
        didSet {
            iconView.image = icon
        }
    }
    
    @IBInspectable var keyboard: Int {
        get {
            return entryView.keyboardType.rawValue
        }
        set(keyboardIndex) {
            if let type = UIKeyboardType.init(rawValue: keyboardIndex) {
            entryView.keyboardType = type
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
    
    var gestureRecognizer: UIGestureRecognizer?
    
    var hasError: Bool = false {
        didSet {
            setBarColor()
        }
    }
    
    private var wasEdited = false
    
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
            view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            addSubview(view)
            
            gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedView))
            
            if let gestureRecognizer = self.gestureRecognizer {
                addGestureRecognizer(gestureRecognizer)
            }
            isUserInteractionEnabled = true
        }
    }
    
    func loadViewFromNib() -> UIView? {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        
        return view
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        wasEdited = true
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.bottomBorder.alpha = 1.0
        }
        if let gestureRecognizer = self.gestureRecognizer {
            removeGestureRecognizer(gestureRecognizer)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.bottomBorder.alpha = 0.15
        }
        if let gestureRecognizer = gestureRecognizer {
            addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let function = delegate?.textFieldShouldReturn {
            return function(textField)
        }
        return false
    }
    
    @objc
    func tappedView() {
        entryView.becomeFirstResponder()
    }
    
    private func setBarColor() {
        if !wasEdited {
            return
        }
        
        if hasError {
            bottomBorder.backgroundColor = UIColor.red50()
        } else {
            bottomBorder.backgroundColor = .white
        }
    }
}
