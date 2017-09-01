//
//  PaddedView.swift
//  Habitica
//
//  Created by Phillip Thelen on 27/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {
    
    var horizontalPadding: CGFloat = 8.0
    var verticalPadding: CGFloat = 4.0
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width+horizontalPadding*2, height: size.height+verticalPadding*2)
    }
    
}
