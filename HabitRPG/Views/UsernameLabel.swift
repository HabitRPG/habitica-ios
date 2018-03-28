//
//  UsernameLabel.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class UsernameLabel: UILabel {
    
    @objc public var contributorLevel: Int = 0 {
        didSet {
            textColor = UIColor.contributorColor(for: contributorLevel)
            iconView.image = HabiticaIcons.imageOfContributorBadge(contributorTier: CGFloat(contributorLevel), isNPC: false)
        }
    }
    
    private let iconView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont.systemFont(ofSize: 15.0)
        addSubview(iconView)
        self.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        iconView.frame = CGRect(x: self.frame.size.width - 16, y: self.frame.size.height/2-8, width: 16, height: 16)
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += 18
        return size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let paddedSize = CGSize(width: size.width - 18, height: size.height)
        var newSize = super.sizeThatFits(paddedSize)
        newSize.width += 18
        return newSize
    }
}
