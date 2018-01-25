//
//  ProgressBar.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class ProgressBar: UIView {
    
    @objc var value: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @objc var stackedValue: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @objc var maxValue: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @objc var barColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    @objc var stackedBarColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    @objc var barBackgroundColor: UIColor = UIColor.gray600() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
    }
    
    @objc
    func setBarValue(_ value: CGFloat, animated: Bool = false) {
        self.value = value
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let trackPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.height/2)
        context?.setFillColor(barBackgroundColor.cgColor)
        trackPath.fill()
        trackPath.addClip()
        let percent = self.value / self.maxValue
        if stackedValue > 0 {
            let stackedPercent = self.stackedValue / self.maxValue
            if !(self.maxValue == 0 || stackedPercent < 0) {
                let fillPath = UIBezierPath(roundedRect: CGRect.init(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * (percent + stackedPercent), height: rect.size.height), cornerRadius: rect.size.height/2)
                context?.setFillColor(stackedBarColor.cgColor)
                fillPath.fill()
            }
        }
        if !(self.maxValue == 0 || percent < 0) {
            let fillPath = UIBezierPath(roundedRect: CGRect.init(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * percent, height: rect.size.height), cornerRadius: rect.size.height/2)
            context?.setFillColor(barColor.cgColor)
            fillPath.fill()
        }
    }
}
