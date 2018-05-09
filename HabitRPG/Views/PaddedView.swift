//
//  PaddedView.swift
//  Habitica
//
//  Created by Phillip Thelen on 27/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class PaddedView: UIView {

    var horizontalPadding: CGFloat {
        get {
            return insets.left
        }
        set {
            insets.left = newValue
            insets.right = newValue
        }
    }
    var verticalPadding: CGFloat {
        get {
            return insets.top
        }
        set {
            insets.top = newValue
            insets.bottom = newValue
        }
    }
    
    var insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
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
        containedView.frame = CGRect(x: insets.left, y: insets.top, width: self.frame.size.width-insets.left-insets.right, height: self.frame.size.height-insets.top-insets.bottom)
        }
    }

    override var intrinsicContentSize: CGSize {
        if let containedSize = containedView?.intrinsicContentSize {
            return CGSize(width: containedSize.width+insets.left+insets.right, height: containedSize.height+insets.top+insets.bottom)
        }
        return CGSize()
    }

}
