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
            invalidateIntrinsicContentSize()
            setNeedsLayout()
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
            superview?.setNeedsLayout()
        }
    }
    
    @objc public var font: UIFont {
        get {
            return countLabel.font
        }
        
        set(newFont) {
            countLabel.font = newFont
            setNeedsLayout()
        }
    }
    
    private let countLabel: HRPGAbbrevNumberLabel = HRPGAbbrevNumberLabel()
    private let currencyImageView: UIImageView = UIImageView(image: HabiticaIcons.imageOfGold)
    
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
        
        currencyImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        countLabel.text = "0"
        countLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 15)
        if #available(iOS 10.0, *) {
            countLabel.adjustsFontForContentSizeCategory = true
        }
        
        addSubview(countLabel)
        addSubview(currencyImageView)
        
        setNeedsUpdateConstraints()
        updateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func updateSize() {
        countLabel.font = viewSize == .normal ? UIFont.preferredFont(forTextStyle: .footnote) : countLabel.font.withSize(17)
        
        if currency == .gem {
            currencyImageView.image = (viewSize == .normal ? HabiticaIcons.imageOfGem : HabiticaIcons.imageOfGem_36)
        }

        setNeedsLayout()
        layoutIfNeeded()
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
            countLabel.textColor = ThemeService.shared.theme.dimmedTextColor
            currencyImageView.alpha = 0.3
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private var iconWidth: CGFloat {
        return (viewSize == .normal ? CGFloat(18) : CGFloat(24))
    }
    
    private var requiredWidth: CGFloat {
        return iconWidth + 4 + countLabel.bounds.size.width
    }
    
    private func layout() {
        countLabel.pin.vertically().sizeToFit(.height)
        let halfSize = requiredWidth / 2
        let offset = ((bounds.size.width / 2) - halfSize) + 4 + iconWidth
        countLabel.pin.left(offset)
        currencyImageView.pin.vertically().left(of: countLabel).marginRight(4)
    }
    
    override var intrinsicContentSize: CGSize {
        layout()
        return CGSize(width: requiredWidth, height: 28)
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        countLabel.pin.vertically().sizeToFit(.height)
        pin.width(requiredWidth).height(28)
        layout()
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
