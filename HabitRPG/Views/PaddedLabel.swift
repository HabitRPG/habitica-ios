//
//  PaddedView.swift
//  Habitica
//
//  Created by Phillip Thelen on 27/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {
    
    @objc public var horizontalPadding: CGFloat = 8.0
    @objc public var verticalPadding: CGFloat = 4.0
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width+horizontalPadding*2, height: size.height+verticalPadding*2)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let paddedSize = CGSize(width: size.width+horizontalPadding*2, height: size.height+verticalPadding*2)
        return super.sizeThatFits(paddedSize)
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        let paddedSize = CGSize(width: frame.size.width+horizontalPadding*2, height: frame.size.height+verticalPadding*2)
        frame = CGRect(x: 0, y: 0, width: paddedSize.width, height: paddedSize.height)
    }
}
