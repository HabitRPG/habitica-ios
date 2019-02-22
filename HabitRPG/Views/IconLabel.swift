//
//  IconLabel.swift
//  Habitica
//
//  Created by Phillip on 30.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
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
        
        iconView.contentMode = UIView.ContentMode.center
        
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .white
        
        addSubview(label)
        addSubview(iconView)
        
        let viewDictionary = ["image": self.iconView, "label": self.label]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[image]-4-[label]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[image]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
        
        addConstraint(NSLayoutConstraint.init(item: label,
                                              attribute: NSLayoutConstraint.Attribute.centerY,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: self,
                                              attribute: NSLayoutConstraint.Attribute.centerY,
                                              multiplier: 1,
                                              constant: 0))
        iconView.addConstraint(
            NSLayoutConstraint.init(item: iconView,
                                    attribute: NSLayoutConstraint.Attribute.width,
                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                    toItem: nil,
                                    attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                    multiplier: 1,
                                    constant: 18))
        
        let widthConstraint = NSLayoutConstraint.init(item: self,
                                                      attribute: NSLayoutConstraint.Attribute.width,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,
                                                      toItem: nil,
                                                      attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                      multiplier: 1,
                                                      constant: 18)
        widthConstraint.priority = UILayoutPriority(rawValue: 500)
        self.addConstraint(widthConstraint)
        
        setNeedsUpdateConstraints()
        updateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
        if icon == nil || text == nil {
            return CGSize.zero
        } else {
            let width = 22 + label.intrinsicContentSize.width
            return CGSize(width: width, height: 20)
        }
    }
}
