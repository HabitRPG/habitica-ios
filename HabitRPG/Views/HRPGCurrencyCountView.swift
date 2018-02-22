//
//  HRPGCurrencyCountView.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/13/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

enum CurrencyCountViewState {
    case normal, cantAfford, locked
}

enum CurrencyCountViewSize {
    case normal, large
}

enum CurrencyCountViewOrientation {
    case vertical, horizontal
}

class HRPGCurrencyCountView: UIView {
    
    @objc public var amount = 0 {
        didSet {
            countLabel.text = String(describing: amount)
            applyAccesibility()
        }
    }
    
    public var currency = Currency.gold {
        didSet {
            currencyImageView.image = currency.getImage()
            updateStateValues()
            applyAccesibility()
        }
    }
    
    public var state: CurrencyCountViewState = .normal {
        didSet {
            updateStateValues()
            applyAccesibility()
        }
    }
    
    public var viewSize: CurrencyCountViewSize = .normal {
        didSet {
            updateSize()
        }
    }
    
    public var orientation: CurrencyCountViewOrientation = .horizontal {
        didSet {
            updateOrientation()
        }
    }
    
    @objc public var font: UIFont {
        get {
            return countLabel.font
        }
        
        set(newFont) {
            countLabel.font = newFont
        }
    }
    
    private let countLabel: HRPGAbbrevNumberLabel = HRPGAbbrevNumberLabel()
    private let currencyImageView: UIImageView = UIImageView(image: HabiticaIcons.imageOfGold)
    
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
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
        currencyImageView.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        currencyImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        countLabel.text = "0"
        countLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 15)
        if #available(iOS 10.0, *) {
            countLabel.adjustsFontForContentSizeCategory = true
        }
        
        addSubview(countLabel)
        addSubview(currencyImageView)
        
        addConstraints(longwaysConstraints())
        addConstraints(shortwaysConstraints())
        
        widthConstraint = NSLayoutConstraint.init(item: currencyImageView,
                                                  attribute: NSLayoutAttribute.width,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutAttribute.notAnAttribute,
                                                  multiplier: 1,
                                                  constant: viewSize == .normal ? 18 : 24)
        if let width = widthConstraint {
            currencyImageView.addConstraint(width)
        }
        if let height = heightConstraint {
            currencyImageView.addConstraint(height)
        }
        
        setNeedsUpdateConstraints()
        updateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func updateSize() {
        widthConstraint?.constant = (viewSize == .normal ? 18 : 24)
        heightConstraint?.constant = (viewSize == .normal ? 16 : 20)
        
        countLabel.font = viewSize == .normal ? UIFont.preferredFont(forTextStyle: .footnote) : countLabel.font.withSize(17)
        
        if currency == .gem {
            currencyImageView.image = (viewSize == .normal ? HabiticaIcons.imageOfGem : HabiticaIcons.imageOfGem_36)
        }
        
        setNeedsUpdateConstraints()
        updateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func updateOrientation() {
        self.removeConstraints(self.constraints)
        
        addConstraints(longwaysConstraints())
        addConstraints(shortwaysConstraints())
    }
    
    private func updateStateValues() {
        switch state {
        case .normal:
            countLabel.textColor = currency.getTextColor()
            currencyImageView.alpha = 1.0
        case .cantAfford:
            countLabel.textColor = .red100()
            currencyImageView.alpha = 0.3
        case .locked:
            countLabel.textColor = .gray400()
            currencyImageView.alpha = 0.3
        }
    }
    
    private func longwaysConstraints() -> [NSLayoutConstraint] {
        let viewDictionary = ["image": self.currencyImageView, "label": self.countLabel]
        let orientationChar = orientation == .horizontal ? "H" : "V"
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "\(orientationChar):|-0-[image]-4-[label]-0-|",
                                                        options: NSLayoutFormatOptions(rawValue: 0),
                                                        metrics: nil,
                                                        views: viewDictionary)
        
        if orientation == .vertical {
            constraints.append(NSLayoutConstraint.init(item: countLabel,
                                                       attribute: NSLayoutAttribute.centerX,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: self,
                                                       attribute: NSLayoutAttribute.centerX,
                                                       multiplier: 1,
                                                       constant: 0))
        }
        return constraints
    }
    
    private func shortwaysConstraints() -> [NSLayoutConstraint] {
        let viewDictionary = ["image": self.currencyImageView, "label": self.countLabel]
        let orientationChar = orientation == .horizontal ? "V" : "H"
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "\(orientationChar):|-0-[image]-0-|",
                                                         options: NSLayoutFormatOptions(rawValue: 0),
                                                         metrics: nil,
                                                         views: viewDictionary)
        if orientation == .horizontal {
            constraints.append(NSLayoutConstraint.init(item: countLabel,
                                                       attribute: NSLayoutAttribute.centerY,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: self,
                                                       attribute: NSLayoutAttribute.centerY,
                                                       multiplier: 1,
                                                       constant: 0))
        }
        return constraints
    }
    
    //Helper methods since objc can't access swift enums
    @objc
    public func setAsGold() {
        currency = .gold
    }
    
    @objc
    public func setAsGems() {
        currency = .gem
    }
    
    @objc
    public func setAsHourglasses() {
        currency = .hourglass
    }
    
    private func applyAccesibility() {
        self.shouldGroupAccessibilityChildren = true
        self.isAccessibilityElement = true
        self.countLabel.isAccessibilityElement = false
        
        self.accessibilityLabel = "\(amount) \(currency)"
    }
}
