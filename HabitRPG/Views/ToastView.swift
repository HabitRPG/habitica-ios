//
//  ToastManager.Swift
//  Habitica
//
//  Created by Collin Ruffenach on 11/6/14.
//  Copyright (c) 2014 Notion. All rights reserved.
//

import UIKit

class ToastView: UIView {
        
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var priceContainer: UIView!
    @IBOutlet weak var priceIconLabel: IconLabel!
    @IBOutlet weak var statsDiffStackView: UIStackView!
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var bottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var topSpacing: NSLayoutConstraint!
    @IBOutlet weak var leadingSpacing: NSLayoutConstraint!
    @IBOutlet weak var trailingSpacing: NSLayoutConstraint!
    
    @IBOutlet weak var leftImageWidth: NSLayoutConstraint!
    @IBOutlet weak var leftImageHeight: NSLayoutConstraint!
    @IBOutlet weak var priceContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var priceTrailingPadding: NSLayoutConstraint!
    @IBOutlet weak var priceLeadingPadding: NSLayoutConstraint!
    @IBOutlet weak var priceIconLabelWidth: NSLayoutConstraint!
    
    var options: ToastOptions = ToastOptions()
    
    public convenience init(title: String, subtitle: String, background: ToastColor) {
        self.init(frame: CGRect.zero)
        options.title = title
        options.subtitle = subtitle
        options.backgroundColor = background
        loadOptions()
    }
    
    public convenience init(title: String, background: ToastColor) {
        self.init(frame: CGRect.zero)
        options.title = title
        options.backgroundColor = background
        loadOptions()
    }
    
    public convenience init(title: String, subtitle: String, icon: UIImage, background: ToastColor) {
        self.init(frame: CGRect.zero)
        options.title = title
        options.subtitle = subtitle
        options.leftImage = icon
        options.backgroundColor = background
        loadOptions()
    }
    
    public convenience init(title: String, icon: UIImage, background: ToastColor) {
        self.init(frame: CGRect.zero)
        options.title = title
        options.backgroundColor = background
        options.leftImage = icon
        loadOptions()
    }
    
    public convenience init(title: String, rightIcon: UIImage, rightText: String, rightTextColor:UIColor, background: ToastColor) {
        self.init(frame: CGRect.zero)
        options.title = title
        options.backgroundColor = background
        options.rightIcon = rightIcon
        options.rightText = rightText
        options.rightTextColor = rightTextColor
        loadOptions()
    }
    
    public convenience init(healthDiff: Int, magicDiff: Int, expDiff: Int, goldDiff: Int, background: ToastColor) {
        self.init(frame: CGRect.zero)
        addStatsView(HabiticaIcons.imageOfHeartDarkBg, diff: healthDiff)
        addStatsView(HabiticaIcons.imageOfExperience, diff: expDiff)
        addStatsView(HabiticaIcons.imageOfMagic, diff: magicDiff)
        addStatsView(HabiticaIcons.imageOfGold, diff: goldDiff)
        options.backgroundColor = background
        loadOptions()
    }
    
    private func addStatsView(_ icon: UIImage, diff: Int) {
        if diff != 0 {
            let iconLabel = IconLabel()
            iconLabel.icon = icon
            iconLabel.text = diff > 0 ? "+\(diff)" : "\(diff)"
            iconLabel.setContentCompressionResistancePriority(1000, for: .horizontal)
            statsDiffStackView.addArrangedSubview(iconLabel)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureViews()
    }
    
    private func configureViews() {
        self.backgroundColor = .clear
        if let view = viewFromNibForClass() {
            translatesAutoresizingMaskIntoConstraints = false
            
            view.frame = bounds
            addSubview(view)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            
            backgroundView.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
            backgroundView.layer.borderWidth = 1
            
            self.isUserInteractionEnabled = false
            backgroundView.isUserInteractionEnabled = true
        }
    }

    func loadOptions() {
        self.backgroundView.backgroundColor = options.backgroundColor.getUIColor()
        self.backgroundView.layer.borderColor = options.backgroundColor.getUIColor().darker(by: 10)?.cgColor

        topSpacing.constant = 6
        bottomSpacing.constant = 6
        leadingSpacing.constant = 8
        trailingSpacing.constant = 8
        if let title = self.options.title {
            titleLabel.isHidden = false
            titleLabel.text = title
            titleLabel.sizeToFit()
            titleLabel.numberOfLines = -1
            titleLabel.font = UIFont.systemFont(ofSize: 13)
        } else {
            titleLabel.isHidden = true
            titleLabel.text = nil
        }
        
        if let subtitle = self.options.subtitle {
            subtitleLabel.isHidden = false
            subtitleLabel.text = subtitle
            subtitleLabel.sizeToFit()
            subtitleLabel.numberOfLines = -1
            self.titleLabel.font = UIFont.systemFont(ofSize: 16)
        } else {
            subtitleLabel.isHidden = true
            subtitleLabel.text = nil
        }
        
        if let leftImage = self.options.leftImage {
            leftImageView.isHidden = false
            leftImageView.image = leftImage
            leadingSpacing.constant = 4
            leftImageWidth.constant = 46
            leftImageHeight.priority = 999
        } else {
            leftImageView.isHidden = true
            leftImageWidth.constant = 0
            leftImageHeight.priority = 500
        }
        
        if let icon = options.rightIcon, let text = options.rightText, let textColor = options.rightTextColor {
            priceContainer.isHidden = false
            priceIconLabel.icon = icon
            priceIconLabel.text = text
            priceIconLabel.textColor = textColor
            trailingSpacing.constant = 0
            self.backgroundView.layer.borderColor = options.backgroundColor.getUIColor().cgColor
        } else {
            priceContainer.isHidden = true
            priceIconLabel.removeFromSuperview()
        }
        
        priceContainerWidth.constant = 0
        
        self.setNeedsLayout()
        setNeedsUpdateConstraints()
        updateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
}
