//
//  PillView.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

enum PillStyle {
    case cornered
    case rounded
    case circular
}

@IBDesignable
class PillView: UIView {
    
    @IBInspectable
    var text: String? {
        get {
            return self.label.text
        }
        set {
            self.label.text = newValue
        }
    }
    
    @IBInspectable
    var icon: UIImage? {
        didSet {
            icon?.withRenderingMode(.alwaysTemplate)
            self.iconView.image = icon
            if icon != nil {
                self.label.textAlignment = .natural
            } else {
                self.label.textAlignment = .center
            }
        }
    }
    
    @IBInspectable
    var hasBorder: Bool = false {
        didSet {
            if hasBorder {
                self.layer.borderWidth = 1
            } else {
                self.layer.borderWidth = 0
            }
        }
    }
    
    @IBInspectable
    var isCircular: Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    var hasRoundedCorners: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.gray200() {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var pillColor: UIColor = UIColor.gray400() {
        didSet {
            layer.backgroundColor = pillColor.cgColor
            
            if (self.automaticTextColor) {
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                if pillColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                    if red*0.299 + green*0.587 + blue*0.114 > 0.729 {
                        self.label.textColor = .black
                    } else {
                        self.label.textColor = .white
                    }
                }
            }
        }
    }
    
    @IBInspectable
    var textColor: UIColor = UIColor.black {
        didSet {
            self.label.textColor = textColor
            self.iconView.tintColor = textColor
        }
    }
    
    @IBInspectable
    var automaticTextColor: Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private let label: UILabel
    private let iconView: UIImageView;
    
    override init(frame: CGRect) {
        self.label = UILabel()
        self.iconView = UIImageView()
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.label = UILabel()
        self.iconView = UIImageView()
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        self.addSubview(self.label)
        self.addSubview(self.iconView)
        self.label.textAlignment = .center
        self.label.font = UIFont.preferredFont(forTextStyle: .caption1)
        self.iconView.contentMode = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.frame = CGRect(x: 6, y: 0, width: 15, height: self.frame.size.height)
        var labelOffset = CGFloat(0)
        if icon != nil {
            labelOffset = CGFloat(25)
        }
        self.label.frame = CGRect(x: labelOffset, y: 0, width: self.frame.size.width-labelOffset, height: self.frame.size.height)
        if self.isCircular {
            layer.cornerRadius = frame.size.height / 2
        } else if self.hasRoundedCorners {
            layer.cornerRadius = 5
        } else {
            layer.cornerRadius = 0
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            if self.isHidden {
                return CGSize(width: 0, height: 0)
            }
            let originalSize = self.label.intrinsicContentSize
            var width = originalSize.width+24
            let height = originalSize.height+12
            if icon != nil {
                width += 15+4
            }
            return CGSize(width: width, height: height)
        }
    }

}
