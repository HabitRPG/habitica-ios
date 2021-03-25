//
//  GradientView.swift
//  Habitica
//
//  Created by Phillip on 27.07.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

//https://stackoverflow.com/a/37243106/1315039
@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = .black {
        didSet {
            updateColors()
        }
    }
    @IBInspectable var endColor: UIColor = .white {
        didSet {
            updateColors()
        }
    }
    @IBInspectable var startLocation: Double = 0.05 {
        didSet {
            updateLocations()
        }
    }
    @IBInspectable var endLocation: Double = 0.95 {
        didSet {
            updateLocations()
        }
    }
    @IBInspectable var horizontalMode: Bool = false {
        didSet {
            updatePoints()
        }
    }
    @IBInspectable var diagonalMode: Bool =  false {
        didSet {
            updatePoints()
        }
    }
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    @objc var gradientLayer: CAGradientLayer {
        // swiftlint:disable:next force_cast
        return layer as! CAGradientLayer
    }
    
    @objc
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    @objc
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    @objc
    func updateColors() {
        gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}
