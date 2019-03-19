//
//  QuestProgressBarView.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class QuestProgressBarView: UIView {
    
    private let formatter = NumberFormatter()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = CustomFontMetrics.scaledSystemFont(ofSize: 14, ofWeight: .semibold)
        return view
    }()
    private let progressView: ProgressBar = {
        let view = ProgressBar()
        view.barBackgroundColor = UIColor.init(white: 1.0, alpha: 0.16)
        return view
    }()
    private let valueLabel: UILabel = {
        let view = UILabel()
        view.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
        return view
    }()
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()
    private let bigIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()
    private let pendingLabel: UILabel = {
        let view = UILabel()
        view.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
        return view
    }()
    private let pendingIconView: UIImageView = {
        let view = UIImageView()
        view.image = HabiticaIcons.imageOfDamage
        view.contentMode = .center
        return view
    }()
    
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
    
    public var barBackgroundColor = UIColor.init(white: 1.0, alpha: 0.16) {
        didSet {
            progressView.barBackgroundColor = barBackgroundColor
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
    
    public var icon: UIImage? {
        get {
            return iconView.image
        }
        set {
            iconView.image = newValue
        }
    }
    
    public var bigIcon: UIImage? {
        get {
            return bigIconView.image
        }
        set {
            bigIconView.image = newValue
            setNeedsLayout()
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
    
    public var titleTextColor = UIColor.white {
        didSet {
            titleLabel.textColor = titleTextColor
        }
    }
    
    public var valueTextColor = UIColor.white {
        didSet {
            valueLabel.textColor = valueTextColor
            pendingLabel.textColor = valueTextColor
        }
    }
    
    private func updateValueLabel() {
        self.valueLabel.text = "\(formatter.string(from: NSNumber(value: currentValue)) ?? "") / \(formatter.string(from: NSNumber(value: maxValue)) ?? "")"
        setNeedsLayout()
    }
    
    private func updatePendingLabel() {
        pendingLabel.isHidden = pendingTitle.isEmpty
        pendingIconView.isHidden = pendingTitle.isEmpty
        pendingLabel.text = "\(formatter.string(from: NSNumber(value: pendingValue)) ?? "") \(pendingTitle)"
        setNeedsLayout()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
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
        addSubview(titleLabel)
        addSubview(progressView)
        addSubview(valueLabel)
        addSubview(iconView)
        addSubview(pendingIconView)
        addSubview(pendingLabel)
        addSubview(bigIconView)
        pendingIconView.isHidden = true
        pendingLabel.isHidden = true
        
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.locale = NSLocale.current
        formatter.maximumFractionDigits = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    func layout() {
        var offset = CGFloat(0)
        if let bigIcon = self.bigIcon {
            bigIconView.pin.start().top().bottom().width(bigIcon.size.width)
            offset = bigIcon.size.width + 6
        }
        titleLabel.pin.top().start(offset).end().sizeToFit(.width)
        progressView.pin.below(of: titleLabel).marginTop(4).start(offset).end().height(8)
        let lowerHeight = max(20, valueLabel.intrinsicContentSize.height)
        if icon != nil {
            iconView.pin.start(offset).below(of: progressView).width(20).height(lowerHeight).marginTop(4)
            valueLabel.pin.right(of: iconView).marginLeft(4)
        } else {
            valueLabel.pin.start(offset)
        }
        valueLabel.pin.below(of: progressView).height(lowerHeight).sizeToFit(.height).marginTop(4)
        pendingLabel.pin.below(of: progressView).end().height(lowerHeight).sizeToFit(.height).marginTop(4)
        pendingIconView.pin.left(of: pendingLabel).marginRight(4).below(of: progressView).width(20).height(lowerHeight).marginTop(4)
    }
    
    override var intrinsicContentSize: CGSize {
        layout()
        return CGSize(width: self.frame.size.width, height: valueLabel.frame.origin.y + valueLabel.frame.size.height)
    }
    
}
