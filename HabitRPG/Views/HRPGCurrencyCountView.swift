//
//  HRPGCurrencyCountView.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/13/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGCurrencyCountView: UIView {
    
    public var amount = 0 {
        didSet {
            countLabel.text = String(describing: amount)
        }
    }
    
    public var currency = Currency.gold {
        didSet {
            currencyImageView.image = currency.getImage()
            countLabel.textColor = currency.getTextColor()
        }
    }
    
    private let countLabel: HRPGAbbrevNumberLabel = HRPGAbbrevNumberLabel()
    private let currencyImageView: UIImageView = UIImageView(image: UIImage(named: "gold_coin"))
    
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
        countLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        
        addSubview(countLabel)
        addSubview(currencyImageView)
        
        let viewDictionary = ["image": self.currencyImageView, "label": self.countLabel]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[image]-4-[label]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[image]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
        
        addConstraint(NSLayoutConstraint.init(item: countLabel,
                                              attribute: NSLayoutAttribute.centerY,
                                              relatedBy: NSLayoutRelation.equal,
                                              toItem: self,
                                              attribute: NSLayoutAttribute.centerY,
                                              multiplier: 1,
                                              constant: 0))
        currencyImageView.addConstraint(
            NSLayoutConstraint.init(item: currencyImageView,
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
    
    
    //Helper methods since objc can't access swift enums
    public func setAsGold() {
        currency = .gold
    }
    
    public func setAsGems() {
        currency = .gem
    }
    
    public func setAsHourglasses() {
        currency = .hourglass
    }
}
