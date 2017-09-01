//
//  GradientImageView.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/18/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class GradientImageView: UIImageView {
    open var gradient: CAGradientLayer = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient.removeFromSuperlayer()
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
}
