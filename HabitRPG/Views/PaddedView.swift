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
            if let containedView = containedView {
                containedView.removeFromSuperview()
            }
            if let newView = newView {
                self.addSubview(newView)
            }
        }
    }

    override func layoutSubviews() {
        if let containedView = containedView {
        containedView.frame = CGRect(x: horizontalPadding, y: verticalPadding, width: self.frame.size.width-self.horizontalPadding*2, height: self.frame.size.height-self.verticalPadding*2)
        }
    }

    override var intrinsicContentSize: CGSize {
        if let containedSize = containedView?.intrinsicContentSize {
            return CGSize(width: containedSize.width+horizontalPadding*2, height: containedSize.height+verticalPadding*2)
        }
        return CGSize()
    }

}
