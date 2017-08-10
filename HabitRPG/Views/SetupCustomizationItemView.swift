//
//  SetupCustomizationItemView.swift
//  Habitica
//
//  Created by Phillip on 07.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class SetupCustomizationItemView: UIView {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    var isActive = false {
        didSet {
            updateViewsForActivity()
        }
    }
    
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
            borderView.layer.borderColor = UIColor.purple400().cgColor
        }
    }
    
    func loadViewFromNib() -> UIView? {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        
        return view
    }
    
    func setItem(_ item: SetupCustomization) {
        if let icon = item.icon {
            iconView.image = icon
        }
        if let color = item.color {
            iconView.backgroundColor = color
        }
        if let text = item.text {
            labelView.text = text
        } else {
            labelView.isHidden = true
        }
    }
    
    private func updateViewsForActivity() {
        if isActive {
            borderView.layer.borderWidth = 4
            labelView.textColor = .white
        } else {
            borderView.layer.borderWidth = 0
            labelView.textColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
}
