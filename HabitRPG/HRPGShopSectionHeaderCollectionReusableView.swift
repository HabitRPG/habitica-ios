//
//  HRPGShopSectionHeaderCollectionReusableView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/1/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class HRPGShopSectionHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gearCategoryLabel: UILabel!
    @IBOutlet weak var dropdownIconView: UIImageView!
    @IBOutlet weak var otherClassDisclaimer: UILabel!
    @IBOutlet weak var swapsInLabel: UILabel!
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var lowerBackgroundView: UIView!
    
    @IBOutlet weak var rightSparkleView: UIImageView!
    @IBOutlet weak var leftSparkleView: UIImageView!
    var onGearCategoryLabelTapped: (() -> Void)?
        
    @IBOutlet weak var changeClassWrapper: UIView!
    @IBOutlet weak var changeClassTitle: UILabel!
    @IBOutlet weak var changeClassSubtitle: UILabel!
    @IBOutlet weak var changeClassPriceLabel: CurrencyCountView!
    override func awakeFromNib() {
        super.awakeFromNib()
        gearCategoryLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gearCategoryLabelTapped)))
        titleLabel.textColor = .white
        swapsInLabel.textColor = .white
        
        backgroundView.layer.cornerRadius = 9
        lowerBackgroundView.layer.cornerRadius = 6
        lowerBackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    @objc
    private func gearCategoryLabelTapped() {
        if let action = onGearCategoryLabelTapped {
            action()
        }
    }
    
    func hideSecondRow() {
        separatorView.isHidden = true
        lowerBackgroundView.isHidden = true
        swapsInLabel.isHidden = true
        gearCategoryLabel.isHidden = true
        dropdownIconView.isHidden = true
    }
    
    func setSecondRow(date: Date) {
        separatorView.isHidden = false
        lowerBackgroundView.isHidden = false
        swapsInLabel.isHidden = false
        gearCategoryLabel.isHidden = true
        dropdownIconView.isHidden = true
        if date > Date() {
            swapsInLabel.text = L10n.swapsInX(date.getImpreciseRemainingString())
        } else {
            swapsInLabel.text = L10n.refreshForItems
        }
        lowerBackgroundView.backgroundColor = .purple300
    }
    
    func setSecondRow(className: String, classColor: UIColor) {
        separatorView.isHidden = false
        lowerBackgroundView.isHidden = false
        swapsInLabel.isHidden = true
        gearCategoryLabel.isHidden = false
        dropdownIconView.isHidden = false
        gearCategoryLabel.text = className
        lowerBackgroundView.backgroundColor = classColor
        gearCategoryLabel.textColor = classColor.isLight() ? .gray50 : .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let topOffset = 0.0
        let horizontalPadding = 12.0
        let verticalPadding = 8.0
        titleLabel.pin.start(horizontalPadding + 24).end(horizontalPadding + 24).top(topOffset+verticalPadding).sizeToFit(.width)
        leftSparkleView.pin.start(horizontalPadding + 16).vCenter(to: titleLabel.edge.vCenter)
        rightSparkleView.pin.end(horizontalPadding + 16).vCenter(to: titleLabel.edge.vCenter)
        
        var height = titleLabel.bounds.size.height + verticalPadding*2
        if !separatorView.isHidden || !lowerBackgroundView.isHidden {
            separatorView.pin.start(horizontalPadding).end(horizontalPadding).top(topOffset+height - 3).height(3)
            lowerBackgroundView.pin.start(horizontalPadding + 3).end(horizontalPadding + 3).top(topOffset+height).height(height-8)
            height *= 2
            height -= 5
        }
        if !swapsInLabel.isHidden {
            swapsInLabel.pin.start(horizontalPadding + 12).end(horizontalPadding).top(topOffset+height/2).height(height/2)
        }
        if !gearCategoryLabel.isHidden {
            gearCategoryLabel.pin.start(horizontalPadding + 12).end(horizontalPadding).top(topOffset+height/2).height(height/2)
        }
        if !dropdownIconView.isHidden {
            dropdownIconView.pin.end(horizontalPadding + 16).vCenter(to: lowerBackgroundView.edge.vCenter).width(10).height(7)
        }
        backgroundView.pin.start(horizontalPadding).end(horizontalPadding).top(topOffset).height(height)
        
        if !otherClassDisclaimer.isHidden {
            otherClassDisclaimer.pin.below(of: backgroundView).marginTop(12).start().end().sizeToFit(.width)
        }
        
        if !changeClassWrapper.isHidden {
            changeClassWrapper.pin.below(of: otherClassDisclaimer).marginTop(6).start(12).end(12).height(60)
        }
    }
}
