//
//  QuestProgressBarView.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class QuestProgressBarView: UIView {
    
    private var formatter = NumberFormatter()
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var progressView: ProgressBar!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var pendingLabel: UILabel!
    @IBOutlet private weak var pendingIconView: UIImageView!
    @IBOutlet weak var pendingView: UIView!
    
    public var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    public var pendingTitle: String = "" {
        didSet {
            updatePendingLabel()
        }
    }
    
    public var barColor: UIColor {
        get {
            return progressView.barColor
        }
        set {
            progressView.barColor = newValue
            pendingLabel.textColor = newValue
        }
    }
    
    public var pendingBarColor: UIColor {
        get {
            return progressView.stackedBarColor
        }
        set {
            progressView.stackedBarColor = newValue
        }
    }
    
    public var pendingIcon: UIImage? {
        get {
            return pendingIconView.image
        }
        set {
            pendingIconView.image = newValue
        }
    }
    
    public var icon: UIImage? {
        get {
            return iconView.image
        }
        set {
            iconView.image = newValue
        }
    }

    public var maxValue: Float = 0 {
        didSet {
            progressView.maxValue = CGFloat(maxValue)
            updateValueLabel()
        }
    }
    
    public var currentValue: Float = 0 {
        didSet {
            progressView.value = CGFloat(currentValue)
            updateValueLabel()
        }
    }
    public var pendingValue: Float = 0 {
        didSet {
            progressView.stackedValue = CGFloat(pendingValue)
            updatePendingLabel()
        }
    }
    
    private func updateValueLabel() {
        self.valueLabel.text = "\(formatter.string(from: NSNumber(value: currentValue)) ?? "") / \(formatter.string(from: NSNumber(value: maxValue)) ?? "")"
    }
    
    private func updatePendingLabel() {
        pendingView.isHidden = pendingTitle.count == 0
        pendingLabel.text = "\(formatter.string(from: NSNumber(value: pendingValue)) ?? "") \(pendingTitle)"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            translatesAutoresizingMaskIntoConstraints = true
            
            view.frame = bounds
            view.autoresizingMask = [
                UIViewAutoresizing.flexibleWidth,
                UIViewAutoresizing.flexibleHeight
            ]
            addSubview(view)
            pendingView.isHidden = true
            
            progressView.barBackgroundColor = UIColor.init(white: 1.0, alpha: 0.16)
            titleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 14, ofWeight: .semibold)
            pendingLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
            valueLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
            
            formatter.usesGroupingSeparator = true
            formatter.numberStyle = .decimal
            formatter.locale = NSLocale.current
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.size.width, height: 66)
    }
    
}
