//
//  GradientImageView.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/18/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class GradientImageView: UIImageView {
    private var _gradient: CAGradientLayer?
    @objc open var gradient: CAGradientLayer? {
        get {
            return _gradient
        }
        set {
            gradient?.removeFromSuperlayer()
            _gradient = newValue
            if let newGradient = gradient {
                layer.insertSublayer(newGradient, at: 0)
            }
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient?.frame = bounds
    }
}
