//
//  IconLabel.swift
//  Habitica
//
//  Created by Phillip on 30.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class IconLabel: UIView {
    
    public var text: String? {
        get {
            return label.text
        }
        set(newText) {
            label.text = newText
        }
    }
    
    public var icon: UIImage? {
        get {
            return iconView.image
        }
        set(newIcon) {
            iconView.image = newIcon
        }
    }
    
    public var font: UIFont {
        get {
            return label.font
        }
        
        set(newFont) {
            label.font = newFont
        }
    }
    
    public var textColor: UIColor {
        get {
            return label.textColor
        }
        
        set(newColor) {
            label.textColor = newColor
        }
    }
    
    private let label: UILabel = UILabel()
    private let iconView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureViews()
    }
    
    internal func configureViews() {
        translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.contentMode = UIViewContentMode.center
        
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        
        addSubview(label)
        addSubview(iconView)
        
        let viewDictionary = ["image": self.iconView, "label": self.label]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[image]-4-[label]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[image]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
        
        addConstraint(NSLayoutConstraint.init(item: label,
                                              attribute: NSLayoutAttribute.centerY,
                                              relatedBy: NSLayoutRelation.equal,
                                              toItem: self,
                                              attribute: NSLayoutAttribute.centerY,
                                              multiplier: 1,
                                              constant: 0))
        iconView.addConstraint(
            NSLayoutConstraint.init(item: iconView,
                                    attribute: NSLayoutAttribute.width,
                                    relatedBy: NSLayoutRelation.equal,
                                    toItem: nil,
                                    attribute: NSLayoutAttribute.notAnAttribute,
                                    multiplier: 1,
                                    constant: 18))
        
        setNeedsUpdateConstraints()
        updateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
        if icon == nil || text == nil {
            return CGSize.zero
        } else {
            return super.intrinsicContentSize
        }
    }
}
