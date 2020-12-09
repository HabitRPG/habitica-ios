//
//  PillView.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

enum PillStyle {
    case cornered
    case rounded
    case circular
}

@IBDesignable
class PillView: UIView {

    @IBInspectable var text: String? {
        get {
            return self.label.text
        }
        set {
            self.label.text = newValue
        }
    }

    @IBInspectable var icon: UIImage? {
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

    @IBInspectable var hasBorder: Bool = false {
        didSet {
            if hasBorder {
                self.layer.borderWidth = 1
            } else {
                self.layer.borderWidth = 0
            }
        }
    }

    @IBInspectable var isCircular: Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }

    @IBInspectable var hasRoundedCorners: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }

    @IBInspectable var pillColor: UIColor = UIColor.gray400 {
        didSet {
            layer.backgroundColor = pillColor.cgColor

            if self.automaticTextColor {
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

    @IBInspectable var textColor: UIColor = UIColor.black {
        didSet {
            self.label.textColor = textColor
            self.iconView.tintColor = textColor
        }
    }

    @IBInspectable var automaticTextColor: Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }

    override var isHidden: Bool {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    private let label: UILabel
    private let iconView: UIImageView

    override init(frame: CGRect) {
        label = UILabel()
        iconView = UIImageView()
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        label = UILabel()
        iconView = UIImageView()
        super.init(coder: aDecoder)
        setupView()
    }

    func setupView() {
        addSubview(label)
        addSubview(iconView)
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        iconView.contentMode = .center
        
        if borderColor == nil {
            borderColor = ThemeService.shared.theme.secondaryBadgeColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.frame = CGRect(x: 8, y: 0, width: 15, height: frame.size.height)
        var labelOffset = CGFloat(0)
        if icon != nil {
            labelOffset = CGFloat(27)
        }
        label.frame = CGRect(x: labelOffset, y: 0, width: frame.size.width-labelOffset, height: frame.size.height)
        layer.sublayers?.forEach({ sublayer in
            sublayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            if isCircular {
                sublayer.cornerRadius = frame.size.height / 2
            } else if hasRoundedCorners {
                sublayer.cornerRadius = 5
            } else {
                sublayer.cornerRadius = 0
            }
        })
        if isCircular {
            layer.cornerRadius = frame.size.height / 2
        } else if hasRoundedCorners {
            layer.cornerRadius = 5
        } else {
            layer.cornerRadius = 0
        }
    }

    override var intrinsicContentSize: CGSize {
            if self.isHidden {
                return CGSize(width: 0, height: 0)
            }
            let originalSize = label.intrinsicContentSize
            var width = originalSize.width+16
            let height = originalSize.height+12
            if icon != nil {
                width += 15+4
            }
            return CGSize(width: width, height: height)
    }
}
