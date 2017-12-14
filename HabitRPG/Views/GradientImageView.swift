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
        set {
            gradient?.removeFromSuperlayer()
            _gradient = newValue
            if let newGradient = gradient {
                self.layer.insertSublayer(newGradient, at: 0)
            }
            setNeedsLayout()
        }
        get {
            return _gradient
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient?.frame = self.bounds
    }
}
