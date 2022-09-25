//
//  ProgressBar.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftUI

struct ProgressBarUI<V>: View where V: BinaryFloatingPoint {
    let value: V
    
    init(value: V, maxValue: V = 1.0) {
        // Cap progressBar value at maxValue to avoid overflow
        self.value = min(value, maxValue) / maxValue
    }
    
    var body: some View {
        GeometryReader { reader in
            let radius = reader.size.height / 2
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: radius)
                    .frame(width: reader.size.width, height: reader.size.height)
                    .foregroundColor(Color(ThemeService.shared.theme.offsetBackgroundColor))
                
                RoundedRectangle(cornerRadius: radius)
                    .size(width: reader.size.width * CGFloat(value), height: reader.size.height)
            }
        }
        
    }
    
}

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
    @objc var barBackgroundColor: UIColor = ThemeService.shared.theme.offsetBackgroundColor {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let trackPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.height/2)
        context?.setFillColor(barBackgroundColor.cgColor)
        trackPath.fill()
        trackPath.addClip()
        var percent = value / maxValue
        if stackedValue > 0 {
            var stackedPercent = stackedValue / maxValue
            if stackedPercent > 1 {
                stackedPercent = 1
            }
            if !(maxValue == 0 || stackedPercent < 0) {
                let rect = CGRect.init(x: rect.origin.x,
                                       y: rect.origin.y,
                                       width: rect.size.width * percent,
                                       height: rect.size.height)
                let fillPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.size.height / 2)
                context?.setFillColor(stackedBarColor.cgColor)
                fillPath.fill()
            }
            percent -= stackedPercent
        }
        if !(maxValue == 0 || percent < 0) {
            let fillPath = UIBezierPath(roundedRect: CGRect.init(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * percent, height: rect.size.height), cornerRadius: rect.size.height/2)
            context?.setFillColor(barColor.cgColor)
            fillPath.fill()
        }
    }
}
