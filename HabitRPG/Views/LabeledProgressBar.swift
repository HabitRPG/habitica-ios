//
//  LabeledProgressBar.swift
//  Habitica
//
//  Created by Alasdair McCall on 24/08/2018.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class LabeledProgressBar: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var iconView: UIImageView! {
        didSet {
            iconView.contentMode = .left
            iconView.tintColor = self.color
        }
    }
    
    @IBOutlet weak var progressView: ProgressBar!
    
    @IBOutlet weak var labelView: UILabel! {
        didSet {
            labelView.textColor = UIColor.darkGray
            labelView.textAlignment = .natural
            if #available(iOS 10.0, *) {
                labelView.adjustsFontForContentSizeCategory = true
            }
        }
    }
    
    @IBOutlet weak var typeView: UILabel! {
        didSet {
            typeView.textColor = UIColor.darkGray
            typeView.textAlignment = .natural
            if #available(iOS 10.0, *) {
                typeView.adjustsFontForContentSizeCategory = true
            }
        }
    }

    // MARK: - Private

    private lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.generatesDecimalNumbers = true
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.minimumIntegerDigits = 1
        return numberFormatter
    }()
    
    // MARK: - Public
    
    public var color = UIColor.black {
        didSet {
            progressView.barColor = color
            iconView.tintColor = color
        }
    }
    
    public var icon: UIImage? {
        didSet {
            iconView.image = icon
        }
    }
    
    public var value = NSNumber(value: 0) {
        didSet {
            updateLabelViewText()
            progressView.setBarValue(CGFloat(value.floatValue),
                                     animated: true)
        }
    }
    
    public var maxValue = NSNumber(value: 0) {
        didSet {
            updateLabelViewText()
            progressView.maxValue = CGFloat(maxValue.floatValue)
        }
    }
    
    public var type = "" {
        didSet {
            typeView.text = type
            self.applyAccessibility()
        }
    }
    
    var textColor = UIColor.black {
        didSet {
            labelView.textColor = textColor
            typeView.textColor = textColor
        }
    }
    
    public var fontSize = 11 {
        didSet {
            let scaledFont = CustomFontMetrics.scaledSystemFont(ofSize: CGFloat(fontSize),
                                                                compatibleWith: nil)
            typeView.font = scaledFont
            labelView.font = scaledFont
        }
    }
    
    var isActive = false {
        didSet {
            self.alpha = isActive ? 1.0 : 0.4
            self.applyAccessibility()
        }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            
            view.frame = bounds
            addSubview(view)
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private func updateLabelViewText() {

        var currentValue = value
        if value.floatValue > 1 || value.floatValue < 0 {
            currentValue = NSNumber(value: floor(value.floatValue))
        } else {
            currentValue = NSNumber(value: ceil(value.floatValue * 10) / 10)
        }
        
        guard let valueString = numberFormatter.string(from: currentValue),
            let maxString = numberFormatter.string(from: maxValue) else{
                return
        }
        
        labelView.text = "\(valueString) / \(maxString)"
        self.applyAccessibility()
    }
    
    private func applyAccessibility() {
        
        isAccessibilityElement = isActive
        shouldGroupAccessibilityChildren = true
        labelView.isAccessibilityElement = false
        typeView.isAccessibilityElement = false

        accessibilityLabel = "\(type), \(value.floatValue) of \(maxValue)"
    }
}
