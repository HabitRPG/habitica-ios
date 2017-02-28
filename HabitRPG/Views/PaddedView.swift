//
//  PaddedView.swift
//  Habitica
//
//  Created by Phillip Thelen on 27/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class PaddedView: UIView {

    var horizontalPadding: CGFloat = 8.0
    var verticalPadding: CGFloat = 4.0
    var containedView: UIView? {
        willSet(newView) {
            if (containedView != nil) {
                containedView?.removeFromSuperview()
            }
            self.addSubview(newView!)
        }
    }
    
    override func layoutSubviews() {
        if containedView != nil {
        containedView!.frame = CGRect(x: horizontalPadding, y: verticalPadding, width: self.frame.size.width-self.horizontalPadding*2, height: self.frame.size.height-self.verticalPadding*2)
        }
    }

    override var intrinsicContentSize: CGSize {
        if let containedSize = containedView?.intrinsicContentSize {
            return CGSize(width: containedSize.width+horizontalPadding*2, height: containedSize.height+verticalPadding*2)
        }
        return CGSize()
    }
    
}
