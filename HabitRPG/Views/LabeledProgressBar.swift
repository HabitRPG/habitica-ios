//
//  LabeledProgressBar.swift
//  Habitica
//
//  Created by Phillip Thelen on 04.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import PinLayout
import UIKit

class LabeledProgressBar: UIView {
    var isActive: Bool = true {
        didSet {
            alpha = isActive ? 1.0 : 0.4
            applyAccessibility()
        }
    }
    var color: UIColor = .black {
        didSet {
            iconView.tintColor = color
            progressBar.barColor = color
        }
    }
    var value: Float = 0 {
        didSet {
            progressBar.value = CGFloat(value)
            updateLabels()
        }
    }
    var maxValue: Float = 100 {
        didSet {
            progressBar.maxValue = CGFloat(maxValue)
            updateLabels()
        }
    }
    var type: String? {
        didSet {
            typeView.text = type
            applyAccessibility()
            setNeedsLayout()
        }
    }
    var icon: UIImage? {
        didSet {
            iconView.image = icon
        }
    }
    var fontSize: CGFloat = 12 {
        didSet {
            labelView.font = UIFontMetrics.default.scaledSystemFont(ofSize: fontSize)
            typeView.font = UIFontMetrics.default.scaledSystemFont(ofSize: fontSize)
        }
    }
    var textColor: UIColor = ThemeService.shared.theme.primaryTextColor {
        didSet {
            labelView.textColor = textColor
            typeView.textColor = textColor
        }
    }
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 1
        formatter.minimumIntegerDigits = 1
        return formatter
    }()
    
    let progressBar = ProgressBar()
    let iconView = UIImageView()
    let labelView = UILabel()
    let typeView = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(progressBar)
        addSubview(iconView)
        addSubview(labelView)
        addSubview(typeView)
        
        textColor = ThemeService.shared.theme.primaryTextColor
        fontSize = 11
    }
    
    private func updateLabels() {
        var currentValue = value
        if value > 1 || value < 0 {
            currentValue = floor(value)
        } else {
            currentValue = ceil((value * 10) / 10)
        }
        labelView.text = "\(numberFormatter.string(from: NSNumber(value: currentValue)) ?? "0") / \(numberFormatter.string(from: NSNumber(value: maxValue)) ?? "0")"
        applyAccessibility()
        setNeedsLayout()
    }
    
    private func applyAccessibility() {
        isAccessibilityElement = isActive
        shouldGroupAccessibilityChildren = true
        labelView.isAccessibilityElement = false
        typeView.isAccessibilityElement = false
        
        accessibilityLabel = "\(typeView.text ?? "") \(Int(value)) of \(Int(maxValue))"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        iconView.pin.start().size(18)
        progressBar.pin.after(of: iconView).marginStart(6).end().height(8).top()
        labelView.pin.below(of: progressBar).marginTop(2).start(to: progressBar.edge.start).sizeToFit()
        typeView.pin.below(of: progressBar).marginTop(2).end(to: progressBar.edge.end).sizeToFit()
        
        progressBar.setNeedsDisplay()
    }
}
