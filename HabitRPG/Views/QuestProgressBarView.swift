//
//  QuestProgressBarView.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class QuestProgressBarView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    public var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    public var barColor: UIColor? {
        get {
            return progressView.backgroundColor
        }
        set {
            progressView.backgroundColor = newValue
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
            updateProgressBarWidth()
            updateValueLabel()
        }
    }
    
    public var currentValue: Float = 0 {
        didSet {
            updateProgressBarWidth()
            updateValueLabel()
        }
    }
    
    private func updateValueLabel() {
        self.valueLabel.text = "\(String(currentValue).stringWithAbbreviatedNumber()) / \(String(maxValue).stringWithAbbreviatedNumber())"
    }
    
    private func updateProgressBarWidth() {
        var percent = self.currentValue / self.maxValue
        if self.maxValue == 0 || percent < 0 {
            percent = 0
        }
        if percent > 1.0 {
            percent = 1.0
        }
        progressViewWidthConstraint.constant = CGFloat(percent) * self.frame.size.width
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
